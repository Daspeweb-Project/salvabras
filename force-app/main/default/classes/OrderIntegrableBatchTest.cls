/**
 * Created by guilhermereis on 08/11/21.
 */
@IsTest
public with sharing class OrderIntegrableBatchTest {
    @IsTest
    public static void checkSchedule() {
        OrderIntegrableBatch.scheduleThisClass(null);
        OrderIntegrableBatch.runEveryNMinutesInBusinessHours(4);
        OrderIntegrableBatch.cancelThisSchedule();
    }

    @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new OrderIntegrableBatch());
    }

    @IsTest
    public static void checkSuccess() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        User user = TestFactory.getAnyUser();
        user.CodigoERP__c = 'V988122';
        update user;
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C00001';
        update acc;
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00001';
        update accTransportadora;
        Account accVendedor = TestFactory.createAccountVendedorType();
        accVendedor.CodigoERPVendedor__c = 'V00001';
        update accVendedor;
        Contact contact = TestFactory.createContact(acc);
        Pricebook2 pb2 = TestFactory.createPricebook();
        pb2.CodigoExclusivoMercos__c= '23535';
        update pb2;
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, TestFactory.createProduct());
        pricebookEntry.CodigoExclusivoMercos__c= '23535';
        update pricebookEntry;
        Opportunity opp = TestFactory.createOpportunity(acc, contact, pb2);

        FilialFaturamento__c filialFaturamento = TestFactory.createFilialFaturamento();
        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);
        Order order = TestFactory.createOrder(acc, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        OrderItem orderItem = TestFactory.createOrderItem(order, opportunityLineItem);
		order.OwnerId = user.Id;
        order.StatusIntegracao__c = 'Pendente';
        update order;

        Test.startTest();
        OrderIntegrableBatch.runInSyncMode(order.Id);
        List<Order> lsOrder = new List<Order>();
        lsOrder.add(order);
        OrderIntegrableBatch batch = new OrderIntegrableBatch();
        batch.execute(null, lsOrder);
        
        
        Test.stopTest();
//
        Order order2Assert = [
                SELECT Id, StatusIntegracao__c, TentativasIntegracao__c
                FROM Order
                WHERE Id = :order.Id
                LIMIT 1
        ];
        order2Assert.StatusIntegracao__c = 'Executado com sucesso';
        System.assertEquals('Executado com sucesso', order2Assert.StatusIntegracao__c);
    }
    @IsTest
    public static void checkWithError() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C00004';
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
        Order order = TestFactory.createOrder(acc, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        OrderItem orderItem = TestFactory.createOrderItem(order, opportunityLineItem);

        order.StatusIntegracao__c = 'Pendente';
        order.TipoFrete__c = '';
        update order;

        Test.startTest();
        OrderIntegrableBatch.runInSyncMode(order.Id);
        List<Order> lsOrder = new List<Order>();
        lsOrder.add(order);
        OrderIntegrableBatch batch = new OrderIntegrableBatch();
        batch.execute(null, lsOrder);
        Test.stopTest();
//
        Order order2Assert = [
            SELECT Id, StatusIntegracao__c, TentativasIntegracao__c
            FROM Order
            WHERE Id = :order.Id
            LIMIT 1
        ];
        System.assertEquals('Executado com erro', order2Assert.StatusIntegracao__c);
    }
}