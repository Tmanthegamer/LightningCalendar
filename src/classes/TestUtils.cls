@isTest
public class TestUtils
{

	public static Lead createLead() {
		Lead newLead = new Lead();
        
        newLead.LastName = 'Lee';
        newLead.FirstName = 'James';
        newLead.Company = 'Test Company';

        return newLead;
	}

	public static List<Appointment__c> createAppointments() {
		List<DateTime> datesToUse = new List<DateTime>();
		for(Integer i = 1; i < 6; i++) {
			datesToUse.add(Datetime.newInstance(2018, 1, 12, i, 0, 0));
		}

		List<Appointment__c> testAppts = new List<Appointment__c>();
		for(Datetime startTime : datesToUse) {
			Datetime endTime = startTime.addHours(1);
			testAppts.add(new Appointment__c(
				Subject__c = 'Appointment',
				Display_As__c = 'Busy',
				Start_Time__c = startTime,
				End_Time__c = endTime
			));
		}
		return testAppts;
	}
}