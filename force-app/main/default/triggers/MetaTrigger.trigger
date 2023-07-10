trigger MetaTrigger on Meta__c (after insert, after update, before insert, before update) {
    if(Trigger.isAfter){
        MetaUtil.separar_metas((List<Meta__c>) Trigger.new, (Map<id,Meta__c>) Trigger.oldMap);
    }else{
        MetaUtil.atualizaNome((List<Meta__c>) Trigger.new);
    }
}