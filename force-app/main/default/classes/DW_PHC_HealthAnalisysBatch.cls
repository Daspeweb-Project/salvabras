/**
 * Created by guilhermereis on 02/02/22.
 */

global with sharing class DW_PHC_HealthAnalisysBatch implements Database.Batchable<sObject>,Schedulable{
    String cycle;
    
    public DW_PHC_HealthAnalisysBatch(String cycle){
        this.cycle = cycle;
    }
    
    public static void runInSyncMode(Id accountId){
        Account account = [SELECT Id, CreatedDate , PortfolioHealthControl__c, PHCCicloFinalModa2__c, FaturamentoMedioUltimos6Meses__c FROM Account WHERE Id = :accountId LIMIT 1];
        DW_PHC_HealthAnalisysBatch batch = new DW_PHC_HealthAnalisysBatch(account.PHCCicloFinalModa2__c);
        batch.execute(null, new List<Account>{account});
    }
    
    public static void scheduleThisClass(String cron){
        System.schedule('DW_PHC_HealthAnalisysBatch', cron == null ? '0 28 * * * ?' : cron, new DW_PHC_HealthAnalisysBatch());
    }

    public DW_PHC_HealthAnalisysBatch(){
    }

    global void execute(SchedulableContext ctx) {
        //7, 10, 15, 20, 25, 30, 45, 60, 75, 90, 120, 150, 180, 360
        List<String> phcSegmentationList = new List<String>();
        phcSegmentationList.add('007 dias');
        phcSegmentationList.add('010 dias');
        phcSegmentationList.add('015 dias');
        phcSegmentationList.add('020 dias');
        phcSegmentationList.add('025 dias');
        phcSegmentationList.add('030 dias');
        phcSegmentationList.add('045 dias');
        phcSegmentationList.add('060 dias');
        phcSegmentationList.add('075 dias');
        phcSegmentationList.add('090 dias');
        phcSegmentationList.add('120 dias');
        phcSegmentationList.add('150 dias');
        phcSegmentationList.add('180 dias');
        phcSegmentationList.add('360 dias');
        
        for(String phcSegmentation : phcSegmentationList){
            if(!Test.isRunningTest()){
                Database.executeBatch(new DW_PHC_HealthAnalisysBatch(phcSegmentation), 20);
            }
        }
    }

    global Iterable<SObject> start(Database.BatchableContext BC){
        List<SObject> sObjectList = DW_QueryFactory.get('Account')
                .setCondition(DW_QueryCondition.newInstance('PHCCicloFinalModa2__c', '=', this.cycle))
                .run();
        return (List<Account>)sObjectList;
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList){
        Set<Id> accountSet = new Set<Id>();
        List<Account> accToUpdate = new List<Account>();
        for (Account acc : accountList) accountSet.add(acc.Id);
        Integer daysToEvaluate = getDaysToEvaluateBasedOnCycle();

        Map<Id, Double> resultByAccountMapCycle1 = calcTotalByCycle(accountSet, daysToEvaluate);
        Map<Id, Double> resultByAccountMapCycle2 = calcTotalByCycle(accountSet, daysToEvaluate * 2);
        Map<Id, Double> resultByAccountMapCycle3 = calcTotalByCycle(accountSet, daysToEvaluate * 3);
        Map<Id, Double> resultByAccountMapCycle4 = calcTotalByCycle(accountSet,  daysToEvaluate * 4);
        Map<Id, Double> resultByAccountMapCycle5 = calcTotalByCycle(accountSet,  daysToEvaluate * 5);

        for(Account acc : accountList){
            acc.PHCciclo1__c = resultByAccountMapCycle1.get(acc.Id);
            acc.PHCciclo2__c = resultByAccountMapCycle2.get(acc.Id);
            acc.PHCciclo3__c = resultByAccountMapCycle3.get(acc.Id);
            acc.PHCciclo4__c = resultByAccountMapCycle4.get(acc.Id);
            acc.PHCciclo5__c = resultByAccountMapCycle5.get(acc.Id);
            acc.PHCciclo2__c = acc.PHCciclo2__c - acc.PHCciclo1__c;
            acc.PHCciclo3__c = acc.PHCciclo3__c - acc.PHCciclo2__c - acc.PHCciclo1__c;
            acc.PHCciclo4__c = acc.PHCciclo4__c - acc.PHCciclo3__c - acc.PHCciclo2__c - acc.PHCciclo1__c;
            acc.PHCciclo5__c = acc.PHCciclo5__c - acc.PHCciclo4__c - acc.PHCciclo3__c - acc.PHCciclo2__c - acc.PHCciclo1__c;
            String pchSegmentation = getPCHSegmentation(acc.PHCciclo5__c, acc.PHCciclo4__c, acc.PHCciclo3__c, acc.PHCciclo2__c, acc.PHCciclo1__c, acc.FaturamentoMedioUltimos6Meses__c, Date.newInstance(acc.CreatedDate.year(), acc.CreatedDate.month(), acc.CreatedDate.day()));
            //if(pchSegmentation != acc.PortfolioHealthControl__c){
                acc.PortfolioHealthControl__c = pchSegmentation;
                acc.UltimaAtualizacaoSegmentacaoPHC__c = System.now();
                accToUpdate.add(acc);
            //}
            System.debug(LoggingLevel.INFO, '@@@acc.PortfolioHealthControl__c: ' + acc.PortfolioHealthControl__c);

        }
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(accountSet, accountList, 'Erro ao tentar calcular HC.');
    }
    public String getPCHSegmentation(Decimal ciclo5, Decimal ciclo4, Decimal ciclo3, Decimal ciclo2, Decimal ciclo1, Decimal averageMonthRevenue, Date createdDate){
        String phc = '';
        if(ciclo5 > 0 && ciclo4 > 0 && ciclo3 > 0 && ciclo2 > 0 && ciclo1 > 0){
            phc = 'Fiel';
        }
        if(ciclo2 > 0 && ciclo1 == 0){
            phc = 'Ponto de pedido';
        }
        if(/*ciclo5 > 0 && ciclo4 > 0 && */ciclo3 > 0 && ciclo2 == 0 && ciclo1 == 0){
            phc = 'Perdendo';
        }
        if((ciclo5 > 0 || ciclo4 > 0) && ciclo3 == 0 && ciclo2 == 0 && ciclo1 == 0){
            phc = 'Perdido';
        }
        if(ciclo5 == 0 && ciclo4 == 0 && ciclo3 == 0 && ciclo2 == 0 && ciclo1 == 0){
            phc = 'Inativo';
        }
        if(ciclo2 == 0 && ciclo1 > 0){
            phc = 'Recuperando';
        }
        if(ciclo3 == 0 && ciclo2 > 0 && ciclo1 > 0){
            phc = 'Recuperado';
        }
        if((ciclo5 == 0 || ciclo4 == 0) && ciclo3 > 0 && ciclo2 > 0 && ciclo1 > 0){
            phc = 'Mantido';
        }
        if(ciclo5 == 0 && ciclo4 == 0 && ciclo3 == 0 && ciclo2 == 0 && ciclo1 > 0 && averageMonthRevenue > 0){
            phc = 'Reabertura';
        }
        //if(ciclo5 == 0 && ciclo4 == 0 && ciclo3 == 0 && ciclo2 == 0 && ciclo1 > 0 && createdDate > System.today().addDays(-30)){
        if(createdDate > System.today().addDays(-30)){
        	phc = 'Abertura';
        }
        return phc;
    }
    public Integer getDaysToEvaluateBasedOnCycle(){
        Integer daysToEvaluate = null;
        if(this.cycle == '007 dias'){
            daysToEvaluate = 7;
        }else if(this.cycle == '010 dias'){
            daysToEvaluate = 10;
        }else if(this.cycle == '015 dias'){
            daysToEvaluate = 15;
        }else if(this.cycle == '020 dias'){
            daysToEvaluate = 20;
        }else if(this.cycle == '025 dias'){
            daysToEvaluate = 25;
        }else if(this.cycle == '030 dias'){
            daysToEvaluate = 30;
        }else if(this.cycle == '045 dias'){
            daysToEvaluate = 45;
        }else if(this.cycle == '060 dias'){
            daysToEvaluate = 60;
        }else if(this.cycle == '075 dias'){
            daysToEvaluate = 75;
        }else if(this.cycle == '090 dias'){
            daysToEvaluate = 90;
        }else if(this.cycle == '120 dias'){
            daysToEvaluate = 120;
        }else if(this.cycle == '150 dias'){
            daysToEvaluate = 150;
        }else if(this.cycle == '180 dias'){
            daysToEvaluate = 180;
        }else{
            daysToEvaluate = 360;
        }
        return daysToEvaluate;
    }

    public Map<Id, Double> calcTotalByCycle(Set<Id> accountSet, Integer daysTofilter){
        Date dateFrom = System.today().addDays(daysTofilter*-1);
        Date dateTo = System.today();
        Map<Id, Double> resultByAccountMap = new Map<Id, Double>();
        for (Id accountId : accountSet){
            resultByAccountMap.put(accountId, 0);
        }
                    
        AggregateResult[] aggResultList = [
            SELECT
                SUM(TotalAmount) periodSum,
                AccountId AccountId
            FROM Order
            WHERE Status IN ('Ativado')
            AND Type IN ('N') 
            AND AccountId IN : accountSet
            AND EffectiveDate >= :dateFrom
            AND EffectiveDate <= :dateTo
            GROUP BY AccountId
        ];
        System.debug(LoggingLevel.ERROR, '@@@@DW_PHC_HealthAnalisysBatch.calcTotalByCycle -> aggResultList: ' + aggResultList);
        for(AggregateResult aggregateResult : aggResultList){
            Double periodSum = Double.valueOf(aggregateResult.get('periodSum'));
            resultByAccountMap.put(String.valueOf(aggregateResult.get('AccountId')), periodSum == null ? 0 : periodSum);
        }
        return resultByAccountMap;
    }

    global void finish(Database.BatchableContext BC)
    {

    }
}