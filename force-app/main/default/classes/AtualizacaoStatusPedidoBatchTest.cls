@IsTest
public class AtualizacaoStatusPedidoBatchTest {
    @IsTest
    public static void checkSchedule() {
        AtualizacaoStatusPedidoBatch.runEveryNMinutes(4);
        AtualizacaoStatusPedidoBatch.cancelThisSchedule();
    }
    @IsTest
    public static void checkSchedule2() {
        AtualizacaoStatusPedidoBatch.scheduleThisClass(null);
    }
    @IsTest
    public static void main(){
        Test.setMock(HttpCalloutMock.class, new AtualizacaoStatusPedidoMock());
        Test.startTest();
        User user = TestFactory.getAnyUser();
        user.CodigoERP__c = 'V988122';
        update user;
        Account acc = TestFactory.createAccountClienteType();
        acc.CodigoERP__c = 'C00001';
        update acc;
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00002';
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
        Order order = TestFactory.createOrder(acc, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        OrderItem orderItem = TestFactory.createOrderItem(order, opportunityLineItem);
		order.OwnerId = user.Id;
        order.StatusIntegracaoLiberacao__c = 'Pendente';
        update order;
        
            AtualizacaoStatusPedidoBatch.runInSyncMode(order.Id);
    	Test.stopTest();
    }
}