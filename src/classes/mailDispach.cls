public class mailDispach {
	public void sendMail(
	String[] toAddresses,String[] ccAddresses,ID templId, ID contact,
	    ID whatID ){
		// Create a new single email message object
		// that will send out a single email to the addresses in the To, CC & BCC list.
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		// Assign the addresses for the To and CC lists to the mail object.
		mail.setToAddresses(toAddresses);
	//	mail.setCcAddresses(ccAddresses);
		// Specify the address used when the recipients reply to the email.
		//mail.setReplyTo('support@acme.com'); // email to apex code
		// Specify the name used as the display name.
		//mail.setSenderDisplayName('Salesforce Support');
		// Specify the subject line for your email address.
		//mail.setSubject('New Case Created : ');
		// Set to True if you want to BCC yourself on the email.
		mail.setTargetObjectId( contact ); 
		mail.setWhatId( whatID );
		mail.setBccSender( false );
		// Optionally append the salesforce.com email signature to the email.
		// The email address of the user executing the Apex Code will be used.
		mail.setUseSignature(false);
		// Specify the text content of the email.
		//mail.setPlainTextBody('Your Case: has been created');
		mail.setTemplateId( templId );
		// Specify the html version of the content as well.
		//mail.setHtmlBody('Your case:<b> 12212 </b>has been created<p>View case <a href=https://prerelna1.pre.salesforce.com/'+case.Id+'>click here</a>');
		// Send the email you have created.
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
	}
}