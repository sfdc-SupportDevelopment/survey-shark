public class surveyInvite {
	
    public surveyInvite(ApexPages.StandardSetController c) {
   		cl = new List<contactList>();
    	string surveyId = ApexPages.currentPage().getParameters().get('vid');
    	system.assert( surveyid != null, 'missing Survey id : vid=');
    	survey = [ select id, name from Survey__c where id = :surveyid limit 1];
        setcontroller = c; 
        setcontroller.setPageSize(15);
        loadRecords();
        
 
    }
  

    private void trackSelected() {  // update cl_map from current page checkboxs 
    	for ( ContactLIst cc : cl ) {
        	if ( cc.sel ) {
        		cl_map.put(cc.con.id,true);
        	} else { 
        		if ( cl_map.containsKey(cc.con.id)) 
        			cl_map.remove(cc.con.id);
        	}
        }
    }
    private void loadRecords() {
		trackSelected();
        
    	cl.clear();
    	for ( Contact cc : (List<Contact>)setcontroller.getRecords() ) {
        	ContactList tmp =  new contactList(cc );
        	
        	// if they are in the map, set the selected value here
        	if ( cl_map.containsKey(tmp.con.id)) {
        		tmp.sel = true;
        	}
        	cl.add( tmp );
        }
    }
    public PageReference massInvite() { 
    	List<Invitation__c> il = new List<Invitation__c>();
    	trackSelected();
    	for ( id cid : cl_map.keySet() ) {
    		il.add( new Invitation__c( contact__c = cid, survey__c = survey.id ) );
    	}
    	insert il;
    	system.debug( il);
    	return new PageReference( '/'+ survey.id );
    }
    public PageReference previousPage() { 
    	setcontroller.previous();
    	loadRecords();	
    	return null;
    } 
    public PageReference nextPage() {

	// somehow save the ones that were seleted and the others that were not
	// so that we can restore them when we land on this page again?    	
		setcontroller.next();
    	loadRecords();
    	return null;
    }
    public PageReference changedFilter() { 
        system.debug( ' changedFilter ' + setcontroller.getfilterId());
        PageReference p = new PageReference( 
	         '/apex/inviteContacts' + 
	         '?fcf=' + setcontroller.getfilterId() + '&vid='+survey.id);
        p.setRedirect(true);
        return p;
    }
    
    /* select all or none */
    private Boolean selall2 = false;
    public Boolean getSelAll2() { return selall2;  }
    public void SetSelAll2 ( boolean r ) { selall2 = r; }
    public String buttonLabel { get { return (selall2 == false ? 'Select All' : 'Select None' ); } }
    public PageReference doSelAll() {    	// put everything on the list	
    	selAll2 =  ! selAll2;
    	system.debug( 'sel all is ' + selAll2);
    	setSelectAll(selAll2);  
    	loadRecords();
    	return null;
    }
    
    
    public class contactList { 
    	public Contact con { get; set; }
    	public boolean sel { get; set; }
    	public contactList( Contact c ) { con = c; sel = false; }
    }
    public ApexPages.StandardSetController setcontroller { get; private set;} 
    
    public List<ContactList> cl { get; set;} 
    
    // selected items map
    public Map<id,Boolean> cl_map = new Map<Id,Boolean>();
    
    
    private void setSelectAll( boolean sel ) {
    	// put all on the selected map, or remove all...
    	integer pagenum = setcontroller.getPageNumber();
    	if ( sel == false ) { 
    		cl_map.clear(); 
    		for ( ContactLIst cc : cl ) { cc.sel = false; }
    	}
    	else {
    		for ( ContactLIst cc : cl ) { cc.sel = true; }
    		setcontroller.first();
    		do {
    		    for ( Contact cc : (List<Contact>)setcontroller.getRecords() ) {
    		    	cl_map.put( cc.id, true);
    			}
    			if ( setcontroller.getHasNext() ) setcontroller.next();
    		}	while ( setcontroller.getHasNext() == true );
    	} 
    
    	setcontroller.setPageNumber(pagenum);
    }
    
    public Integer pageSize { get { return setcontroller.getresultSize() / setcontroller.getPageSize() ; }}
    public Survey__c survey { get; set; }
    
    /* 
     * need more asserts in here !
     */
    public static  testmethod void t2() { 
    	PageReference pageRef = Page.inviteContacts;
    	Test.setCurrentPage(pageRef);
    	Survey__c ts = new Survey__c();
    	insert ts;
    	List<Contact> cl = [ select id from contact limit 2];
		pageRef.getParameters().put('vid',ts.id);
		surveyInvite si = new SurveyInvite ( new ApexPages.Standardsetcontroller(cl) );
		si.changedFilter();
		si.doSelAll();
		si.nextPage();
		si.previousPage();
		si.massInvite();
		si.getSelAll2();
		si.SetSelAll2(true);
		integer p = si.pageSize;
    }
    
     public static  testmethod void t3() { 
    	/*PageReference pageRef = Page.surveyWizard;
    	Test.setCurrentPage(pageRef);
    	
    	User u = [ select id,usertype from user where id = '005400000012jsa' limit 1];
    	system.assert  ( u != null );
    	
    	System.runAs( u ) {
	    	system.debug( Site.getCurrentSiteUrl() );
	    	system.debug( Site.getOriginalUrl() );
	    	system.debug( Site.isPasswordExpired() );
	    	system.debug( Site.getCustomWebAddress( ) );
	    	system.debug( Site.getDomain() );
	    	system.debug( Site.getName() );
	    	system.debug( Site.getPrefix() );
	    	system.debug( Site.getTemplate() );
	    	system.debug( Site.isPasswordExpired() );
	    	system.debug( Site.isRegistrationEnabled() );    
    	}	*/
    	
     }
}