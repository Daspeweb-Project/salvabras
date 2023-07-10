@isTest
public class DwGetSintegraWSTest {    
	@isTest
    public static void getSintegraDataTestSt(){
        Test.setMock(HttpCalloutMock.class, new DwGetSintegraWSMock('ST'));
        Database.SaveResult accountResult = Database.insert(new Account(
        	Name = 'getSintegraDataTestST',
            Documento__c = DWControllerSintegraWSTest.documentTest
        ));
        Test.startTest();
        DWControllerSintegraWS.getSintegraData(
            accountResult.getId(),
            'ST',
            null,
            null,
            DWControllerSintegraWSTest.documentTest,
            null
        );
        Test.stopTest();
    }
    
	@isTest
    public static void getSintegraDataTestSn(){
        Test.setMock(HttpCalloutMock.class, new DwGetSintegraWSMock('SN'));
        Database.SaveResult accountResult = Database.insert(new Account(
        	Name = 'getSintegraDataTestSn',
            Documento__c = DWControllerSintegraWSTest.documentTest
        ));
        Test.startTest();
        DWControllerSintegraWS.getSintegraData(
            accountResult.getId(),
            'SN',
            null,
            null,
            DWControllerSintegraWSTest.documentTest,
            null
        );
        Test.stopTest();
    }
    
	@isTest
    public static void getSintegraDataTestRf(){
        Test.setMock(HttpCalloutMock.class, new DwGetSintegraWSMock('RF'));
        Database.SaveResult accountResult = Database.insert(new Account(
        	Name = 'getSintegraDataTestRf',
            Documento__c = DWControllerSintegraWSTest.documentTest
        ));
        Test.startTest();
        DWControllerSintegraWS.getSintegraData(
            accountResult.getId(),
            'RF',
            null,
            null,
            DWControllerSintegraWSTest.documentTest,
            null
        );
        Test.stopTest();
    }
    
	@isTest
    public static void getSintegraDataTestCPF(){
        Test.setMock(HttpCalloutMock.class, new DwGetSintegraWSMock('CPF'));
        Database.SaveResult accountResult = Database.insert(new Account(
        	Name = 'getSintegraDataTestCPF',
            Documento__c = DWControllerSintegraWSTest.documentTest
        ));
        Test.startTest();
        DWControllerSintegraWS.getSintegraData(
            accountResult.getId(),
            'CPF',
            null,
            null,
            DWControllerSintegraWSTest.documentTest,
            null
        );
        Test.stopTest();
    }
    
	@isTest
    public static void getSintegraDataTestCatch(){
        Test.setMock(HttpCalloutMock.class, new DwGetSintegraWSMock('tete'));
        Database.SaveResult accountResult = Database.insert(new Account(
        	Name = 'getSintegraDataTestCatch',
            Documento__c = DWControllerSintegraWSTest.documentTest
        ));
        Test.startTest();
        DWControllerSintegraWS.getSintegraData(
            accountResult.getId(),
            'CPF',
            null,
            null,
            DWControllerSintegraWSTest.documentTest,
            null
        );
        Test.stopTest();
    }
}