global class DWMercosProduct2IntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao pre produto')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Product2')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            
        .run();
                            
        (new DWMercosProduct2IntegrableBatch()).execute(new DWMercosProduct2IntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWMercosProduct2IntegrableBatch(){
        
    }
 
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWMercosProduct2IntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWMercosProduct2IntegrableBatch ' + cron, cron , new DWMercosProduct2IntegrableBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWMercosAccountIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Product2')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracaoMercos__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'Pendente', 'Executado com erro',''}))
           // .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 30))
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWMercosProduct2IntegrableBatch sObjectList' + sObjectList);

        return (List<PRoduct2>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<Product2> product2List) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWMercosProduct2IntegrableBatch product2List' + product2List);
        Set<Id> product2Set = new Set<Id>();

        for (Product2 produto : product2List){
            product2Set.add(produto.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWMercosProduct2Integrable mercosProduct2Integrable = new DWMercosProduct2Integrable();

            System.debug(LoggingLevel.INFO, '@@@DWMercosProduct2IntegrableBatch DWMercosProduct2IntegrableBatch.requestFactoryInstance.getLog()' + mercosProduct2Integrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(mercosProduct2Integrable.requestFactoryInstance.getLog()) ? mercosProduct2Integrable.requestFactoryInstance.getLog():log;
            try{
                mercosProduct2Integrable.callIntegration(produto);
                
                if ((mercosProduct2Integrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || mercosProduct2Integrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    produto.StatusIntegracaoMercos__c = 'Executado com sucesso';
                    if( String.isBlank(produto.CodigoExclusivoMercos__c))produto.CodigoExclusivoMercos__c = mercosProduct2Integrable.requestFactoryInstance.getResponse().getHeader('MeusPedidosID');
                    
                }
                else  if(mercosProduct2Integrable.isError){
                    
                    produto.StatusIntegracaoMercos__c = 'Executado com erro';
                    log.ResponseBody__c = mercosProduct2Integrable.errorMessage;
                }
                
            }catch (Exception e){
               
                System.debug(LoggingLevel.ERROR, '@@@mercosProduct2Integrable e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@mercosProduct2Integrable e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                produto.StatusIntegracaoMercos__c = 'Executado com erro';
            }finally {
                string[] headerkeys = mercosProduct2Integrable.requestFactoryInstance.getResponse().getHeaderKeys();
                Map<string, string> headers = new map<string, string>();
                
                for(string s : headerkeys){
                    headers.put(s,mercosProduct2Integrable.requestFactoryInstance.getResponse().getHeader(s));
                }
                if (mercosProduct2Integrable.requestFactoryInstance.getLog() != null) {
                    log = mercosProduct2Integrable.requestFactoryInstance.getLog();
                }
                log.HeadersResponse__c = headers.toString();
                
                log.Produto__c = produto.Id;
                log.Name = produto.Name == null ? 'Integração do produto mercos ' : 'Integração do produto mercos : '+produto.Name.abbreviate(50);
                httpRequestLogList.add(log);
                produto.TentativasIntegracaoMercos__c = produto.TentativasIntegracaoMercos__c == null
                    ? 1
                    : produto.TentativasIntegracaoMercos__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@mercosProduct2Integrable httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        Map<Id, String> accToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(product2List, false);
        
        
        for (Integer i = 0; i < product2List.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            Product2 origRecord = product2List[i];
            if (!upsertResult.isSuccess()) {
                accToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
             

        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : accToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar enviar produto para o Mercos. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar enviar produto para o Mercos.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :product2Set)];
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