public class DW_AccountKPIBatch implements Database.Batchable<Account>, Schedulable {
    public Integer recordsProcessed = 0;
    
    public static void scheduleThisClass(String cron){
        System.schedule('DW_AccountKPIBatch', cron == null ? '0 28 * * * ?' : cron, new DW_AccountKPIBatch());
    }
     
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new DW_AccountKPIBatch(), 20);
    }

    public static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
                SELECT Id, CronJobDetail.name
                FROM CronTrigger
                WHERE CronJobDetail.name LIKE '%DW_AccountKPIBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
        }
    }

    public static void runInSyncMode(Id accId){
        DW_AccountKPIBatch batch = new DW_AccountKPIBatch();
        List<Account> sObjectList = [SELECT Id, FaturamentoMedioUltimos3Meses__c, FaturamentoMedioUltimos6Meses__c FROM Account WHERE Id = :accId];
        batch.execute(null, sObjectList);
    } 
    
    public List<Account> start(Database.BatchableContext bc) {
        return [SELECT Id, FaturamentoMedioUltimos3Meses__c, FaturamentoMedioUltimos6Meses__c FROM Account];
    }

    public void execute(Database.BatchableContext bc, List<Account> accountList){
        Set<Id> allAccountSet = (new Map<Id, Sobject>(accountList)).keySet();
        Set<Id> accountToDeleteChatterPostSet = new Set<Id>();
        List<Account> accToUpdateList = new List<Account>();

        Map<Id, Decimal> averageByAccountId3Month = DW_AccountKPIBatchHelper.getAverage(allAccountSet, 3);
        Map<Id, Decimal> averageByAccountId6Month = DW_AccountKPIBatchHelper.getAverage(allAccountSet, 6);
        
        for (Account account : accountList) {
            if(account.FaturamentoMedioUltimos3Meses__c != averageByAccountId3Month.get(account.Id) 
                || account.FaturamentoMedioUltimos6Meses__c != averageByAccountId6Month.get(account.Id)
                || Test.isRunningTest())
            {
                account.FaturamentoMedioUltimos3Meses__c  = averageByAccountId3Month.get(account.Id);
                account.FaturamentoMedioUltimos6Meses__c  = averageByAccountId6Month.get(account.Id);
                recordsProcessed = recordsProcessed + 1;
                accToUpdateList.add(account);
                accountToDeleteChatterPostSet.add(account.Id);
            }
        }
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(accountToDeleteChatterPostSet, accToUpdateList, 'Erro ao calcular o valor médio de oportunidades ganhas em n meses.');
    }

    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed.');

    }
}