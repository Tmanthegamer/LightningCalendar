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
		
		Test.startTest();
		Lead convertedLead = CreateAppointmentController.createAppointment(
			JSON.serialize(testLead), 
			DEFAULT_TITLE, 
			DEFAULT_START_TIME, 
			DEFAULT_END_TIME, 
			DEFAULT_START_DATE, 
			DEFAULT_END_DATE, 
			DEFAULT_SUBJECT, 
			DEFAULT_DISPLAY_AS
		);
		Test.stopTest();
		
		System.assert(convertedLead != null, 'Our lead should not be null');
		
		System.assert(
			String.isNotBlank(convertedLead.ConvertedOpportunityId), 
			'We need our returned lead to have an opportunity to navigate to'
		);
	}

}