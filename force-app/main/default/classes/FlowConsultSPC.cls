public class FlowConsultSPC {
    @InvocableMethod
    public static List<FlowOutput> runBatch(List<FlowInput> flowInputList){
        List<FlowOutput> flowOutputList = new List<FlowOutput>();
        for (FlowInput flowInput : flowInputList){
            if (flowInput.batch == 'consultSPC'){
            	SPC.consultaDocumento(flowInput.recordId, 'codProduct');        
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