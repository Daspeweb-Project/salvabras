public without sharing class DwGetSintegraIntegrable extends DW_Integrable {
    String plugin;
    String cpf;
    String dataNascimento;
    String cnpjIe;
    String uf;

    public Object responseTemplate;

    public DwGetSintegraIntegrable(String plugin, String cpf, String dataNascimento, String cnpjIe, String uf){
        this.plugin = plugin;
        this.cpf = cpf;
        this.dataNascimento = dataNascimento;
        this.cnpjIe = cnpjIe;
        this.uf = uf;
    }
    
    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }

    public override String constructEndpoint() {
        return MetadataHelper.getInstance().daspeMicroservico.ConsultaAPI__c;
    }

    public override String setMethod() {
        return 'GET';
    }

    public override Map<String, String> constructHeaders() {
        return new Map<String, String>{
            'Content-Type' => 'application/json'
        };
    }
    
    public override Map<String, String> constructQueryParameters() {
        Map<String, String> queryParameters = new Map<String, String>(); 
        queryParameters.put('token', MetadataHelper.getInstance().daspeMicroservico.Token__c);
        if (plugin != null) queryParameters.put('plugin', plugin);
        if (cpf != null) queryParameters.put('cpf', cpf);
        if (dataNascimento != null) queryParameters.put('dataNascimento', dataNascimento);
        if (cnpjIe != null) queryParameters.put('cnpj', cnpjIe);
        if (uf != null) queryParameters.put('uf', uf);
        return queryParameters;
    } 
    
    public override String getSerializedRequest() {
        return JSON.serialize('');
    }
    
    public override void setDeserializedResponseObject() {
        System.debug('this.requestFactoryInstance.getResponse().getBody():' + this.requestFactoryInstance.getResponse().getBody());
        if (plugin == 'ST') { 
            this.responseTemplate = (GetSintegraWSIntegrableTempate) JSON.deserialize(
                this.requestFactoryInstance.getResponse().getBody(),
                GetSintegraWSIntegrableTempate.class
            );
        } else if (plugin == 'SN') {
            this.responseTemplate = (DW_SintegraResponse_SN) JSON.deserialize(
                this.requestFactoryInstance.getResponse().getBody(),
                DW_SintegraResponse_SN.class
            );
        } else if (plugin == 'RF') {
            this.responseTemplate = (DW_SintegraResponse_RF) JSON.deserialize(
                this.requestFactoryInstance.getResponse().getBody(),
                DW_SintegraResponse_RF.class
            );
        } else if (plugin == 'CPF') {
            this.responseTemplate = (DW_SintegraResponse_CPF) JSON.deserialize(
                this.requestFactoryInstance.getResponse().getBody(),
                DW_SintegraResponse_CPF.class
            );
        }
        System.debug('responseTemplate:' + responseTemplate);
        this.deserializedResponseObject = responseTemplate;
    }
    
    public override void finish() {
        
    }
}