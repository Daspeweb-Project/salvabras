/**
 * Created by hellenmartins on 28/03/2022.
 */

trigger OrdemCarregamentoOportunidadeTrigger on OrdensCarregamentoPedido__c (before insert,before update, before delete, after insert ) {

    if (Trigger.isInsert && Trigger.isAfter) {
        OrdemCarregamentoOportunidadeService ordemOppService = new OrdemCarregamentoOportunidadeService(Trigger.new, Trigger.old,Trigger.newMap,Trigger.oldMap);
        ordemOppService.incluirOrdemCarragamentoNaOportunidade();
        ordemOppService.criaProdutoOrdemCarregamento();
    }
   
   
}