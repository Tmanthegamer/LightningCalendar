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
}