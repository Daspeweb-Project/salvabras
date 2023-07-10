trigger TransportadoraTrigger on Transportadora__c (after insert, after update) {
    Map<Id, Transportadora__c> mapOld = (Map<Id,Transportadora__c>) Trigger.oldMap;
    List<Preenche_CEP__e> ceps = new List<Preenche_CEP__e>();
    for(Transportadora__c transportadora : Trigger.New){
        Boolean add = true;
        if(mapOld != null){
            if(mapOld.get(transportadora.Id) != null){
                if(mapOld.get(transportadora.Id).CEP__c == transportadora.CEP__c){
                    add = false;
                }
            }
        }
        if(add && transportadora.CEP__c != null){
        	Preenche_CEP__e cep = new Preenche_CEP__e(Objeto__c = 'transportadora', Id_registro__c = transportadora.Id, CEP__c = transportadora.CEP__c);
            ceps.add(cep);
        }
    }
    System.debug(ceps);
    if(ceps.size() > 0)
    	 EventBus.publish(ceps);
}