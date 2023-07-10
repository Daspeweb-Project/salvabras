global class DWMercosPbEntryPrecoIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao pre entrada de preço')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('PricebookEntry')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            
        .run();
                            
        (new DWMercosPbEntryPrecoIntegrableBatch()).execute(new DWMercosPbEntryPrecoIntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWMercosPbEntryPrecoIntegrableBatch(){
        
    }
    public DWMercosPbEntryPrecoIntegrableBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWMercosPbEntryPrecoIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWMercosPbEntryPrecoIntegrableBatch ' + cron, cron , new DWMercosPbEntryPrecoIntegrableBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWMercosPbEntryPrecoIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('PricebookEntry')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracaoMercos__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'','Pendente', 'Executado com erro'})
            ).setCondition(DW_QueryCondition.newInstance('IsActive','=',true))            
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWMercosPbEntryPrecoIntegrableBatch sObjectList' + sObjectList);

        return (List<PricebookEntry>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<PricebookEntry> pricebookEntryList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWMercosPbEntryPrecoIntegrableBatch pricebookEntryList' + pricebookEntryList);
        Set<Id> pricebookEntrySet = new Set<Id>();

        for (PricebookEntry catalogoEntradaPreco : pricebookEntryList){
            pricebookEntrySet.add(catalogoEntradaPreco.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWMercosEntradaTabelaPrecoIntegrable mercosPricebookEntryIntegrable = new DWMercosEntradaTabelaPrecoIntegrable();

            System.debug(LoggingLevel.INFO, '@@@DWMercosPbEntryPrecoIntegrableBatch DWMercosPbEntryPrecoIntegrableBatch.requestFactoryInstance.getLog()' + mercosPricebookEntryIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(mercosPricebookEntryIntegrable.requestFactoryInstance.getLog()) ? mercosPricebookEntryIntegrable.requestFactoryInstance.getLog():log;
            try{
                mercosPricebookEntryIntegrable.callIntegration(catalogoEntradaPreco);
                
                if ((mercosPricebookEntryIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || mercosPricebookEntryIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    catalogoEntradaPreco.StatusIntegracaoMercos__c = 'Executado com sucesso';
                    if( String.isBlank(catalogoEntradaPreco.CodigoExclusivoMercos__c))catalogoEntradaPreco.CodigoExclusivoMercos__c = mercosPricebookEntryIntegrable.requestFactoryInstance.getResponse().getHeader('MeusPedidosID');
                    
                }
                else  if(mercosPricebookEntryIntegrable.isError){
                    
                    catalogoEntradaPreco.StatusIntegracaoMercos__c = 'Executado com erro';
                    log.ResponseBody__c = mercosPricebookEntryIntegrable.errorMessage;
                }
                
            }catch (Exception e){
               
                System.debug(LoggingLevel.ERROR, '@@@DWMercosPbEntryPrecoIntegrableBatch e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@DWMercosPbEntryPrecoIntegrableBatch e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                catalogoEntradaPreco.StatusIntegracaoMercos__c = 'Executado com erro';
            }finally {
                string[] headerkeys = mercosPricebookEntryIntegrable.requestFactoryInstance.getResponse().getHeaderKeys();
                Map<string, string> headers = new map<string, string>();
                
                for(string s : headerkeys){
                    headers.put(s,mercosPricebookEntryIntegrable.requestFactoryInstance.getResponse().getHeader(s));
                }
                if (mercosPricebookEntryIntegrable.requestFactoryInstance.getLog() != null) {
                    log = mercosPricebookEntryIntegrable.requestFactoryInstance.getLog();
                }
                log.HeadersResponse__c = headers.toString();
                
                log.Name = catalogoEntradaPreco.Name == null ? 'Int pbe mercos ' : 'Int pbe mercos : '+catalogoEntradaPreco.Name.abbreviate(50);
                httpRequestLogList.add(log);
                catalogoEntradaPreco.TentativasIntegracaoMercos__c = catalogoEntradaPreco.TentativasIntegracaoMercos__c == null
                    ? 1
                    : catalogoEntradaPreco.TentativasIntegracaoMercos__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@mercosPricebook2Integrable httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        Map<Id, String> accToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(pricebookEntryList, false);
        
        
        for (Integer i = 0; i < pricebookEntryList.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            PricebookEntry origRecord = pricebookEntryList[i];
            if (!upsertResult.isSuccess()) {
                accToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
             

        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : accToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar enviar entrada catalogo preço para o Mercos. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar enviar entrada catalogo preço para o Mercos.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :pricebookEntrySet)];
        List<FeedItem> feedItemList = (List<FeedItem>)searchList[0];
        if(feedItemList.size() > 0){
            delete feedItemList;
        }
        
        //insert feedItemListToInsert;
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