@IsTest
public with sharing class DWMercosProduct2IntegrableBatchTest {
    @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosProduct2IntegrableBatch());
    } 
    
    @IsTest
    public static void postProductSuccessMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        
        Product2 objProduct = new Product2(CodigoERP__c= '8301400004',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            Empresa__c ='Salvabras',
            ICMS_Simples__c ='7%',
            IsActive = true
        );
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = objProduct.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        Test.startTest();
        List<Product2> lsAproduct2 = new List<Product2>();
        lsAproduct2.add(objProduct);
        DWMercosProduct2IntegrableBatch batch = new DWMercosProduct2IntegrableBatch();
        batch.execute(null, lsAproduct2);
        Test.stopTest();
    }
    @IsTest
    public static void postProductrunAssynMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        
        Product2 objProduct = new Product2(CodigoERP__c= '8301400004',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            Empresa__c ='Salvabras',
            ICMS_Simples__c ='7%',
            IsActive = true
        );
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = objProduct.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        List<String> listString = new List<String>();
        listString.add(objProduct.Id);
        
        Test.startTest();
        DWMercosProduct2IntegrableBatch.testQA(listString);
        Test.stopTest();
    }  
    @IsTest
    public static void postProductCancelMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        
        Product2 objProduct = new Product2(CodigoERP__c= '8301400004',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            Empresa__c ='Salvabras',
            ICMS_Simples__c ='7%',
            IsActive = true
        );
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = objProduct.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        List<String> listString = new List<String>();
        listString.add(objProduct.Id);
        
        Test.startTest();
        DWMercosProduct2IntegrableBatch.cancelThisSchedule();
        Test.stopTest();
    }
     @IsTest
    public static void scheduleThisClassMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        
        Product2 objProduct = new Product2(CodigoERP__c= '8301400004',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            Empresa__c ='Salvabras',
            ICMS_Simples__c ='7%',
            IsActive = true
        );
        Update standardPricebook;
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        
        PricebookEntry pbe = new PricebookEntry(
            Pricebook2Id = standardPricebook.Id,
            Product2Id = objProduct.Id,
            UnitPrice = 1020,
            IsActive = true
        );
        Insert pbe;
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;
        
        //Query for the Pricebook2 record, to check IsStandard field
        standardPricebook = [SELECT Id, IsStandard FROM Pricebook2 WHERE Id = :standardPricebook.Id];
        List<String> listString = new List<String>();
        listString.add(objProduct.Id);
        
        Test.startTest();
        DWMercosProduct2IntegrableBatch.scheduleThisClass(null);
        Test.stopTest();
    }  
    
}