global class DWMercosTituloBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao titulo mercos')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Titulo__c')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'Id', new List<String>{id.get(0)}))
            
            .run();
        
        (new DWMercosTituloBatch()).execute(new DWMercosTituloBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWMercosTituloBatch(){
        
    }
    public DWMercosTituloBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWMercosTituloBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWMercosTituloBatch ' + cron, cron , new DWMercosTituloBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWMercosTituloBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Titulo__c')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracaoMercos__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'Pendente', 'Executado com erro',''}))
            
           // .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 30))
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWMercosTituloBatch sObjectList' + sObjectList);

        return (List<Titulo__c>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<Titulo__c> tituloList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWMercostTituloIntegrable tituloList' + tituloList);
        Set<Id> tituloSet = new Set<Id>();

        for (Titulo__c titulo : tituloList){
            tituloSet.add(titulo.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWMercostTituloIntegrable mercosTituloIntegrable = new DWMercostTituloIntegrable();

            System.debug(LoggingLevel.INFO, '@@@DWMercostTituloIntegrable DWMercostTituloIntegrable.requestFactoryInstance.getLog()' + mercosTituloIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(mercosTituloIntegrable.requestFactoryInstance.getLog()) ? mercosTituloIntegrable.requestFactoryInstance.getLog():log;
            try{
                mercosTituloIntegrable.callIntegration(titulo);
                
                if ((mercosTituloIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || mercosTituloIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    titulo.StatusIntegracaoMercos__c = 'Executado com sucesso';
                    if( String.isBlank(titulo.CodigoExclusivoMercos__c))titulo.CodigoExclusivoMercos__c = mercosTituloIntegrable.requestFactoryInstance.getResponse().getHeader('MeusPedidosID');
                    
                }
                else  if(mercosTituloIntegrable.isError){
                    
                    titulo.StatusIntegracaoMercos__c = 'Executado com erro';
                    log.ResponseBody__c = mercosTituloIntegrable.errorMessage;
                }
                
            }catch (Exception e){
               
                System.debug(LoggingLevel.ERROR, '@@@mercosTituloIntegrable e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@mercosTituloIntegrable e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                titulo.StatusIntegracaoMercos__c = 'Executado com erro';
            }finally {
                string[] headerkeys = mercosTituloIntegrable.requestFactoryInstance.getResponse().getHeaderKeys();
                Map<string, string> headers = new map<string, string>();
                
                for(string s : headerkeys){
                    headers.put(s,mercosTituloIntegrable.requestFactoryInstance.getResponse().getHeader(s));
                }
                if (mercosTituloIntegrable.requestFactoryInstance.getLog() != null) {
                    log = mercosTituloIntegrable.requestFactoryInstance.getLog();
                }
                log.HeadersResponse__c = headers.toString();
                
                log.Titulo__c = titulo.Id;
                log.Name = titulo.Name == null ? 'Integração do titulo mercos ' : 'Integração do titulo mercos : '+titulo.Name.abbreviate(50);
                httpRequestLogList.add(log);
                titulo.TentativasIntegracaoMercos__c = titulo.TentativasIntegracaoMercos__c == null
                    ? 1
                    : titulo.TentativasIntegracaoMercos__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@mercosTituloIntegrable httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        Map<Id, String> accToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(tituloList, false);
        
        
        for (Integer i = 0; i < tituloList.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            Titulo__c origRecord = tituloList[i];
            if (!upsertResult.isSuccess()) {
                accToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
             

        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : accToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar enviar titulo para o Mercos. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar enviar titulo para o Mercos.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :tituloSet)];
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