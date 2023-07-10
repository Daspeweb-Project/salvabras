@IsTest
public class DWQuoteIntegrableBatchTest {
    @IsTest static void success(){
        Test.setMock(HttpCalloutMock.class, new DWQuoteIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        Product2 objProduct = new Product2(CodigoERP__c= '8301400004',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        Opportunity opp = new Opportunity(name = 'test', AccountId = acc.Id, StageName = 'F1 - Pré - Formalização', closedate = system.today());
        insert opp;
        Quote qut = new Quote(Name = 'teste', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId());
        insert qut;
        QuoteLineItem qlli = new QuoteLineItem(QuoteId = qut.id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
      	insert qlli; 
        Quote qut2 = new Quote(Name = 'teste2', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId(), Cota_o_SalvaBras__c = false);
        insert qut2;
        List<String> idQuoteList = new List<String>();
        idQuoteList.add(qut.id);
        Test.startTest();
        
        DWQuoteIntegrableBatch.testQA(idQuoteList);
        Test.stopTest();
        
    }
    @IsTest static void scheduleThisClass(){
        Test.setMock(HttpCalloutMock.class, new DWQuoteIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        Product2 objProduct = new Product2(CodigoERP__c= '2',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        Opportunity opp = new Opportunity(name = 'test', AccountId = acc.Id, StageName = 'F1 - Pré - Formalização', closedate = system.today());
        insert opp;
        Quote qut = new Quote(Name = 'teste', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId());
        insert qut;
        QuoteLineItem qlli = new QuoteLineItem(QuoteId = qut.id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
      	insert qlli; 
        Quote qut2 = new Quote(Name = 'teste2', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId(), Cota_o_SalvaBras__c = false);
        insert qut2;
        List<String> idQuoteList = new List<String>();
        idQuoteList.add(qut.id);
        Test.startTest();
        
        DWQuoteIntegrableBatch.scheduleThisClass(null);
        Test.stopTest();
        
    }
    @IsTest static void runEveryNMinutes(){
        Test.setMock(HttpCalloutMock.class, new DWQuoteIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        Product2 objProduct = new Product2(CodigoERP__c= '2',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        Opportunity opp = new Opportunity(name = 'test', AccountId = acc.Id, StageName = 'F1 - Pré - Formalização', closedate = system.today());
        insert opp;
        Quote qut = new Quote(Name = 'teste', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId());
        insert qut;
        QuoteLineItem qlli = new QuoteLineItem(QuoteId = qut.id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
      	insert qlli; 
        Quote qut2 = new Quote(Name = 'teste2', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId(), Cota_o_SalvaBras__c = false);
        insert qut2;
        List<String> idQuoteList = new List<String>();
        idQuoteList.add(qut.id);
        Test.startTest();
        
        DWQuoteIntegrableBatch.runEveryNMinutes(1);
        Test.stopTest();
        
    }
     @IsTest static void runEveryNMinutesInBusinessHours(){
        Test.setMock(HttpCalloutMock.class, new DWQuoteIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        Product2 objProduct = new Product2(CodigoERP__c= '2',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        Opportunity opp = new Opportunity(name = 'test', AccountId = acc.Id, StageName = 'F1 - Pré - Formalização', closedate = system.today());
        insert opp;
        Quote qut = new Quote(Name = 'teste', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId());
        insert qut;
        QuoteLineItem qlli = new QuoteLineItem(QuoteId = qut.id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
      	insert qlli; 
        Quote qut2 = new Quote(Name = 'teste2', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId(), Cota_o_SalvaBras__c = false);
        insert qut2;
        List<String> idQuoteList = new List<String>();
        idQuoteList.add(qut.id);
        Test.startTest();
        
        DWQuoteIntegrableBatch.runEveryNMinutesInBusinessHours(1);
        Test.stopTest();
        
    }
    @IsTest static void cancelThisSchedule(){
        Test.setMock(HttpCalloutMock.class, new DWQuoteIntegrableMock());
        
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074',CodigoERP__c = '1242');
        insert acc;
        
        Product2 objProduct = new Product2(CodigoERP__c= '2',Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                   Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        Opportunity opp = new Opportunity(name = 'test', AccountId = acc.Id, StageName = 'F1 - Pré - Formalização', closedate = system.today());
        insert opp;
        Quote qut = new Quote(Name = 'teste', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId());
        insert qut;
        QuoteLineItem qlli = new QuoteLineItem(QuoteId = qut.id, PriceBookentryId = objPBE.Id, Quantity = 1, UnitPrice = 1);
      	insert qlli; 
        Quote qut2 = new Quote(Name = 'teste2', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId(), Cota_o_SalvaBras__c = false);
        insert qut2;
        List<String> idQuoteList = new List<String>();
        idQuoteList.add(qut.id);
        Test.startTest();
        
        DWQuoteIntegrableBatch.cancelThisSchedule();
        Test.stopTest();
        
    }
    
}