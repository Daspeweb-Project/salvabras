global class DWPreAccountIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao pre conta')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            
        .run();
                            
        (new DWPreAccountIntegrableBatch()).execute(new DWPreAccountIntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWPreAccountIntegrableBatch(){
        
    }
    public DWPreAccountIntegrableBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWPreAccountIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWPreAccountIntegrableBatch ' + cron, cron , new DWPreAccountIntegrableBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWPreAccountIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracao__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'Pendente', 'Executado com erro'}))
           // .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 30))
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWPreAccountIntegrableBatch sObjectList' + sObjectList);

        return (List<Account>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<Account> accList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWPreAccountIntegrableBatch accList' + accList);
        Set<Id> accSet = new Set<Id>();

        for (Account acc : accList){
            accSet.add(acc.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWPreAccountIntegrable preAccountIntegrable = new DWPreAccountIntegrable();

            System.debug(LoggingLevel.INFO, '@@@DWPreAccountIntegrableBatch DWPreAccountIntegrable.requestFactoryInstance.getLog()' + preAccountIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(preAccountIntegrable.requestFactoryInstance.getLog()) ? preAccountIntegrable.requestFactoryInstance.getLog():log;
            try{
                preAccountIntegrable.callIntegration(acc);
                System.debug(LoggingLevel.INFO, '@@@preAccountIntegrable this.isError' + preAccountIntegrable.isError);

                System.debug(LoggingLevel.INFO, '@@@preAccountIntegrable preAccountIntegrable.responseTemplate' + preAccountIntegrable.responseTemplate);
                if(preAccountIntegrable.isError){
                    acc.StatusIntegracao__c = 'Executado com erro';
                    log.ResponseBody__c = preAccountIntegrable.errorMessage;
                }
                //pre  account
                else if ((preAccountIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || preAccountIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    DWPreAccountResponseTemplate responseTemplate = (DWPreAccountResponseTemplate)preAccountIntegrable.deserializedResponseObject;
                    acc.StatusIntegracao__c = 'Executado com sucesso';
                    acc.CodigoERP__c = responseTemplate.A1_COD;
                    
                }
                
            }catch (Exception e){
                System.debug(LoggingLevel.ERROR, '@@@preAccountIntegrable e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@preAccountIntegrable e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                acc.StatusIntegracao__c = 'Executado com erro';
            }finally {
                if (preAccountIntegrable.requestFactoryInstance.getLog() != null) {
                    log = preAccountIntegrable.requestFactoryInstance.getLog();
                }
                log.Conta__c = acc.Id;
                log.Name = acc.Name == null ? 'Integração da pré conta ' : 'Integração da pré conta : '+acc.Name.abbreviate(50);
                httpRequestLogList.add(log);
                acc.TentativasIntegracao__c = acc.TentativasIntegracao__c == null
                    ? 1
                    : acc.TentativasIntegracao__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@DWPreAccountIntegrableBatch httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        Map<Id, String> accToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(accList, false);
        
        
        for (Integer i = 0; i < accList.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            Account origRecord = accList[i];
            if (!upsertResult.isSuccess()) {
                accToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
             

        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : accToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar enviar pré conta para o ERP. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar enviar pré conta para o ERP.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :accSet)];
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