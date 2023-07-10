@IsTest
public class ControllerVisualizarDANFETest {
    @isTest
    public static void ControllerPdfProposta() {
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        NotaFiscal__c notaFiscal = new NotaFiscal__c();
        notaFiscal.DataEmissao__c = System.today();
        notaFiscal.Conta__c = acc.Id;
        notaFiscal.Valor__c = 242;
        notaFiscal.Status__c = 'OK';
        notaFiscal.TipoNotaFiscal__c = 'N';
        notaFiscal.CodigoERP__c = '2425';
        insert notaFiscal;
        
        PageReference myVfPage = Page.VisualizarDANFE;
		Test.setCurrentPage(myVfPage);
        ApexPages.currentPage().getParameters().put('Id',notaFiscal.Id);
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(notaFiscal);
        
        ControllerVisualizarDANFE controller = new ControllerVisualizarDANFE(ctrl);
        controller.base64 = '';
    }

}