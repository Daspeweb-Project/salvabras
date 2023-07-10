global class DW_PHC_CycleAnalysisBatch implements Database.Batchable<sObject>,Schedulable{
    
    public static void runInSyncMode(Id accountId){
        DW_PHC_CycleAnalysisBatch batch = new DW_PHC_CycleAnalysisBatch();
        batch.execute(null, [SELECT Id, CreatedDate , Name, PHCCicloFinalModa1__c, PHCCicloFinalModa2__c FROM Account WHERE Id = :accountId]);
    }
    
    public static void scheduleThisClass(String cron){
        System.schedule('DW_PHC_CycleAnalysisBatch', cron == null ? '0 28 * * * ?' : cron, new DW_PHC_CycleAnalysisBatch());
    }
    
    public Iterable<SObject> start(Database.BatchableContext BC){
        return [SELECT Id, PHCCicloFinalModa1__c, PHCCicloFinalModa2__c, Name FROM Account];
    }
    
    global void execute(SchedulableContext ctx) {        
        if(!Test.isRunningTest()){
            Database.executeBatch(new DW_PHC_CycleAnalysisBatch(), 20);
        }

    }     
    
    public void execute(Database.BatchableContext BC, List<Account> accountList){
        Set<Id> accountIds = new Set<Id>();
        Map<Id, Account> accountMap = new Map<Id, Account>();
        List<Account> toUpdate = new List<Account>();
        for(Account acc : accountList){
            accountIds.add(acc.Id);
            accountMap.put(acc.Id, acc);
        }
        
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(accountIds, accountList, 'Erro ao tentar calcular ciclo de compras ideal. ');
        
        List<Order> orders = [
            SELECT Id, AccountId, EffectiveDate
            FROM Order 
            WHERE AccountId IN :accountIds 
            AND Status IN ('Ativado') 
            AND Type IN ('N')
            ORDER BY AccountId, EffectiveDate DESC
        ];
        
        Map<Id, List<Order>> mapAccountOrders = new Map<Id,List<Order>>();
        
        for(Order order : orders){
            if(mapAccountOrders.get(order.AccountId) == null){
                mapAccountOrders.put(order.AccountId, new List<Order>());
            }
            mapAccountOrders.get(order.AccountId).add(order);
        }
        
        for(Id accountId : accountIds){
            Account acc = accountMap.get(accountId);
            List<Order> ordersAux = mapAccountOrders.containsKey(accountId) 
                ? mapAccountOrders.get(accountId)
                : new List<Order>();
            
            List<OrderWrapper> orderWrapperList = new List<DW_PHC_CycleAnalysisBatch.OrderWrapper>();
            
            List<Integer> cycleSpacesV1 = new List<Integer>();
            List<Integer> cycleSpacesV2 = new List<Integer>();
            for (Order order : ordersAux){
                orderWrapperList.add(new OrderWrapper(order));
            }
            
            orderWrapperList.sort();
            
            List<OrderWrapper> orderWrapperToKeepList = new List<DW_PHC_CycleAnalysisBatch.OrderWrapper>();

            for (Integer index = 0; index < orderWrapperList.size(); index++){
                if (orderWrapperList.size() > index + 1) {
                    OrderWrapper orderWrapper = orderWrapperList.get(index);
                    OrderWrapper orderWrapper2 = orderWrapperList.get(index+1);
                    Integer diff = Integer.valueOf(Math.floor(orderWrapper.order.EffectiveDate.daysBetween(orderWrapper2.order.EffectiveDate)));
                    System.debug(LoggingLevel.INFO, '@@@ analisando diferença para excluir da lista: diff' + diff);
                    System.debug(LoggingLevel.INFO, '@@@ orderWrapper.order.EffectiveDate' + orderWrapper.order.EffectiveDate);
                    System.debug(LoggingLevel.INFO, '@@@ orderWrapper2.order.EffectiveDate' + orderWrapper2.order.EffectiveDate);
                    if(diff >= 4){
                        orderWrapperToKeepList.add(orderWrapper);
                    }
                }
            }
            
            orderWrapperToKeepList.sort();
            
            for (Integer index = 0; index < orderWrapperToKeepList.size(); index++){
                if (orderWrapperToKeepList.size() > index + 1) {
                    OrderWrapper orderWrapper = orderWrapperToKeepList.get(index);
                    OrderWrapper orderWrapper2 = orderWrapperToKeepList.get(index+1);
                    Integer diff = Integer.valueOf(Math.floor(orderWrapper.order.EffectiveDate.daysBetween(orderWrapper2.order.EffectiveDate)));
                    if(diff > 60){
                        diff = 60;//personalização para a easychef
                    }
                    System.debug(LoggingLevel.INFO, '@@@ opp.CloseDate - opportunityWrapper.opp.CloseDate - diff: ' + orderWrapper.order.EffectiveDate);
                    System.debug(LoggingLevel.INFO, '@@@ opp.CloseDate - opportunityWrapper2.opp.CloseDate - diff: ' + orderWrapper2.order.EffectiveDate);
                    System.debug(LoggingLevel.INFO, '@@@ opp.CloseDate - opp.CloseDate - diff antes: ' + diff);
                    //valores possívels 5, 10, 15, 20, 25, 30, 45, 60, 75, 90, 105, 
                    if(diff < 360){
                        cycleSpacesV1.add(normalizeDiffBetweenDatesV1(diff));
                        cycleSpacesV2.add(normalizeDiffBetweenDatesV2(diff));
                    }
                    System.debug(LoggingLevel.INFO, '@@@ opp.CloseDate - opp.CloseDate - diff normalizado: ' + normalizeDiffBetweenDatesV1(diff));
                    System.debug(LoggingLevel.INFO, '@@@ opp.CloseDate - opp.CloseDate - diff normalizado 2: ' + normalizeDiffBetweenDatesV2(diff));
                }
            }
            
            Integer cycleV1 = getMostFrequent(cycleSpacesV1);
            Integer cycleV2 = getMostFrequent(cycleSpacesV2);
            
            String mostFrequentV1 = String.valueOf(getMostFrequent(cycleSpacesV1)).leftPad(3, '0') + ' dias';
            String mostFrequentV2 = String.valueOf(getMostFrequent(cycleSpacesV2)).leftPad(3, '0') + ' dias';
            
            System.debug(LoggingLevel.INFO, '@@@mostFrequentV1: ' + mostFrequentV1);
            System.debug(LoggingLevel.INFO, '@@@mostFrequentV2: ' + mostFrequentV2);
            
            if(acc.PHCCicloFinalModa1__c != mostFrequentV1 || acc.PHCCicloFinalModa2__c != mostFrequentV2){
                //acc.PHCCicloFinalModa__c = mostFrequentV1;
                acc.PHCCicloFinalModa1__c = mostFrequentV1;
                acc.PHCCicloFinalModa2__c = mostFrequentV2;
                acc.UltimaAtualizacaoPHC__c = System.now(); 
                //System.debug(LoggingLevel.INFO, '@@@ opp.CloseDate - opp.CloseDate - mostFreqCycle: ' + mostFreqCycle);
                toUpdate.add(acc);
            }
        }
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(accountIds, toUpdate, 'Erro ao tentar calcular ciclo de compras ideal. ');
    }
    
    public Integer getMostFrequent(List<Integer> cycleSpaces){
        System.debug(LoggingLevel.INFO, '@@@cycleSpaces: ' + cycleSpaces);
        
        Map<Integer, Integer> counterForMode = new Map<Integer, Integer>();//7 => 1, 30 => 4, 60 => 2
        
        for(Integer cycle : cycleSpaces){
            if (counterForMode.containsKey(cycle)) {
                counterForMode.put(cycle, counterForMode.get(cycle) + 1);
            }else{
                counterForMode.put(cycle, 1);
            }
        }
        
        Integer mostFreqCycle = null;
        Integer mostFreqCycleCounter = null;
        
        for (Integer cycle : counterForMode.keySet()){
            Integer currentCounter = counterForMode.get(cycle);
            if(mostFreqCycle == null){
                mostFreqCycle = cycle;
                mostFreqCycleCounter = counterForMode.get(cycle);
            }else if(counterForMode.get(cycle) > mostFreqCycleCounter){
                mostFreqCycle = cycle;
                mostFreqCycleCounter = counterForMode.get(cycle);
            }
        }
        System.debug(LoggingLevel.INFO, '@@@mostFreqCycle: ' + mostFreqCycle);
        System.debug(LoggingLevel.INFO, '@@@mostFreqCycleCounter: ' + mostFreqCycleCounter);
        
        if(counterForMode.get(mostFreqCycle) < 3 && !Test.isRunningTest()){
            mostFreqCycle = normalizeDiffBetweenDatesV1(meanInteger(cycleSpaces));
        }
        return mostFreqCycle == null ? 30 : mostFreqCycle;
    }
    
    public Integer meanInteger(List<Integer> nums) {
        Integer total = 0;
        for (Integer n : nums) {
            total += n;
        }
        return total / nums.size();
    }
    
    public Integer normalizeDiffBetweenDatesV1(Integer diff){
        if (diff <= 7 ){
            diff = 7;
        }else if (diff > 7 && diff <= 12) {
            diff = 10;
        }else if (diff >= 13 && diff <= 17) {
            diff = 15;
        }else if (diff >= 18 && diff <= 22) {
            diff = 20;
        }else if (diff >= 23 && diff <= 27) {
            diff = 25;
        }else if (diff >= 28 && diff <= 38) {
            diff = 30;
        }else if (diff >= 39 && diff <= 53) {
            diff = 45;
        }else if (diff >= 54 && diff <= 68) {
            diff = 60;
        }else if (diff >= 69 && diff <= 83) {
            diff = 75;
        }else if (diff >= 84 && diff <= 105) {
            diff = 90;
        }else if (diff >= 106 && diff <= 135) {
            diff = 120;
        }else if (diff >= 136 && diff <= 165) {
            diff = 150;
        }else if (diff >= 166 && diff <= 270) {
            diff = 180;
        }else{
            diff = 360;
        }
        return diff;
    }
    public Integer normalizeDiffBetweenDatesV2(Integer diff){
        if (diff <= 7 ){
            diff = 7;
        }else if (diff > 7 && diff <= 23) {
            diff = 15;
        }else if (diff >= 24 && diff <= 38) {
            diff = 30;
        }else if (diff >= 39 && diff <= 53) {
            diff = 45;
        }else if (diff >= 54 && diff <= 68) {
            diff = 60;
        }else if (diff >= 69 && diff <= 83) {
            diff = 75;
        }else if (diff >= 84 && diff <= 106) {
            diff = 90;
        }else if (diff >= 107 && diff <= 135) {
            diff = 120;
        }else if (diff >= 136 && diff <= 165) {
            diff = 150;
        }else if (diff >= 166 && diff <= 270) {
            diff = 180;
        }else{
            diff = 360;
        }
        return diff;
    }
    
    public void Finish(Database.BatchableContext BC){        
        if (!Test.isRunningTest()) {
            
             //7, 10, 15, 20, 25, 30, 45, 60, 75, 90, 120, 150, 180, 360
            List<String> phcSegmentationList = new List<String>();
            phcSegmentationList.add('007 dias');
            phcSegmentationList.add('010 dias');
            phcSegmentationList.add('015 dias');
            phcSegmentationList.add('020 dias');
            phcSegmentationList.add('025 dias');
            phcSegmentationList.add('030 dias');
            phcSegmentationList.add('045 dias');
            phcSegmentationList.add('060 dias');
            phcSegmentationList.add('075 dias');
            phcSegmentationList.add('090 dias');
            phcSegmentationList.add('120 dias');
            phcSegmentationList.add('150 dias');
            phcSegmentationList.add('180 dias');
            phcSegmentationList.add('360 dias');
        
            for(String phcSegmentation : phcSegmentationList){
                if(!Test.isRunningTest()){
                    Database.executeBatch(new DW_PHC_HealthAnalisysBatch(phcSegmentation), 20);
                }
            }
            
        }
    
    }
    
    public class OrderWrapper implements Comparable {
        
        public Order order;
        
        public OrderWrapper(Order order) {
            this.order = order;
        }
        
        public Integer compareTo(Object compareTo) {
            OrderWrapper compareToOrder = (OrderWrapper)compareTo;
            Integer returnValue = 0;
            if (order.EffectiveDate > compareToOrder.order.EffectiveDate) {
                returnValue = 1;
            } else if (order.EffectiveDate < compareToOrder.order.EffectiveDate) {
                returnValue = -1;
            } else if ((order.EffectiveDate == null) && (compareToOrder.order.EffectiveDate != null)){
                returnValue = -1;
            } else if ((order.EffectiveDate != null) && (compareToOrder.order.EffectiveDate == null)){
                returnValue = 1;
            }
            return returnValue;
        }
    }
    
}