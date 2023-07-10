@IsTest
public class OrdemCarregamentoServiceTest {
   @IsTest
   public static void main(){
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
    ordemCarregamento.Status__c = 'Aguardando faturamento';

    insert ordemCarregamento;
    OrdensCarregamentoPedido__c ordemCarregamentoPedido = new OrdensCarregamentoPedido__c(
        OrdemCarregamento__c = ordemCarregamento.Id,
        Pedido__c = order.Id
    );
    insert ordemCarregamentoPedido;
    NotaFiscal__c nota = new NotaFiscal__c(
        Name = '000256/001',
        Pedido__c = order.Id,
        TipoNotaFiscal__c = 'N',
        Conta__c = acc.Id,
        DataEmissao__c = System.today(),
        Status__c = 'Faturado',
        Valor__c = 100,
        CodigoERP__c = '123',
         FilialFaturamento__c = filialFaturamento.Id
    );
    insert nota;

    ContentVersion cv = new ContentVersion();
    cv.ContentLocation = 'S';
    cv.title='NF-' + order.OrderNumber + '.pdf';
    cv.VersionData=blob.valueof('New Bitmap Image.pdf');
    cv.PathOnClient = cv.Title;
    insert cv;

    Id conDocDanfe = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id].ContentDocumentId;
    ContentDocumentLink conDocLinkDanfe = new ContentDocumentLink();
    conDocLinkDanfe.LinkedEntityId = ordemCarregamentoPedido.OrdemCarregamento__c;
    conDocLinkDanfe.ContentDocumentId = conDocDanfe;
    conDocLinkDanfe.ShareType = 'I';
    conDocLinkDanfe.Visibility = 'AllUsers';
    insert conDocLinkDanfe;
    ordemCarregamento.Status__c = 'Aguardando expedição';
    update ordemCarregamento;

   }
}