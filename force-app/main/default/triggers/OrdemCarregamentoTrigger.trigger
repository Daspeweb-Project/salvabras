/**
 * Created by helle on 06/07/2021.
 */

trigger OrdemCarregamentoTrigger on OrdemCarregamento__c (before insert, before update, after update) {
    OrdemCarregamentoService ordemCarregamentoService = new OrdemCarregamentoService(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
  
    if(Trigger.isAfter && Trigger.isUpdate){
        ordemCarregamentoService.checkIfHasToSendAttach();
    }
}