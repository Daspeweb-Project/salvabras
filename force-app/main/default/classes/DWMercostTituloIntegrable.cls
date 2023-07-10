public without sharing class DWMercostTituloIntegrable extends DW_Integrable {

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
        Titulo__c titulo = (Titulo__c)this.deserializedRequestObject;
        if (! String.isBlank(titulo.CodigoExclusivoMercos__c)) {
            String url = DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoTitulos__c+'/'+titulo.CodigoExclusivoMercos__c;
            return url;
        }
        return DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoTitulos__c;
        
    }
    
    public override String setMethod() {
        Titulo__c titulo = (Titulo__c)this.deserializedRequestObject;
        
        if (! String.isBlank(titulo.CodigoExclusivoMercos__c)) {
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
        Titulo__c tituloObj = (Titulo__c)this.deserializedRequestObject;
        Account ac = [SELECT ID,CodigoExclusivoMercos__c FROM Account WHERE Id = :tituloObj.Conta__c];
        
        if(DW_Helper.isNullOrBlank(tituloObj.Conta__c)) throw new IllegalArgumentException('O preenchimento da conta da Titulo é obrigatorio');
        if(DW_Helper.isNullOrBlank(ac.CodigoExclusivoMercos__c)) throw new IllegalArgumentException('O preenchimento do código Mercos da conta do Titulo é obrigatorio');
        if(DW_Helper.isNullOrBlank(tituloObj.Name)) throw new IllegalArgumentException('O preenchimento do Numero do Titulo é obrigatorio');
        if(DW_Helper.isNullOrBlank(tituloObj.DataVencimentoReal__c)) throw new IllegalArgumentException('O preenchimento do Data vencimento Real do Titulo é obrigatorio');
        if(DW_Helper.isNullOrBlank(tituloObj.Valor__c)) throw new IllegalArgumentException('O preenchimento do Valor do Titulo é obrigatorio');
        TituloMercosIntegrableRequestTemplate requestTemplate = new TituloMercosIntegrableRequestTemplate(); 
        requestTemplate.cliente_id = Integer.valueOf(ac.CodigoExclusivoMercos__c);
        requestTemplate.data_vencimento = String.valueOf(tituloObj.DataVencimentoReal__c).removeEnd(' 00:00:00');
        requestTemplate.numero_documento = tituloObj.Name;
        requestTemplate.observacao = ! DW_Helper.isNullOrBlank(tituloObj.Tipo__c)?'Tipo: ' +tituloObj.Tipo__c : '';
		requestTemplate.valor = tituloObj.Valor__c;
        
        return JSON.serialize(requestTemplate);
        
    }
  
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {

    }
}