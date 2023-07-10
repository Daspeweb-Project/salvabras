@IsTest
public class AccountKPIBatchTest {
    @TestSetup
    public static void makeData(){
        Account acc = new Account(Name='Teste');
        insert acc;

        Date today = System.today();
        Date fiveMonthsAgo = today.addMonths(-5);
        Date threeMonthsAgo = today.addMonths(-3);
        Date oneMonthAgo = today.addMonths(-1);
        
        // List<Opportunity> opps = new List<Opportunity>{
        //     new Opportunity(Name='Opp 1', CloseDate=fiveMonthsAgo, StageName='Prospecting', AccountId=acc.Id, Amount=1800.00),
        //     new Opportunity(Name='Opp 2', CloseDate=threeMonthsAgo, StageName='Prospecting', AccountId=acc.Id, Amount=1500.00),
        //     new Opportunity(Name='Opp 3', CloseDate=oneMonthAgo, StageName='Prospecting', AccountId=acc.Id, Amount=1500.00)
        // };

        // insert opps;
    }

    @IsTest
    public static void run() {
        Test.startTest();
        AccountKPIBatch akb = new AccountKPIBatch();
        Id batchId = Database.executeBatch(akb);
        Test.stopTest();
        
        Account acc = [SELECT Id FROM Account WHERE Name = 'Teste' LIMIT 1];

        AccountKPIBatch.runInSyncMode(acc.id);
        AccountKPIBatch.scheduleThisClass(null);
        AccountKPIBatch.cancelThisSchedule();
    }
}