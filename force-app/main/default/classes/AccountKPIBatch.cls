public class AccountKPIBatch implements Database.Batchable<Account>, Schedulable {    
    public Integer recordsProcessed = 0;
    
    public static void scheduleThisClass(String cron){
        System.schedule('Recalcular m�dia de oportunidades ganhas', cron == null ? '0 28 * * * ?' : cron, new AccountKPIBatch());
    }
    
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new AccountKPIBatch(), 1);
    }

    public static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
                SELECT Id, CronJobDetail.name
                FROM CronTrigger
                WHERE CronJobDetail.name LIKE '%AccountKPIBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
        }
    }

    public static void runInSyncMode(Id accId){
        AccountKPIBatch batch = new AccountKPIBatch();
        List<Account> sObjectList = [SELECT Id FROM Account WHERE Id = :accId];
        batch.execute(null, sObjectList);
    } 
    
    public List<Account> start(Database.BatchableContext bc) {
        return [SELECT Id, FaturamentoMedioUltimos3meses__c, FaturamentoMedioUltimos6meses__c FROM Account];
    }

    public void execute(Database.BatchableContext bc, List<Account> records){
        for (Account account : records) {
            account.FaturamentoMedioUltimos3meses__c = AccountKPIBatchHelper.getAverage(account.Id, 3);
            account.FaturamentoMedioUltimos6meses__c = AccountKPIBatchHelper.getAverage(account.Id, 6);
            recordsProcessed = recordsProcessed + 1;
        }

        update records;
    }

    public void finish(Database.BatchableContext bc){
        System.debug(recordsProcessed + ' records processed.');

    }
}