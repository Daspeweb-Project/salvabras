trigger DW_LeadTrigger on Lead (after insert, after update, before insert, before update) {
    
    if(TriggerByPass__c.getOrgDefaults().DW_LeadTrigger__c && !Test.isRunningTest()){
        return;
    }
    
    List<Lead> leadNewList = Trigger.new;
    List<Lead> leadOldList = Trigger.old;
    Map<Id, Lead> leadNewMap = Trigger.newMap;
    Map<Id, Lead> leadOldMap = Trigger.oldMap;
    
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        for (Lead lead : leadNewList){
            Lead leadOld = (leadOldMap != null && leadOldMap.containsKey(lead.Id)) ? this.leadOldMap.get(lead.Id) : new Lead();
            if (lead.Street != null && lead.Street != '' && (lead.Street != leadOld.Street || leadOld.Id == null)) {
                List<String> addressLineList = lead.Street.split(',');
                if (addressLineList.size() < 3 || addressLineList.size() > 4) {
                    lead.Street.addError('Insira o endereço no seguinte padrão: Rua de Tal, 999, loja 2, Bairro de Tal');
                    continue;
                }
                String street = addressLineList.get(0);
                String numbr = '';
                String complement = '';
                String neighbouerhood = '';
                System.debug('Passsou');
                
                if (addressLineList.size() == 4) {
                    numbr = addressLineList.get(1);
                    complement = addressLineList.get(2);
                    neighbouerhood = addressLineList.get(3);
                }else{
                    numbr = addressLineList.get(1);
                    complement = '';
                    neighbouerhood = addressLineList.get(2);
                }
                
                if(street.length()>80){
                    lead.Street.addError('Rua maior que 80 caracteres');
                }
                if(numbr.length()>10){
                    lead.Street.addError('Número maior que 10 caracteres');
                }
                if(complement!= ''  && complement.length()>50){
                    lead.Street.addError('Complemento maior que 50 caracteres');
                }
                if(neighbouerhood.length()>40){
                    lead.Street.addError('Bairro maior que 40 caracteres');
                }
            }
        }
    }
}