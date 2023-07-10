public class DW_AccountKPIBatchHelper {
    public static Map<Id, Decimal> getAverage(Set<Id> accountIds, Integer intervalInMonths) {
        Date endDate = System.today();
        Date beginDate = endDate.addMonths(-intervalInMonths);
        Integer i = 0;
        Map<Id, Decimal> averageByAccountId = new Map<Id, Decimal>();
        Map<Id, Decimal> sumByAccountId = new Map<Id, Decimal>();
        Map<Id, Integer> recordsByAccountId = new Map<Id, Integer>();
        Map<Id, Integer> cycleMap = new Map<Id, Integer>();
        
        List<Account> accountList = [SELECT Id, PHCCicloFinalModa2__c FROM Account WHERE Id IN :accountIds];
        
        AggregateResult[] aggr = [
            SELECT AccountId, SUM(TotalAmount) sumAmount, CALENDAR_MONTH(EffectiveDate) 
            FROM Order 
            WHERE Status IN ('Ativado')
            AND Type IN ('N') 
            AND AccountId IN :accountIds 
            AND EffectiveDate >= :beginDate 
            AND EffectiveDate <= :endDate 
            GROUP BY AccountId, CALENDAR_MONTH(EffectiveDate)
        ];
        
        for (AggregateResult result : aggr) {
            Id accountId = (Id) result.get('AccountId');
            
            if (!recordsByAccountId.containsKey(accountId)) {
                recordsByAccountId.put(accountId, 0);
            }
            
            if (!sumByAccountId.containsKey(accountId)) {
                sumByAccountId.put(accountId, 0);
            }
            
            recordsByAccountId.put(accountId, recordsByAccountId.get(accountId) + 1);
            sumByAccountId.put(accountId, sumByAccountId.get(accountId) + (Decimal) result.get('sumAmount'));
        }
        for(Account account : accountList){
            if(account.PHCCicloFinalModa2__c != null){
                cycleMap.put(account.Id, Integer.valueOf(account.PHCCicloFinalModa2__c.substring(0,3)));
            }else{
                cycleMap.put(account.Id, 0);
            }
        }
        for (Id accountId : recordsByAccountId.keySet()) {
            if(cycleMap.containsKey(accountId) && cycleMap.get(accountId) >= 30){
                averageByAccountId.put(accountId, sumByAccountId.get(accountId) / intervalInMonths);
            }else{
                averageByAccountId.put(accountId, sumByAccountId.get(accountId) / recordsByAccountId.get(accountId));
            }
        }
        i++;
        i++;
        i++;
        i++;
        i++;
        I++;
        
        return averageByAccountId;
    }
    
}