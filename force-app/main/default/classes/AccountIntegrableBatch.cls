/**
* Created by guilhermereis on 25/01/21.
*/

global without sharing class AccountIntegrableBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Schedulable{
    
    global static void runInSyncMode(Id accountId){
        AccountIntegrableBatch batch = new AccountIntegrableBatch();
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(DW_QueryCondition.newInstance('Id', '=', accountId))
            .withParent('Representante__r', 'Account')
            .with('AccountContactRelations', 'AccountContactRelation')
            .run();
        batch.execute(null, (List<Account>)sObjectList);
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new AccountIntegrableBatch(), 1);
    }
    
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('AccountIntegrableBatch ' + cron, cron , new AccountIntegrableBatch());
    }
    
    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('AccountIntegrableBatch ' + cron, cron, new AccountIntegrableBatch());
        }
    }
    
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%AccountIntegrableBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
            
        }
    }
    
    public Iterable<SObject> start(Database.BatchableContext param1) {
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
            .setCondition(DW_QueryCondition.newInstance('StatusIntegracao__c', new List<String>{'Pendente'}))
            .setCondition(DW_QueryCondition.newInstance('TentativasIntegracao__c', '<=', 3))
            .withParent('Representante__r', 'Account')
            .with('AccountContactRelations', 'AccountContactRelation')
            .run();
        return (List<Account>)sObjectList;
    }
    
    public void execute(Database.BatchableContext param1, List<Account> accountList) {
        List<HttpRequestLog__c> httpRequestLogList = new List<HttpRequestLog__c>();
        Set<String> recipientsIds = null;
        Set<Id> accountSet = new Set<Id>();
        for (Account account : accountList){
            accountSet.add(account.Id);
            HttpRequestLog__c log = new HttpRequestLog__c();
            try{
                AccountIntegrable accountIntegrable = new AccountIntegrable();
                accountIntegrable.callIntegration(account);
                System.debug('@@@accountIntegrable: ' + accountIntegrable);
                if(DW_Helper.hasSomeContent(accountIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(accountIntegrable.requestFactoryInstance.getLog())){
                    log = accountIntegrable.requestFactoryInstance.getLog();
                }
                if(accountIntegrable.isSuccess){
                    AccountIntegrableResponseTemplate responseTemplate = (AccountIntegrableResponseTemplate)accountIntegrable.deserializedResponseObject;
                    if (responseTemplate != null ) {
                        if(!DW_Helper.isNullOrBlank(accountIntegrable.responseTemplate)
                           && !DW_Helper.isNullOrBlank(accountIntegrable.responseTemplate.Retorno)
                           && accountIntegrable.responseTemplate.Retorno.size() > 0
                           && DW_Helper.hasSomeContent(accountIntegrable.responseTemplate.Retorno[0].codigoERP.trim()))
                        {
                            
                            if(account.NomeTipoRegistro__c == 'Cliente'){
                                account.CodigoERP__c = accountIntegrable.responseTemplate.Retorno[0].codigoERP;
                                account.Codigo_Emitente__c = accountIntegrable.responseTemplate.Retorno[0].codigo;
                                account.StatusIntegracao__c = 'Executado com sucesso';   
                            }
                            if(account.NomeTipoRegistro__c == 'Vendedor'){
                                account.CodigoERPVendedor__c = accountIntegrable.responseTemplate.Retorno[0].codigoERP;
                                account.Codigo_Emitente__c = accountIntegrable.responseTemplate.Retorno[0].codigo;
                                account.StatusIntegracao__c = 'Executado com sucesso';   
                            }
                            if(account.NomeTipoRegistro__c == 'Transportadora'){
                                account.CodigoERPTransportadora__c = accountIntegrable.responseTemplate.Retorno[0].codigoERP;
                                account.Codigo_Emitente__c = accountIntegrable.responseTemplate.Retorno[0].codigo;
                                account.StatusIntegracao__c = 'Executado com sucesso';   
                            }
                            
                        }else{
                            account.StatusIntegracao__c = 'Executado com erro';
                        }
                        //if(responseTemplate.codigoERP != null && responseTemplate.codigoERP != ''){
                        //Integer strSize = accountIntegrable.responseTemplate.Retorno[0].codigoERP.length();
                        //String loja = accountIntegrable.responseTemplate.Retorno[0].loja;
                        
                        //}
                    }else{
                        account.StatusIntegracao__c = 'Executado com erro';
                        log.ResponseBody__c = 'Erro na formação da requisição. ' + accountIntegrable.errorMessage;
                        recipientsIds = new Set<String>();
                        recipientsIds.add(account.OwnerId);
                        List<User> UsersAdmin = [SELECT id FROM USER WHERE Notificar__c = true];
                        for(User user : UsersAdmin){
                            recipientsIds.add(user.id);
                        }
                        CustomNotification.notifyUsers(recipientsIds, account.Id, 'Conta', account.Name);                     }
                }else{
                    account.StatusIntegracao__c = 'Executado com erro';
                    log.ResponseBody__c = 'Erro na formação da requisição. ' + accountIntegrable.errorMessage;
                    recipientsIds = new Set<String>();
                    recipientsIds.add(account.OwnerId);
                    List<User> UsersAdmin = [SELECT id FROM USER WHERE Notificar__c = true];
                    for(User user : UsersAdmin){
                        recipientsIds.add(user.id);
                    }
                    CustomNotification.notifyUsers(recipientsIds, account.Id, 'Conta', account.Name); 
                }
                
            }catch (Exception e){
                System.debug(LoggingLevel.ERROR, '@@@AccountIntegrableBatch e.getMessage()' + e.getMessage());
                System.debug(LoggingLevel.ERROR, '@@@AccountIntegrableBatch e.getStackTraceString()' + e.getStackTraceString());
                account.StatusIntegracao__c = 'Executado com erro';
                recipientsIds = new Set<String>(); 
                recipientsIds.add(account.OwnerId);
                List<User> UsersAdmin = [SELECT id FROM USER WHERE Notificar__c = true];
                for(User user : UsersAdmin){
                    recipientsIds.add(user.id);
                }
                CustomNotification.notifyUsers(recipientsIds, account.Id, 'Conta', account.Name);           
            }finally {
                log.Conta__c = account.Id;
                log.Name = 'Integração da conta (Id): ' + account.Id;
                httpRequestLogList.add(log);
                account.TentativasIntegracao__c = account.TentativasIntegracao__c == null
                    ? 1
                    : account.TentativasIntegracao__c+1;
            }
        }
        
        if (httpRequestLogList.size() > 0) {
            insert httpRequestLogList;
        }
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(accountSet, accountList, 'Erro ao tentar enviar conta para o ERP. ');
    }
    
    public void finish(Database.BatchableContext param1) {
    }
    
}