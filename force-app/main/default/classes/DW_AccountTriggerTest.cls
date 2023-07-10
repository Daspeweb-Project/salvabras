@isTest
public class DW_AccountTriggerTest {
    @isTest
    public static void main(){
        Account account = new Account();
        account.Name = 'Nome conta';
        account.Documento__c = '08816341904';
        account.Phone = '41999116120';
        account.BillingPostalCode = '83010190';
        account.ShippingPostalCode = '83010190';
        account.BillingStreet = 'Rua das Flores, 800, ap 303';
        account.ShippingStreet = 'Rua das Flores, 800, ap 303';
        insert account;
        
        Account accountToAssert = [SELECT Id, Documento__c, Phone, BillingPostalCode FROM Account WHERE Id = :account.Id LIMIT 1];
        System.assertEquals('088.163.419-04', accountToAssert.Documento__c);
        System.assertEquals('+55 (41) 99911-6120', accountToAssert.Phone);
        System.assertEquals('83010-190', accountToAssert.BillingPostalCode);
    }
    @isTest
    public static void mainWithError1(){
        Account account = new Account();
        account.Name = 'Nome conta';
        account.Documento__c = '08816341904';
        account.Phone = '419991161200';
        account.BillingPostalCode = '83010190';
        try{
            insert account;
        }catch(Exception e){
            
        }
    }
    @isTest
    public static void mainWithError2(){
        Account account = new Account();
        account.Name = 'Nome conta';
        account.Documento__c = '088163419040';
        account.Phone = '41999116120';
        account.BillingPostalCode = '83010190';
        try{
            insert account;
        }catch(Exception e){
            
        }
    }
    @isTest
    public static void mainWithError3(){
        Account account = new Account();
        account.Name = 'Nome conta';
        account.Documento__c = '08816341904';
        account.Phone = '41999116120';
        account.BillingPostalCode = '830101902';
        try{
            insert account;
        }catch(Exception e){
            
        }
    }
}