public class responseCon {
	public responseCon(ApexPages.StandardSetController c) {
		String surveyId = ApexPages.currentPage().getParameters().get('vid');
    	System.assert( surveyid != null, 'missing Survey id : vid=');
    	survey = [ select id, name from Survey__c where id = :surveyid limit 1];
 
		surveyResponses = [ Select r.Text_Area__c, r.SystemModstamp, 
			r.Summary__c, r.Response__c, r.Response_Number__c, 
			r.Response_Date__c, r.Response_Bool__c, r.Question__c, 
			r.Question__r.sort_order__c,
			r.Question_Type__c, r.Question_Text__c, r.Name, 
			r.LastModifiedDate, r.LastModifiedById, r.IsDeleted, 
			r.Invitation__c, r.Id,r.Invitation__r.Survey__c, 
			r.Invitation__r.Contact__r.LastName, 
			r.Invitation__r.Contact__r.FirstName, 
			 r.CreatedDate  From Response__c r 
			 where r.Invitation__r.Survey__c = :survey.id 
			 order by r.Question__r.sort_order__c limit 200 ]; 
	}
   	public Survey__c survey { get; set; }
   	public List<Response__c> surveyResponses { get; private set; }
}