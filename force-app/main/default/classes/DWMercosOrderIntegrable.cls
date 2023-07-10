public without sharing class DWMercosOrderIntegrable  extends DW_Integrable {
        public OrderMercosIntegrableResponseTemplate responseTemplate;

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
        Order pedido = (Order)this.deserializedRequestObject;
        if (! String.isBlank(pedido.CodigoExclusivoMercos__c)) {
            String url = DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoPedido__c+'/'+pedido.CodigoExclusivoMercos__c;
            return url;
        }
        return DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoPedido__c;
        
    }
    
    public override String setMethod() {
        Order pedido = (Order)this.deserializedRequestObject;
        
        if (! String.isBlank(pedido.CodigoExclusivoMercos__c)) {
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
        Order pedido = (Order)this.deserializedRequestObject;
        
        Order order  = ((List<Order>) DW_QueryFactory.get('Order')
                        .setCondition(DW_QueryCondition.newInstance('Id', '=', pedido.Id))
                        .withParent('CondicaoPagamento__r','CondicaoPagamento__c')
                        
                        .withParent('Pricebook2', 'Pricebook2')
                        .withParent('Transportadora__r', 'Account')
                        .withParent('Account')
                        .withParent('Opportunity')
                        .run())
                        .get(0);
                        
                        
        if(DW_Helper.isNullOrBlank(order.Account.CodigoExclusivoMercos__c)) throw new IllegalArgumentException('O preenchimento do código mercos da conta é obrigatorio para integração do pedido');
        if(DW_Helper.isNullOrBlank(order.CondicaoPagamento__r.CodigoExclusivoMercos__c)) throw new IllegalArgumentException('O preenchimento do código mercos da Condição de Pagamento é obrigatorio para integração do pedido');
        if(DW_Helper.isNullOrBlank(order.Pricebook2.CodigoExclusivoMercos__c)) throw new IllegalArgumentException('O preenchimento do código mercos da catalogo de preço é obrigatorio para integração do pedido');

        List<OrderItem> orderItemList = [SELECT id, CodigoExclusivoMercos__c,Product2.CodigoExclusivoMercos__c,Quantity,UnitPrice,ListPrice,ValorSemIPI__c FROM OrderItem WHERE OrderId =: order.Id   order by CreatedDate desc];
        
        
        for(OrderItem orderItem : orderItemList){
            if(DW_Helper.isNullOrBlank(orderItem.Product2.CodigoExclusivoMercos__c)) throw new IllegalArgumentException ('Código Mercos do produto obrigatório para integração do pedido');
        }
        OrderMercosIntegrableRequestTemplate requestTemplate = new OrderMercosIntegrableRequestTemplate(); 
      	requestTemplate.cliente_id = Integer.valueOf(order.Account.CodigoExclusivoMercos__c);
        requestTemplate.data_emissao =String.valueOf(order.EffectiveDate).removeEnd(' 00:00:00');
        requestTemplate.data_criacao =String.valueOf(order.createdDate);
        if(! DW_Helper.isNullOrBlank(order.Transportadora__c))requestTemplate.transportadora_id =! DW_Helper.isNullOrBlank(order.Transportadora__r.CodigoExclusivoTransportadoraMercos__c)? Integer.valueOf(order.Transportadora__r.CodigoExclusivoTransportadoraMercos__c): null;
        requestTemplate.condicao_pagamento_id = Integer.valueOf(order.CondicaoPagamento__r.CodigoExclusivoMercos__c);
        requestTemplate.rastreamento =order.Id;
        requestTemplate.observacoes = '';
        List<OrderMercosIntegrableRequestTemplate.cls_itens> itemsRequestList = new List<OrderMercosIntegrableRequestTemplate.cls_itens>();

        for(OrderItem orderItem : orderItemList){
            OrderMercosIntegrableRequestTemplate.cls_itens itemsRequest = new OrderMercosIntegrableRequestTemplate.cls_itens();
            itemsRequest.produto_id = INteger.valueOf(orderItem.Product2.CodigoExclusivoMercos__c);
            itemsRequest.tabela_preco_id = Integer.valueOf(order.Pricebook2.CodigoExclusivoMercos__c);
			itemsRequest.quantidade = Integer.valueOf(orderItem.Quantity);
            itemsRequest.preco_tabela = orderItem.ValorSemIPI__c;
            itemsRequest.observacoes = '';
            if(! DW_Helper.isNullOrBlank(orderItem.CodigoExclusivoMercos__c)) itemsRequest.id = Integer.valueOf(orderItem.CodigoExclusivoMercos__c);
            itemsRequestList.add(itemsRequest);
        } 
        requestTemplate.itens = itemsRequestList;
        String jsonSerialize = JSON.serialize(requestTemplate);
        if(DW_Helper.isNullOrBlank(orderItemList[0].CodigoExclusivoMercos__c)){
            jsonSerialize = JSON.serialize(requestTemplate).replaceAll(',"id":null','');
        }
        
        
        return jsonSerialize;
        
    }
  
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {
this.responseTemplate = (OrderMercosIntegrableResponseTemplate)JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody()
            		, OrderMercosIntegrableResponseTemplate.class
        );
        this.deserializedResponseObject = responseTemplate;
    }
}