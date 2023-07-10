public without sharing class DWMercosTransportadoraIntegrable extends DW_Integrable {

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
        Account account = (Account)this.deserializedRequestObject;
        if (! String.isBlank(account.CodigoExclusivoTransportadoraMercos__c)) {
            String url = DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoTransportadora__c+'/'+account.CodigoExclusivoTransportadoraMercos__c;
            return url;
        }
        return DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoTransportadora__c;
        
    }
    
    public override String setMethod() {
        Account account = (Account)this.deserializedRequestObject;
        
        if (! String.isBlank(account.CodigoExclusivoTransportadoraMercos__c)) {
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
        Account ac = (Account)this.deserializedRequestObject;
        CPMercosIntegrableRequestTemplate requestTemplate = new CPMercosIntegrableRequestTemplate(); 
        
        requestTemplate.nome = ac.Name;
        return JSON.serialize(requestTemplate);
        
    }
    
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {

    }
}