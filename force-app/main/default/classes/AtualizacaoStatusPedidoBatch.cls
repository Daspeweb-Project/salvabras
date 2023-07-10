global without sharing class AtualizacaoStatusPedidoBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
      
    global static void runInSyncMode(Id orderId){
        AtualizacaoStatusPedidoBatch batch = new AtualizacaoStatusPedidoBatch();
        List<SObject> sObjectList = DW_QueryFactory.get('Order')
        .setCondition(DW_QueryCondition.newInstance('StatusIntegracaoLiberacao__c', new List<String>{'Pendente'}))
        .setCondition(DW_QueryCondition.newInstance('Id', '=', orderId))
        .run();
        batch.execute(null, (List<Order>)sObjectList);
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new AtualizacaoStatusPedidoBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('AtualizacaoStatusPedidoBatch ' + cron, cron , new AtualizacaoStatusPedidoBatch());
    }
    
    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('AtualizacaoStatusPedidoBatch ' + cron, cron, new AtualizacaoStatusPedidoBatch());
        }
    }
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%AtualizacaoStatusPedidoBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Order')
            .setCondition(DW_QueryCondition.newInstance('StatusIntegracaoLiberacao__c', new List<String>{'Pendente'}))
            .run();
        return (List<Order>)sObjectList;
    }
    
    public void execute(Database.BatchableContext param1, List<Order> orderList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        for (Order order : orderList){
            HttpRequestLog__c log = new HttpRequestLog__c();
            AtualizacaoStatusPedidoIntegrable atualizacaoIntegrable = new AtualizacaoStatusPedidoIntegrable();
            try {
                atualizacaoIntegrable.callIntegration(order);
                if(DW_Helper.hasSomeContent(atualizacaoIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(atualizacaoIntegrable.requestFactoryInstance.getLog())){
                    log = atualizacaoIntegrable.requestFactoryInstance.getLog();
                }  
                ResponseAtualizacaoStatusPedido responseTemplate = (ResponseAtualizacaoStatusPedido)atualizacaoIntegrable.deserializedResponseObject;
    
                if (responseTemplate.sucesso == 'true') {
                    order.StatusIntegracaoLiberacao__c = 'Executado com sucesso';
                }else{
                    order.StatusIntegracaoLiberacao__c = 'Executado com erro';

                }
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, '@@@AccountIntegrableBatch e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@AccountIntegrableBatch e.getStackTraceString()' + e.getStackTraceString());
                order.StatusIntegracaoLiberacao__c = 'Executado com erro';
            }finally {
                if (atualizacaoIntegrable.requestFactoryInstance.getLog() != null) {
                    log = atualizacaoIntegrable.requestFactoryInstance.getLog();
                }
                log.Order__c = order.Id;
                log.Name = 'Integração liberação do pedido: ' + order.OrderNumber;
                httpRequestLogList.add(log);
            }
        }
        if (httpRequestLogList.size() > 0) {
            insert httpRequestLogList;
        }
        
        List<Database.UpsertResult> upsertResultList = Database.upsert(orderList, false);

    
    }
    
    public void finish(Database.BatchableContext param1) {
    }
}