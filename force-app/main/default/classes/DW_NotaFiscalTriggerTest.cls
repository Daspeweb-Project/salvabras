@IsTest
public with sharing class DW_NotaFiscalTriggerTest {
    @IsTest
    public static void testSucesso(){
        NotaFiscal__c nf = new NotaFiscal__c();
        nf.Name = '000000340/001';
        nf.CodigoEmpresaERP__c = '01';
        nf.CodigoFilialERP__c = '01';
        nf.DataEmissao__c = Date.newInstance(2022, 7, 30);
        nf.Status__c = 'A';
        nf.Valor__c = 100.00;
        nf.TipoNotaFiscal__c = 'N';
        nf.NotaOrigemTerceiros__c = false;
        nf.ChaveDANFE__c = '35220116557984000146550010000003401740601168';
        nf.DataDigitacao__c = Date.newInstance(2022, 7, 30);
        nf.ValorCTE__c = 0;
        nf.Quantidade__c = 1;
        nf.Faturado__c = 'Sim';
        FilialFaturamento__c filial = TestFactory.createFilialFaturamento();
        nf.FilialFaturamento__c = filial.id;
        nf.CodigoContaERP__c = 'C88888';
        nf.CodigoPedido__c = '88888';
        Account acc = TestFactory.createAccountClienteType();
        nf.Conta__c =  acc.id;
        nf.Pedido__c =  createOrder(acc, filial).id;
		nf.CodigoERP__c = '1010';

        insert nf;
    }

    public static Order createOrder(Account account, FilialFaturamento__c filial){
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00001';
        accTransportadora.DataAberturaEmpresa__c = System.today().addDays(-200);//todo mudar o tipo desse campo
        update accTransportadora;
        Account accVendedor = TestFactory.createAccountVendedorType();
        accVendedor.DataAberturaEmpresa__c = System.today().addDays(-200);//todo mudar o tipo desse campo
        accVendedor.CodigoERPVendedor__c = 'V00001';
        update accVendedor;
        Contact contact = TestFactory.createContact(account);
        Pricebook2 pb2 = TestFactory.createPricebook();
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, TestFactory.createProduct());
        Opportunity opp = TestFactory.createOpportunity(account, contact, pb2);

        FilialFaturamento__c filialFaturamento = filial;
        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);
        Order order = TestFactory.createOrder(account, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        return order;
    }
}