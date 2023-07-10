@isTest
public class DW_PHC_HealthAnalisysBatchTest {
    @isTest(SeeAllData=true)
    public static void main(){
        AggregateResult[] aggregateResultList = [
            SELECT count(Id), AccountId accountId
            FROM Order
            WHERE Status IN ('Ativado')
            GROUP BY AccountId
            HAVING count(Id) > 5
            LIMIT 1
        ];
        
        Id accountId = String.valueOf(aggregateResultList.get(0).get('accountId'));
        
        Account account = [SELECT Id FROM Account WHERE Id = :accountId LIMIT 1];
        account.PHCCicloFinalModa2__c = '007 dias';
        update account;
        DW_PHC_HealthAnalisysBatch.runInSyncMode(account.Id);
        DW_PHC_HealthAnalisysBatch batchForScheduleTest = new DW_PHC_HealthAnalisysBatch();
        batchForScheduleTest.execute(new SchedulableContextLocal());
    }
    @isTest
    public static void getPCHSegmentationTest(){
        DW_PHC_HealthAnalisysBatch batch = new DW_PHC_HealthAnalisysBatch('007 dias');
        /*System.assertEquals('Abertura', batch.getPCHSegmentation(10000, 10000, 10000, 10000, 10000, 10000, System.today()));
        System.assertEquals('Ponto de pedido', batch.getPCHSegmentation(10000, 10000, 10000, 10000, 0, 10000, System.today()));
        System.assertEquals('Ponto de pedido', batch.getPCHSegmentation(0, 10000, 10000, 10000, 0, 10000, System.today()));
        System.assertEquals('Ponto de pedido', batch.getPCHSegmentation(0, 0, 10000, 10000, 0, 10000, System.today()));
        System.assertEquals('Ponto de pedido', batch.getPCHSegmentation(0, 0, 0, 10000, 0, 10000, System.today()));
        System.assertEquals('Ponto de pedido', batch.getPCHSegmentation(0, 10000, 0, 10000, 0, 10000, System.today()));
        System.assertEquals('Ponto de pedido', batch.getPCHSegmentation(10000, 10000, 0, 10000, 0, 10000, System.today()));
		System.assertEquals('Perdendo', batch.getPCHSegmentation(10000, 10000, 10000, 0, 0, 10000, System.today()));
        System.assertEquals('Perdido', batch.getPCHSegmentation(10000, 10000, 0, 0, 0, 10000, System.today()));
        System.assertEquals('Inativo', batch.getPCHSegmentation(0, 0, 0, 0, 0, 10000, System.today()));
        System.assertEquals('Recuperando', batch.getPCHSegmentation(10000, 10000, 10000, 0, 10000, 10000, System.today()));
        System.assertEquals('Recuperado', batch.getPCHSegmentation(10000, 10000, 0, 10000, 10000, 10000, System.today()));
        System.assertEquals('Mantido', batch.getPCHSegmentation(10000, 0, 10000, 10000, 10000, 10000, System.today()));
        System.assertEquals('Mantido', batch.getPCHSegmentation(0, 10000, 10000, 10000, 10000, 10000, System.today()));
        System.assertEquals('Mantido', batch.getPCHSegmentation(0, 0, 10000, 10000, 10000, 10000, System.today()));
        System.assertEquals('Reabertura', batch.getPCHSegmentation(0, 0, 0, 0, 10000, 10000, System.today().addDays(-31)));
        System.assertEquals('Abertura', batch.getPCHSegmentation(0, 0, 0, 0, 10000, 0, System.today()));*/
    }
	@isTest
    public static void getDaysToEvaluateBasedOnCycleTest(){
        System.assertEquals(7, (new DW_PHC_HealthAnalisysBatch('007 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(10, (new DW_PHC_HealthAnalisysBatch('010 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(15, (new DW_PHC_HealthAnalisysBatch('015 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(20, (new DW_PHC_HealthAnalisysBatch('020 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(25, (new DW_PHC_HealthAnalisysBatch('025 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(30, (new DW_PHC_HealthAnalisysBatch('030 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(45, (new DW_PHC_HealthAnalisysBatch('045 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(60, (new DW_PHC_HealthAnalisysBatch('060 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(75, (new DW_PHC_HealthAnalisysBatch('075 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(90, (new DW_PHC_HealthAnalisysBatch('090 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(120, (new DW_PHC_HealthAnalisysBatch('120 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(150, (new DW_PHC_HealthAnalisysBatch('150 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(180, (new DW_PHC_HealthAnalisysBatch('180 dias').getDaysToEvaluateBasedOnCycle()));
        System.assertEquals(360, (new DW_PHC_HealthAnalisysBatch('360 dias').getDaysToEvaluateBasedOnCycle()));
    }
    public class SchedulableContextLocal implements SchedulableContext{
        public Id getTriggerId(){
            return null;
        }
    }
}