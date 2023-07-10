global class DWExecuteAllIntegrations implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    @InvocableMethod(label='Chamar integracao pre pre conta e avaliação')
    global static void testQA(List<String> id) {
        List<SObject> sObjectList = DW_QueryFactory.get('Quote')
        .setCondition(
            DW_QueryCondition.newInstance(
                'Id', new List<String>{id.get(0)}))
            .with('QuoteLineItems')
                            	.withParent('Account')

        .run();
                            
        (new DWExecuteAllIntegrations()).execute(new DWExecuteAllIntegrations.BatchContext(), sObjectList);
    }
     
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new DWExecuteAllIntegrations(), 1);
    }
     global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('DWExecuteAllIntegrations ' + cron, cron , new DWExecuteAllIntegrations());
    }
     public Iterable<SObject> start(Database.BatchableContext param1) {
        List<Quote> sObjectList = (List<Quote>) DW_QueryFactory.get('Quote')
        .setCondition(DW_QueryCondition.newInstance('StatusIntegracao__c', new List<String>{'Pendente', 'Executado com erro'}))
        .run();

        return (List<Quote>)sObjectList;
    }
    
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%DWExecuteAllIntegrations%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
    public void execute(Database.BatchableContext param1, List<Quote> quoteList) {
        List<HttpRequestLog__c> httpRequestAcLogList = new List<HttpRequestLog__c>();
        List<HttpRequestLog__c> httpRequestQuoteLog = new List<HttpRequestLog__c>();
        List<QuoteLineItem> quoteLineItemForUpdate = new List<QuoteLineItem>();
        List<Account> accountForUpdate = new List<Account>();

        Set<Id> quoteSetId = new Set<Id>();
        Set<Id> accSetId = new Set<Id>();
        for (Quote quote : quoteList){
            quoteSetId.add(quote.Id);
            accSetId.add(quote.AccountId);
        }
        Map<String,QuoteLineItem> mapQuoteLineItem = new Map<String,QuoteLineItem>();
        List<QuoteLineItem> sObjectList  = ((List<QuoteLineItem>) DW_QueryFactory.get('QuoteLineItem')
                            .setCondition(DW_QueryCondition.newInstance('QuoteId', quoteSetId))
                            .withParent('Product2')
                            .run());
        
        for(QuoteLineItem quoteLine :sObjectList ){
            mapQuoteLineItem.put(quoteLine.Product2.CodigoERP__c,quoteLine);
        }
        List<Account> accByQuoteToList = (List<Account>) DW_QueryFactory.get('Account')
        .setCondition(DW_QueryCondition.newInstance('Id', accSetId))
        .run();
       
        Map<Id,Account> mapAux = new Map<Id,Account>();
        for(Account ac : accByQuoteToList){
            mapAux.put(ac.Id,ac);
        }
        for (Quote quote : quoteList){
            HttpRequestLog__c log = new HttpRequestLog__c();
            try{
                String codigExclusivoConta = '';
                Account acc = mapAux.get(quote.AccountId);
                if(String.isBlank(acc.CodigoERP__c)){
                    HttpRequestLog__c logAcc = new HttpRequestLog__c();
                    DWPreAccountIntegrable acIntegrable = new DWPreAccountIntegrable();
                    acIntegrable.callIntegration(acc);
                    if(DW_Helper.hasSomeContent(acIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(acIntegrable.requestFactoryInstance.getLog())){
                        logAcc = acIntegrable.requestFactoryInstance.getLog();
                    } 
                    DWPreAccountResponseTemplate responseTemplate = (DWPreAccountResponseTemplate)acIntegrable.deserializedResponseObject;
                    System.debug('responseTemplate:'+responseTemplate);
                    acc.StatusIntegracao__c = 'Executado com sucesso';
                    acc.CodigoERP__c = responseTemplate.A1_COD;  
                    logAcc.Conta__c = acc.Id;
                    logAcc.Name = acc.Name == null ? 'Integração da pré conta ' : 'Integração da pré conta : '+acc.Name.abbreviate(50);
                    httpRequestAcLogList.add(logAcc);   
                    codigExclusivoConta = responseTemplate.A1_COD;
                    accountForUpdate.add(acc);
                }else{
                    codigExclusivoConta = acc.CodigoERP__c;
                }
                quote.CodigoExclusivoConta__c = codigExclusivoConta;
                DWQuoteIntegrable quoteIntegrable = new DWQuoteIntegrable();
                quoteIntegrable.callIntegration(quote);
                if(quoteIntegrable.isError){
                    log.ResponseBody__c = quoteIntegrable.errorMessage;
                }
                QuoteIntegrableResponseTemplate responseTemplate = (QuoteIntegrableResponseTemplate)quoteIntegrable.deserializedResponseObject;
                log.ResponseBody__c = quoteIntegrable.responseTemplate.toString();
                
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
 
            }catch (Exception e){
                quote.StatusIntegracao__c = 'Executado com erro';   
                
                System.debug(LoggingLevel.ERROR, '@@@OppAgencyIntegrableBatch e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@OppAgencyIntegrableBatch e.getStackTraceString()' + e.getStackTraceString());
            }finally {
                log.Quote__c = quote.Id;
                log.Name = quote.Name == null ? 'Integração da cotação ': 'IQ : '+quote.QuoteNumber ;
                httpRequestQuoteLog.add(log);
                quote.TentativasIntegracao__c = quote.TentativasIntegracao__c == null
                    ? 1
                    : quote.TentativasIntegracao__c+1;
                    
            }
        }
        if (httpRequestQuoteLog.size() > 0) {
            insert httpRequestQuoteLog;
        }
        if (httpRequestAcLogList.size() > 0) {
            insert httpRequestAcLogList;
        }
        if(accountForUpdate.size()>0){
            update accountForUpdate;
        }
        update quoteLineItemForUpdate;
        
        update quoteList;
    }
    public void finish(Database.BatchableContext param1) {
    }

    public class BatchContext implements Database.BatchableContext {
        public Id getChildJobId(){
            return null;
        }
        public Id getJobId(){
            return null;
        }
    }
    
}