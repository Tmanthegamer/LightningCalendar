@isTest
private class CreateAppointmentTest
{
	private static Lead testLead;

	private static Datetime DEFAULT_START_TIME = Datetime.now();
	private static Datetime DEFAULT_END_TIME = Datetime.now().addHours(1);
	private static Date DEFAULT_START_DATE = Date.today();
	private static Date DEFAULT_END_DATE = Date.today();
	private static String DEFAULT_SUBJECT = AppointmentService.Subject.APPOINTMENT;
	private static String DEFAULT_DISPLAY_AS = AppointmentService.Display_As.BUSY;
	private static String DEFAULT_TITLE = 'TITLE';

	static {
		testLead = TestUtils.createLead();
		insert testLead;
	}

	@isTest
	static void convertLeadTest_LeadService() {

		Test.startTest();
		LeadService.convertLeads(new List<Lead>{testLead});
		Test.stopTest();

		testLead = LeadService.queryLeadConvertedData(testLead.Id);
		System.assert(testLead != null, 'Our test lead should have been converted');
	}

	@isTest
	static void createAppointmentWithConversionTest_CreateAppointmentService() {
		testLead = LeadService.queryLeadData(testLead.Id);

		Test.startTest();
		Lead convertedLead = CreateAppointmentService.createAppointmentWithConversion(
			testLead, 
			DEFAULT_TITLE, 
			DEFAULT_START_TIME, 
			DEFAULT_END_TIME, 
			DEFAULT_START_DATE, 
			DEFAULT_END_DATE, 
			DEFAULT_SUBJECT, 
			DEFAULT_DISPLAY_AS
		);
		Test.stopTest();
		

		List<Appointment__c> appts = AppointmentService.queryAllApointments();
		System.assert(convertedLead != null, 'We should have a converted lead');
		System.assertEquals(1, appts.size(), 'We should have created on appointment');
	}

	@isTest
	static void getLeadData_CreateAppointmentController() {
		Id leadId = testLead.Id;
		
		Test.startTest();
		Lead queriedLead = CreateAppointmentController.getLead(leadId);
		Test.stopTest();
		
		System.assert(queriedLead != null, 'Our lead should not be null');
	}

	@isTest
	static void createAppointment_CreateAppointmentController() {
		Id leadId = testLead.Id;
		
		CreateAppointmentController.ApptWrapper appt = new CreateAppointmentController.ApptWrapper();
		
		appt.title = 'Test Appointment';
		appt.subject = DEFAULT_SUBJECT;
		appt.displayAs = DEFAULT_DISPLAY_AS;
		Datetime start = Datetime.newInstance(2018, 1, 20, 12, 30, 0);
		Datetime endTimes = Datetime.newInstance(2018, 1, 20, 13, 30, 0);
		appt.startTime = AppointmentService.convertDatetimeToJavascriptFormat(start);
		appt.endTime = AppointmentService.convertDatetimeToJavascriptFormat(endTimes);

		Test.startTest();
		String convertedLeadId = CreateAppointmentController.createAppointment(
			leadId,
			JSON.serialize(appt)
		);
		Test.stopTest();
		System.assert(String.isNotBlank(convertedLeadId), 'Our lead should not be null');
		
	}

	@isTest
	static void getInitData_ValidLead() {
		Id leadId = testLead.Id;
		insert TestUtils.createAppointments();

		Map<String, Object> data = CreateAppointmentController.getInitData(leadId);
		Lead testLead = (Lead) data.get('lead');
		List<Appointment__c> appts = (List<Appointment__c>) data.get('appointments');
		String eventDataJSON = (String) data.get('eventDataJSON');
		List<String> subjects = (List<String>) data.get('subjects');
		List<String> displayAs = (List<String>) data.get('displayAs');
		
		System.assert(testLead != null && testLead.Id == leadId);
		System.assert(String.isNotBlank(eventDataJSON));
		System.assert(subjects != null && subjects.isEmpty() == false);
		System.assert(displayAs != null && displayAs.isEmpty() == false);
		System.assert(appts != null && appts.isEmpty() == false, 'Did not have any appointments');
	}

}