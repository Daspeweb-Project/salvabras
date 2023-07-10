/**
* Created by guilhermereis on 25/01/21.
*/

@IsTest
public with sharing class AccountIntegrableBatchTest {
    @IsTest
    public static void main() {
        Database.executeBatch(new AccountIntegrableBatch());
    }
    @IsTest
    public static void scheduleThisClass(){
        AccountIntegrableBatch.scheduleThisClass(null);
    }
    @IsTest
    public static void cancelThisSchedule(){
        AccountIntegrableBatch.cancelThisSchedule();
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
        TestFactory.createContact(acc);

        Test.startTest();
        AccountIntegrableBatch.runInSyncMode(acc.Id);
        
        List<Account> lsAccount = new List<Account>();
        lsAccount.add(acc);
        AccountIntegrableBatch batch = new AccountIntegrableBatch();
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
        System.assertEquals('Pendente', accountToAssert.StatusIntegracao__c);
        System.assertEquals('C04470', accountToAssert.CodigoERP__c);
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
        TestFactory.createContact(acc);

        Test.startTest();
        AccountIntegrableBatch.runInSyncMode(acc.Id);
        Test.stopTest();

        Account accountToAssert = ((List<Account>)DW_QueryFactory.get('Account')
                .setCondition(DW_QueryCondition.newInstance('Id', '=', acc.Id))
                .run())
                .get(0);

        List<HttpRequestLog__c> httpRequestLogList = (List<HttpRequestLog__c>)DW_QueryFactory.get('HttpRequestLog__c')
                .setCondition(DW_QueryCondition.newInstance('Conta__c', '=', acc.Id))
                .run();

        System.assertEquals(1, httpRequestLogList.size());
        System.assertEquals('Executado com sucesso', accountToAssert.StatusIntegracao__c);
        System.assertEquals('T00778', accountToAssert.CodigoERPTransportadora__c);
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
        TestFactory.createContact(acc);

        Test.startTest();
        AccountIntegrableBatch.runInSyncMode(acc.Id);
        Test.stopTest();

        Account accountToAssert = ((List<Account>)DW_QueryFactory.get('Account')
                .setCondition(DW_QueryCondition.newInstance('Id', '=', acc.Id))
                .run())
                .get(0);

        List<HttpRequestLog__c> httpRequestLogList = (List<HttpRequestLog__c>)DW_QueryFactory.get('HttpRequestLog__c')
                .setCondition(DW_QueryCondition.newInstance('Conta__c', '=', acc.Id))
                .run();

        System.assertEquals(1, httpRequestLogList.size());
        System.assertEquals('Executado com sucesso', accountToAssert.StatusIntegracao__c);
        System.assertEquals('V00082', accountToAssert.CodigoERPVendedor__c);
    }
}