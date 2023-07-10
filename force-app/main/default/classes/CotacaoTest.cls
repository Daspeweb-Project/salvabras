@isTest
public class CotacaoTest {
    @testsetup static void setup(){
        Account acc = new Account(name = 'teste',CNPJ_CPF__c = '14794512074');
        insert acc;
        
        Product2 objProduct = new Product2(Name = 'Test product1',Custo_de_Produto_Bras__c = 10, Calculo_IPI__c = 10, Custo_de_Produto_Pro__c = 20, NCM__c = 10, Peso_KG__c = 10, IPI__c = 10, Embalagem_Master__c = 'true', Tipo_de_produto__c = 'Fita crepe');                                            
        insert objProduct;
        PriceBookEntry objPBE = new PriceBookEntry(UnitPrice = 300, PriceBook2Id = Test.getStandardPricebookId(),
                                                        Product2Id = objProduct.Id, IsActive = true);
        insert objPBE;
        Opportunity opp = new Opportunity(name = 'test', AccountId = acc.Id, StageName = 'F1 - Pré - Formalização', closedate = system.today());
        insert opp;
        Quote qut = new Quote(Name = 'teste', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId());
        insert qut;
        Quote qut2 = new Quote(Name = 'teste2', OpportunityId = opp.Id, Valor_do_Frete__c = 100, Nome_do_Logo__c = 'teste', PriceBook2ID = Test.getStandardPricebookId(), Cota_o_SalvaBras__c = false);
        insert qut2;
    }
    @isTest static void test(){
        Quote qut = [SELECT Id FROM Quote where name = 'teste'];
        PriceBookEntry objPBE = [SELECT id from PricebookEntry];
        List<QuoteLineItem> lista = new List<QuoteLineItem>();
        QuoteLineItem linha = new QuoteLineItem(QuoteId = qut.Id, PricebookEntryId = objPBE.Id, Quantity = 10, UnitPrice = 10);
        lista.add(linha);
        QuoteLineItem linha2 = new QuoteLineItem(QuoteId = qut.Id, PricebookEntryId = objPBE.Id, Quantity = 10, UnitPrice = 8);
        lista.add(linha2);
        insert lista;
    }
    @isTest static void test2(){
        Quote qut = [SELECT Id FROM Quote where name = 'teste2'];
        PriceBookEntry objPBE = [SELECT id from PricebookEntry];
        QuoteLineItem linha = new QuoteLineItem(QuoteId = qut.Id, PricebookEntryId = objPBE.Id, Quantity = 10, UnitPrice = 10);
        insert linha;
    }
}