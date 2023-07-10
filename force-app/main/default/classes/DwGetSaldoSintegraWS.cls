public without sharing class DwGetSaldoSintegraWS {
    public static String callSaldo(id recordId) {
        String resultado = '';
        HttpRequestLog__c log = new HttpRequestLog__c();
        Account ac = [SELECT  Id,Documento__c,DataUltimaConsultaSaldoSintegraWS__c,StatusIntegracaoSaldoSintegraWS__c FROM account WHERE Id = :recordId];

        try{ 
            DwGetSaldoSintegraIntegrable dwGetSaldoIntegrable = new DwGetSaldoSintegraIntegrable();
            dwGetSaldoIntegrable.callIntegration(ac);
            if(DW_Helper.hasSomeContent(dwGetSaldoIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(dwGetSaldoIntegrable.requestFactoryInstance.getLog())){
                log = dwGetSaldoIntegrable.requestFactoryInstance.getLog();
            } 
            if(dwGetSaldoIntegrable.isError){
                ac.StatusIntegracaoSaldoSintegraWS__c = 'Integrado com erro';
                log.ResponseBody__c = dwGetSaldoIntegrable.errorMessage;
            }
            GetSaldoSintegraWSIntegrableTempate responseTemplate = (GetSaldoSintegraWSIntegrableTempate)dwGetSaldoIntegrable.deserializedResponseObject;
            if(responseTemplate.code == '3'){
                resultado = responseTemplate.message;
                throw new DW_Exception();
            }
            ac.StatusIntegracaoSaldoSintegraWS__c = 'Integrado com sucesso';  
            resultado = responseTemplate.qtd_consultas_disponiveis;
        }catch (Exception e){
            ac.StatusIntegracaoSaldoSintegraWS__c = 'Integrado com erro';   
            if(resultado == '')resultado = e.getMessage() + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, '@@@DwGetSaldoSintegraWS e.getMessage()' + e.getMessage());
            System.debug(LoggingLevel.ERROR, '@@@DwGetSaldoSintegraWS e.getStackTraceString()' + e.getStackTraceString());
        }finally {
            ac.DataUltimaConsultaSaldoSintegraWS__c= System.now();
            log.Conta__c = ac.Id;
            log.Name = 'Integração de Saldo Sintegra WS';
            insert log;
            update ac;
        }

        return resultado;
    }
}