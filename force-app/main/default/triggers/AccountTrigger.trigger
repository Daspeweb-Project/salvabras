trigger AccountTrigger on Account (after insert, after update) {
    Map<Id, Account> mapOld = (Map<Id,Account>) Trigger.oldMap;
    List<Preenche_CEP__e> ceps = new List<Preenche_CEP__e>();
    for(Account acc : Trigger.New){
        Boolean add = true;
        if(mapOld != null){
            if(mapOld.get(acc.Id) != null){
                if(mapOld.get(acc.Id).CEP__c == acc.CEP__c){
                    add = false;
                }
            }
        }
        if(add && acc.CEP__c != null){
        	Preenche_CEP__e cep = new Preenche_CEP__e(Objeto__c = 'conta', Id_registro__c = acc.Id, CEP__c = acc.CEP__c);
            ceps.add(cep);
        }
    }
    System.debug(ceps);
    if(ceps.size() > 0)
    	 EventBus.publish(ceps);
}