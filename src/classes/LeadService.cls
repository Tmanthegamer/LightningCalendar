public without sharing class LeadService {

	public static String buildLocationFromLead(Lead l) {
		String location = '';
		if(String.isNotBlank(l.Street)) location += 'Street: ' + l.Street +'\n';
		if(String.isNotBlank(l.State)) location += 'State: ' + l.State +'\n';
		if(String.isNotBlank(l.City)) location += 'City: ' + l.City +'\n';
		if(String.isNotBlank(l.Country)) location += 'Country: ' + l.Country +'\n';
		if(String.isNotBlank(l.PostalCode)) location += 'PostalCode: ' + l.PostalCode +'\n';  
		location = location.removeEnd('\n');

		return location;
	}

	public static void convertLeads(List<Lead> leads) {

		List<Database.LeadConvert> convertList = new List<Database.LeadConvert>();
		LeadStatus convertStatus = [SELECT Id, MasterLabel FROM LeadStatus WHERE IsConverted=true LIMIT 1];
		System.debug(leads);
		for( Lead l : leads ) {
			Database.LeadConvert lc = new Database.LeadConvert();
			lc.setLeadId(l.id);
			lc.setConvertedStatus(convertStatus.MasterLabel);

			convertList.add(lc);   
		}
		
		List<Database.LeadConvertResult> converts = Database.convertLead(convertList);
		for( Database.LeadConvertResult c : converts ) {
			System.assert(c.isSuccess());
		}

	}

	public static Lead queryLeadData(String leadId) {
		List<Lead> leads = queryLeadData(new Set<String>{leadId});System.debug(leadId); System.debug(leads);
		return leads.isEmpty() ? null : leads[0];
	}

	public static List<Lead> queryLeadData(Set<String> leadIds) {
		return [
			SELECT
				Street,
				State,
				City,
				Country,
				PostalCode,
				Email,
				Phone,
				Status,
				OwnerId,
				Owner.FirstName,
				Owner.LastName,
				Owner.Email,
				Owner.Phone
			FROM Lead
			WHERE Id IN: leadIds
			AND IsConverted = false
		];
	}

	public static Lead queryLeadConvertedData(Id leadId) {
		List<Lead> leads = queryLeadConvertedData(new Set<Id>{leadId});
		return leads.isEmpty() ? null : leads[0];
	}
	public static List<Lead> queryLeadConvertedData(Set<Id> leadIds) {
		return [
			SELECT 
				Street,
				State,
				City,
				Country,
				PostalCode,
				Email,
				Phone,
				ConvertedOpportunityId,
				ConvertedContactId,
				Status,
				OwnerId
			FROM 
				Lead
			WHERE
				Id IN: leadIds
				AND IsConverted = true
		];
		/*
ConvertedAccountId
ConvertedContactId
ConvertedDate
ConvertedOpportunityId
IsConverted
Status
		*/
	}
}