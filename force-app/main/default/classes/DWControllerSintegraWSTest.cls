@isTest
public class DWControllerSintegraWSTest {
    public static String documentTest = '06990590000123';
    
	@isTest
    public static void getSintegraSaldoTest(){
        Test.startTest();
        Database.SaveResult accountResult = Database.insert(new Account(
        	Name = 'getSintegraSaldoTest',
            Documento__c = DWControllerSintegraWSTest.documentTest
        ));
        DWControllerSintegraWS.getSintegraSaldo(accountResult.getId());
        Test.stopTest();
    }
}