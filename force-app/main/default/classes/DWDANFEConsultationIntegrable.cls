public without sharing class DWDANFEConsultationIntegrable extends DW_Integrable{
    public DWDANFEResponseTemplate responseTemplate;

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
         
            return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndPointConsultaDANFE__c;
        
    }
    
    public override String setMethod() {
        
        return 'POST';
    }

    public override Map<String, String> constructHeaders() {
         return new Map<String, String>{
            'Content-Type' => 'application/json'
        };
    }
 
    public override Map<String, String> constructQueryParameters() {
        return new Map<String, String>();
    }

    public override String getSerializedRequest() {
        NotaFiscal__c nf = (NotaFiscal__c)this.deserializedRequestObject;
        NotaFiscal__c nfFiscal  = ((List<NotaFiscal__c>) DW_QueryFactory.get('NotaFiscal__c')
                            .setCondition(DW_QueryCondition.newInstance('Id', '=', nf.Id))
                        	.withParent('Conta__r','Account')
                            .run())
                            .get(0);
        
        
        
        
        DWDANFERequestTemplate requestTemplate = new DWDANFERequestTemplate();
        requestTemplate.cliente = nfFiscal.Conta__r.CodigoERP__c;
        //requestTemplate.lojacli = 'quote.Account.LojaCliente__c';
        requestTemplate.loja = '01';
        requestTemplate.doc = nfFiscal.CodigoERP__c;
        requestTemplate.serie = nfFiscal.Serie__c;
         System.debug(' serielize' +  
                     JSON.serialize(requestTemplate)
                     );
        return JSON.serialize(requestTemplate);
        
        
        
        

        
    }
  
    public override void setDeserializedResponseObject() {
        System.debug(' this.requestFactoryInstance.getResponse().getBody()_original' +  
                     this.requestFactoryInstance.getResponse().getBody()
                     );
        
        this.responseTemplate = (DWDANFEResponseTemplate)JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody()
                     , DWDANFEResponseTemplate.class
        );
        this.deserializedResponseObject = responseTemplate;
    }

    public override void finish() {

    }
}