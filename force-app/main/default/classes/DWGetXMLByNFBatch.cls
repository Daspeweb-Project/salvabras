global  class DWGetXMLByNFBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao da XML')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('NotaFiscal__c')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
        .run();
                            
        (new DWGetXMLByNFBatch()).execute(new DWGetXMLByNFBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWGetXMLByNFBatch(){
        
    }
    public DWGetXMLByNFBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWGetXMLByNFBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWGetXMLByNFBatch ' + cron, cron , new DWGetXMLByNFBatch());
    }
    
    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('DWGetXMLByNFBatch ' + cron, cron, new DWGetXMLByNFBatch());
        }
    }
    
    
    global static void runEveryNMinutesInBusinessHours(Integer each) {
        for (Integer minute = 0; minute < 60; minute += each){
            for (Integer hour = 0; hour <= 23; hour ++){
                if(hour > 8 && hour < 20 && !Test.isRunningTest()){
                    String cron = '0 ' + minute + ' ' + hour + ' * * ?';
                    System.schedule('DWGetXMLByNFBatch ' + cron, cron, new DWGetXMLByNFBatch());
                }
            }
        }
    }
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWGetXMLByNFBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('NotaFiscal__c')
           
           // .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 30))
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWGetXMLByNFBatch sObjectList' + sObjectList);

        return (List<NotaFiscal__c>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<NotaFiscal__c> nfList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@DWGetXMLByNFBatch ' + nfList);
        Set<Id> nfSet = new Set<Id>();
      

        for (NotaFiscal__c nf : nfList){
            nfSet.add(nf.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWXMLConsultationIntegrable getXMLIntegrable = new DWXMLConsultationIntegrable();

            System.debug(LoggingLevel.INFO, '@@@DWGetXMLByNFBatch DWGetXMLByNFBatch.requestFactoryInstance.getLog()' + getXMLIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(getXMLIntegrable.requestFactoryInstance.getLog()) ? getXMLIntegrable.requestFactoryInstance.getLog():log;
            try{
                getXMLIntegrable.callIntegration(nf);
                System.debug(LoggingLevel.INFO, '@@@DWGetXMLByNFBatch this.isError' + getXMLIntegrable.isError);

                System.debug(LoggingLevel.INFO, '@@@DWGetXMLByNFBatch DWGetXMLByNFBatch.responseTemplate' + getXMLIntegrable.responseTemplate);
                if(getXMLIntegrable.isError){
                    nf.StatusIntegracaoXML__c = 'Executado com erro';
                    log.ResponseBody__c = getXMLIntegrable.errorMessage;
                    if(getXMLIntegrable.errorMessage.length()>10000){
                        log.ResponseBody__c = getXMLIntegrable.errorMessage.substring(0,10000);
                    }
                }
                //DWGetDanfeByNFBatch
                else if ((getXMLIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || getXMLIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& DWGetDanfeByNFBatch.responseTemplate.companyInternalId != null && DWGetDanfeByNFBatch.responseTemplate.companyInternalId != ''*/) {
                    DWDANFEResponseTemplate responseTemplate = (DWDANFEResponseTemplate)getXMLIntegrable.deserializedResponseObject;
                    nf.ChaveXML__c = responseTemplate.base64;
                    nf.ChaveXML__c = responseTemplate.base64;
                    

                    if(responseTemplate.base64.length()>131070){
                        nf.ChaveXML__c = responseTemplate.base64.substring(0,131072);
                        nf.ChaveXMLPt2__c = responseTemplate.base64.substring(131072,responseTemplate.base64.length());
                    }
                    nf.StatusIntegracaoXML__c = 'Executado com sucesso';
                    nf.TentativasIntegracaoXML__c = 0;
                    Blob b = EncodingUtil.base64Decode(responseTemplate.base64);
                    nf.XML__c = b.toString();

                
                }else{
                    nf.StatusIntegracaoXML__c = 'Executado com erro';
                }
                
            }catch (Exception e){
                System.debug(LoggingLevel.ERROR, '@@@DWGetXMLByNFBatch e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@DWGetXMLByNFBatch e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                
                nf.StatusIntegracaoConsultaDANFE__c = 'Executado com erro';
            }finally {
                if (getXMLIntegrable.requestFactoryInstance.getLog() != null) {
                    log = getXMLIntegrable.requestFactoryInstance.getLog();
                }
                if(log.ResponseBody__c.length()> 10000){
                    log.ResponseBody__c =log.ResponseBody__c.substring(0,10000);
                }
                log.NotaFiscal__c = nf.Id;
                log.Name = nf.Name == null ? 'Integração da XML ': 'XML : '+nf.name ;
                httpRequestLogList.add(log);
                nf.TentativasIntegracaoXML__c = nf.TentativasIntegracaoXML__c == null
                    ? 1
                    : nf.TentativasIntegracaoXML__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@DWGetXMLByNFBatch httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        
        Map<Id, String> quoteToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(nfList, true);

        for (Integer i = 0; i < nfList.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            NotaFiscal__c origRecord = nfList[i];
            if (!upsertResult.isSuccess()) {
                quoteToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : quoteToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar buscar XML do ERP. ' + quoteToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar buscar XML do ERP.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :nfSet)];
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