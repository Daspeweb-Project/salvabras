@isTest
public class DW_AccountKPIBatchTest {
    @isTest(SeeAllData=true)
    public static void main(){
        AggregateResult[] aggregateResultList = [
            SELECT count(Id), AccountId accountId
            FROM Order
            WHERE Status IN ('Ativado') 
            AND Type IN ('N')
            GROUP BY AccountId
            HAVING count(Id) > 5
            LIMIT 1
        ];
        Id accountId = String.valueOf(aggregateResultList.get(0).get('accountId'));
        DW_AccountKPIBatch.runInSyncMode(accountId);
        DW_AccountKPIBatch.scheduleThisClass(null);
        DW_AccountKPIBatch.cancelThisSchedule();
    }
}