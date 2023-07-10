@IsTest
public class DWMercosTranspIntegrableBatchTest {
 @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosTransportadoraIntegrableBatch());
    }
    @IsTest
    public static void postAccountSuccessMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transportadora').getRecordTypeId();
        
        acc.recordTypeId = recordTypeIdCliente;
        acc.Name = 'teste';
        acc.Documento__c = '10337577994';
        acc.BillingStreet = 'Rua de cobrança, 999, loja 2, Bairro de Tal';
        acc.BillingPostalCode = '83055050';
        acc.BairroCobranca__c = 'bairro cobrança';
        acc.BillingCity = 'cidade cobrança';
        acc.BillingState = 'CE';
        acc.BillingCountry = 'Brasil';
        acc.ShippingState = 'ES';
        acc.ShippingCity = 'cidade entrega';
        acc.Bairro__c = 'bairro entrega';
        acc.ShippingStreet = 'Rua de entrega, 999, loja 2, Bairro de Tal';
        acc.ShippingPostalCode = '83055050';
        insert acc;
        
        
        Test.startTest();
        List<Account> lsAcc = new List<Account>();
        lsAcc.add(acc);
        DWMercosTransportadoraIntegrableBatch batch = new DWMercosTransportadoraIntegrableBatch();
        batch.execute(null, lsAcc);
        Test.stopTest();
    }
     @IsTest
    public static void postTranspCancelMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transportadora').getRecordTypeId();
        
        acc.recordTypeId = recordTypeIdCliente;
        acc.Name = 'teste';
        acc.Documento__c = '10337577994';
        acc.BillingStreet = 'Rua de cobrança, 999, loja 2, Bairro de Tal';
        acc.BillingPostalCode = '83055050';
        acc.BairroCobranca__c = 'bairro cobrança';
        acc.BillingCity = 'cidade cobrança';
                acc.BillingCountry = 'Brasil';

        acc.BillingState = 'CE';
        acc.ShippingState = 'ES';
        acc.ShippingCity = 'cidade entrega';
        acc.Bairro__c = 'bairro entrega';
        acc.ShippingStreet = 'Rua de entrega, 999, loja 2, Bairro de Tal';
        acc.ShippingPostalCode = '83055050';
        insert acc;
        
        
        Test.startTest();
        List<Account> lsAcc = new List<Account>();
        
        DWMercosTransportadoraIntegrableBatch.cancelThisSchedule();
        
        Test.stopTest();
    }
      @IsTest
    public static void postTestQaMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transportadora').getRecordTypeId();
        
        acc.recordTypeId = recordTypeIdCliente;
        acc.Name = 'teste';
        acc.Documento__c = '10337577994';
        acc.BillingStreet = 'Rua de cobrança, 999, loja 2, Bairro de Tal';
        acc.BillingPostalCode = '83055050';
        acc.BairroCobranca__c = 'bairro cobrança';
                acc.BillingCountry = 'Brasil';

        acc.BillingCity = 'cidade cobrança';
        acc.BillingState = 'CE';
        acc.ShippingState = 'ES';
        acc.ShippingCity = 'cidade entrega';
        acc.Bairro__c = 'bairro entrega';
        acc.ShippingStreet = 'Rua de entrega, 999, loja 2, Bairro de Tal';
        acc.ShippingPostalCode = '83055050';
        insert acc;
        
        
        Test.startTest();
        List<String> lsAcc = new List<String>();
        lsAcc.add(acc.Id);

        DWMercosTransportadoraIntegrableBatch.testQA(lsAcc);
        
        Test.stopTest();
    }
     @IsTest
    public static void postTestScheduleMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Transportadora').getRecordTypeId();
        
        acc.recordTypeId = recordTypeIdCliente;
        acc.Name = 'teste';
        acc.Documento__c = '10337577994';
        acc.BillingStreet = 'Rua de cobrança, 999, loja 2, Bairro de Tal';
        acc.BillingPostalCode = '83055050';
        acc.BairroCobranca__c = 'bairro cobrança';
                acc.BillingCountry = 'Brasil';

        acc.BillingCity = 'cidade cobrança';
        acc.BillingState = 'CE';
        acc.ShippingState = 'ES';
        acc.ShippingCity = 'cidade entrega';
        acc.Bairro__c = 'bairro entrega';
        acc.ShippingStreet = 'Rua de entrega, 999, loja 2, Bairro de Tal';
        acc.ShippingPostalCode = '83055050';
        insert acc;
        
        
        Test.startTest();
        List<String> lsAcc = new List<String>();
        lsAcc.add(acc.Id);

        DWMercosTransportadoraIntegrableBatch.scheduleThisClass(null);
        
        Test.stopTest();
    }
}