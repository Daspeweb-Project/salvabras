@IsTest
public class GerenciarTransporteControllerTest {
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
        Account accMotorista = TestFactory.createAccountMotoristaType();

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
        Veiculo__c veiculo = new Veiculo__c(
            Name = 'Truck',
            MetroCubicoCapacidadeCarga__c = 0
        );
        insert veiculo;
        VeiculoMotorista__c veiculoMotorista = new VeiculoMotorista__c(
            Veiculo__c = veiculo.Id,
            Motorista__c = accMotorista.Id
        );
        insert veiculoMotorista;
        Praca__c praca = new Praca__c(
            Name = 'Grande SP',
            Valor__c = 100,
            Veiculo__c = veiculo.Id
        );
        insert praca;

        MotoristaPraca__c motoristaPraca = new MotoristaPraca__c(
            Praca__c = praca.Id,
            Motorista__c = accMotorista.Id
        );
        insert motoristaPraca;

        GerenciarTransporteController.getVehicle(ordemCarregamento.Id);
        GerenciarTransporteController.getDriver(veiculo.Id);
        GerenciarTransporteController.getPraca( accMotorista.Id, veiculo.Id);
        GerenciarTransporteController.save(ordemCarregamento.Id, veiculo.Id, accMotorista.Id, praca.Id);

    	Test.stopTest();
    }
}