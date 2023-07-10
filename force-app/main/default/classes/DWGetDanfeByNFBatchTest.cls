@IsTest
public class DWGetDanfeByNFBatchTest {
    @IsTest static void success(){
        Test.setMock(HttpCalloutMock.class, new DWDANFEIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        NotaFiscal__c notaFiscal = new NotaFiscal__c();
        notaFiscal.DataEmissao__c = System.today();
        notaFiscal.Conta__c = acc.Id;
        notaFiscal.Valor__c = 242;
        notaFiscal.Status__c = 'OK';
        notaFiscal.TipoNotaFiscal__c = 'N';
        notaFiscal.CodigoERP__c = '2425';
        insert notaFiscal;
        
        List<String> idNFList = new List<String>();
        idNFList.add(notaFiscal.id);
        Test.startTest();
        
        DWGetDanfeByNFBatch.testQA(idNFList);
        Test.stopTest();
        
    }
    @IsTest static void error(){
        Test.setMock(HttpCalloutMock.class, new DWDANFEERRORIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        NotaFiscal__c notaFiscal = new NotaFiscal__c();
        notaFiscal.DataEmissao__c = System.today();
        notaFiscal.Conta__c = acc.Id;
        notaFiscal.Valor__c = 242;
        notaFiscal.Status__c = 'OK';
        notaFiscal.TipoNotaFiscal__c = 'N';
        notaFiscal.CodigoERP__c = '2425';
        insert notaFiscal;
        
        List<String> idNFList = new List<String>();
        idNFList.add(notaFiscal.id);
        Test.startTest();
        
        DWGetDanfeByNFBatch.testQA(idNFList);
        Test.stopTest();
        
    }
    @IsTest static void executeBatch(){
        Test.setMock(HttpCalloutMock.class, new DWDANFEERRORIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        NotaFiscal__c notaFiscal = new NotaFiscal__c();
        notaFiscal.DataEmissao__c = System.today();
        notaFiscal.Conta__c = acc.Id;
        notaFiscal.Valor__c = 242;
        notaFiscal.Status__c = 'OK';
        notaFiscal.TipoNotaFiscal__c = 'N';
        notaFiscal.CodigoERP__c = '2425';
        insert notaFiscal;
        
        List<String> idNFList = new List<String>();
        idNFList.add(notaFiscal.id);
        Test.startTest();
        
        DWGetDanfeByNFBatch.scheduleThisClass(null);
        Test.stopTest();
        
    }
    @IsTest static void testrunEveryNMinutes(){
        Test.setMock(HttpCalloutMock.class, new DWDANFEIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        NotaFiscal__c notaFiscal = new NotaFiscal__c();
        notaFiscal.DataEmissao__c = System.today();
        notaFiscal.Conta__c = acc.Id;
        notaFiscal.Valor__c = 242;
        notaFiscal.Status__c = 'OK';
        notaFiscal.TipoNotaFiscal__c = 'N';
        notaFiscal.CodigoERP__c = '2425';
        insert notaFiscal;
        
        List<String> idNFList = new List<String>();
        idNFList.add(notaFiscal.id);
        Test.startTest();
        
        DWGetDanfeByNFBatch.runEveryNMinutes(23);
        Test.stopTest();
        
    }
    @IsTest static void testrunEveryNMinutesInBusinessHours(){
        Test.setMock(HttpCalloutMock.class, new DWDANFEIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        NotaFiscal__c notaFiscal = new NotaFiscal__c();
        notaFiscal.DataEmissao__c = System.today();
        notaFiscal.Conta__c = acc.Id;
        notaFiscal.Valor__c = 242;
        notaFiscal.Status__c = 'OK';
        notaFiscal.TipoNotaFiscal__c = 'N';
        notaFiscal.CodigoERP__c = '2425';
        insert notaFiscal;
        
        List<String> idNFList = new List<String>();
        idNFList.add(notaFiscal.id);
        Test.startTest();
        
        DWGetDanfeByNFBatch.runEveryNMinutesInBusinessHours(23);
        Test.stopTest();
        
    }
    @IsTest static void tescancelThisSchedule(){
        Test.setMock(HttpCalloutMock.class, new DWDANFEIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        NotaFiscal__c notaFiscal = new NotaFiscal__c();
        notaFiscal.DataEmissao__c = System.today();
        notaFiscal.Conta__c = acc.Id;
        notaFiscal.Valor__c = 242;
        notaFiscal.Status__c = 'OK';
        notaFiscal.TipoNotaFiscal__c = 'N';
        notaFiscal.CodigoERP__c = '2425';
        insert notaFiscal;
        
        List<String> idNFList = new List<String>();
        idNFList.add(notaFiscal.id);
        Test.startTest();
        
        DWGetDanfeByNFBatch.cancelThisSchedule();
        Test.stopTest();
        
    }
    

}