/**
* Created by guilhermereis on 08/12/2020.
*/

public class BatchSyncFlowController {
    @InvocableMethod
    public static List<FlowOutput> runBatch(List<FlowInput> flowInputList){
        List<FlowOutput> flowOutputList = new List<FlowOutput>();
        for (FlowInput flowInput : flowInputList){
            if (flowInput.batch == 'OrderIntegrableBatch'){
                if(!Test.isRunningTest()){
                    OrderIntegrableBatch.runInSyncMode(flowInput.recordId);
                }
                flowOutputList.add(new FlowOutput(true));
            }else if (flowInput.batch == 'AccountIntegrableBatch'){
                if(!Test.isRunningTest()){
                    AccountIntegrableBatch.runInSyncMode(flowInput.recordId);
                }
                flowOutputList.add(new FlowOutput(true));
            }else{
                flowOutputList.add(new FlowOutput(false));
            }
        }
        return flowOutputList;
    }

    public class FlowInput{
        @InvocableVariable
        public String batch;
        @InvocableVariable
        public Id recordId;
        public FlowInput(){
        }
        public FlowInput(String batch, Id recordId){
            this.batch = batch;
            this.recordId = recordId;
        }
    }

    public class FlowOutput{
        @InvocableVariable
        public Boolean isDispatched;
        public FlowOutput(Boolean isDispatched){
            this.isDispatched = isDispatched;
        }
    }
}