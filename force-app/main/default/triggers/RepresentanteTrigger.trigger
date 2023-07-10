trigger RepresentanteTrigger on Representante__c (after insert, after update) {
    Map<Id, Representante__c> mapOld = (Map<Id,Representante__c>) Trigger.oldMap;
    List<Preenche_CEP__e> ceps = new List<Preenche_CEP__e>();
    for(Representante__c representante : Trigger.New){
        Boolean add = true;
        if(mapOld != null){
            if(mapOld.get(representante.Id) != null){
                if(mapOld.get(representante.Id).CEP__c == representante.CEP__c){
                    add = false;
                }
            }
        }
        if(add && representante.CEP__c != null){
        	Preenche_CEP__e cep = new Preenche_CEP__e(Objeto__c = 'representante', Id_registro__c = representante.Id, CEP__c = representante.CEP__c);
            ceps.add(cep);
        }
    }
    System.debug(ceps);
    if(ceps.size() > 0)
    	 EventBus.publish(ceps);
}