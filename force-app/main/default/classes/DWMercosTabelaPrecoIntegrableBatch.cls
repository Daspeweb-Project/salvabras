global class DWMercosTabelaPrecoIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao pre catalogo de preço')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Pricebook2')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            
        .run();
                            
        (new DWMercosTabelaPrecoIntegrableBatch()).execute(new DWMercosTabelaPrecoIntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWMercosTabelaPrecoIntegrableBatch(){
        
    }
    public DWMercosTabelaPrecoIntegrableBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWMercosTabelaPrecoIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWMercosTabelaPrecoIntegrableBatch ' + cron, cron , new DWMercosTabelaPrecoIntegrableBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWMercosTabelaPrecoIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Pricebook2')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracaoMercos__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'','Pendente', 'Executado com erro'}))
           // .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 30))
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWMercosTabelaPrecoIntegrableBatch sObjectList' + sObjectList);

        return (List<Pricebook2>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<Pricebook2> pricebook2List) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWMercosTabelaPrecoIntegrableBatch pricebook2List' + pricebook2List);
        Set<Id> pricebook2Set = new Set<Id>();

        for (Pricebook2 catalogoPreco : pricebook2List){
            pricebook2Set.add(catalogoPreco.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWMercosTabelaPrecoIntegrable mercosPricebook2Integrable = new DWMercosTabelaPrecoIntegrable();

            System.debug(LoggingLevel.INFO, '@@@DWMercosTabelaPrecoIntegrableBatch DWMercosTabelaPrecoIntegrableBatch.requestFactoryInstance.getLog()' + mercosPricebook2Integrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(mercosPricebook2Integrable.requestFactoryInstance.getLog()) ? mercosPricebook2Integrable.requestFactoryInstance.getLog():log;
            try{
                mercosPricebook2Integrable.callIntegration(catalogoPreco);
                
                if ((mercosPricebook2Integrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || mercosPricebook2Integrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    catalogoPreco.StatusIntegracaoMercos__c = 'Executado com sucesso';
                    if( String.isBlank(catalogoPreco.CodigoExclusivoMercos__c))catalogoPreco.CodigoExclusivoMercos__c = mercosPricebook2Integrable.requestFactoryInstance.getResponse().getHeader('MeusPedidosID');
                    
                }
                else  if(mercosPricebook2Integrable.isError){
                    
                    catalogoPreco.StatusIntegracaoMercos__c = 'Executado com erro';
                    log.ResponseBody__c = mercosPricebook2Integrable.errorMessage;
                }
                
            }catch (Exception e){
               
                System.debug(LoggingLevel.ERROR, '@@@mercosPricebook2Integrable e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@mercosPricebook2Integrable e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                catalogoPreco.StatusIntegracaoMercos__c = 'Executado com erro';
            }finally {
                string[] headerkeys = mercosPricebook2Integrable.requestFactoryInstance.getResponse().getHeaderKeys();
                Map<string, string> headers = new map<string, string>();
                
                for(string s : headerkeys){
                    headers.put(s,mercosPricebook2Integrable.requestFactoryInstance.getResponse().getHeader(s));
                }
                if (mercosPricebook2Integrable.requestFactoryInstance.getLog() != null) {
                    log = mercosPricebook2Integrable.requestFactoryInstance.getLog();
                }
                log.HeadersResponse__c = headers.toString();
                
                log.CatalogoPreco__c = catalogoPreco.Id;
                log.Name = catalogoPreco.Name == null ? 'Integração do catalogo preço mercos ' : 'Integração do catalogo preço : '+catalogoPreco.Name.abbreviate(50);
                httpRequestLogList.add(log);
                catalogoPreco.TentativasIntegracaoMercos__c = catalogoPreco.TentativasIntegracaoMercos__c == null
                    ? 1
                    : catalogoPreco.TentativasIntegracaoMercos__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@mercosPricebook2Integrable httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        Map<Id, String> accToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(pricebook2List, true);
        
        
        for (Integer i = 0; i < pricebook2List.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            Pricebook2 origRecord = pricebook2List[i];
            if (!upsertResult.isSuccess()) {
                accToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
             

        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : accToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar enviar catalogo preço para o Mercos. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar enviar catalogo preço para o Mercos.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :pricebook2Set)];
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