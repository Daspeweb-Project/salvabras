public without sharing class DWMercosCdPagamentoIntegrable  extends DW_Integrable {

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
        CondicaoPagamento__c condicaoPagamento = (CondicaoPagamento__c)this.deserializedRequestObject;
        if (! String.isBlank(condicaoPagamento.CodigoExclusivoMercos__c)) {
            String url = DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndPointCriacaoCondicaoPagamento__c+'/'+condicaoPagamento.CodigoExclusivoMercos__c;
            return url;
        }
        return DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndPointCriacaoCondicaoPagamento__c;
        
    }
    
    public override String setMethod() {
        CondicaoPagamento__c condicaoPagamento = (CondicaoPagamento__c)this.deserializedRequestObject;
        
        if (! String.isBlank(condicaoPagamento.CodigoExclusivoMercos__c)) {
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
        CondicaoPagamento__c condicaoPagamento = (CondicaoPagamento__c)this.deserializedRequestObject;
               
        
        CPMercosIntegrableRequestTemplate requestTemplate = new CPMercosIntegrableRequestTemplate(); 
       
        requestTemplate.nome = condicaoPagamento.Name;
        return JSON.serialize(requestTemplate);
        
    }
  
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {

    }
}