trigger OpportunityTrigger on Opportunity (after insert, after update) {
    MetaUtil.separar_opportunidades((List<Opportunity>) Trigger.new, (Map<id,Opportunity>) Trigger.oldMap);
}