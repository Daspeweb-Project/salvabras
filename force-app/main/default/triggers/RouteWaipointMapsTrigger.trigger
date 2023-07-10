trigger RouteWaipointMapsTrigger on maps__Waypoint__c (after insert,after update) {
	RouteService routeSrv = new RouteService(Trigger.new, Trigger.old, Trigger.newMap, Trigger.oldMap);
      if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
      	routeSrv.generateOC();
    }
}