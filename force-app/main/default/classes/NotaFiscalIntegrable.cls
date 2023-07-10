public without sharing class NotaFiscalIntegrable extends DW_Integrable {
    public override void callIntegration(Object obj){
        this.deserializedRequestObject = (Account)obj;
        this.sendRequest();
    }

    public override String constructEndpoint() {
        return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndpointConsultaNFs__c + '?page=1&pagesize=999999';
    }

    public override String setMethod() {
        return 'POST';
    }

    public override Map<String, String> constructHeaders() {
        return new Map<String, String>{
            //'Authorization' => 'Bearer ' + DaspeMicroservicoHelper.getInstance().daspeMicroservico.Token__c,
            'Content-Type' => 'application/json'
        };
    }

    public override Map<String, String> constructQueryParameters() {
        return new Map<String, String>();
    }

    public override void setDeserializedResponseObject(){
        this.deserializedResponseObject = (NotaFiscalIntegrableResponseTemplate)JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody(),
            NotaFiscalIntegrableResponseTemplate.class
        );
    }

    public override String getSerializedRequest(){
        System.debug('[INTEGRACAO][daspeMicroservico.EndpointConsultaNFs__c] Start');
        Account account = (Account)this.deserializedRequestObject;

        NotaFiscalIntegrableRequestTemplate template = new NotaFiscalIntegrableRequestTemplate();

        if(DW_Helper.isNullOrBlank(account.CodigoERP__c)) throw new IllegalArgumentException ('Código ERP (Conta) obrigatório para integração');

        template.cliente = account.CodigoERP__c;
        template.lojacli = account.loja_conta__c;

        System.debug('Json' + JSON.serialize(template));
        return JSON.serialize(template);
    }

    public override void finish() {
        System.debug(LoggingLevel.INFO, '@@@this.finish this.requestFactoryInstance: ' + this.requestFactoryInstance);
        System.debug(LoggingLevel.INFO, '@@@this.finish this.deserializedResponseObject: ' + this.deserializedResponseObject);
    }
}