public without sharing class DWMercosTabelaPrecoIntegrable extends DW_Integrable {

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
        Pricebook2 catalogoPreco = (Pricebook2)this.deserializedRequestObject;
        if (! String.isBlank(catalogoPreco.CodigoExclusivoMercos__c)) {
            String url = DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndPointCriacaoTabelaPreco__c+'/'+catalogoPreco.CodigoExclusivoMercos__c;
            return url;
        }
        return DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndPointCriacaoTabelaPreco__c;
        
    }
    
    public override String setMethod() {
        Pricebook2 catalogoPreco = (Pricebook2)this.deserializedRequestObject;
        
        if (! String.isBlank(catalogoPreco.CodigoExclusivoMercos__c)) {
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
        Pricebook2 catalogoPreco = (Pricebook2)this.deserializedRequestObject;
        
        
        
        CatalogoMercosIntegrableRequestTemplate requestTemplate = new CatalogoMercosIntegrableRequestTemplate(); 
        requestTemplate.nome =  catalogoPreco.Name;
        requestTemplate.tipo = 'P';
        return JSON.serialize(requestTemplate);
        
    }
  
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {

    }
}