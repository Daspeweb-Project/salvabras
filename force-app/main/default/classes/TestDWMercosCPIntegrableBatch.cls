@IsTest
public class TestDWMercosCPIntegrableBatch {
     @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosCPIntegrableBatch());
    }
    @IsTest
    public static void postAccountSuccessMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();
        
        
        
        Test.startTest();
        List<CondicaoPagamento__c> lscp = new List<CondicaoPagamento__c>();
        lscp.add(condicaoPagamento);
        DWMercosCPIntegrableBatch batch = new DWMercosCPIntegrableBatch();
        batch.execute(null, lscp);
        Test.stopTest();
    }
     @IsTest
    public static void postTranspCancelMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();
        
        Test.startTest();
        List<Account> lsAcc = new List<Account>();
        
        DWMercosCPIntegrableBatch.cancelThisSchedule();
        
        Test.stopTest();
    }
      @IsTest
    public static void postTestQaMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
                CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();

        
        Test.startTest();
        List<String> lscp = new List<String>();
        lscp.add(condicaoPagamento.Id);

        DWMercosCPIntegrableBatch.testQA(lscp);
        
        Test.stopTest();
    }
     @IsTest
    public static void postTestScheduleMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
                        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();

        
        
        Test.startTest();
       List<String> lscp = new List<String>();
        lscp.add(condicaoPagamento.Id);

        DWMercosCPIntegrableBatch.scheduleThisClass(null);
        
        Test.stopTest();
    }

}