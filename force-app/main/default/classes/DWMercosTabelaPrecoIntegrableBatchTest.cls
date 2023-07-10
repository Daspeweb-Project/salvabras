@IsTest
public class DWMercosTabelaPrecoIntegrableBatchTest {
    @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosTabelaPrecoIntegrableBatch());
    }
    @IsTest
    public static void postPricebookSuccessMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';                                                                                      // Nome do produto
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;                                                                                                             // IPI
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 20%';
        pb.Empresa__c ='Salvabras';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        
        
        Test.startTest();
        List<Pricebook2> lsPb = new List<Pricebook2>();
        lsPb.add(pb);
        DWMercosTabelaPrecoIntegrableBatch batch = new DWMercosTabelaPrecoIntegrableBatch();
        batch.execute(null, lsPb);
        Test.stopTest();
    }
    @IsTest
    public static void postPricebookAsyncMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';                                                                                      // Nome do produto
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;                                                                                                             // IPI
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 20%';
        pb.Empresa__c ='Salvabras';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        
        List<String> listString = new List<String>();
        listString.add(pb.Id);
        Test.startTest();
        
        DWMercosTabelaPrecoIntegrableBatch.testQA(listString);
        Test.stopTest();
    }
    @IsTest
    public static void postPricebookCancelMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';                                                                                      // Nome do produto
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;                                                                                                             // IPI
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 20%';
        pb.Empresa__c ='Salvabras';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        
        List<String> listString = new List<String>();
        listString.add(pb.Id);
        Test.startTest();
        
        DWMercosTabelaPrecoIntegrableBatch.cancelThisSchedule();
        Test.stopTest();
    }
    @IsTest
    public static void scheduleThisClassMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Product2 product = new Product2();
        product.Name = 'teste';                                                                                      // Nome do produto
        product.Embalagem_Master__c = 'Unitário';                                                                                      // Embalagem Master
        product.CodigoERP__c = 'vini131313';                                                                                                // Código ERP
        product.NCM__c = 73.269;                                                                                                  // NCM
        product.Peso_KG__c = 0.75;                                                                                                    // Peso (KG
        product.IPI__c = 5;                                                                                                             // IPI
        product.Calculo_IPI__c = 1.05;                                                                                                // Calculo IPI
        product.Custo_de_Produto_Bras__c = 123123123;                                                                                      // Custo Bras
        product.Custo_de_Produto_Pro__c = 123123;                                                                                      // Custo Pro
        insert product;
        Pricebook2 pb = new Pricebook2();
        pb.Name = 'Salvabras Revenda 20%';
        pb.Empresa__c ='Salvabras';
        pb.ICMS_Simples__c = '12%';
        insert pb;
        
        List<String> listString = new List<String>();
        listString.add(pb.Id);
        Test.startTest();
        
        DWMercosTabelaPrecoIntegrableBatch.scheduleThisClass(null);
        Test.stopTest();
    }
}