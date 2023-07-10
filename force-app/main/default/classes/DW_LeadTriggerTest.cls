@isTest
public class DW_LeadTriggerTest {
    @isTest
    public static void main(){
        Lead lead = new Lead();
        lead.LastName = 'Lead Teste';
        lead.Company = 'company';
        lead.Street = 'Rua das Flores, 800, ap 303';
        insert lead;
    }
    @isTest
    public static void mainWithError1(){
        Lead lead = new Lead();
        lead.LastName = 'Lead Teste';
        lead.Company = 'Teste';
        lead.Street = 'Rua das Flores, 800';
        try{
            insert lead;
        }catch(Exception e){
            
        }
    }
    @isTest
    public static void mainWithError2(){
        Lead lead = new Lead();
        lead.LastName = 'Lead Teste';
        lead.Company = 'company';
        lead.Street = 'Rua das Flores, 800, ap 303, Centro, adicional';
        try{
            insert lead;
        }catch(Exception e){
            
        }
    }
    @isTest
    public static void mainWithError3(){
        Lead lead = new Lead();
        lead.LastName = 'Lead Teste';
        lead.Company = 'company';
        lead.Street = 'Rua das Flores teste muitos caracteres abcdefghijklmnopqrstuvxz1234567891020304050, 800, ap 303, Centro';
        try{
            insert lead;
        }catch(Exception e){
            
        }
    }
    
    @isTest
    public static void mainWithError4(){
        Lead lead = new Lead();
        lead.LastName = 'Lead Teste';
        lead.Company = 'company';
        lead.Street = 'Rua das Flores, teste número grande, ap 303, Centro';
        try{
            insert lead;
        }catch(Exception e){
            
        }
    }
    
        @isTest
    public static void mainWithError5(){
        Lead lead = new Lead();
        lead.LastName = 'Lead Teste';
        lead.Company = 'company';
        lead.Street = 'Rua das Flores, teste número grande, Teste bairro muito grande abcdefghijklmon';
        try{
            insert lead;
        }catch(Exception e){
            
        }
    }
}