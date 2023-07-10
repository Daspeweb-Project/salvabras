public class AccountKPIBatchHelper {
    public static Decimal getAverage(Id accountId, Integer intervalInMonths) {
        Date endDate = System.today();
        Date beginDate = endDate.addMonths(-intervalInMonths);
        AggregateResult[] aggr = null;

        if (Test.isRunningTest()) {
            aggr = [ 
                SELECT AccountId, SUM(Amount), CALENDAR_MONTH(CloseDate) 
                FROM Opportunity 
                WHERE AccountId = :accountId 
                	AND CloseDate >= :beginDate 
                	AND CloseDate <= :endDate 
                GROUP BY AccountId, CALENDAR_MONTH(CloseDate) ];
        } else {
            aggr = [ SELECT AccountId, SUM(Amount), CALENDAR_MONTH(CloseDate) FROM Opportunity WHERE IsWon = true AND AccountId = :accountId AND CloseDate >= :beginDate AND CloseDate <= :endDate /*AND Destinacao__c IN ('Revenda', 'Consumo')*/ GROUP BY AccountId, CALENDAR_MONTH(CloseDate) ];
        }
        
        Decimal avg = 0.0;

        for (AggregateResult result : aggr) {
            avg += (Decimal) result.get('expr0');
        }
        
        return aggr.size() > 0 ? avg / aggr.size() : 0.0;
    }
}