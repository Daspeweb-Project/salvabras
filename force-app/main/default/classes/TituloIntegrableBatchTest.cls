@IsTest
public with sharing class TituloIntegrableBatchTest {
    /*@IsTest
    public static void checkSchedule() {
        TituloIntegrableBatch.scheduleThisClass(null);
        TituloIntegrableBatch.runEveryNMinutesInBusinessHours(4);
        TituloIntegrableBatch.cancelThisSchedule();
    }*/

    @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new TituloIntegrableBatch());
    }

    @IsTest
    public static void checkSuccess() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        User user = TestFactory.getAnyUser();
        user.CodigoERP__c = 'V988122';
        update user;
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C02868';
        update acc;
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00001';
        update accTransportadora;
        Account accVendedor = TestFactory.createAccountVendedorType();
        accVendedor.CodigoERPVendedor__c = 'V00001';
        update accVendedor;
        Contact contact = TestFactory.createContact(acc);
        Pricebook2 pb2 = TestFactory.createPricebook();
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, TestFactory.createProduct());
        Opportunity opp = TestFactory.createOpportunity(acc, contact, pb2);

        FilialFaturamento__c filialFaturamento = TestFactory.createFilialFaturamento();
        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);

        Test.startTest();
        TituloIntegrableBatch.runInSyncMode(acc.Id);
        List<Account> lsAccount = new List<Account>();
        lsAccount.add(acc);
        TituloIntegrableBatch batch = new TituloIntegrableBatch();
        batch.execute(null, lsAccount);
        Test.stopTest();
    }

    @IsTest
    public static void checkWithError() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C02868';
        update acc;
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00005';
        update accTransportadora;
        Account accVendedor = TestFactory.createAccountVendedorType();
        accVendedor.CodigoERPVendedor__c = 'V00006';
        update accVendedor;
        Contact contact = TestFactory.createContact(acc);
        Pricebook2 pb2 = TestFactory.createPricebook();
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, TestFactory.createProduct());
        Opportunity opp = TestFactory.createOpportunity(acc, contact, pb2);

        FilialFaturamento__c filialFaturamento = TestFactory.createFilialFaturamento();
        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);

        Test.startTest();
        TituloIntegrableBatch.runInSyncMode(acc.Id);
        List<Account> lsAccount = new List<Account>();
        lsAccount.add(acc);
        TituloIntegrableBatch batch = new TituloIntegrableBatch();
        batch.execute(null, lsAccount);
        Test.stopTest();
    }
}