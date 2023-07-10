@isTest
public class DW_PHC_CycleAnalysisBatchTest {
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
        DW_PHC_CycleAnalysisBatch.runInSyncMode(account.Id);
    }
    
    @isTest
    public static void getMostFrequentTest(){
        DW_PHC_CycleAnalysisBatch batch = new DW_PHC_CycleAnalysisBatch();
        System.assertEquals(5, batch.getMostFrequent(new List<Integer>{1, 2, 3, 4, 5, 6, 7, 8, 2, 3, 4, 5, 6, 5, 6, 5, 8, 9}));
    }
    
    @isTest
    public static void normalizeDiffBetweenDatesV1Test(){
        DW_PHC_CycleAnalysisBatch batch = new DW_PHC_CycleAnalysisBatch();
        System.assertEquals(7, batch.normalizeDiffBetweenDatesV1(7));
        System.assertEquals(10, batch.normalizeDiffBetweenDatesV1(12));
        System.assertEquals(15, batch.normalizeDiffBetweenDatesV1(13));
        System.assertEquals(15, batch.normalizeDiffBetweenDatesV1(17));
        System.assertEquals(20, batch.normalizeDiffBetweenDatesV1(18));
        System.assertEquals(20, batch.normalizeDiffBetweenDatesV1(22));
        System.assertEquals(25, batch.normalizeDiffBetweenDatesV1(23));
        System.assertEquals(25, batch.normalizeDiffBetweenDatesV1(27));
        System.assertEquals(30, batch.normalizeDiffBetweenDatesV1(28));
        System.assertEquals(30, batch.normalizeDiffBetweenDatesV1(38));
        System.assertEquals(45, batch.normalizeDiffBetweenDatesV1(39));
        System.assertEquals(45, batch.normalizeDiffBetweenDatesV1(53));
        System.assertEquals(60, batch.normalizeDiffBetweenDatesV1(54));
        System.assertEquals(60, batch.normalizeDiffBetweenDatesV1(68));
        System.assertEquals(75, batch.normalizeDiffBetweenDatesV1(69));
        System.assertEquals(75, batch.normalizeDiffBetweenDatesV1(83));
        System.assertEquals(90, batch.normalizeDiffBetweenDatesV1(84));
        System.assertEquals(90, batch.normalizeDiffBetweenDatesV1(105));
        System.assertEquals(120, batch.normalizeDiffBetweenDatesV1(106));
        System.assertEquals(120, batch.normalizeDiffBetweenDatesV1(135));
        System.assertEquals(150, batch.normalizeDiffBetweenDatesV1(136));
        System.assertEquals(150, batch.normalizeDiffBetweenDatesV1(165));
        System.assertEquals(180, batch.normalizeDiffBetweenDatesV1(166));
        System.assertEquals(180, batch.normalizeDiffBetweenDatesV1(270));
        System.assertEquals(360, batch.normalizeDiffBetweenDatesV1(400));
    }
    @isTest
    public static void normalizeDiffBetweenDatesV2Test(){
        DW_PHC_CycleAnalysisBatch batch = new DW_PHC_CycleAnalysisBatch();
        System.assertEquals(7, batch.normalizeDiffBetweenDatesV2(7));
        System.assertEquals(15, batch.normalizeDiffBetweenDatesV2(23));
        System.assertEquals(30, batch.normalizeDiffBetweenDatesV2(24));
        System.assertEquals(30, batch.normalizeDiffBetweenDatesV2(38));
        System.assertEquals(45, batch.normalizeDiffBetweenDatesV2(39));
        System.assertEquals(45, batch.normalizeDiffBetweenDatesV2(53));
        System.assertEquals(60, batch.normalizeDiffBetweenDatesV2(54));
        System.assertEquals(60, batch.normalizeDiffBetweenDatesV2(68));
        System.assertEquals(75, batch.normalizeDiffBetweenDatesV2(69));
        System.assertEquals(75, batch.normalizeDiffBetweenDatesV2(83));
        System.assertEquals(90, batch.normalizeDiffBetweenDatesV2(84));
        System.assertEquals(90, batch.normalizeDiffBetweenDatesV2(106));
        System.assertEquals(120, batch.normalizeDiffBetweenDatesV2(107));
        System.assertEquals(120, batch.normalizeDiffBetweenDatesV2(135));
        System.assertEquals(150, batch.normalizeDiffBetweenDatesV2(136));
        System.assertEquals(150, batch.normalizeDiffBetweenDatesV2(165));
        System.assertEquals(180, batch.normalizeDiffBetweenDatesV2(166));
        System.assertEquals(180, batch.normalizeDiffBetweenDatesV2(270));
        System.assertEquals(360, batch.normalizeDiffBetweenDatesV2(400));
    }
}