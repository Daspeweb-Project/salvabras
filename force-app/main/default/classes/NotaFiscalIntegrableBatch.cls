global with sharing class NotaFiscalIntegrableBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    global static void runInSyncMode(Id accountId){
        NotaFiscalIntegrableBatch batch = new NotaFiscalIntegrableBatch();
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(DW_QueryCondition.newInstance('Id', '=', accountId))
            .run();
        batch.execute(null, (List<Account>)sObjectList);
    }

    /*global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('NotaFiscalIntegrableBatch ' + cron, cron , new NotaFiscalIntegrableBatch());
    }

    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('NotaFiscalIntegrableBatch ' + cron, cron, new NotaFiscalIntegrableBatch());
        }
    }

    global static void runEveryNMinutesInBusinessHours(Integer each) {
        for (Integer minute = 0; minute < 60; minute += each){
            for (Integer hour = 0; hour <= 23; hour ++){
                if(hour > 8 && hour < 20 && !Test.isRunningTest()){
                    String cron = '0 ' + minute + ' ' + hour + ' * * ?';
                    System.schedule('NotaFiscalIntegrableBatch ' + cron, cron, new NotaFiscalIntegrableBatch());
                }
            }
        }
    }

    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%NotaFiscalIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
        }
    }*/

    public void execute(SchedulableContext param1) {
        Database.executeBatch(new NotaFiscalIntegrableBatch());
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(DW_QueryCondition.newInstance('StatusIntegracaoNFs__c', new List<String>{'Pendente', ''}))
            .run();
        return (List<Account>)sObjectList;
    }

    public void execute(Database.BatchableContext param1, List<Account> accountList) {
        Set<String> recipientsIds = null;
        Set<Id> accountSet = new Set<Id>();
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        for (Account account : accountList){
            accountSet.add(account.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            account.MensagemIntegracaoNFs__c = null;

            try{
                NotaFiscalIntegrable NotaFiscalIntegrable = new NotaFiscalIntegrable();
                NotaFiscalIntegrable.callIntegration(account);
                if(DW_Helper.hasSomeContent(NotaFiscalIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(NotaFiscalIntegrable.requestFactoryInstance.getLog())){
                    log = NotaFiscalIntegrable.requestFactoryInstance.getLog();
                }
                if(NotaFiscalIntegrable.isError){
                    if (DW_Helper.isNullOrBlank(account.MensagemIntegracaoNFs__c)) account.MensagemIntegracaoNFs__c = NotaFiscalIntegrable.errorMessage;
                    account.StatusIntegracaoNFs__c = 'Executado com erro';
                    log.ResponseBody__c = NotaFiscalIntegrable.errorMessage;
                }
                if(NotaFiscalIntegrable.isSuccess){
                    NotaFiscalIntegrableResponseTemplate responseTemplate = (NotaFiscalIntegrableResponseTemplate)NotaFiscalIntegrable.deserializedResponseObject;
                    if (responseTemplate?.NFs?.size() > 0) {
                        // iteração de NFs
                        Map<String, String> mapItemNfErpNfErp = new Map<String, String>();

                        List<NotaFiscal__c> nfsToUpsert = new List<NotaFiscal__c>();
                        List<ItemNotaFiscal__c> itemNfsToUpsert = new List<ItemNotaFiscal__c>();
                        for (NotaFiscalIntegrableResponseTemplate.NFs nf : responseTemplate.NFs) {
                            String year = nf.dtemissa.substring(0, 4);
                            String month = nf.dtemissa.substring(4, 6);
                            String day = nf.dtemissa.substring(6, 8);
                            String dateToParse = day + '/' + month + '/' + year;

                            NotaFiscal__c upsertNf = new NotaFiscal__c();
                            upsertNf.Name = 'NF 2' + nf.documento + ' - ' + dateToParse;
                            upsertNf.Conta__c = account.Id;
                            upsertNf.CodigoERP__c = nf.documento;
                            upsertNf.TipoNotaFiscal__c = 'N';
                            upsertNf.Status__c = 'OK';
                            upsertNf.DataEmissao__c = Date.parse(dateToParse);
                            upsertNf.NumeroTitulo__c = nf.numtit;
                            upsertNf.Serie__c = nf.serie;
                            upsertNf.CodigoCondicaoPagamentoERP__c = nf.condpgt; // Fluxo irá colocar a Condição de Pagamento no campo correto se existir
                            upsertNf.CodigoContaERP__c = nf.cliente; // Fluxo irá colocar a Conta no campo correto se existir

                            Decimal nfTotal = 0;
                            for (NotaFiscalIntegrableResponseTemplate.itens itemNf : nf.itens) {
                                nfTotal += itemNf.total;

                                ItemNotaFiscal__c upsertItemNf = new ItemNotaFiscal__c();
                                upsertItemNf.CodigoERP__c = upsertNf.CodigoERP__c + '_item_' + itemNf.item;
                                upsertItemNf.ItemNota__c = itemNf.item;
                                upsertItemNf.CodigoProdutoERP__c = itemNf.produto.trim(); // Fluxo irá colocar o Produto no campo correto se existir
                                upsertItemNf.TES__c = itemNf.tes;
                                upsertItemNf.Quantidade__c = itemNf.quantidade;
                                upsertItemNf.PrecoUnitario__c = itemNf.prcven;
                                upsertItemNf.ValorTotal__c = itemNf.total;

                                mapItemNfErpNfErp.put(upsertItemNf.CodigoERP__c, upsertNf.CodigoERP__c);
                                itemNfsToUpsert.add(upsertItemNf);
                            }
                            upsertNf.Valor__c = nfTotal;
                            nfsToUpsert.add(upsertNf);
                        }

                        upsert nfsToUpsert CodigoERP__c;
                        for (ItemNotaFiscal__c itemNf : itemNfsToUpsert) {
                            for (NotaFiscal__c nf : nfsToUpsert) {
                                if (nf.CodigoERP__c == mapItemNfErpNfErp.get(itemNf.CodigoERP__c)) {
                                    itemNf.NotaFiscal__c = nf.Id;
                                }
                            }
                        }

                        upsert itemNfsToUpsert CodigoERP__c;

                        account.StatusIntegracaoNFs__c = 'Executado com sucesso';
                        account.TentativasIntegracaoNFs__c = 0;
                    }else{
                        if (DW_Helper.isNullOrBlank(account.MensagemIntegracaoNFs__c)) account.MensagemIntegracaoNFs__c = 'Corpo de resposta da API inválido ou vazio';
                        account.StatusIntegracao__c = 'Executado com erro';
                        log.ResponseBody__c = 'Erro na formação da requisição. ' + NotaFiscalIntegrable.errorMessage;
                    }
                }else{
                    account.StatusIntegracaoNFs__c = 'Executado com erro';
                    log.ResponseBody__c = 'Erro na formação da requisição. ' + NotaFiscalIntegrable.errorMessage;
                }
            }catch (Exception e){
                if (DW_Helper.isNullOrBlank(account.MensagemIntegracaoNFs__c)) account.MensagemIntegracaoNFs__c = e.getMessage();
                log.ResponseBody__c = e.getMessage() + '/n' + e.getStackTraceString();
                System.debug(LoggingLevel.ERROR, '@@NotaFiscalIntegrableBatch.execute() e.getMessage: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@NotaFiscalIntegrableBatch.execute() e.getCause: ' + e.getCause());
                System.debug(LoggingLevel.ERROR, '@@NotaFiscalIntegrableBatch.execute() e.getLineNumber: ' + e.getLineNumber());
                System.debug(LoggingLevel.ERROR, '@@NotaFiscalIntegrableBatch.execute() e.getStackTraceString: ' + String.valueOf(e.getStackTraceString()));
            }finally {
                log.Conta__c = account.Id;
                log.Name = 'Tentativa de integração NFs conta: ' + account.Id;
                httpRequestLogList.add(log);
                account.TentativasIntegracaoNFs__c = account.TentativasIntegracaoNFs__c == null
                    ? 1
                    : account.TentativasIntegracaoNFs__c+1;
            }
        }

        if (httpRequestLogList.size() > 0) {
            insert httpRequestLogList;
        }
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(accountSet, accountList, 'Erro ao tentar enviar pedido para o ERP. ');
    }

    public void finish(Database.BatchableContext param1) {
    }
}