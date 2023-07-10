@isTest
public class DwGetSaldoSintegraWSTest {
	@isTest
    public static void callSaldoTest(){
        Test.setMock(HttpCalloutMock.class, new DwGetSaldoSintegraWSMock());
        Database.SaveResult accountResult = Database.insert(new Account(
        	Name = 'callSaldoTest',
            Documento__c = DWControllerSintegraWSTest.documentTest
        ));
        Test.startTest();
        DwGetSaldoSintegraWS.callSaldo(accountResult.getId());
        Test.stopTest();
    }
}