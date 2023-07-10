/**
 * Created by guilhermereis on 06/11/21.
 */
@IsTest
public with sharing class BatchSyncFlowControllerTest {
    @IsTest
    public static void main(){
        List<BatchSyncFlowController.FlowInput> batchInputList = new List<BatchSyncFlowController.FlowInput>{
                new BatchSyncFlowController.FlowInput('OrderIntegrableBatch', '3017h000000EBjtAAG'),
                new BatchSyncFlowController.FlowInput('AccountIntegrableBatch', '3017h000000EBjtAAG')
        };
        BatchSyncFlowController.runBatch(batchInputList);
    }
}