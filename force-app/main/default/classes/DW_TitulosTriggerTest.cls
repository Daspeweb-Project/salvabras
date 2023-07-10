@IsTest
public with sharing class DW_TitulosTriggerTest {
    
    @IsTest
    public static void testSucesso(){
        Titulo__c titulo = new Titulo__c();
        titulo.Name = '000000340/001';
        FilialFaturamento__c filial = TestFactory.createFilialFaturamento();
        Account acc = TestFactory.createAccountClienteType();
        titulo.Conta__c =  acc.id;
        titulo.DataBaixa__c = System.today().addDays(-200);
        titulo.DataEmissao__c = System.today().addDays(-200);
        titulo.DataVencimento__c = System.today().addDays(-200);
        titulo.Saldo__c = 5344.5;
        titulo.Parcela__c = 'A';
        titulo.Valor__c = 5344.5;
        titulo.DataVencimentoReal__c = System.today().addDays(-200);
        titulo.Tipo__c = 'NF';
		titulo.CodigoERP__c = '1010';
        titulo.CodigoCliente__c = 'C88888';  
        titulo.Status__c = 'A';
        insert titulo;
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