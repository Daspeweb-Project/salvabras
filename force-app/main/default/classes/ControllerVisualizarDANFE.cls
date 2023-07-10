public without sharing class ControllerVisualizarDANFE {
    public List<NotaFiscal__c> notaFiscal{get;set;}
    public String base64{get;set;}
    public ControllerVisualizarDANFE(ApexPages.StandardController stdController){  
        NotaFiscal__c notaFiscal = [SELECT ID,ChaveDANFE__c,ChaveDANFEPt2__c,StatusIntegracaoConsultaDANFE__c FROM NotaFiscal__c WHERE Id = :ApexPages.currentPage().getParameters().get('Id')];
        if(! String.isBlank(notaFiscal.ChaveDANFEPt2__c))this.base64 = notaFiscal.ChaveDANFE__c+notaFiscal.ChaveDANFEPt2__c;        
    }
}