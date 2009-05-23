public class sendInvites {
  public sendInvites(ApexPages.StandardSetController c) {
   		inviteList = new List<invite>();
    	string surveyId = ApexPages.currentPage().getParameters().get('vid');
    	system.assert( surveyid != null, 'missing Survey id : vid=');
    	survey = [ select id, name from Survey__c where id = :surveyid limit 1];
        setcontroller = c; 
        setcontroller.setPageSize(15);
        loadRecords();
         // fetch the templates that we may use , they are in a folder named Survey_Templates
   		surveyTemplates = [ select id,name from EmailTemplate where 
   		 Folder.DeveloperName = 'Survey_Templates' 
   		 AND IsActive = true ];
   		
   		if (surveyTemplates.size() > 0 ) {
   			templateid =surveyTemplates[0].id;
   		}     
   		
   	 }
      List<EmailTemplate> surveyTemplates = new List<EmailTemplate>();
	public List<SelectOption> getTemplateOptions() {
  	 	List<SelectOption> options = new List<SelectOption>();
  	 	for( EmailTemplate et : surveyTemplates) {
  	 		options.add( new SelectOption(et.id, et.name) );
  	 	}
  	 	return options;
   	}
   	String templateid = ''; 
   	
  public String getOptionsSelected() {
   	 	return templateid;
  	}
 
  	public void setOptionsSelected(String templateid) {
  	 	this.templateid = templateid;
  	}
      private void loadRecords() {      	// for the UI
      	inviteList.clear();       					// send up to 200 at a time, single page
      	for ( Invitation__c i : [select id,name,contact__r.name, Invite_Sent__c,
								      	 contact__r.email from invitation__c
								      	 where survey__c = :survey.id  
								      	 and completed__c != true 
								      	 and contact__r.email != null 
								      	 limit 200 ]) {
      		inviteList.add( new invite( i) );
      	}
      	
      }
      
      public PageReference massSend() { 
      	mailDispach md = new mailDispach();
      	// perform the send of all selected
      	Invitation__c[] sentInvites = new invitation__c[0];
      	for ( invite ii : inviteList) {
      		// send email
      		md.sendMail( new List<string>{ ii.inv.Contact__r.email } ,
      	 new list<string>()  , templateid , ii.inv.Contact__c, ii.inv.id );
      		// TODO 
      		
      		// mark it as sent
      		ii.inv.Invite_Sent__c = true;
      		sentInvites.add (ii.inv);
      	}
      	update sentInvites;  
      	msg = 'invites sent ';
        return new PageReference( '/'+ survey.id );
      }
    public string msg { get; set; } { msg = '';}
    private Boolean selall2 = false;
    public Boolean getSelAll2() { return selall2;  }
    public void SetSelAll2 ( boolean r ) { selall2 = r; }
    public String buttonLabel { get { return (selall2 == false ? 'Select All' : 'Select None' ); } }
  
    public PageReference doSelAll() {    	// put everything on the list	
    	for( invite ii : inviteList ) {
    	 	ii.sel = true;
    	}
    	return null;
    }
    
    //public EmailTemplate ee { get; set; } { ee = new EmailTemplate(); } 
    // build a select option list of templates in the survey folder, include that here
    // is the email logged with the contact?
    
  public class invite { 
    	public Invitation__c inv { get; set; }
    	public boolean sel { get; set; }
    	public invite( Invitation__c c ) { inv = c; sel = false; }
    }
     public Survey__c survey { get; set; }
     public List<invite> inviteList { get; set; }
      public ApexPages.StandardSetController setcontroller { get; private set;} 
   
     public static  testmethod void t2() { 
    	PageReference pageRef = Page.sendInvitations; 
    	Test.setCurrentPage(pageRef);
    	Survey__c ss = new Survey__c();
    	insert ss;
    	Contact c =  new Contact( email='foo@bar.com' ,lastname='bar');
    	insert c; 
    	Invitation__c ts = new Invitation__c(Survey__c = ss.id, Contact__c = c.id);
    	insert ts;
    	List<Invitation__c> tx = [ select id,name from Invitation__c where Survey__c = :ss.id ];
    	
    	pageRef.getParameters().put('vid',ss.id);
		sendInvites si = new sendInvites ( 
			new ApexPages.Standardsetcontroller( tx ) );
	
    	system.assert( si.getTemplateOptions() != null );
    	system.assert( si.buttonLabel != null );
    	system.assert( si.massSend() != null );
    	system.assert( si.getOptionsSelected() != '' );
    	si.setOptionsSelected( 'string' );
    	si.SetSelAll2( true );
    	
     }
}