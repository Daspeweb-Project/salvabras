global class DWQuoteIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao de cotacao')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Quote')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            .with('QuoteLineItems')
        .run();
                            
        (new DWQuoteIntegrableBatch()).execute(new DWQuoteIntegrableBatch.BatchContext(), sObjectList);
    }



    List<String> statusList = new List<String>();
    public DWQuoteIntegrableBatch(){
        
    }
    public DWQuoteIntegrableBatch(String[] statusList){
        this.statusList = statusList;
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWQuoteIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWQuoteIntegrableBatch ' + cron, cron , new DWQuoteIntegrableBatch());
    }
    
    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('DWQuoteIntegrableBatch ' + cron, cron, new DWQuoteIntegrableBatch());
        }
    }
    
    
    global static void runEveryNMinutesInBusinessHours(Integer each) {
        for (Integer minute = 0; minute < 60; minute += each){
            for (Integer hour = 0; hour <= 23; hour ++){
                if(hour > 8 && hour < 20 && !Test.isRunningTest()){
                    String cron = '0 ' + minute + ' ' + hour + ' * * ?';
                    System.schedule('DWQuoteIntegrableBatch ' + cron, cron, new DWQuoteIntegrableBatch());
                }
            }
        }
    }
        
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWQuoteIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
     
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Quote')
            .setCondition(
                DW_QueryCondition.newInstance(
                    'StatusIntegracao__c', 
                    this.statusList.size() > 0 ? this.statusList : new List<String>{'Pendente', 'Executado com erro'}))
           // .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 30))
            .run();
            System.debug(LoggingLevel.INFO, '@@@DWQuoteIntegrableBatch sObjectList' + sObjectList);

        return (List<Quote>)sObjectList;
    } 
     
    public void execute(Database.BatchableContext param1, List<Quote> quoteList) {
        List<QuoteLineItem> quoteLineItemForUpdate = new List<QuoteLineItem>();
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        System.debug(LoggingLevel.INFO, '@@@OrderIntegrableBatch quoteList' + quoteList);
        Set<Id> quoteSet = new Set<Id>();
        for (Quote quote : quoteList){
            quoteSet.add(quote.Id);
        }
        Map<String,QuoteLineItem> mapQuoteLineItem = new Map<String,QuoteLineItem>();
        List<QuoteLineItem> sObjectList  = ((List<QuoteLineItem>) DW_QueryFactory.get('QuoteLineItem')
                            .setCondition(DW_QueryCondition.newInstance('QuoteId', quoteSet))
                            .withParent('Product2')
                            .run());
        
        System.debug('sObjectList'+sObjectList);
        for(QuoteLineItem quoteLine :sObjectList ){
            mapQuoteLineItem.put(quoteLine.Product2.CodigoERP__c,quoteLine);
        }
        System.debug('mapQuoteLineItem'+mapQuoteLineItem);
        for (Quote quote : quoteList){
            quoteSet.add(quote.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            DWQuoteIntegrable quoteIntegrable = new DWQuoteIntegrable();

            System.debug(LoggingLevel.INFO, '@@@QuoteIntegrableBatch QuoteIntegrableBatch.requestFactoryInstance.getLog()' + quoteIntegrable.requestFactoryInstance.getLog());

            log = DW_Helper.hasSomeContent(quoteIntegrable.requestFactoryInstance.getLog()) ? quoteIntegrable.requestFactoryInstance.getLog():log;
            try{
                quoteIntegrable.callIntegration(quote);
                System.debug(LoggingLevel.INFO, '@@@QuoteIntegrableBatch this.isError' + quoteIntegrable.isError);

                System.debug(LoggingLevel.INFO, '@@@QuoteIntegrableBatch quoteIntegrable.responseTemplate' + quoteIntegrable.responseTemplate);
                if(quoteIntegrable.isError){
                    quote.StatusIntegracao__c = 'Executado com erro';
                    log.ResponseBody__c = quoteIntegrable.errorMessage;
                }
                //PEDIDO
                else if ((quoteIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 201 || quoteIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200) /*&& quoteIntegrable.responseTemplate.companyInternalId != null && orderIntegrable.responseTemplate.companyInternalId != ''*/) {
                    QuoteIntegrableResponseTemplate responseTemplate = (QuoteIntegrableResponseTemplate)quoteIntegrable.deserializedResponseObject;
                    quote.StatusIntegracao__c = 'Executado com sucesso';
                    Double totalBaseCalculo = 0;
                    Double totalBaseICMS = 0;
                    Double totalVlrCofins = 0;
                    Double totalVlrIcms = 0;
                    Double totalVlrNf = 0;
                    Double totalICMSSolTotal = 0;
                    Double totalVlrPs2 = 0;
                    quote.TentativasIntegracao__c = 0;
                    for(QuoteIntegrableResponseTemplate.cls_produtos quoteProduts : responseTemplate.produtos){
                        String codProduto = quoteProduts.produto;
                        QuoteLineItem quoteLineItem = new QuoteLineItem();
                        quoteLineItem.id = mapQuoteLineItem.get(codProduto).Id;
                        
                        totalBaseCalculo += quoteProduts.impostos.BASE_CALC != null ? quoteProduts.impostos.BASE_CALC :0 ;
                        totalBaseICMS += quoteProduts.impostos.BASE_ICMS != null ? quoteProduts.impostos.BASE_ICMS :0 ;
                        totalVlrCofins += quoteProduts.impostos.VL_COFINS != null ? quoteProduts.impostos.VL_COFINS :0 ;
                        totalVlrIcms += quoteProduts.impostos.VL_ICMS != null ? quoteProduts.impostos.VL_ICMS :0 ;
                        totalVlrNf += quoteProduts.impostos.VALOR_NF != null ? quoteProduts.impostos.VALOR_NF :0 ;
                        totalVlrPs2 += quoteProduts.impostos.VALPS2 != null ? quoteProduts.impostos.VALPS2 :0 ;
                        totalICMSSolTotal += quoteProduts.impostos.ICMS_SOL != null ? quoteProduts.impostos.ICMS_SOL :0 ;

                        quoteLineItem.BaseCalc__c = quoteProduts.impostos.BASE_CALC != null ? quoteProduts.impostos.BASE_CALC :0 ;
                        quoteLineItem.BaseIcms__c = quoteProduts.impostos.BASE_ICMS != null ? quoteProduts.impostos.BASE_ICMS :0 ;
                        quoteLineItem.ValorCofins__c = quoteProduts.impostos.VL_COFINS != null ? quoteProduts.impostos.VL_COFINS :0 ;
                        quoteLineItem.ValorIcms__c = quoteProduts.impostos.VL_ICMS != null ? quoteProduts.impostos.VL_ICMS :0 ;
                        quoteLineItem.ValorNF__c = quoteProduts.impostos.VALOR_NF != null ? quoteProduts.impostos.VALOR_NF :0 ;
                        quoteLineItem.VALPS2__c = quoteProduts.impostos.VALPS2 != null ? quoteProduts.impostos.VALPS2 :0 ;
                        quoteLineItem.ICMSSol__c = quoteProduts.impostos.ICMS_SOL != null ? quoteProduts.impostos.ICMS_SOL :0 ;
                        quoteLineItemForUpdate.add(quoteLineItem);
                        
                    }
                    
                    quote.TotalBaseCalc__c = totalBaseCalculo;
                    quote.TotalValorIcms__c = totalBaseICMS;
                    quote.TotalValorCofins__c = totalVlrCofins;
                    quote.TotalValorNf__c = totalVlrNf;
                    quote.TotalBaseICMS__c = totalBaseICMS;
                    quote.TotalICMSSol__c = totalICMSSolTotal;

                    quote.TotalValPs2__c = totalVlrPs2;

                }else if(quoteIntegrable.requestFactoryInstance.getResponse().getStatusCode() == 200 /*&& quoteIntegrable.responseTemplate.errorMessage != null && quoteIntegrable.responseTemplate.errorMessage != ''*/){
                    quote.StatusIntegracao__c = 'Executado com erro';
                    log.ResponseBody__c = quoteIntegrable.responseTemplate.toString();
                }else{
                    quote.StatusIntegracao__c = 'Executado com erro';
                }
                
            }catch (Exception e){
                System.debug(LoggingLevel.ERROR, '@@@QuoteIntegrableBatch e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@QuoteIntegrableBatch e.getStackTraceString()' + e.getStackTraceString());
                log.ResponseBody__c = e.getMessage();
                quote.StatusIntegracao__c = 'Executado com erro';
            }finally {
                if (quoteIntegrable.requestFactoryInstance.getLog() != null) {
                    log = quoteIntegrable.requestFactoryInstance.getLog();
                }
                log.Quote__c = quote.Id;
                log.Name = quote.Name == null ? 'Integração da cotação ': 'IQ : '+quote.QuoteNumber ;
                httpRequestLogList.add(log);
                quote.TentativasIntegracao__c = quote.TentativasIntegracao__c == null
                    ? 1
                    : quote.TentativasIntegracao__c+1;
                    
            }
        }
        
        
        if (httpRequestLogList.size() > 0) {
            System.debug(LoggingLevel.ERROR, '@@@QuoteIntegrableBatch httpRequestLogList' + httpRequestLogList);

            insert httpRequestLogList;
        }
        update quoteLineItemForUpdate;
        Map<Id, String> quoteToPostErrorMessageMap = new Map<Id, String>();
        List<Database.UpsertResult> upsertResultList = Database.upsert(quoteList, false);
        update quoteList;
        for (Integer i = 0; i < quoteList.size(); i++) {
            Database.UpsertResult upsertResult = upsertResultList[i];
            Quote origRecord = quoteList[i];
            if (!upsertResult.isSuccess()) {
                quoteToPostErrorMessageMap.put(origRecord.Id, upsertResult.getErrors().get(0).getMessage());
            } 
        }
        
        List<FeedItem> feedItemListToInsert = new List<FeedItem>();
        for(Id id : quoteToPostErrorMessageMap.keySet()){
            FeedItem feed = new FeedItem();
            feed.ParentId =  id;
            feed.Body = 'Erro ao tentar enviar cotação para o ERP. ' + quoteToPostErrorMessageMap.get(id);
            feedItemListToInsert.add(feed);
        }
        List<List<SObject>> searchList = [
            FIND 'Erro ao tentar enviar cotação para o ERP.*' IN ALL FIELDS 
            RETURNING FeedItem (Id, Body WHERE id in :quoteSet)];
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