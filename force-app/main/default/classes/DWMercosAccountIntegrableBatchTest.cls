@IsTest
public class DWMercosAccountIntegrableBatchTest {
    @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosAccountIntegrableBatch());
    }
    @IsTest
    public static void postAccountSuccessMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
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
        Contact contact = new Contact();
        contact.LastName = 'Pecuch';
        contact.Email = 'v.pecuch@daspeweb.com.br';
        contact.MobilePhone  = '41998233505';
        contact.AccountId = acc.Id;
        insert contact;
        
        Test.startTest();
        List<Account> lsAcc = new List<Account>();
        lsAcc.add(acc);
        DWMercosAccountIntegrableBatch batch = new DWMercosAccountIntegrableBatch();
        batch.execute(null, lsAcc);
        Test.stopTest();
    }
    @IsTest
    public static void postAccountAsyncMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
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
        Contact contact = new Contact();
        contact.LastName = 'Pecuch';
        contact.Email = 'v.pecuch@daspeweb.com.br';
        contact.MobilePhone  = '41998233505';
        contact.AccountId = acc.Id;
        insert contact;
        List<String> listString = new List<String>();
        listString.add(acc.Id);
        Test.startTest();
       
        DWMercosAccountIntegrableBatch.testQA(listString);
        
        Test.stopTest();
    }
    @IsTest
    public static void postAccountCancelMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
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
        Contact contact = new Contact();
        contact.LastName = 'Pecuch';
        contact.Email = 'v.pecuch@daspeweb.com.br';
        contact.MobilePhone  = '41998233505';
        contact.AccountId = acc.Id;
        insert contact;
        List<String> listString = new List<String>();
        listString.add(acc.Id);
        Test.startTest();
       
        DWMercosAccountIntegrableBatch.cancelThisSchedule();
        
        Test.stopTest();
    }
    @IsTest
    public static void scheduleThisClassMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        Id recordTypeIdCliente = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Cliente').getRecordTypeId();
        
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
        Contact contact = new Contact();
        contact.LastName = 'Pecuch';
        contact.Email = 'v.pecuch@daspeweb.com.br';
        contact.MobilePhone  = '41998233505';
        contact.AccountId = acc.Id;
        insert contact;
        List<String> listString = new List<String>();
        listString.add(acc.Id);
        Test.startTest();
       
        DWMercosAccountIntegrableBatch.scheduleThisClass(null);
        
        Test.stopTest();
    }
}