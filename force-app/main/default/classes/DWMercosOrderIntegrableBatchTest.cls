@IsTest
public class DWMercosOrderIntegrableBatchTest{
@IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosOrderIntegrableBatch());
    }
    
    @IsTest
    public static void postOrderSuccessMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C00001';
        acc.CodigoExclusivoMercos__c = '34543';
        update acc;
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00001';
        accTransportadora.CodigoExclusivoTransportadoraMercos__c = '34543';
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
        condicaoPagamento.CodigoExclusivoMercos__c = '234435';
        update condicaoPagamento;
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);
        Order order = TestFactory.createOrder(acc, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        OrderItem orderItem = TestFactory.createOrderItem(order, opportunityLineItem);
        order.StatusIntegracao__c = 'Pendente';
        update order;
        
        Test.startTest();
        List<Order> lsOrders = new List<Order>();
        lsOrders.add(order);
        DWMercosOrderIntegrableBatch batch = new DWMercosOrderIntegrableBatch();
        batch.execute(null, lsOrders);
        Test.stopTest();
    }
    
   @IsTest
    public static void postOrderCancelMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C00001';
        acc.CodigoExclusivoMercos__c = '34543';
        update acc;
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00001';
        accTransportadora.CodigoExclusivoTransportadoraMercos__c = '34543';
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
        condicaoPagamento.CodigoExclusivoMercos__c = '234435';
        update condicaoPagamento;
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);
        Order order = TestFactory.createOrder(acc, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        OrderItem orderItem = TestFactory.createOrderItem(order, opportunityLineItem);
        order.StatusIntegracao__c = 'Pendente';
        update order;
        
        Test.startTest();
        DWMercosOrderIntegrableBatch.cancelThisSchedule();
        Test.stopTest();
    }
    @IsTest
    public static void postOrderTestQaMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C00001';
        acc.CodigoExclusivoMercos__c = '34543';
        update acc;
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00001';
        accTransportadora.CodigoExclusivoTransportadoraMercos__c = '34543';
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
        condicaoPagamento.CodigoExclusivoMercos__c = '234435';
        update condicaoPagamento;
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);
        Order order = TestFactory.createOrder(acc, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        OrderItem orderItem = TestFactory.createOrderItem(order, opportunityLineItem);
        order.StatusIntegracao__c = 'Pendente';
        update order;
        
        Test.startTest();
        List<String> lsOrders = new List<String>();
        lsOrders.add(order.Id);
        DWMercosOrderIntegrableBatch.testQA(lsOrders);
        Test.stopTest();
    }
    
    
}