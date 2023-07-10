public without sharing class OrdemCarregamentoOportunidadeService {
    List<OrdensCarregamentoPedido__c> ocOppNewList;
    List<OrdensCarregamentoPedido__c> ocOppOldList;
    Map<Id, OrdensCarregamentoPedido__c> ocOppNewMap;
    Map<Id, OrdensCarregamentoPedido__c> ocOppOldMap;
    public OrdemCarregamentoOportunidadeService() {
    }
    public OrdemCarregamentoOportunidadeService(List<OrdensCarregamentoPedido__c> ocOppNewList,
            List<OrdensCarregamentoPedido__c> ocOppOldList,
            Map<Id, OrdensCarregamentoPedido__c> ocOppNewMap,
            Map<Id, OrdensCarregamentoPedido__c> ocOppOldMap) {
        if (ocOppOldList == null) ocOppOldList = new List<OrdensCarregamentoPedido__c>();
        this.ocOppNewList = ocOppNewList;
        this.ocOppOldList = ocOppOldList;
        this.ocOppNewMap = ocOppNewMap;
        this.ocOppOldMap = ocOppOldMap;
    }

    public void incluirOrdemCarragamentoNaOportunidade() {
        Set<Id> oppSet = new Set<Id>();
        List<Order> oppList = new List<Order>();
        for (OrdensCarregamentoPedido__c ordemCarregamentoOpp : this.ocOppNewList) {
            oppSet.add(ordemCarregamentoOpp.Pedido__c);
        }
        if (oppSet.size() == 0) {
            return;
        }
        for (OrdensCarregamentoPedido__c ocOpp : this.ocOppNewList) {
            Order order = new Order(
                    Id = ocOpp.Pedido__c,
                    OrdemCarregamentoPedido__c = ocOpp.Id
            );

            oppList.add(order);
        }
        System.debug('oppList ... ' + oppList);
        update oppList;
    }

    public void criaProdutoOrdemCarregamento() {
        List<OrdemCarregamentoProdutoPedido__c> ocProdutoList = new List<OrdemCarregamentoProdutoPedido__c>();
        Set<Id> oppIdSet = new Set<Id>();
        for (OrdensCarregamentoPedido__c ordemCarregamentoOpp : this.ocOppNewList) {
            oppIdSet.add(ordemCarregamentoOpp.Pedido__c);
        }
        if (oppIdSet.size() == 0) {
            return ;
        }
        Map<Id, Id> ordensCarregamentoOportunidadeMap = new Map<Id, Id>();
        for (OrdensCarregamentoPedido__c ordemCarregamentoOportunidade : this.ocOppNewList) {
            ordensCarregamentoOportunidadeMap.put(ordemCarregamentoOportunidade.Pedido__c, ordemCarregamentoOportunidade.Id);
        }
        Map<Id, Id> ordemCarregamentoMap = new Map<Id, Id>();
        for (OrdensCarregamentoPedido__c ordemCarregamentoOportunidade : this.ocOppNewList) {
            ordemCarregamentoMap.put(ordemCarregamentoOportunidade.Pedido__c, ordemCarregamentoOportunidade.OrdemCarregamento__c);
        }

        List<OrderItem> orderItemList = [
                SELECT
                        AvailableQuantity,
                        CodigoERPProduto__c,
                        CreatedById,
                        CreatedDate,
                        Description,
                        EndDate,
                        Id,
                        IPI__c,
                        IsDeleted,
                        LastModifiedById,
                        LastModifiedDate,
                        ListPrice,
                        OrderId,
                        OrderItemNumber,
                        OriginalOrderItemId,
                        PesoBruto__c,
                        PesoLiquido__c,
                        PesoProdutoKg__c,
                        PricebookEntryId,
                        Product2Id,
                        Quantity,
                        QuoteLineItemId,
                        ServiceDate,
                        SystemModstamp,
                        TipoOperacao__c,
                        TotalPrice,
                        UnitPrice,
                        ValorSemIPI__c
                FROM OrderItem
                WHERE OrderId IN :oppIdSet
        ];


        for (OrderItem orderItem : orderItemList) {
            Id ordemOportunidade = ordensCarregamentoOportunidadeMap.get(orderItem.OrderId);
            Id ordemCarregamento = ordemCarregamentoMap.get(orderItem.OrderId);
            OrdemCarregamentoProdutoPedido__c ordemCarregamentoProdutoOportunidade = new OrdemCarregamentoProdutoPedido__c(
                    OrdemCarregamento__c = ordemCarregamento,
                    ProdutoPedido__c = orderItem.Id,
                    QuantidadeKG__c = orderItem.Quantity,
                    OrdemCarregamentoOportunidade__c = ordemOportunidade
            );
            ocProdutoList.add(ordemCarregamentoProdutoOportunidade);
        }
        insert ocProdutoList;
    }

}