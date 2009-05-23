public class SurveyController {
 
 public Invitation__c invitation {set; get;} 
 public List<Question__c> questions { get; private set;}
 public List<SurveyItem> surveyList { get ; 		set; }
 public List<SurveyItem> surveyListPage { get; set; } 
 public Map<Id,Response__c> responseMap = new Map<Id, Response__c>();
 
 public PageReference saveForLater() { 
 	List<Response__c> tosave = new List<Response__c>(); 
 	for (SurveyItem si : surveyList) {
 		tosave.add (si.response);
 	} 
 	upsert tosave;
 	return Page.surveyWizardSaved; 
 }
 
 public PageReference closeSurvey() {
 		delete [ select id from Invitation__c where completed__c = false 
 		 AND survey__c = :SurveyId ]; 	
 		return survey.cancel();
 }
 
 public PageReference resume() { 	return Page.surveyWizard;  }
 
 public PageReference saveAndClose() { 
 	saveQuestions(); 
	return survey.cancel();
 }
 
 public PageReference addQuestions() { 
 	questions.add( new Question__c( survey__c = SurveyId ) );
 	return null;
 }
 
 private void renumber() { 
 	Integer num = 1; 
 	List<Question__c> tmp = new List<Question__c>();
 	for ( Question__c q : questions) {
 		addQuestion(tmp,q);			
 	}
 	for ( Question__c q : tmp) {
 		q.Sort_Order__c = num++;
 	}
 	questions = tmp;
 }

 private void addQuestion(Question__c[] inp, Question__c newq) {
        Integer position = inp.size();
        for (Integer i = 0; i < inp.size(); i++) {
            if (newq.sort_order__c < inp[i].sort_order__c) {
                position = i;
                break;
            }
        }
        
        if (position == inp.size()) {
            inp.add(newq);
        } else {
            inp.add(position, newq);
        }
    }
 
 public PageReference saveQuestions() { 
 	renumber();
 	upsert questions; 
  	loadQuestions();
  	return null; 
  	} 
 public PageReference done() { 
 	saveForLater(); 
 	
 	// TODO see if all questions are answered
 	
 	// set completed flag
 	invitation.Completed__c = true;
 	update invitation;
 	System.debug( invitation );

 	return new PageReference( invitation.survey__r.completed_URL__c );
 }
 
 public ApexPages.StandardSetController setCon {set; get;}
 
 public Integer TotalPages { get { return setCon.getResultSize() / setCon.getPageSize(); } }
 private void loadQuestions() { 
 	questions = [ select id, name, type__c,question_description__c,Sort_Order__c from Question__c 
				where Survey__c = :SurveyId order by sort_order__c ];
 }
 
 public string SurveyId {get; set;}
 public Apexpages.Standardcontroller survey {get; private set;}
 public SurveyController( Apexpages.Standardcontroller s) { 
 	survey = s;
 	SurveyId = s.getRecord().id;
 	loadQuestions();
 } 
 public SurveyController() { 
	String eid = System.currentPageReference().getParameters().get('inv');
    if ( eid == null ) {    	return; } 
    system.debug( eid);

	eid = Encodingutil.urlencode(eid, 'UTF-8').replaceAll('%','_');
	
 	system.debug( eid);
 
 	try { 
	invitation = [select id, name, invite_code__c ,Survey__r.Name,
	    Contact__r.Name , Survey__r.id, Survey__r.Description__c, Survey__r.completed_URL__c,Survey_Link__c,
	   	Survey__r.Questions_per_page__c from Invitation__c 
	   	where invite_code__c = :eid 
	   	and Completed__c != true 
	   	limit 1];
		
 	
 	
	// store the existing responses by question id
	
		for ( Response__c r: [select r.SystemModstamp, r.Text_Area__c, r.Response__c, r.Response_Date__c, r.Response_Number__c, r.Response_Bool__c, r.Question__c, r.Name,  r.Invitation__c, r.Id  From Response__c r 
			where r.invitation__c = :invitation.id ]) {
			responseMap.put(r.Question__c,r);		
		}
	
	} catch( System.Queryexception q) { 
		// invalid or completed survey
		
		return;
	} 
	//system.debug( responseMap );
		
	questions = [ select id, name, type__c,question_description__c,Sort_Order__c from Question__c 
			where Survey__c = :invitation.Survey__c ];
    setCon = new ApexPages.StandardSetController(Database.getQueryLocator(
 		                [select id, name, type__c,question_description__c,Sort_Order__c from Question__c 
			where Survey__c = :invitation.Survey__c order by sort_order__c]
			));

	setCon.setPageSize(1000);
	setcon.setPageNumber(1);
	setcon.first(); 		
		
	surveyList = new List<SurveyItem>();
	for (Question__c q: (List<Question__c>)setCon.getRecords() ) {  // list of all 
		Response__c re = responseMap.get(q.id);
 		if ( re == null ) {
 			re = new Response__c( invitation__c = invitation.id, question__c = q.id  );  
 			responseMap.put(q.id, re);
 		}
		surveyList.add( new SurveyItem( q, invitation,  re ));
	}

	setCon.setPageSize( invitation.Survey__r.Questions_per_page__c.intValue()	 );
	setcon.setPageNumber(1);
	setcon.first(); 		
 	loadSurveyListPage(); // load just the records to show on current page into a list
 		
 }
 
 public PageReference next() { // save current page, load a new page
 	saveForLater(); // ignore return
 	setCon.next(); 
 	loadSurveyListPage();
 	return null;
 }
 
 public PageReference previous() { 
 	saveForLater(); // ignore return
 	setCon.previous(); 
 	loadSurveyListPage();
 	return null; }
 
 void loadSurveyListPage() {
 	surveyListPage = new List<SurveyItem>();
 	for (Question__c q: (list<Question__c>)setCon.getRecords() ) {  
 		surveyListPage.add( new SurveyItem( q, invitation, responseMap.get(q.id)) );
 	}
 }
 
 
 public class SurveyItem { 
 	public Question__c question { set; get; }
 	public Response__c response  { set; get; }
 	public Invitation__c invite { set; get; }
 	public SurveyItem( Question__c q, Invitation__c i,Response__c r ) { 
 		question = q; 
 		system.assert( q != null ); 
 		invite = i;
 		system.assert( i != null ); 
 		response = r; 
 		system.assert( r != null ); 
 		system.debug( this); 
 	}
 }  
 
 
 public List<SelectOption> getRadioItems() {
          List<SelectOption> options = new List<SelectOption>(); 
          options.add(new SelectOption('1.0','Strongly Agree'));
          options.add(new SelectOption('2.0','Agree')); 
          options.add(new SelectOption('3.0','Netural')); 
          options.add(new SelectOption('4.0','Disagree')); 
          options.add(new SelectOption('5.0','Strongly Disagree')); 
          return options; }
                   
 
 public static  testmethod void t1() { 

    Survey__c ts = new Survey__c(completed_URL__c='http://www.salesforce.com');
    insert ts;
    system.debug(ts);
    Question__c tq = new Question__c(question_description__c='why ?',type__c ='Radio',survey__c=ts.id ); 
    insert tq;
    
    Invitation__c ti = new Invitation__c( survey__c=ts.id , completed__c = false );
    insert ti;
    ti = [select id,survey__c,invite_code__c from Invitation__c where id = : ti.id limit 1];
    system.debug( ti);
    system.assert( ti.Invite_Code__c != null , ' expected a valid code, must include trigger in deployment');

 	PageReference pageRef = new Pagereference('/apex/surveyWizard?inv='+ti.Invite_Code__c);  //Page.surveyWizard;
    Test.setCurrentPage(pageRef);

    System.assert( System.currentPageReference().getParameters().get('inv') == ti.Invite_code__c , ' could not read INV parameter'); 
 	
 	surveyController controller = new surveyController();
 	    
 	system.assert( controller.invitation != null ,' expected valid invitation');
    controller.getRadioItems();
 	controller.next();
 	controller.previous();
 	
 	controller.saveForLater();
 	controller.done();
 	
 } 
 public static  testmethod void t2() { 
 	PageReference pageRef = Page.surveyQuestionEdit;
    Test.setCurrentPage(pageRef);
    Survey__c ts = new Survey__c();
    insert ts;
    Question__c tq = new Question__c(question_description__c='why ?',type__c ='Radio',survey__c=ts.id ); 
    insert tq;
    
    system.debug(ts);
    surveyController controller = new surveyController(new 
    	Apexpages.Standardcontroller(ts) );
    controller.addQuestions();	
    controller.saveAndClose();
    controller.saveQuestions();
 	controller.resume();   
 }
}