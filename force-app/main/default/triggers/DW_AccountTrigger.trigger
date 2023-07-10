trigger DW_AccountTrigger on Account (after insert, after update, before insert, before update) {
    if(TriggerByPass__c.getOrgDefaults().DW_AccountTrigger__c && !Test.isRunningTest()){
        return;
    }
    DW_AccountService accountSrv = new DW_AccountService(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
      	accountSrv.splitStreetAddress();
        accountSrv.checkDocumentFormat();
        accountSrv.checkPostalCodesFormat();
        accountSrv.checkPhoneFormat();
    }
}