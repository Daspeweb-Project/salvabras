@isTest
public class MetaTest {
    @testsetup static void setup(){
        Profile vendedor = [SELECT id FROM Profile WHERE Name = 'Vendedor'];
        Profile admin = [SELECT id FROM Profile WHERE Name = 'Administrador do sistema'];
        
        User usuarioAdmin = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name IN ('System Administrator','Administrador do sistema')].Id,
            LastName = 'TestDataFactory',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert usuarioAdmin;
        
        User usuariovendedor = new User(
            ProfileId = vendedor.Id,
            LastName = 'TestDataFactory2',
            Email = 'puser0002@amamama.com',
            Username = 'puser0002@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST2',
            Title = 'title2',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert usuariovendedor;
        Account acc = new Account(Name = 'teste',CNPJ_CPF__c = '14794512074');
        insert acc;
        
        Opportunity opp = new Opportunity();
        opp.name = 'test';
        opp.Amount = 2000;
        opp.AccountId = acc.Id;
        opp.Stagename = 'F5 - Ganho';
        opp.CloseDate = System.today();
        opp.OwnerId = usuariovendedor.Id;
        insert opp;
        
        Quote q = new Quote();
        q.ExpirationDate = System.today();
        q.OpportunityId = opp.id;
        q.Name = 'Test';
        q.Valor_do_Frete__c = 10;
        q.Nome_do_Logo__c = 'teste';
        insert q;
    }
    
    @isTest static void criarMetaMesAtual(){
        User usuarioVendedor = [SELECT ID FROM USER WHERE alias = 'alias2'];
        Account conta = [SELECT ID FROM ACCOUNT];
        Meta__c meta = new Meta__c();
        meta.Usuario__c = usuariovendedor.Id;
        meta.Ano__c = System.today().year();
        meta.Mes__c = 'Abril';
        meta.Valor__c = 2000;
        insert meta;
        
        Opportunity opp = new Opportunity();
        opp.name = 'test';
        opp.Amount = 2000;
        opp.AccountId = conta.Id;
        opp.Stagename = 'F5 - Ganho';
        opp.CloseDate = System.today();
        opp.OwnerId = usuariovendedor.Id;
        insert opp;
        Meta__c meta2 = [select id, valor_alcancado__c, andamento__c FROM Meta__c where Id =: meta.Id];
        List<Meta_Semanal__c> metas_semanais = [SELECT Id FROM Meta_Semanal__c WHERE Meta__c =: meta.Id];
        
        List<Meta_diaria__c> metas_diarias = [SELECT Id FROM Meta_diaria__c WHERE Meta_semanal__r.Meta__c =: meta.Id];
        
        
    }
}