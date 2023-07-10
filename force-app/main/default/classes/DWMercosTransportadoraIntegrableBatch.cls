global class  DWMercosTransportadoraIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao transportadora mercos')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            
        .run();
                            
        (new DWMercosTransportadoraIntegrableBatch()).execute(new DWMercosTransportadoraIntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWMercosTransportadoraIntegrableBatch(){
        
    }
    public DWMercosTransportadoraIntegrableBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWMercosTransportadoraIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWMercosTransportadoraIntegrableBatch ' + cron, cron , new DWMercosTransportadoraIntegrableBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWMercosTransportadoraIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        Id recordTypeIdTransportadora = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transportadora').getRecordTypeId();
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracaoMercosTransportadora__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'Pendente', 'Executado com erro',''}))
            .setCondition(DW_QueryCondition.newInstance('recordTypeId', '=', recordTypeIdTransportadora))
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWMercosTransportadoraIntegrableBatch sObjectList' + sObjectList);

        return (List<Account>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<Account> accList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWMercosTransportadoraIntegrableBatch accList' + accList);
        Set<Id> accSet = new Set<Id>();

        for (Account acc : accList){
            accSet.add(acc.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWMercosTransportadoraIntegrable mercosAccountIntegrable = new DWMercosTransportadoraIntegrable();

            System.debug(LoggingLevel.INFO, '@@@DWMercosTransportadoraIntegrableBatch DWMercosAccountIntegrableBatch.requestFactoryInstance.getLog()' + mercosAccountIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(mercosAccountIntegrable.requestFactoryInstance.getLog()) ? mercosAccountIntegrable.requestFactoryInstance.getLog():log;
            try{
                mercosAccountIntegrable.callIntegration(acc);
                
                if ((mercosAccountIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || mercosAccountIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {


                    acc.StatusIntegracaoMercosTransportadora__c = 'Executado com sucesso';
                    if( String.isBlank(acc.CodigoExclusivoTransportadoraMercos__c))acc.CodigoExclusivoTransportadoraMercos__c = mercosAccountIntegrable.requestFactoryInstance.getResponse().getHeader('MeusPedidosID');
                    
                }
                else  if(mercosAccountIntegrable.isError){
                    
                    acc.StatusIntegracaoMercosTransportadora__c = 'Executado com erro';
                    log.ResponseBody__c = mercosAccountIntegrable.errorMessage;
                }
                
            }catch (Exception e){
               
                System.debug(LoggingLevel.ERROR, '@@@DWMercosTransportadoraIntegrableBatch e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@DWMercosTransportadoraIntegrableBatch e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                acc.StatusIntegracaoMercosTransportadora__c = 'Executado com erro';
            }finally {
                string[] headerkeys = mercosAccountIntegrable.requestFactoryInstance.getResponse().getHeaderKeys();
                Map<string, string> headers = new map<string, string>();
                
                for(string s : headerkeys){
                    headers.put(s,mercosAccountIntegrable.requestFactoryInstance.getResponse().getHeader(s));
                }
                if (mercosAccountIntegrable.requestFactoryInstance.getLog() != null) {
                    log = mercosAccountIntegrable.requestFactoryInstance.getLog();
                }
                log.HeadersResponse__c = headers.toString();
                
                log.Conta__c = acc.Id;
                log.Transportadora__c = acc.Id;
                log.Name = acc.Name == null ? 'Integração do mercos ' : 'Integração do mercos : '+acc.Name.abbreviate(50);
                httpRequestLogList.add(log);
                acc.TentativasIntegracaoMercos__c = acc.TentativasIntegracaoMercos__c == null
                    ? 1
                    : acc.TentativasIntegracaoMercos__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@DWMercosTransportadoraIntegrableBatch httpRequestLogList' + httpRequestLogList);

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
            feed.Body = 'Erro ao tentar transportadora mercos. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar transportadora mercos.*' IN ALL FIELDS 
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