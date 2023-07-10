public without sharing class DWQuoteIntegrable extends DW_Integrable{
    public QuoteIntegrableResponseTemplate responseTemplate;

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
         
            return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndPointConsultaImposto__c;
        
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
        Quote cotacao = (Quote)this.deserializedRequestObject;
        
        Quote quote  = ((List<Quote>) DW_QueryFactory.get('Quote')
                            .setCondition(DW_QueryCondition.newInstance('Id', '=', cotacao.Id))
                            .with('QuoteLineItems')
                        	.withParent('Account')
                        	.withParent('CondicaoPagamento__r','CondicaoPagamento__c')
                    	    .withParent('Pricebook2','Pricebook2')
                            .run())
                            .get(0);
        
        
        List<QuoteLineItem> quoteItemList  = ((List<QuoteLineItem>) DW_QueryFactory.get('QuoteLineItem')
                            .setCondition(DW_QueryCondition.newInstance('QuoteId', '=', cotacao.Id))
                            .withParent('Product2')
                            .run());
                            
        if(quoteItemList.size() ==0 ) throw new IllegalArgumentException('É preciso ter uma linha de cotação para a integração funcionar');
        
        String codigoExclusivoConta = '';
        if(!DW_Helper.isNullOrBlank(cotacao.CodigoExclusivoConta__c)){
            codigoExclusivoConta= cotacao.CodigoExclusivoConta__c;
        }else if(! DW_Helper.isNullOrBlank(quote.Account.CodigoERP__c)){
            codigoExclusivoConta= quote.Account.CodigoERP__c;
        }
        if(DW_Helper.isNullOrBlank(codigoExclusivoConta)) throw new IllegalArgumentException('O preenchimento do Código ERP da conta é obrigatorio');
        
        For(QuoteLineItem quoteLineItem : quoteItemList){
            if(DW_Helper.isNullOrBlank(quoteLineItem.Product2.CodigoERP__c)) throw new IllegalArgumentException('O preenchimento do Código ERP do produto no item do cotação é obrigatorio');
            if(DW_Helper.isNullOrBlank(quoteLineItem.TipoOperacao__c)) throw new IllegalArgumentException('O preenchimento do tipo de operação no item do cotação é obrigatorio');
        }
        
        QuoteIntegrableRequestTemplate requestTemplate = new QuoteIntegrableRequestTemplate();
        requestTemplate.cliente = codigoExclusivoConta;
        //requestTemplate.lojacli = 'quote.Account.LojaCliente__c';
        requestTemplate.lojacli = '01';
        requestTemplate.tipo = 'N';
        
        List<QuoteIntegrableRequestTemplate.cls_itenspedido> listProductsRequest = New List<QuoteIntegrableRequestTemplate.cls_itenspedido>();
        For(QuoteLineItem quoteItem : quoteItemList){
        	QuoteIntegrableRequestTemplate.cls_itenspedido productRequest = New QuoteIntegrableRequestTemplate.cls_itenspedido();    
            productRequest.PRODUTO = quoteItem.Product2.CodigoERP__c;
            productRequest.QTDVEN = Integer.valueOf(quoteItem.Quantity);
            productRequest.PRCVEN = quoteItem.UnitPrice;
            productRequest.VALOR = quoteItem.TotalPrice;
            productRequest.TpOper = quoteItem.TipoOperacao__c;
            
            
            listProductsRequest.add(productRequest);
        }
        requestTemplate.itenspedido = listProductsRequest;
         System.debug(' serielize' +  
                     JSON.serialize(requestTemplate)
                     );
        return JSON.serialize(requestTemplate);
        
    }
  
    public override void setDeserializedResponseObject() {
        System.debug(' this.requestFactoryInstance.getResponse().getBody()_original' +  
                     this.requestFactoryInstance.getResponse().getBody()
                     );
        System.debug(' this.requestFactoryInstance.getResponse().getBody()' +  
                     this.requestFactoryInstance.getResponse().getBody()
                     .replace('01-','')
                     .replace('02-','')
                     .replace('03-','')
                     .replace('04-','')
                     .replace('05-','')
                     .replace('06-','')
                     .replace('07-','')
                     .replace('08-','')
                     .replace('09-','')
                     .replace('10-','')
                     
                     .replace('BASE ICMS','BASE_ICMS')
                     .replace('VL. COFINS','VL_COFINS')
                     .replace('VL ICMS','VL_ICMS')
                     .replace('VALOR NF','VALOR_NF')
                     .replace('VALPS2','VALPS2')
                     .replace('ICMS SOL.','ICMS_SOL')
                     .replace('BASE CALC.','BASE_CALC'));
        this.responseTemplate = (QuoteIntegrableResponseTemplate)JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody()
            		 .replace('01-','')
                     .replace('02-','')
                     .replace('03-','')
                     .replace('04-','')
                     .replace('05-','')
                     .replace('06-','')
                     .replace('07-','')
                     .replace('08-','')
                     .replace('09-','')
                     .replace('10-','')
                     .replace('BASE ICMS','BASE_ICMS')
                     .replace('VL. COFINS','VL_COFINS')
                     .replace('VL ICMS','VL_ICMS')
                     .replace('VALOR NF','VALOR_NF')
                     .replace('VALPS2','VALPS2')
            		 .replace('ICMS SOL.','ICMS_SOL')
                     .replace('BASE CALC.','BASE_CALC'), QuoteIntegrableResponseTemplate.class
        );
        this.deserializedResponseObject = responseTemplate;
    }

    public override void finish() {

    }
}