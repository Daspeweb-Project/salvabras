trigger DW_ContactTrigger on Contact (after insert, after update, before insert, before update) {
    if(TriggerByPass__c.getOrgDefaults().DW_ContactTrigger__c && !Test.isRunningTest()){
        return;
    }
    DW_ContactService contactService = new DW_ContactService(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
    if(Trigger.isBefore && (Trigger.isUpdate || Trigger.isInsert)){
        contactService.checkPhoneFormat();
    }
}