/**
* Created by guilhermereis on 08/12/2020.
*/

public without sharing class OrderIntegrable extends DW_Integrable {
    
    public override void callIntegration(Object obj){
        this.deserializedRequestObject = (Order)obj;
        this.sendRequest();
    }
    
    public override String constructEndpoint() {
        
        return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndpointCriacaoPedido__c;
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
        this.deserializedResponseObject = (OrderIntegrableResponseTemplate)JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody(),
            OrderIntegrableResponseTemplate.class);
    }
    
    //infelizmente a estrutura dos caras do Protheus é essa, é de chorar... fazer o que..
    ////payload da requisição
    public override String getSerializedRequest(){
        
        System.debug('Start integracao');
        Order order = (Order)this.deserializedRequestObject;
        
        OrderIntegrableRequestTemplate template = new OrderIntegrableRequestTemplate();
        template.PEDIDO = new List<OrderIntegrableRequestTemplate.Pedido>{new OrderIntegrableRequestTemplate.Pedido()};
        template.PEDIDO.get(0).CABECALHO = new OrderIntegrableRequestTemplate.Cabecalho();
        //formação do cabeçalho
        if(!DW_Helper.isNullOrBlank(order.CodigoERP__c)) throw new IllegalArgumentException ('Pedido já integrado. Não é possível uma nova integração.');
        if(order.Status == 'Ativo') throw new IllegalArgumentException ('Pedido Ativo. Não é possível uma nova integração.');
        if(order.FilialFaturamento__c == null) throw new IllegalArgumentException ('Filial de faturamento obrigatória para integração');
        if(DW_Helper.isNullOrBlank(order.FilialFaturamento__r.CodigoEmpresaERP__c)) throw new IllegalArgumentException ('Código da empresa de faturamento obrigatória para integração');
        if(DW_Helper.isNullOrBlank(order.FilialFaturamento__r.CodigoFilialERP__c )) throw new IllegalArgumentException ('Código da filial de faturamento obrigatória para integração');

        if(DW_Helper.isNullOrBlank(order.Account)) throw new IllegalArgumentException ('Cliente obrigatório para integração');
        if(DW_Helper.isNullOrBlank(order.Account.CodigoERP__c)) throw new IllegalArgumentException ('Código ERP (Cliente) obrigatório para integração');
       
       // if(DW_Helper.isNullOrBlank(order.Type)) throw new IllegalArgumentException ('Tipo de venda obrigatório para integração');
        if(DW_Helper.isNullOrBlank(order.CondicaoPagamento__c)) throw new IllegalArgumentException ('Condição de pagamento obrigatória para integração');
        if(DW_Helper.isNullOrBlank(order.CondicaoPagamento__r.CodigoERP__c)) throw new IllegalArgumentException ('Código da condição de pagamento obrigatória para integração');
      //  if(DW_Helper.isNullOrBlank(order.CodigoERPVendedorUsuario__c)) throw new IllegalArgumentException ('Código ERP do vendedor (usuário) obrigatório para integração');
             if(DW_Helper.isNullOrBlank(order.Vendedor__c)) throw new IllegalArgumentException ('Vendedor obrigatório para integração');
        if(DW_Helper.isNullOrBlank(order.Vendedor__r.CodigoERPVendedor__c)) throw new IllegalArgumentException ('Código ERP do vendedor (conta) obrigatório para integração');
        

        
        if(DW_Helper.isNullOrBlank(order.Vendedor__r.CodigoERPVendedor__c)) throw new IllegalArgumentException ('Código do vendedor obrigatório para integração');
        if(DW_Helper.isNullOrBlank(order.TipoFrete__c)) throw new IllegalArgumentException ('Tipo de frete obrigatório para integração');
        if(order.PesoBruto__c <= 0) throw new IllegalArgumentException ('Peso bruto deve ser maior que 0 para integração');
		if(order.PesoLiquido__c <= 0) throw new IllegalArgumentException ('Peso líquido deve ser maior que 0 para integração');
        if(DW_Helper.isNullOrBlank(order.UnidadeMedida__c)) throw new IllegalArgumentException ('Unidade de medida obrigatória para integração');
        if(DW_Helper.isNullOrBlank(order.Natureza__c)) throw new IllegalArgumentException ('Natureza obrigatória para integração');
      	if(DW_Helper.isNullOrBlank(order.Vendedor__r) && DW_Helper.isNullOrBlank(order.Vendedor__r.CodigoERPVendedor__c)) throw new IllegalArgumentException ('Código vendedor obrigatório para integração');
        
  
		List<OrderItem> orderItemList = [SELECT id, Product2.ProductCode FROM OrderItem WHERE OrderId =: order.Id ];
        for(OrderItem orderItem : orderItemList){
            if(DW_Helper.isNullOrBlank(orderItem.Product2.ProductCode)) throw new IllegalArgumentException ('Código ERP do produto obrigatório para integração');
        }
        
        template.PEDIDO.get(0).CABECALHO.CodEmp = order.FilialFaturamento__r.CodigoEmpresaERP__c;
        template.PEDIDO.get(0).CABECALHO.CodFil = order.FilialFaturamento__r.CodigoFilialERP__c;
        template.PEDIDO.get(0).CABECALHO.Loja = '01';
        template.PEDIDO.get(0).CABECALHO.Cliente = order.Account.CodigoERP__c;//código ero do cliente, valor ex C000001 
        
        template.PEDIDO.get(0).CABECALHO.TpCadastro = '3';
        template.PEDIDO.get(0).CABECALHO.Pedido = order.PoNumber;
        template.PEDIDO.get(0).CABECALHO.PresencaCom = '0';
        template.PEDIDO.get(0).CABECALHO.TipoPv = order.Type != null ? order.Type: 'N';
        String codigoTransp = '';
        if(order.Transportadora__r!= null && order.Transportadora__r.CodigoERPTransportadora__c!= null){
            codigoTransp = order.Transportadora__r.CodigoERPTransportadora__c;
		}
        template.PEDIDO.get(0).CABECALHO.Transportadora = codigoTransp;
        template.PEDIDO.get(0).CABECALHO.Cond_ESPACE_Pagto = order.CondicaoPagamento__r.CodigoERP__c  ;
        template.PEDIDO.get(0).CABECALHO.Vendedor2 = order.Vendedor__r.CodigoERPVendedor__c;
        template.PEDIDO.get(0).CABECALHO.Vendedor1 = order.CodigoERPVendedorUsuario__c;
        template.PEDIDO.get(0).CABECALHO.TipoFrete = order.TipoFrete__c.substring(0,1);
        template.PEDIDO.get(0).CABECALHO.PesoBruto = order.PesoBruto__c;
        template.PEDIDO.get(0).CABECALHO.PesoLiquido = order.PesoLiquido__c;
        template.PEDIDO.get(0).CABECALHO.Volume = 0;//todo como preencher volume
        template.PEDIDO.get(0).CABECALHO.Especie = getString(order.UnidadeMedida__c);
        template.PEDIDO.get(0).CABECALHO.MensagemNota = DW_Helper.hasSomeContent(order.ObservacoesNotaFiscal__c) ? getString(order.ObservacoesNotaFiscal__c) : '';
        template.PEDIDO.get(0).CABECALHO.MensagemPadrao = '999';//todo o que é mensagem padrão?
        template.PEDIDO.get(0).CABECALHO.DataEntregaCab = order.EffectiveDate.format();//  '20/09/2021';
        template.PEDIDO.get(0).CABECALHO.Natureza = getString(order.Natureza__c);
        template.PEDIDO.get(0).CABECALHO.PedidoSF = getString(order.OrderNumber);
        System.debug('PedidoSF '+order.id);


        template.PEDIDO.get(0).itens = new List<OrderIntegrableRequestTemplate.Itens>();
        Integer counter = 1;
        List<OrderItem> items = DW_QueryFactory.get('OrderItem')
            .setCondition(DW_QueryCondition.newInstance('OrderId', '=' ,order.Id))
            .run();
        if(items == null || items.size() == 0) throw new IllegalArgumentException ('Pedido deve ter ao menos um produto.');
        for(OrderItem orderItem : items){ 
            OrderIntegrableRequestTemplate.Itens item = new OrderIntegrableRequestTemplate.Itens();
            item.Item = getString(String.valueOf(counter).leftPad(2, '0'));
            item.Produto = orderItem.CodigoERPProduto__c ;
            item.Qtde = orderItem.Quantity;
            item.Preco = orderItem.ValorSemIPI__c;
            item.Operacao = getString(orderItem.TipoOperacao__c);
            item.DataEntrega = order.EffectiveDate.format();
            item.PedidoCliente = order.PoNumber!= null ? order.PoNumber : '';
            template.PEDIDO.get(0).itens.add(item);
            counter++;
        }
        return JSON.serialize(template).replaceAll('_ESPACE_', ' ');
    }
    
    public override void finish() {
        System.debug(LoggingLevel.INFO, '@@@this.finish this.requestFactoryInstance: ' + this.requestFactoryInstance);
        System.debug(LoggingLevel.INFO, '@@@this.finish this.deserializedResponseObject: ' + this.deserializedResponseObject);
    }
    
    
        public  String  getString(String objeto){
    	return getString(objeto, '');
    }
    
    public  String  getString(String objeto, String padrao){
        if(objeto!= null || objeto == ''){
			return removeAcentos(objeto.toUpperCase());
        }else{
            return removeAcentos(padrao.toUpperCase());
        }		
	}
    
    public String removeAcentos(String str){
      str = str.replaceAll('[ÂÀÁÄÃ]','A'); 
      str = str.replaceAll('[ÊÈÉË]','E'); 
      str = str.replaceAll('ÎÍÌÏ','I'); 
      str = str.replaceAll('[ÔÕÒÓÖ]','O'); 
      str = str.replaceAll('[ÛÙÚÜ]','U'); 
      str = str.replaceAll('Ç','C'); 
      str = str.replaceAll('Ý','Y'); 
      str = str.replaceAll('Ñ','N'); 
      return str; 
    }
    
}