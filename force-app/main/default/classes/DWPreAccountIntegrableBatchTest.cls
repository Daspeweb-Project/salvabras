@IsTest
public class DWPreAccountIntegrableBatchTest {
@IsTest
    public static void main() {
        Database.executeBatch(new DWPreAccountIntegrableBatch());
    }
    @IsTest
    public static void scheduleThisClass(){
        DWPreAccountIntegrableBatch.scheduleThisClass(null);
    }
    @IsTest
    public static void cancelThisSchedule(){
        DWPreAccountIntegrableBatch.cancelThisSchedule();
    }
    @IsTest
    public static void testClienteType() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        User user = TestFactory.getAnyUser();
        user.CodigoERP__c = '1234';
        update user;
        Account acc = TestFactory.createAccountClienteType();
        acc.OwnerId = user.Id;
        update acc;
        List<String> idAcList = new List<String>();
        idAcList.add(acc.Id);
        TestFactory.createContact(acc);

        Test.startTest();
    DWPreAccountIntegrableBatch.testQA(idAcList);        
        List<Account> lsAccount = new List<Account>();
        lsAccount.add(acc);
        DWPreAccountIntegrableBatch batch = new DWPreAccountIntegrableBatch();
        batch.execute(null, lsAccount);
        Test.stopTest();

        Account accountToAssert = ((List<Account>)DW_QueryFactory.get('Account')
                .setCondition(DW_QueryCondition.newInstance('Id', '=', acc.Id))
                .run())
                .get(0);

        List<HttpRequestLog__c> httpRequestLogList = (List<HttpRequestLog__c>)DW_QueryFactory.get('HttpRequestLog__c')
                .setCondition(DW_QueryCondition.newInstance('Conta__c', '=', acc.Id))
                .run();

        System.assertEquals(2, httpRequestLogList.size());
        
    }
    @IsTest
    public static void testTransportadoraType() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        User user = TestFactory.getAnyUser();
        user.CodigoERP__c = '1234';
        update user;
        Account acc = TestFactory.createAccountTransportadoraType();
        acc.OwnerId = user.Id;
        update acc;
        List<String> idAcList = new List<String>();
        idAcList.add(acc.Id);
        TestFactory.createContact(acc);

        Test.startTest();
    DWPreAccountIntegrableBatch.testQA(idAcList);
        Test.stopTest();

        Account accountToAssert = ((List<Account>)DW_QueryFactory.get('Account')
                .setCondition(DW_QueryCondition.newInstance('Id', '=', acc.Id))
                .run())
                .get(0);

        List<HttpRequestLog__c> httpRequestLogList = (List<HttpRequestLog__c>)DW_QueryFactory.get('HttpRequestLog__c')
                .setCondition(DW_QueryCondition.newInstance('Conta__c', '=', acc.Id))
                .run(); 

        System.assertEquals(1, httpRequestLogList.size());
      
    }
    @IsTest
    public static void testVendedorType() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        User user = TestFactory.getAnyUser();
        user.CodigoERP__c = '1234';
        update user;
        Account acc = TestFactory.createAccountVendedorType();
        acc.OwnerId = user.Id;
        update acc;
        List<String> idAcList = new List<String>();
        idAcList.add(acc.Id);
        TestFactory.createContact(acc);

        Test.startTest();
        DWPreAccountIntegrableBatch.testQA(idAcList);
        Test.stopTest();
 
        Account accountToAssert = ((List<Account>)DW_QueryFactory.get('Account')
                .setCondition(DW_QueryCondition.newInstance('Id', '=', acc.Id))
                .run())
                .get(0);

        List<HttpRequestLog__c> httpRequestLogList = (List<HttpRequestLog__c>)DW_QueryFactory.get('HttpRequestLog__c')
                .setCondition(DW_QueryCondition.newInstance('Conta__c', '=', acc.Id))
                .run();

        System.assertEquals(1, httpRequestLogList.size());
    }
  
}