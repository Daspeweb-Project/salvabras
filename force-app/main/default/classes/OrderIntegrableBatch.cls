/**
* Created by guilhermereis on 14/12/2020.
*/

global with sharing class OrderIntegrableBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    global static void runInSyncMode(Id orderId){
        System.debug('Integração pedido '+orderId);
        OrderIntegrableBatch batch = new OrderIntegrableBatch();
        List<SObject> sObjectList = DW_QueryFactory.get('Order')
            .setCondition(DW_QueryCondition.newInstance('Id', '=', orderId))
            .setCondition(DW_QueryCondition.newInstance('StatusIntegracao__c', new List<String>{'Pendente', 'Executado com erro'}))
            .setCondition(DW_QueryCondition.newInstance('Status','=','Rascunho'))
            .setCondition(DW_QueryCondition.newInstance('CodigoERP__c', '=', ''))
            .withParent('CondicaoPagamento__r')
            .withParent('FilialFaturamento__r')
            .withParent('EnderecoEntrega__r')
            .withParent('Vendedor__r', 'Account')
            .withParent('Transportadora__r', 'Account')
            .withParent('Account')
            .withParent('Opportunity')
            .run();
        batch.execute(null, (List<Order>)sObjectList);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('OrderIntegrableBatch ' + cron, cron , new OrderIntegrableBatch());
    }
    
    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('OrderIntegrableBatch ' + cron, cron, new OrderIntegrableBatch());
        }
    }
    
    global static void runEveryNMinutesInBusinessHours(Integer each) {
        for (Integer minute = 0; minute < 60; minute += each){
            for (Integer hour = 0; hour <= 23; hour ++){
                if(hour > 8 && hour < 20 && !Test.isRunningTest()){
                    String cron = '0 ' + minute + ' ' + hour + ' * * ?';
                    System.schedule('OrderIntegrableBatch ' + cron, cron, new OrderIntegrableBatch());
                }
            }
        }
    }
    
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%OrderIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
        }
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new OrderIntegrableBatch());
    }
    
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Order')
            .setCondition(DW_QueryCondition.newInstance('StatusIntegracao__c', new List<String>{'Pendente', 'Executado com erro'}))
            .setCondition(DW_QueryCondition.newInstance('Status','=','Rascunho'))
            .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 3))
            .setCondition(DW_QueryCondition.newInstance('CodigoERP__c', '=', ''))
            .withParent('CondicaoPagamento__r')
            .withParent('FilialFaturamento__r')
            .withParent('EnderecoEntrega__r')
            .withParent('Vendedor__r', 'Account')
            .withParent('Transportadora__r', 'Account')
            .withParent('Account')
            .withParent('Opportunity')
            .run();
        return (List<Order>)sObjectList;
    }
    
    public void execute(Database.BatchableContext param1, List<Order> orderList) {
        Set<String> recipientsIds = null;
        Set<Id> orderSet = new Set<Id>();
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        for (Order order : orderList){
            orderSet.add(order.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            try{
                OrderIntegrable orderIntegrable = new OrderIntegrable();
                orderIntegrable.callIntegration(order);
                if(DW_Helper.hasSomeContent(orderIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(orderIntegrable.requestFactoryInstance.getLog())){
                    log = orderIntegrable.requestFactoryInstance.getLog();
                }
                if(orderIntegrable.isSuccess){
                    OrderIntegrableResponseTemplate responseTemplate = (OrderIntegrableResponseTemplate)orderIntegrable.deserializedResponseObject;
                    if (responseTemplate != null && responseTemplate.Retorno != null  && responseTemplate.Retorno.size() == 1) {
                        if(DW_Helper.hasSomeContent(responseTemplate.Retorno[0].Pedido)){
                            order.CodigoERP__c = responseTemplate.Retorno[0].Pedido;
                            order.Status = 'Ativado';
                            order.StatusIntegracao__c = 'Executado com sucesso';
                            order.TentativasIntegracao__c = 0;
                        }
                    }else{
                        order.StatusIntegracao__c = 'Executado com erro';
                        log.ResponseBody__c = 'Erro na formação da requisição. ' + orderIntegrable.errorMessage;
                        recipientsIds = new Set<String>(); 
                        recipientsIds.add(order.OwnerId);
                        List<User> UsersAdmin = [SELECT id FROM USER WHERE Notificar__c = true];
                        for(User user : UsersAdmin){
                            recipientsIds.add(user.id);
                        }
                        CustomNotification.notifyUsers(recipientsIds, order.Id, 'Pedido', order.OrderNumber); 
                    }
                }else{
                    order.StatusIntegracao__c = 'Executado com erro';
                    log.ResponseBody__c = 'Erro na formação da requisição. ' + orderIntegrable.errorMessage;
                    recipientsIds = new Set<String>(); 
                    recipientsIds.add(order.OwnerId);
                    List<User> UsersAdmin = [SELECT id FROM USER WHERE Notificar__c = true];
                    for(User user : UsersAdmin){
                        recipientsIds.add(user.id);
                    }
                    CustomNotification.notifyUsers(recipientsIds, order.Id, 'Pedido', order.OrderNumber);
                }
            }catch (Exception e){
                log.ResponseBody__c = e.getMessage() + '/n' + e.getStackTraceString();
                System.debug(LoggingLevel.ERROR, '@@OrderIntegrableBatch.execute() e.getMessage: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@OrderIntegrableBatch.execute() e.getCause: ' + e.getCause());
                System.debug(LoggingLevel.ERROR, '@@OrderIntegrableBatch.execute() e.getLineNumber: ' + e.getLineNumber());
                System.debug(LoggingLevel.ERROR, '@@OrderIntegrableBatch.execute() e.getStackTraceString: ' + String.valueOf(e.getStackTraceString()));
                recipientsIds = new Set<String>(); 
                recipientsIds.add(order.OwnerId);
                List<User> UsersAdmin = [SELECT id FROM USER WHERE Notificar__c = true];
                for(User user : UsersAdmin){
                    recipientsIds.add(user.id);
                }
                CustomNotification.notifyUsers(recipientsIds, order.Id, 'Pedido', order.OrderNumber); 
            }finally {
                log.Order__c = order.Id;
                log.Name = 'Tentativa de integração pedido ' + order.OrderNumber;
                if(order.TentativasIntegracao__c == null){
                    order.TentativasIntegracao__c = 1;
                }else{
                    order.TentativasIntegracao__c ++;
                }
                httpRequestLogList.add(log);
            }
        }
        
        if (httpRequestLogList.size() > 0) {
            insert httpRequestLogList;
        }
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(orderSet, orderList, 'Erro ao tentar enviar pedido para o ERP. ');
    }
    
    public void finish(Database.BatchableContext param1) {
    }
}