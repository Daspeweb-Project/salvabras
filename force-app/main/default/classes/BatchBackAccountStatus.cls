global class BatchBackAccountStatus implements Database.Batchable<SObject>, Schedulable{
    global BatchBackAccountStatus(){
    }
 
    public static void scheduleThisClass(String cron){
        if(cron != null){
            System.schedule('Atualizar fase da conta', cron, new BatchBackAccountStatus());
        }else{
            System.schedule('Atualizar fase da conta', '0 10 * * * ?', new BatchBackAccountStatus());   
        }
    }
 
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(new BatchBackAccountStatus(), 1);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([
            SELECT Id,DataFinalizacao__c
            FROM Account WHERE StatusCadastro__c = 'Finalizado'
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> acList){
        List<DiasVoltarFaseConta__mdt> diasVoltarFase = [SELECT Id,Dias__c FROM DiasVoltarFaseConta__mdt  WHERE DeveloperName = 'Padrao' LIMIT 1 ];
        Decimal countdias = 30;
        if(diasVoltarFase[0].Dias__c != null)countdias = diasVoltarFase[0].Dias__c;
        for(Account ac: acList){
            
            Integer daysOpen = (system.today()).daysBetween(Date.valueOf(ac.DataFinalizacao__c));
            if(daysOpen < (-countdias)){
                ac.StatusCadastro__c = 'Análise de crédito';
                ac.DataFinalizacao__c = null;
            }
        }
        update acList;
        
    }
    
    global void finish(Database.BatchableContext BC){
    }

}