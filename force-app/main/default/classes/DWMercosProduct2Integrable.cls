public without sharing class DWMercosProduct2Integrable extends DW_Integrable {

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    public override String constructEndpoint() {
        Product2 produto = (Product2)this.deserializedRequestObject;
        if (! String.isBlank(produto.CodigoExclusivoMercos__c)) {
            String url = DaspeMicroservicoHelperMercos.getInstance().mercosMicroservico.EndPointCriacaoProduto__c+'/'+produto.CodigoExclusivoMercos__c;
            return url;
        }
        return DaspeMicroservicoHelperMercos.getInstance().mercosMicroservico.EndPointCriacaoProduto__c;
        
    }
    
    public override String setMethod() {
        Product2 produto = (Product2)this.deserializedRequestObject;
        
        if (! String.isBlank(produto.CodigoExclusivoMercos__c)) {
            return 'PUT';
        }
        return 'POST';
    }
    
    public override Map<String, String> constructHeaders() {
        return new Map<String, String>{
            'Content-Type' => 'application/json',
                'ApplicationToken' =>DaspeMicroservicoHelperMercos.getInstance().mercosMicroservico.ApplicationToken__c,
                'CompanyToken' => DaspeMicroservicoHelperMercos.getInstance().mercosMicroservico.CompanyToken__c
                };
                    }
 
    public override Map<String, String> constructQueryParameters() {
        return new Map<String, String>();
    }

    public override String getSerializedRequest() {
        Product2 produto = (Product2)this.deserializedRequestObject;
        
        Pricebook2 pricebookPadrao = [select Id from Pricebook2 where isStandard=true limit 1];
        List<PricebookEntry> listPricebookEntry = [SELECT ID,UnitPrice FROM PricebookEntry WHERE Product2Id = : produto.Id AND Pricebook2Id =:pricebookPadrao.Id];
        if(DW_Helper.isNullOrBlank(produto.Name)) throw new IllegalArgumentException('O preenchimento do nome da produto é obrigatorio');
        
        
        
        Product2MercosIntegrableRequestTemplate requestTemplate = new Product2MercosIntegrableRequestTemplate(); 
        requestTemplate.nome = produto.Name;
        requestTemplate.preco_tabela = listPricebookEntry.size()>0 ?listPricebookEntry[0].UnitPrice:0;
        requestTemplate.preco_minimo = null;
        requestTemplate.codigo = produto.ProductCode;
        requestTemplate.comissao = null;
        requestTemplate.ipi = ! DW_Helper.isNullOrBlank(produto.ipi__c) ? produto.ipi__c: null;
        requestTemplate.tipo_ipi = 'P';
        requestTemplate.st = null;
        requestTemplate.moeda = '0';
        requestTemplate.grade_cores = null;
        requestTemplate.grade_tamanhos = null;
        requestTemplate.unidade = ! DW_Helper.isNullOrBlank(produto.Embalagem_Master__c) ? (produto.Embalagem_Master__c.length() >10 ? produto.Embalagem_Master__c.substring(0,10) : produto.Embalagem_Master__c ): '' ;
        requestTemplate.observacoes = ! DW_Helper.isNullOrBlank(produto.Description) ? produto.Description: '' ;
        requestTemplate.ativo=produto.isActive;
        requestTemplate.codigo_ncm= String.valueOf(produto.NCM__c);
        requestTemplate.peso_bruto = produto.Peso_KG__c;
        requestTemplate.largura = produto.Largura__c;
        requestTemplate.altura = produto.Altura__c;
        requestTemplate.comprimento = produto.Comprimento__c;
        requestTemplate.peso_dimensoes_unitario = true;
        requestTemplate.exibir_no_b2b = true;
        return JSON.serialize(requestTemplate);
        
    }
  
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {

    }
}