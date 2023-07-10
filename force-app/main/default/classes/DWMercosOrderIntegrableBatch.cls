global class DWMercosOrderIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao pedido mercos')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Order')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            .with('OrderItems')
        .run();
                            
        (new DWMercosOrderIntegrableBatch()).execute(new DWMercosOrderIntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWMercosOrderIntegrableBatch(){
        
    }
    public DWMercosOrderIntegrableBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWMercosOrderIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWMercosOrderIntegrableBatch ' + cron, cron , new DWMercosOrderIntegrableBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWMercosOrderIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Order')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracaoMercos__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'Pendente', 'Executado com erro',''}))
                        .with('OrderItems')

            .run();
            System.debug(LoggingLevel.INFO, '@@@DWMercosTransportadoraIntegrableBatch sObjectList' + sObjectList);

        return (List<Order>)sObjectList;
    } 
    
    public void execute(Database.BatchableContext param1, List<Order> orderList) {
        List<OrderItem> orderItemForUpdate = new List<OrderItem>();
        
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWMercosTransportadoraIntegrableBatch orderList' + orderList);
        Set<Id> orderSet = new Set<Id>();
        for (Order pedido : orderList){
            orderSet.add(pedido.Id);
        }
        Map<Integer,OrderItem> mapOrderItem = new Map<Integer,OrderItem>();
        List<OrderItem> orderItemList = [SELECT id, Product2.CodigoExclusivoMercos__c,Quantity,UnitPrice,ListPrice FROM OrderItem WHERE OrderId IN :orderSet   order by CreatedDate desc];
        
        
        System.debug('orderItemList'+orderItemList);
        Integer count =1;
        for(OrderItem orderItem :orderItemList ){
            mapOrderItem.put(count,orderItem);
            count = count+1;
            
        }
        System.debug('mapOrderItem: '+mapOrderItem);
        for (Order pedido : orderList){
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWMercosOrderIntegrable mercosOrderIntegrable = new DWMercosOrderIntegrable();

            System.debug(LoggingLevel.INFO, '@@@mercosOrderIntegrable DWMercosAccountIntegrableBatch.requestFactoryInstance.getLog()' + mercosOrderIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(mercosOrderIntegrable.requestFactoryInstance.getLog()) ? mercosOrderIntegrable.requestFactoryInstance.getLog():log;
            try{
                mercosOrderIntegrable.callIntegration(pedido);
                if(mercosOrderIntegrable.isError){
                    
                    pedido.StatusIntegracaoMercos__c = 'Executado com erro';
                    log.ResponseBody__c = mercosOrderIntegrable.errorMessage;
                }
                if ((mercosOrderIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || mercosOrderIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    OrderMercosIntegrableResponseTemplate responseTemplate = (OrderMercosIntegrableResponseTemplate)mercosOrderIntegrable.deserializedResponseObject;
                    Integer countIntegrable = 1;
                    
                    if( String.isBlank(pedido.CodigoExclusivoMercos__c))pedido.CodigoExclusivoMercos__c = String.valueOf(responseTemplate.id);
                    pedido.StatusIntegracaoMercos__c = 'Executado com sucesso';
                    for(OrderMercosIntegrableResponseTemplate.cls_itens itemProduts : responseTemplate.itens){
                        System.debug('countIntegrable: '+countIntegrable);
                        OrderItem orderItem = new OrderItem();
                        orderItem.id = mapOrderItem.get(countIntegrable).Id;
                        if( String.isBlank(orderItem.CodigoExclusivoMercos__c))orderItem.CodigoExclusivoMercos__c = String.valueOf(itemProduts.id);
                        orderItemForUpdate.add(orderItem);
                       countIntegrable = countIntegrable+1;
                    }
                    
                    
                }
                
                
            }catch (Exception e){
               
                System.debug(LoggingLevel.ERROR, '@@@OrderMercosIntegrableResponseTemplate e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@OrderMercosIntegrableResponseTemplate e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                pedido.StatusIntegracaoMercos__c = 'Executado com erro';
            }finally {
                string[] headerkeys = mercosOrderIntegrable.requestFactoryInstance.getResponse().getHeaderKeys();
                Map<string, string> headers = new map<string, string>();
                
                for(string s : headerkeys){
                    headers.put(s,mercosOrderIntegrable.requestFactoryInstance.getResponse().getHeader(s));
                }
                if (mercosOrderIntegrable.requestFactoryInstance.getLog() != null) {
                    log = mercosOrderIntegrable.requestFactoryInstance.getLog();
                }
                log.HeadersResponse__c = headers.toString();
                
                log.ORder__c = pedido.Id;
                log.Name = 'Tentativa de integração pedido mercos ' + order.OrderNumber;
                httpRequestLogList.add(log);
                pedido.TentativasIntegracaoMercos__c = pedido.TentativasIntegracaoMercos__c == null
                    ? 1
                    : pedido.TentativasIntegracaoMercos__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@OrderMercosIntegrableResponseTemplate httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        update orderItemForUpdate;
        
        Map<Id, String> accToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(orderList, false);
        
        for (Integer i = 0; i < orderList.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            ORder origRecord = orderList[i];
            if (!upsertResult.isSuccess()) {
                accToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
             

        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : accToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar pedido mercos. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar pedido mercos.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :orderSet)];
        List<FeedItem> feedItemList = (List<FeedItem>)searchList[0];
        if(feedItemList.size() > 0){
            delete feedItemList;
        }
        
        insert feedItemListToInsert;
    }
    
    public void finish(Database.BatchableContext param1) {
    }    
    public class BatchContext implements Database.BatchableContext {

        public Id getChildJobId() {
            return null;
        }

        public Id getJobId() {
            return null;
        }
    }

}