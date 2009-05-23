trigger invite_code on Invitation__c (before insert) {
	for (Invitation__c i : Trigger.new) {
		DateTime now = System.now();         
		String formattednow = now.formatGmt('yyyy-MM-dd')+'T'+ now.formatGmt('HH:mm:ss')+'.'+now.formatGMT('SSS')+'Z';         
		String canonical = i.id + i.Name + formattednow;                        
		Blob bsig = Crypto.generateDigest('MD5', Blob.valueOf(canonical));         
		String token =  EncodingUtil.base64Encode(bsig);                 
		if(token.length() > 255) { token =  token.substring(0,254); }        
		i.Invite_Code__c = Encodingutil.urlEncode(token, 'UTF-8').replaceAll('%','_');	
	}
}