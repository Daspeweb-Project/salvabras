@IsTest

public class FlowConsultSPCTest {
    @IsTest
    public static void main(){
        Test.setMock(HttpCalloutMock.class, new ApiMockSPC());
        
        
        Account acc = TestFactory.createAccountClienteType();
        update acc;
        
        acc.Documento__c = '05.946.663/0001-17';
        update acc;
         List<FlowConsultSPC.FlowInput> batchInputList = new List<FlowConsultSPC.FlowInput>{
                new FlowConsultSPC.FlowInput('consultSPC', acc.Id)
        };
        FlowConsultSPC.runBatch(batchInputList);
        
    }
}