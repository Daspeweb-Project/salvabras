global with sharing class TituloIntegrableBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    global static void runInSyncMode(Id accountId){
        TituloIntegrableBatch batch = new TituloIntegrableBatch();
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(DW_QueryCondition.newInstance('Id', '=', accountId))
            .run();
        batch.execute(null, (List<Account>)sObjectList);
    }

    /*global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('TituloIntegrableBatch ' + cron, cron , new TituloIntegrableBatch());
    }

    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('TituloIntegrableBatch ' + cron, cron, new TituloIntegrableBatch());
        }
    }

    global static void runEveryNMinutesInBusinessHours(Integer each) {
        for (Integer minute = 0; minute < 60; minute += each){
            for (Integer hour = 0; hour <= 23; hour ++){
                if(hour > 8 && hour < 20 && !Test.isRunningTest()){
                    String cron = '0 ' + minute + ' ' + hour + ' * * ?';
                    System.schedule('TituloIntegrableBatch ' + cron, cron, new TituloIntegrableBatch());
                }
            }
        }
    }

    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%TituloIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
        }
    }*/

    public void execute(SchedulableContext param1) {
        Database.executeBatch(new TituloIntegrableBatch());
    }

    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(DW_QueryCondition.newInstance('StatusIntegracaoTitulos__c', new List<String>{'Pendente', ''}))
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
            account.MensagemIntegracaoTitulos__c = null;

            try{
                TituloIntegrable TituloIntegrable = new TituloIntegrable();
                TituloIntegrable.callIntegration(account);
                if(DW_Helper.hasSomeContent(TituloIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(TituloIntegrable.requestFactoryInstance.getLog())){
                    log = TituloIntegrable.requestFactoryInstance.getLog();
                }
                if(TituloIntegrable.isError){
                    if (DW_Helper.isNullOrBlank(account.MensagemIntegracaoTitulos__c)) account.MensagemIntegracaoTitulos__c = TituloIntegrable.errorMessage;
                    account.StatusIntegracaoTitulos__c = 'Executado com erro';
                    log.ResponseBody__c = TituloIntegrable.errorMessage;
                }
                if(TituloIntegrable.isSuccess){
                    TituloIntegrableResponseTemplate responseTemplate = (TituloIntegrableResponseTemplate)TituloIntegrable.deserializedResponseObject;
                    if (responseTemplate?.titulos?.size() > 0) {
                        // iteração de Títulos
                        List<Titulo__c> titulosToUpsert = new List<Titulo__c>();
                        for (TituloIntegrableResponseTemplate.titulos titulo : responseTemplate.titulos) {
                            Titulo__c upsertTitulo = new Titulo__c();
                            upsertTitulo.Name = titulo.num + (String.isBlank(titulo.parcela) ? '' : '/' + titulo.parcela);
                            upsertTitulo.CodigoERP__c = upsertTitulo.Name;
                            upsertTitulo.Numero__c = titulo.num;
                            upsertTitulo.Conta__c = account.Id;
                            upsertTitulo.Status__c = 'OK';
                            upsertTitulo.Tipo__c = titulo.tipo;
                            upsertTitulo.Parcela__c = titulo.parcela;
                            upsertTitulo.Prefixo__c = titulo.prefixo;
                            upsertTitulo.Filial__c = titulo.filial;

                            titulosToUpsert.add(upsertTitulo);
                        }

                        upsert titulosToUpsert CodigoERP__c;

                        account.StatusIntegracaoTitulos__c = 'Executado com sucesso';
                        account.TentativasIntegracaoTitulos__c = 0;
                    }else{
                        if (DW_Helper.isNullOrBlank(account.MensagemIntegracaoTitulos__c)) account.MensagemIntegracaoTitulos__c = 'Corpo de resposta da API inválido ou vazio';
                        account.StatusIntegracao__c = 'Executado com erro';
                        log.ResponseBody__c = 'Erro na formação da requisição. ' + TituloIntegrable.errorMessage;
                    }
                }else{
                    account.StatusIntegracaoTitulos__c = 'Executado com erro';
                    log.ResponseBody__c = 'Erro na formação da requisição. ' + TituloIntegrable.errorMessage;
                }
            }catch (Exception e){
                if (DW_Helper.isNullOrBlank(account.MensagemIntegracaoTitulos__c)) account.MensagemIntegracaoTitulos__c = e.getMessage();
                log.ResponseBody__c = e.getMessage() + '/n' + e.getStackTraceString();
                System.debug(LoggingLevel.ERROR, '@@TituloIntegrableBatch.execute() e.getMessage: ' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@TituloIntegrableBatch.execute() e.getCause: ' + e.getCause());
                System.debug(LoggingLevel.ERROR, '@@TituloIntegrableBatch.execute() e.getLineNumber: ' + e.getLineNumber());
                System.debug(LoggingLevel.ERROR, '@@TituloIntegrableBatch.execute() e.getStackTraceString: ' + String.valueOf(e.getStackTraceString()));
            }finally {
                log.Conta__c = account.Id;
                log.Name = 'Tentativa de integração titulos conta: ' + account.Id;
                httpRequestLogList.add(log);
                account.TentativasIntegracaoTitulos__c = account.TentativasIntegracaoTitulos__c == null
                    ? 1
                    : account.TentativasIntegracaoTitulos__c+1;
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