@IsTest
public class DWMercosTituloIntegrableBatchTest {
    @IsTest
    public static void checkBatchAsync() {
        Database.executeBatch(new DWMercosTituloBatch());
    }
    @IsTest
    public static void postTituloSuccessMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        acc.Name = 'teste';
        acc.CodigoExclusivoMercos__c = '1231';
        insert acc;
        
        
        Titulo__c sobj = new Titulo__c();
        sobj.CodigoERPCliente__c = 'CODERPEXEMPLO';              // Código ERP (cliente)
        sobj.Name = '23rrer';                                    // Número  do Título
        sobj.CodigoERP__c = '232323';                             // Código ERP
        sobj.Parcela__c = '1';                                   // Parcela
        sobj.DataEmissao__c = system.today();
        sobj.Tipo__c = 'D';                                      // Tipo
        sobj.Conta__c = acc.id;                         // Conta
        sobj.DataVencimentoReal__c = system.today();   // Data de vencimento (real)
        sobj.Saldo__c = 0;                                        // Saldo
        sobj.DataVencimento__c = system.today();      // Data de vencimento
        sobj.Status__c = 'OK';                                    // Status
        sobj.DataBaixa__c = system.today();           // Data da baixa
        sobj.Valor__c = 2.32520;                                  // Valor
        sobj.CodigoCliente__c = 'eefef';                          // Código Cliente
        sobj.StatusIntegracaoMercos__c = 'Executado com sucesso'; // Status integração 
        insert sobj;
        
        Test.startTest();
        List<Titulo__c> lsTitulo = new List<Titulo__c>();
        lsTitulo.add(sobj);
        DWMercosTituloBatch batch = new DWMercosTituloBatch();
        batch.execute(null, lsTitulo);
        Test.stopTest();
    }
    @IsTest
    public static void postTitulorunAssynMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        acc.Name = 'teste';
        acc.CodigoExclusivoMercos__c = '1231';
        insert acc;
        
        
        Titulo__c sobj = new Titulo__c();
        sobj.CodigoERPCliente__c = 'CODERPEXEMPLO';              // Código ERP (cliente)
        sobj.Name = '23rrer';                                    // Número  do Título
        sobj.CodigoERP__c = '232323';                             // Código ERP
        sobj.Parcela__c = '1';                                   // Parcela
        sobj.DataEmissao__c = system.today();
        sobj.Tipo__c = 'D';                                      // Tipo
        sobj.Conta__c = acc.id;                         // Conta
        sobj.DataVencimentoReal__c = system.today();   // Data de vencimento (real)
        sobj.Saldo__c = 0;                                        // Saldo
        sobj.DataVencimento__c = system.today();      // Data de vencimento
        sobj.Status__c = 'OK';                                    // Status
        sobj.DataBaixa__c = system.today();           // Data da baixa
        sobj.Valor__c = 2.32520;                                  // Valor
        sobj.CodigoCliente__c = 'eefef';                          // Código Cliente
        sobj.StatusIntegracaoMercos__c = 'Executado com sucesso'; // Status integração 
        insert sobj;
        List<String> listString = new List<String>();
        listString.add(sobj.Id);
        Test.startTest();
        DWMercosTituloBatch.testQA(listString);
        Test.stopTest();
    }
    @IsTest
    public static void postTituloCancelMercosMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        acc.Name = 'teste';
        acc.CodigoExclusivoMercos__c = '1231';
        insert acc;
        
        
        Titulo__c sobj = new Titulo__c();
        sobj.CodigoERPCliente__c = 'CODERPEXEMPLO';              // Código ERP (cliente)
        sobj.Name = '23rrer';                                    // Número  do Título
        sobj.CodigoERP__c = '232323';                             // Código ERP
        sobj.Parcela__c = '1';                                   // Parcela
        sobj.DataEmissao__c = system.today();
        sobj.Tipo__c = 'D';                                      // Tipo
        sobj.Conta__c = acc.id;                         // Conta
        sobj.DataVencimentoReal__c = system.today();   // Data de vencimento (real)
        sobj.Saldo__c = 0;                                        // Saldo
        sobj.DataVencimento__c = system.today();      // Data de vencimento
        sobj.Status__c = 'OK';                                    // Status
        sobj.DataBaixa__c = system.today();           // Data da baixa
        sobj.Valor__c = 2.32520;                                  // Valor
        sobj.CodigoCliente__c = 'eefef';                          // Código Cliente
        sobj.StatusIntegracaoMercos__c = 'Executado com sucesso'; // Status integração 
        insert sobj;
        List<String> listString = new List<String>();
        listString.add(sobj.Id);
        Test.startTest();
        DWMercosTituloBatch.cancelThisSchedule();
        Test.stopTest();
    }
    @IsTest
    public static void postTituloscheduleThisClassMercosMercos() {
        Test.setMock(HttpCalloutMock.class, new DaspeMicroserviceMock());
        Account acc = new Account();
        acc.Name = 'teste';
        acc.CodigoExclusivoMercos__c = '1231';
        insert acc;
        
        
        Titulo__c sobj = new Titulo__c();
        sobj.CodigoERPCliente__c = 'CODERPEXEMPLO';              // Código ERP (cliente)
        sobj.Name = '23rrer';                                    // Número  do Título
        sobj.CodigoERP__c = '232323';                             // Código ERP
        sobj.Parcela__c = '1';                                   // Parcela
        sobj.DataEmissao__c = system.today();
        sobj.Tipo__c = 'D';                                      // Tipo
        sobj.Conta__c = acc.id;                         // Conta
        sobj.DataVencimentoReal__c = system.today();   // Data de vencimento (real)
        sobj.Saldo__c = 0;                                        // Saldo
        sobj.DataVencimento__c = system.today();      // Data de vencimento
        sobj.Status__c = 'OK';                                    // Status
        sobj.DataBaixa__c = system.today();           // Data da baixa
        sobj.Valor__c = 2.32520;                                  // Valor
        sobj.CodigoCliente__c = 'eefef';                          // Código Cliente
        sobj.StatusIntegracaoMercos__c = 'Executado com sucesso'; // Status integração 
        insert sobj;
        List<String> listString = new List<String>();
        listString.add(sobj.Id);
        Test.startTest();
        DWMercosTituloBatch.scheduleThisClass(null);
        Test.stopTest();
    }
    
}