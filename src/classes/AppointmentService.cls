public without sharing class AppointmentService {

	public static List<Appointment__c> queryAllApointments() {
		return [
			SELECT 
				Name,
				Start_Time__c,
				End_Time__c,
				Start_Date__c,
				End_Date__c,
				Subject__c,
				Display_As__c,
				Duration__c,
				Location__c,
				Email__c,
				Phone__c,
				WhatId__c,
				WhoId__c,
				OwnerId
			FROM Appointment__c
		];
	}

	public static Appointment__c createAppointment(
		Lead l, 
		String title,
		Datetime startTime, 
		Datetime endTime, 
		Date startDate, 
		Date endDate, 
		String subject, 
		String displayAs) {
		
		String location = LeadService.buildLocationFromLead(l);
		Decimal duration = determineMinutesOfTimeDifference(endTime, startTime);
		
		return new Appointment__c(
			Name = title,
			Start_Time__c = startTime,
			End_Time__c = endTime,
			Start_Date__c = startDate,
			End_Date__c = enddate,
			Subject__c = subject,
			Display_As__c = displayAs,
			Duration__c = duration,
			Location__c = location,
			Email__c = l.Email,
			Phone__c = l.Phone,
			WhatId__c = l.ConvertedOpportunityId,
			WhoId__c = l.ConvertedContactId,
			OwnerId = l.OwnerId
		);

	}

	public static Decimal determineMinutesOfTimeDifference(Datetime large, Datetime small) {
		Long largeLong = large.getTime();
		Long smallLong = small.getTime();
		Long milliseconds = largeLong - smallLong;
		Long seconds = milliseconds / 1000;
		Long minutes = seconds / 60;

		return Decimal.valueOf(minutes);
	}

	public static String convertDatetimeToJavascriptFormat(DateTime myDateTime) {
		return myDateTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss');
	}

	public static final Display_As Display_As = new Display_As();
	public class Display_As {
		public String BUSY = 'Busy';
		public String LUNCH = 'Lunch';
		public String NOT_AVAILABLE = 'Not Available';
		public String OCCUPIED = 'Occupied';
		public String TENTATIVE = 'Tentative';
	}

	public static final Subject Subject = new Subject();
	public class Subject {
		public String APPOINTMENT = 'Appointment'; 
		public String ESTIMATION = 'Estimation'; 
		public String INQUIRY = 'Inquiry'; 
		public String OTHER = 'Other'; 
	}
}