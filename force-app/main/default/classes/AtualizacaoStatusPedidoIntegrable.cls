public with sharing class AtualizacaoStatusPedidoIntegrable extends DW_Integrable{

    public ResponseAtualizacaoStatusPedido responseTemplate;
    
    public override void callIntegration(Object obj) {
        
        this.deserializedRequestObject = obj;
        this.sendRequest();
        
    }
    public override String constructEndpoint() {
        return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndpointLiberarPedidoFaturamento__c;
    }
    public override String setMethod() {
        return 'POST';
    }
    public override Map<String, String> constructHeaders() {
        
        return new Map<String, String>{
            //'Authorization' => 'Bearer ' + DaspeMicroservicoHelper.getInstance().daspeMicroservico.Token__c,
            'Content-Type' => 'application/json'
            //'Accept' => 'application/json'
        };
    }
    
    public override Map<String, String> constructQueryParameters() {
        return new Map<String, String>();
    } 
    
    
    public override String getSerializedRequest() {
        Order pedido = (Order)this.deserializedRequestObject;
        RequestAtualizacaoPedido requestTemplate = new RequestAtualizacaoPedido();
        requestTemplate.codigo_pedido= pedido.CodigoERP__c;
        requestTemplate.status_faturamento= 'Liberado';
        return JSON.serialize(requestTemplate);        
    }
    
     public override void setDeserializedResponseObject() {
         System.debug(LoggingLevel.ERROR,'this.requestFactoryInstance.getResponse().getBody():' + this.requestFactoryInstance.getResponse().getBody());
        
        this.responseTemplate = (ResponseAtualizacaoStatusPedido) JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody(),
            ResponseAtualizacaoStatusPedido.class
        );
        System.debug(LoggingLevel.ERROR,'responseTemplate:' + responseTemplate);
        this.deserializedResponseObject = responseTemplate;
    }
    
    public override void finish() {
        
    }
}