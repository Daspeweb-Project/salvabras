@IsTest
public class DWMercosEntradaTabelaPrecoIntegrableTest {
    @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosPbEntryPrecoIntegrableBatch());
    }
    @IsTest
    public static void postPricebookEntrySuccessMercos() {
        Id recordTypeIdProduto = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Produto Concorrente').getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';  
        product.recordTypeId = recordTypeIdProduto;
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.CodigoExclusivoMercos__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;  
        product.CodigoExclusivoMercos__c= '23535';
        
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb2 = TestFactory.createPricebook();
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 18%';
        pb.Empresa__c ='Salvabras';
        pb.CodigoExclusivoMercos__c= '23535';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, product);
        
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pb.id;
        
        pbEntry.CodigoExclusivoMercos__c= '23535';
        pbEntry.UnitPrice = 1313131313.0;
        pbEntry.Product2Id =product.Id;
        insert pbEntry;
        
        Test.startTest();
        List<PricebookEntry> lsPbEntry = new List<PricebookEntry>();
        lsPbEntry.add(pbEntry);
        DWMercosPbEntryPrecoIntegrableBatch batch = new DWMercosPbEntryPrecoIntegrableBatch();
        batch.execute(null, lsPbEntry);
        Test.stopTest();
    }
    @IsTest
    public static void postPricebookRunAssynMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Id recordTypeIdProduto = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Produto Concorrente').getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';  
        product.recordTypeId = recordTypeIdProduto;
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.CodigoExclusivoMercos__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;  
        product.CodigoExclusivoMercos__c= '23535';
        
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb2 = TestFactory.createPricebook();
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 18%';
        pb.Empresa__c ='Salvabras';
        pb.CodigoExclusivoMercos__c= '23535';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, product);
        
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pb.id;
        
        pbEntry.CodigoExclusivoMercos__c= '23535';
        pbEntry.UnitPrice = 1313131313.0;
        pbEntry.Product2Id =product.Id;
        insert pbEntry;
        List<String> listString = new List<String>();
        listString.add(pbEntry.Id);
        Test.startTest();
        
        DWMercosPbEntryPrecoIntegrableBatch.testQA(listString);
        Test.stopTest();
    }
    @IsTest
    public static void postPricebookCancelMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Id recordTypeIdProduto = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Produto Concorrente').getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';  
        product.recordTypeId = recordTypeIdProduto;
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.CodigoExclusivoMercos__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;  
        product.CodigoExclusivoMercos__c= '23535';
        
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb2 = TestFactory.createPricebook();
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 18%';
        pb.Empresa__c ='Salvabras';
        pb.CodigoExclusivoMercos__c= '23535';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, product);
        
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pb.id;
        
        pbEntry.CodigoExclusivoMercos__c= '23535';
        pbEntry.UnitPrice = 1313131313.0;
        pbEntry.Product2Id =product.Id;
        insert pbEntry;
        List<String> listString = new List<String>();
        listString.add(pbEntry.Id);
        Test.startTest();
        
        DWMercosPbEntryPrecoIntegrableBatch.cancelThisSchedule();
        Test.stopTest();
    }
    @IsTest
    public static void scheduleThisClassMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Id recordTypeIdProduto = Schema.SObjectType.Product2.getRecordTypeInfosByName().get('Produto Concorrente').getRecordTypeId();
        
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';  
        product.recordTypeId = recordTypeIdProduto;
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.CodigoExclusivoMercos__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;  
        product.CodigoExclusivoMercos__c= '23535';
        
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb2 = TestFactory.createPricebook();
        
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 18%';
        pb.Empresa__c ='Salvabras';
        pb.CodigoExclusivoMercos__c= '23535';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        PricebookEntry pricebookEntry = TestFactory.createPricebookEntry(pb2, product);
        
        PricebookEntry pbEntry = new PricebookEntry();
        pbEntry.Pricebook2Id = pb.id;
        
        pbEntry.CodigoExclusivoMercos__c= '23535';
        pbEntry.UnitPrice = 1313131313.0;
        pbEntry.Product2Id =product.Id;
        insert pbEntry;
        List<String> listString = new List<String>();
        listString.add(pbEntry.Id);
        Test.startTest();
        DWMercosPbEntryPrecoIntegrableBatch.scheduleThisClass(null);
        Test.stopTest();
    }
}