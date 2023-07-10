@IsTest
public class GerenciamentoOcorrenciaControllerTest {
    @IsTest
    public static void main() {
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
        OrdemCarregamento__c ordemCarregamento = new OrdemCarregamento__c();
        insert ordemCarregamento;
        OrdensCarregamentoPedido__c ordemCarregamentoPedido = new OrdensCarregamentoPedido__c(
            OrdemCarregamento__c = ordemCarregamento.Id,
            Pedido__c = order.Id
        );
        insert ordemCarregamentoPedido;

        GerenciamentoOcorrenciaController.getOrdensCarregamentoOportunidades(ordemCarregamento.Id);
        GerenciamentoOcorrenciaController.getDependentPicklistValues();
        ordemCarregamentoPedido.Ocorrencia__c = 'Comercial';
        GerenciamentoOcorrenciaController.saveUpdates(new List<OrdensCarregamentoPedido__c>{ordemCarregamentoPedido});


    	Test.stopTest();
    }
}