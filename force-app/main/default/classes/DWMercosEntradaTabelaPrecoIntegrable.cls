public without sharing class DWMercosEntradaTabelaPrecoIntegrable extends DW_Integrable {

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
        PricebookEntry catalogoEntradaPreco = (PricebookEntry)this.deserializedRequestObject;
        if (! String.isBlank(catalogoEntradaPreco.CodigoExclusivoMercos__c)) {
            String url = DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndPointCriacaoVinculoTabelaPreco__c+'/'+catalogoEntradaPreco.CodigoExclusivoMercos__c;
            return url;
        }
        return DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndPointCriacaoVinculoTabelaPreco__c;
        
    }
    
    public override String setMethod() {
        PricebookEntry catalogoEntradaPreco = (PricebookEntry)this.deserializedRequestObject;
        
        if (! String.isBlank(catalogoEntradaPreco.CodigoExclusivoMercos__c)) {
            return 'PUT';
        }
        return 'POST';
    }
    
    public override Map<String, String> constructHeaders() {
        return new Map<String, String>{
            'Content-Type' => 'application/json',
                'ApplicationToken' =>DaspeMicroservicoHelper.getInstance().mercosMicroservico.ApplicationToken__c,
                'CompanyToken' => DaspeMicroservicoHelper.getInstance().mercosMicroservico.CompanyToken__c
                };
                    }
 
    public override Map<String, String> constructQueryParameters() {
        return new Map<String, String>();
    }

    public override String getSerializedRequest() {
        PricebookEntry catalogoEntradaPreco = (PricebookEntry)this.deserializedRequestObject;
        Pricebook2 pb2 = [SELECT ID,CodigoExclusivoMercos__c FROM  Pricebook2 WHERE ID = :catalogoEntradaPreco.Pricebook2Id ];
        Product2 prod = [SELECT ID,CodigoExclusivoMercos__c FROM  Product2 WHERE ID = :catalogoEntradaPreco.Product2Id ];
        
        
        PbEntryMercosIntegrableRequestTemplate requestTemplate = new PbEntryMercosIntegrableRequestTemplate(); 
        requestTemplate.tabela_Id =  Integer.valueOF(pb2.CodigoExclusivoMercos__c);
        requestTemplate.produto_Id = Integer.valueOF(prod.CodigoExclusivoMercos__c);
        requestTemplate.preco = catalogoEntradaPreco.UnitPrice;
        return JSON.serialize(requestTemplate);
        
    }
  
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {

    }
}