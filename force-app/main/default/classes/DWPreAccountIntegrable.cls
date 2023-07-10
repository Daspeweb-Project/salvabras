public without sharing class DWPreAccountIntegrable  extends DW_Integrable {
	public DWPreAccountResponseTemplate responseTemplate;

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
         
            return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndPointCriacaoPreCadastro__c;
        
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
        Account ac = (Account)this.deserializedRequestObject;
        
        
        
        if(DW_Helper.isNullOrBlank(ac.tipo_pessoa_conta__c)) throw new IllegalArgumentException('O preenchimento do Tipo pessoa da conta é obrigatorio');
        if(DW_Helper.isNullOrBlank(ac.Type)) throw new IllegalArgumentException('O preenchimento do Tipo da conta é obrigatorio');
        if(DW_Helper.isNullOrBlank(ac.Name)) throw new IllegalArgumentException('O preenchimento do nome da conta é obrigatorio');
        if(DW_Helper.isNullOrBlank(ac.Nome_Abreviado__c)) throw new IllegalArgumentException('O preenchimento do nome Abreviado da conta é obrigatorio');
        
        if(DW_Helper.isNullOrBlank(ac.BillingPostalCode)) throw new IllegalArgumentException('O preenchimento do CEP da cobrança da conta é obrigatorio');
        if(DW_Helper.isNullOrBlank(ac.BillingStreet)) throw new IllegalArgumentException('O preenchimento da Rua de cobrança da conta é obrigatorio');
        if(DW_Helper.isNullOrBlank(ac.BairroCobranca__c)) throw new IllegalArgumentException('O preenchimento do Bairro Cobrança da conta é obrigatorio');
        if(DW_Helper.isNullOrBlank(ac.BillingCity)) throw new IllegalArgumentException('O preenchimento da Cidade Cobrança da conta é obrigatorio');
        if(! DW_Helper.isNullOrBlank(ac.CodigoERP__C)) throw new IllegalArgumentException('A integração do pré cadastro já aconteceu.');
        if(DW_Helper.isNullOrBlank(ac.BillingState)) throw new IllegalArgumentException('O preenchimento do Estado de Cobrança da conta é obrigatorio');
        
        
        
        AccountPreIntegrableRequestTemplate requestTemplate = new AccountPreIntegrableRequestTemplate();
        requestTemplate.A1_PESSOA = ac.tipo_pessoa_conta__c.substring(0,1);
        requestTemplate.A1_TIPO = ac.Type.substring(0,1);
        requestTemplate.A1_NOME = ac.Name;
        requestTemplate.A1_NREDUZ = ac.Nome_Abreviado__c;
        requestTemplate.A1_CGC = ac.Documento__c != '' ? ac.Documento__c.replaceAll('[^0-9]', '') : '';
        requestTemplate.A1_CEP = ac.BillingPostalCode.replaceAll('[^0-9]', '');
        requestTemplate.A1_END = ac.BillingStreet;
        requestTemplate.A1_BAIRRO = ac.BairroCobranca__c;
        requestTemplate.A1_MUN = ac.BillingCity;
        requestTemplate.A1_EST = ac.BillingState;
       
        
         System.debug(' serielize' +  
                     JSON.serialize(requestTemplate)
                     );
        return JSON.serialize(requestTemplate);
        
    }
  
    public override void setDeserializedResponseObject() {
       
        this.responseTemplate = (DWPreAccountResponseTemplate)JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody()
                     , DWPreAccountResponseTemplate.class
        );
        this.deserializedResponseObject = responseTemplate;
    }

    public override void finish() {

    }
}