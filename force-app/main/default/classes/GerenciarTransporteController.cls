public without sharing class GerenciarTransporteController {
    @AuraEnabled(Cacheable=true)
    public static List<Veiculo__c> getVehicle(String orderId){
        OrdemCarregamento__c ordemCarregamento = [SELECT Id, CubagemTotal__c FROM OrdemCarregamento__c WHERE Id = :orderId LIMIT 1];
        return [SELECT Id, Name,MetroCubicoCapacidadeCarga__c FROM Veiculo__c WHERE MetroCubicoCapacidadeCarga__c >= :ordemCarregamento.CubagemTotal__c];
    }
    @AuraEnabled(Cacheable=true)
    public static List<Account> getDriver(String vehicleId){
        List<VeiculoMotorista__c> motoristaVeiculoList = [SELECT Id,Motorista__c FROM VeiculoMotorista__c WHERE Veiculo__c = :vehicleId];
        Set<Id> motoristaSet = new Set<Id>();
        for (VeiculoMotorista__c veiculoMotorista : motoristaVeiculoList) {
            motoristaSet.add(veiculoMotorista.Motorista__c);
        }
        return [SELECT Id,Name FROM Account WHERE Id IN :motoristaSet];
    }
    @AuraEnabled(Cacheable=true)
    public static List<Praca__c> getPraca(String moristaId, String vehicleId){
        List<MotoristaPraca__c> motoristaPracaList = [SELECT Id,Praca__c FROM MotoristaPraca__c WHERE Motorista__c = :moristaId];
        Set<Id> pracaSet = new Set<Id>();
        for (MotoristaPraca__c motoristaPraca : motoristaPracaList) {
            pracaSet.add(motoristaPraca.Praca__c);
        }
        return [SELECT Id,Name, Valor__c FROM Praca__c WHERE Veiculo__c = :vehicleId];
    }
    @AuraEnabled
    public static string save(String ordemCarregamentoId, String vehicleId, String motoristaId, String pracaId){
        try {
            Praca__c praca = [SELECT Id, Valor__c FROM Praca__c WHERE Id = :pracaId LIMIT 1];
            OrdemCarregamento__c ordemCarregamento = new OrdemCarregamento__c(
                Id = ordemCarregamentoId,
                Veiculo__c = vehicleId,
                Motorista__c = motoristaId,
                Praca__c = pracaId,
                ValorFrete__c = praca.Valor__c
            );
            update ordemCarregamento;
            sendEmailToDriver(ordemCarregamentoId);
            return ResponseHTTP.success(new Map<String, Object>{});
        } catch (Exception e) {
            return ResponseHTTP.error(new List<String>{
                e.getMessage() + ' - ' + e.getLineNumber()
            });
        }
    }
    @Future(callout=true)
    public static void sendEmailToDriver(String ocId){
        OrdemCarregamento__c ordemCarregamento = [SELECT Id,RotaMaps__c, Motorista__r.Email__c,DataCarregamento__c FROM OrdemCarregamento__c WHERE Id =:ocId LIMIT 1];
        if (!Test.isRunningTest()) {
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject('Rota nova para o dia ' + ordemCarregamento.DataCarregamento__c.format() );
            semail.setToAddresses(new List<String>{'erick.oliveira@salvabras.com.br'});
            semail.setHtmlBody('<html><head><body>Segue abaixo link para carregamento no dia : ' 
                                + ordemCarregamento.DataCarregamento__c.format() + ' <br/><br/>' 
                                + ordemCarregamento.RotaMaps__c + '</head></body></html>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
        }
        
    }
}