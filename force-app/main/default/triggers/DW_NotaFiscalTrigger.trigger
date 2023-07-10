trigger DW_NotaFiscalTrigger on NotaFiscal__c (after insert, after update, before insert, before update) {
    
 //Add  bypass
    DW_NotaFiscalService notaSvr = new DW_NotaFiscalService(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
            System.debug('Trigger');

    if(Trigger.isBefore && (Trigger.isInsert)){
      	notaSvr.persisteAccNF();
    }
}