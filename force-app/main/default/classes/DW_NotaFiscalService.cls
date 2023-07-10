public without sharing class DW_NotaFiscalService {
    List<NotaFiscal__c> notaFiscaltNewList;
    List<NotaFiscal__c> notaFiscaltOldList;
    Map<Id, NotaFiscal__c> notaFiscaltNewMap;
    Map<Id, NotaFiscal__c> notaFiscaltOldMap;

    public DW_NotaFiscalService(List<NotaFiscal__c> notaFiscaltNewList, List<NotaFiscal__c> notaFiscaltOldList,
                                Map<Id, NotaFiscal__c> notaFiscaltNewMap, Map<Id, NotaFiscal__c> notaFiscaltOldMap) {
                                    if(notaFiscaltOldList == null) notaFiscaltOldList = new List<NotaFiscal__c>();
                                    if(notaFiscaltNewMap == null) notaFiscaltNewMap = new Map<Id, NotaFiscal__c>();
                                    this.notaFiscaltNewList = notaFiscaltNewList;
                                    this.notaFiscaltOldList = notaFiscaltOldList;
                                    this.notaFiscaltNewMap = notaFiscaltNewMap;
                                    this.notaFiscaltOldMap = notaFiscaltOldMap;
                                }

    public void persisteAccNF(){
        verificaCriaContaHistoricoNF();
        verificaCriaPedidoHistoricoNF();
        ajustaContaPedidoComNF();
        ajustaNumeroSerieNF();
    }

    public void ajustaContaPedidoComNF(){
        for (NotaFiscal__c nf : notaFiscaltNewList){
            if(nf.CodigoContaERP__c != null && nf.Conta__r.CodigoERP__c != null ){
                List<Account> accList = getAccByCodigoERP(nf.CodigoContaERP__c);
                if(accList.size()>0){
                    nf.Conta__c = accList.get(0).id;
                }else{
                    System.debug(LoggingLevel.ERROR, '@@DW_NotaFiscalService.ajustaAccNF() e.getMessage: ' + 'Erro ao perssitir conta na NF');
                }
            }
            if(nf.CodigoPedido__c != null){
                List<Order> orderList = getOrderByCodigoERP(nf.CodigoPedido__c);
                if(orderList.size()>0){
                    nf.Pedido__c = orderList.get(0).id;
                }else{
                    System.debug(LoggingLevel.ERROR, '@@DW_NotaFiscalService.ajustaAccNF() e.getMessage: ' + 'Erro ao perssitir conta na NF');
                }
            }
        }
    }

    public void verificaCriaContaHistoricoNF(){
        List<Account> listaContaERP = new List<Account>();
        for (NotaFiscal__c nf : notaFiscaltNewList){
            if(nf.CodigoContaERP__c != null && nf.Conta__r.CodigoERP__c != null){
                List<Account> accList = getAccByCodigoERP(nf.CodigoContaERP__c);
                if(accList.size() == 0){
                    Account acc = criarContaHistoricoNF(nf.CodigoContaERP__c);
                    listaContaERP.add(acc);
                }
            }
        }
        insert listaContaERP;
    }

    public void verificaCriaPedidoHistoricoNF(){
        List<Order> listaOrderERP = new List<Order>();
        for (NotaFiscal__c nf : notaFiscaltNewList){
            if(nf.CodigoPedido__c != null && nf.Conta__r.CodigoERP__c != null){
                List<Order> orderList = getOrderByCodigoERP(nf.CodigoPedido__c);
                if(orderList != null && orderList.size() == 0){
                    Order pedido = criarPedidoHistoricoNF(nf.CodigoPedido__c, nf.CodigoContaERP__c);
                    listaOrderERP.add(pedido);
                }
            }
        }
        insert listaOrderERP;
    }

    public Account criarContaHistoricoNF(String codigoERP){
        Account acc = new Account();
        acc.Name = 'Conta Histórico NF';
        acc.CodigoERP__c = codigoERP;
        return acc;
    }

    public Order criarPedidoHistoricoNF(String codigoERP, String codigoConta){
        Account conta = getAccByCodigoERP(codigoConta).get(0);
        Order order = new Order();
        order.Name = 'Pedido Histórico NF';
        order.CodigoERP__c = codigoERP;
        order.AccountId = conta.id;
        order.Status = 'Rascunho';
        order.EffectiveDate = date.today();
        return order;
    }

    public List<Account> getAccByCodigoERP(String codigoERP){
        List<Account> accList = DW_QueryFactory.get('Account').setCondition(DW_QueryCondition.newInstance('CodigoERP__c', new List<String>{codigoERP})).run();
        return accList;
    }

    public List<Order> getOrderByCodigoERP(String codigoERP){
        List<Order> orderList = DW_QueryFactory.get('Order').setCondition(DW_QueryCondition.newInstance('CodigoERP__c', new List<String>{codigoERP})).run();
        return orderList;
    }


    public void ajustaNumeroSerieNF(){
        for (NotaFiscal__c nf : notaFiscaltNewList){
            if(nf.Numero__c == null && nf.Name!= null && nf.Name.contains('/')){
                String[] name = nf.Name.split('/');
                String numeroStr = name[0];
                String serie = name[1];
                if(numeroStr!= null){
                    nf.Numero__c = numeroStr;
                }

                if(serie!= null){
                    nf.Serie__c = serie;
                }
            }
        }
    }
}