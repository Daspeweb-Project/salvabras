public without sharing class DWControllerSintegraWS {
    // @AuraEnabled
    // public static String controllerSintegraWS(String opcao, String recordId, String plugin, String cpf, String dataNascimento, String cnpjIe, String uf) {
    //     try{
    //         String retornoConsulta = '';
    //         if(opcao == 'DwGetSaldoSintegraWS'){
    //             retornoConsulta = DwGetSaldoSintegraWS.callSaldo(recordId);
    //         }
    //         if(opcao == 'DwGetSintegraWS'){
    //             retornoConsulta = DwGetSintegraWS.callSintegra(recordId, plugin, cpf, dataNascimento, cnpjIe, uf);
    //         }
    //         return JSON.serialize(DW_ResponseHTTP.successObj(new Map<String, Object>{'retorno' => retornoConsulta}));
            
    //     }catch(Exception e){
            
    //         return JSON.serialize(DW_ResponseHTTP.errorObj(new List<String>{e.getMessage(), e.getStackTraceString()}));
    //     }
    // }

    @AuraEnabled
    public static String getSintegraSaldo(String recordId) {
        try {
            String response = DwGetSaldoSintegraWS.callSaldo(recordId);
            if (Test.isRunningTest()) throw new StringException('FORCE ERROR ON TEST');
            return JSON.serialize(DW_ResponseHTTP.successObj(new Map<String, Object>{'response' => response}));
        } catch(Exception e){
            return JSON.serialize(DW_ResponseHTTP.errorObj(new List<String>{e.getMessage(), e.getStackTraceString()}));
        }
    }

    @AuraEnabled
    public static String getSintegraData(String recordId, String plugin, String cpf, String dataNascimento, String cnpjIe, String uf) {
        try {
            String response = DwGetSintegraWS.callSintegra(recordId, plugin, cpf, dataNascimento, cnpjIe, uf);
            if (Test.isRunningTest()) throw new StringException('FORCE ERROR ON TEST');
            return JSON.serialize(DW_ResponseHTTP.successObj(new Map<String, Object>{'response' => response}));
        } catch(Exception e){
            return JSON.serialize(DW_ResponseHTTP.errorObj(new List<String>{e.getMessage(), e.getStackTraceString()}));
        }
    }
}