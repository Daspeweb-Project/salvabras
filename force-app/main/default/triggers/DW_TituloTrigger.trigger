trigger DW_TituloTrigger on Titulo__c (after insert, after update, before insert, before update) {
    
     //Add  bypass
    DW_TituloService tituloSvr = new DW_TituloService(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
            System.debug('Trigger');

    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
      	tituloSvr.persisteAccTitulo();
	}

}