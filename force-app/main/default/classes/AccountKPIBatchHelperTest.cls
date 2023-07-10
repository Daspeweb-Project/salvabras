@IsTest
public class AccountKPIBatchHelperTest {
    @TestSetup
    public static void makeData(){
        Account acc = new Account(Name='Teste');
        insert acc;
        
        Account acc2 = new Account(Name='Teste 2');
        insert acc2;

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
        
        // List<Opportunity> oppsAccount2 = new List<Opportunity>{
        //     new Opportunity(Name='Opp 1 - ' + acc2.Name, CloseDate=fiveMonthsAgo, StageName='Prospecting', AccountId=acc2.Id, Amount=1000.00),
        //     new Opportunity(Name='Opp 2 - ' + acc2.Name, CloseDate=threeMonthsAgo, StageName='Prospecting', AccountId=acc2.Id, Amount=2000.00),
        //     new Opportunity(Name='Opp 3 - ' + acc2.Name, CloseDate=oneMonthAgo, StageName='Prospecting', AccountId=acc2.Id, Amount=4500.00)
        // };

        // insert oppsAccount2;
    }

    @IsTest
    public static void run(){
        Account acc = [SELECT Id FROM Account WHERE Name = 'Teste' LIMIT 1];
        // System.assertEquals(1500.0, AccountKPIBatchHelper.getAverage(acc.Id, 3), 'O valor da média de 3 meses está incorreto');
        // System.assertEquals(1600.0, AccountKPIBatchHelper.getAverage(acc.Id, 6), 'O valor da média de 6 meses está incorreto');

        Account acc2 = [SELECT Id FROM Account WHERE Name = 'Teste 2' LIMIT 1];
        // System.assertEquals(3250.0, AccountKPIBatchHelper.getAverage(acc2.Id, 3), 'O valor da média de 3 meses está incorreto');
        // System.assertEquals(2500.0, AccountKPIBatchHelper.getAverage(acc2.Id, 6), 'O valor da média de 6 meses está incorreto');

    }
}