global class DWMercosCPIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao condicao Pagamento')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('CondicaoPagamento__c')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            
        .run();
                            
        (new DWMercosCPIntegrableBatch()).execute(new DWMercosCPIntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWMercosCPIntegrableBatch(){
        
    }
    public DWMercosCPIntegrableBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWMercosCPIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWMercosCPIntegrableBatch ' + cron, cron , new DWMercosCPIntegrableBatch());
    }
    
   
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWMercosCPIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('CondicaoPagamento__c')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracaoMercos__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'','Pendente', 'Executado com erro'})
            )
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWMercosCPIntegrableBatch sObjectList' + sObjectList);

        return (List<CondicaoPagamento__c>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<CondicaoPagamento__c> condicaoPagamentoList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWMercosCPIntegrableBatch condicaoPagamentoList' + condicaoPagamentoList);
        Set<Id> condicaoPagamentoSet = new Set<Id>();

        for (CondicaoPagamento__c condicaoPagamento : condicaoPagamentoList){
            condicaoPagamentoSet.add(condicaoPagamento.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWMercosCdPagamentoIntegrable mercosCondicaoPagamentoIntegrable = new DWMercosCdPagamentoIntegrable();

            System.debug(LoggingLevel.INFO, '@@@mercosCondicaoPagamentoIntegrable mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getLog()' + mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getLog()) ? mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getLog():log;
            try{
                mercosCondicaoPagamentoIntegrable.callIntegration(condicaoPagamento);
                
                if ((mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    condicaoPagamento.StatusIntegracaoMercos__c = 'Executado com sucesso';
                    if( String.isBlank(condicaoPagamento.CodigoExclusivoMercos__c))condicaoPagamento.CodigoExclusivoMercos__c = mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getResponse().getHeader('MeusPedidosID');
                    
                }
                else  if(mercosCondicaoPagamentoIntegrable.isError){
                    
                    condicaoPagamento.StatusIntegracaoMercos__c = 'Executado com erro';
                    log.ResponseBody__c = mercosCondicaoPagamentoIntegrable.errorMessage;
                }
                
            }catch (Exception e){
               
                System.debug(LoggingLevel.ERROR, '@@@mercosCondicaoPagamentoIntegrable e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@mercosCondicaoPagamentoIntegrable e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                condicaoPagamento.StatusIntegracaoMercos__c = 'Executado com erro';
            }finally {
                string[] headerkeys = mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getResponse().getHeaderKeys();
                Map<string, string> headers = new map<string, string>();
                
                for(string s : headerkeys){
                    headers.put(s,mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getResponse().getHeader(s));
                }
                if (mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getLog() != null) {
                    log = mercosCondicaoPagamentoIntegrable.requestFactoryInstance.getLog();
                }
                log.HeadersResponse__c = headers.toString();
                
                log.Name = condicaoPagamento.Name == null ? 'Int condicao mercos ' : 'Int condicao mercos : '+condicaoPagamento.Name.abbreviate(50);
                httpRequestLogList.add(log);
                condicaoPagamento.TentativasIntegracaoMercos__c = condicaoPagamento.TentativasIntegracaoMercos__c == null
                    ? 1
                    : condicaoPagamento.TentativasIntegracaoMercos__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@mercosPricebook2Integrable httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        Map<Id, String> accToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(condicaoPagamentoList, false);
        
        
        for (Integer i = 0; i < condicaoPagamentoList.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            CondicaoPagamento__c origRecord = condicaoPagamentoList[i];
            if (!upsertResult.isSuccess()) {
                accToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
             

        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : accToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar enviar condicao Pagamento para o Mercos. ' + accToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar enviar condicao Pagamento para o Mercos.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :condicaoPagamentoSet)];
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