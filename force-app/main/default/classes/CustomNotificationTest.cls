/**
 * Created by rafael.vidal on 10/06/22.
 */
@IsTest
public with sharing class CustomNotificationTest {
    @IsTest
    public static void notifyUsers() {
        User user = TestFactory.getAnyUser();
        user.CodigoERP__c = 'V988122';
        update user;

        Set<String> recipientsIds = new Set<String>();
        recipientsIds.add(user.Id);
        
        Account account = TestFactory.createAccountClienteType();
        account.CodigoERP__c = 'C00001';
        account.Name = 'Conta Teste';
        account.OwnerId = user.Id;
        account.BillingCity = 'Oslo';
        account.BillingCountry = 'Norway';
        account.BillingStreet = 'Rua de Tal, 999, loja 2, Bairro de Tal';
        account.BillingPostalCode = '82840-220';
        update account;
        
        Account accTransportadora = TestFactory.createAccountTransportadoraType();
        accTransportadora.CodigoERPTransportadora__c = 'T00001';
        update accTransportadora;
        Account accVendedor = TestFactory.createAccountVendedorType();
        accVendedor.CodigoERPVendedor__c = 'V00001';
        update accVendedor;
        Contact contact = TestFactory.createContact(account);
        Pricebook2 pb2 = TestFactory.createPricebook();
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, TestFactory.createProduct());
        Opportunity opp = TestFactory.createOpportunity(account, contact, pb2);

        FilialFaturamento__c filialFaturamento = TestFactory.createFilialFaturamento();
        CondicaoPagamento__c condicaoPagamento = TestFactory.createCondicaoPagamento();
        OpportunityLineItem opportunityLineItem = TestFactory.createOpportunityLineItem(opp, pricebookEntry);
        Order order = TestFactory.createOrder(account, opp, pb2, filialFaturamento, accTransportadora, condicaoPagamento, accVendedor);
        OrderItem orderItem = TestFactory.createOrderItem(order, opportunityLineItem);
		order.OwnerId = user.Id;
        order.StatusIntegracao__c = 'Pendente';
        update order;
        
        CustomNotification.notifyUsers(recipientsIds, order.Id, 'Pedido', order.Name); 
        CustomNotification.notifyUsers(recipientsIds, account.Id, 'Conta', account.Name);
        
    }
}