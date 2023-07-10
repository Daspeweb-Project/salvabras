@IsTest
public class BatchBackAccountStatusTest {
        

static testMethod void testSchedule(){
    	Account acc = TestFactory.createAccountClienteType();
        acc.StatusCadastro__c = 'Finalizado';
    	acc.DataFinalizacao__c = Date.newInstance(2016, 12, 9);
        update acc;    
    	Test.startTest();
        BatchBackAccountStatus.scheduleThisClass(null);
    	Test.stopTest();
    	Account accUpdate = [SELECT id,StatusCadastro__c,DataFinalizacao__c FROM ACCOUNT WHERE id = :acc.id];
    	System.assertNotEquals(null, accUpdate.DataFinalizacao__c);
    	System.assertNotEquals('Básico', accUpdate.StatusCadastro__c);
        
    }
}