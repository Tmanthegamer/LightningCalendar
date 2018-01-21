public without sharing class CreateAppointmentController {

	private static String getAppointmentData(){
		List<Map<String, Object>> events = new List<Map<String, Object>>();
		List<Appointment__c> appts = AppointmentService.queryAllApointments();
		for(Appointment__c a : appts) {
			System.debug(a);
			events.add( createCalEvent(a) );
		}
		return JSON.serialize(events);
	}

	private static Map<String, Object> createCalEvent(Appointment__c a) {
		Map<String, Object> obj = new Map<String, Object>();
		obj.put( 'title', a.Display_As__c );
		obj.put( 'start', a.Start_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') );
		obj.put( 'end', a.End_Time__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss') );
		return obj;
	}

	@AuraEnabled
	public static Map<String, Object> getInitData(String recordId) {
		Map<String, Object> data = new Map<String, Object>();

		Lead l = getLead(recordId);
		String error = null;
		if( l == null ) {
			l = Leadservice.queryLeadConvertedData(recordId);
			if(l != null) error = 'Lead was already converted, cannot make appointment';
		}
		data.put('lead', l);
		data.put('error', error);
		data.put('appointments', AppointmentService.queryAllApointments());
		data.put('eventDataJSON', getAppointmentData());
		data.put('subjects', CreateAppointmentService.getPicklistValues('Appointment__c', 'Subject__c'));
		data.put('displayAs', CreateAppointmentService.getPicklistValues('Appointment__c', 'Display_As__c'));
	
		return data;
	}

	@AuraEnabled
	public static Lead getLead(String recordId) {
		return Leadservice.queryLeadData(recordId);
	}

	@AuraEnabled
	public static String createAppointment(String recordId, String apptJSON) {

		System.debug(apptJSON);
		System.debug(recordId);
		ApptWrapper appt = (ApptWrapper) JSON.deserialize(apptJSON, ApptWrapper.class);
		
		System.debug(appt);
		String title = appt.title;
		String subject = appt.subject;
		String displayAs = appt.displayAs;
		
		DateTime startTime = Datetime.ValueofGmt(appt.startTime.replace('T', ' '));
		DateTime endTime = Datetime.ValueofGmt(appt.endTime.replace('T', ' '));
		
		System.debug(startTime);
		System.debug(endTime);
		Date startDate = Date.newinstance(startTime.year(), startTime.month(), startTime.day());
		Date endDate = Date.newinstance(endTime.year(), endTime.month(), endTime.day());

		Lead curLead = LeadService.queryLeadData(recordId);
		Lead conLead = CreateAppointmentService.createAppointmentWithConversion(curLead, title, startTime, endTime, startDate, endDate, subject, displayAs);
		System.debug(String.valueOf(conLead));
		return String.isNotBlank(conLead.ConvertedOpportunityId) ? conLead.ConvertedOpportunityId : null; 
	}
	
	@TestVisible
	private class ApptWrapper {
		public String start;
		public String startTime;
		public String endTime;
		public String title;
		public String subject;
		public String displayAs;
	}

}