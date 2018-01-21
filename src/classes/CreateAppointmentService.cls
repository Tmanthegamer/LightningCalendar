public without sharing class CreateAppointmentService {
	
	public static Lead createAppointmentWithConversion(
		Lead l, 
		String title,
		Datetime startTime, 
		Datetime endTime, 
		Date startDate, 
		Date endDate, 
		String subject, 
		String displayAs) {

		LeadService.convertLeads( new List<Lead>{l} );
		l = Leadservice.queryLeadConvertedData(l.Id);

		Appointment__c appt = AppointmentService.createAppointment(l, title, startTime, endTime, startDate, endDate, subject, displayAs);
		insert appt;

		return l;
	}

	public static List<String> getPicklistValues(String objName, String fieldName) {
		List<String> picklistVals = new List<String>();
		Schema.SObjectType targetType = Schema.getGlobalDescribe().get( objName );
		Map<String, Schema.SObjectField> fieldMap = targetType.getDescribe().fields.getMap();
		List<Schema.PicklistEntry> pickListValues = fieldMap.get( fieldName ).getDescribe().getPickListValues();
		for (Schema.PicklistEntry a : pickListValues) { 
			picklistVals.add(a.getValue());
		}
	  	return picklistVals;
	}

}