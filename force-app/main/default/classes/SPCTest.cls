@IsTest
public class SPCTest {
    @IsTest
    public static void consultCNPJ(){
        Test.setMock(HttpCalloutMock.class, new ApiMockSPC());
        
        
        Account acc = TestFactory.createAccountClienteType();
        update acc;
        
        acc.Documento__c = '05.946.663/0001-17';
        update acc;
        Test.startTest();
        SPC.consultaDocumento(acc.Id, '337');
        Test.stopTest();
    }
    public static void consultWithErrorCNPJ(){
        Test.setMock(HttpCalloutMock.class, new ApiMockSPC());
        
        Account acc = TestFactory.createAccountClienteType();
        update acc;
        
        acc.Documento__c = null;
        update acc;
        Test.startTest();
        SPC.consultaDocumento(null, null);
        Test.stopTest();
    }
    
}