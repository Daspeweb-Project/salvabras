/**
 * Created by hellenmartins on 17/11/2021.
 */

public without sharing class GerenciamentoOcorrenciaController {
    @AuraEnabled
    public static Map<String,List<OrdensCarregamentoPedido__c>> getOrdensCarregamentoOportunidades(String orderId) {
        System.debug(LoggingLevel.INFO, 'GerenciamentoOcorrenciaController@getOrdensCarregamentoOportunidades -> : orderId' + orderId);
        List<SObject> ordemCarregamentoParaGerar = DW_QueryFactory.get('OrdensCarregamentoPedido__c')
                .withParent('Pedido__r', 'Order')
                .setCondition(DW_QueryCondition.newInstance('OrdemCarregamento__c', '=', orderId))
                .run();
        List<SObject> ordemCarregamentoComOcorrencia = DW_QueryFactory.get('OrdensCarregamentoPedido__c')
                .setCondition(DW_QueryCondition.newInstance('OrdemCarregamento__c', '=', orderId))
                .setCondition(DW_QueryCondition.newInstance('StatusOcorrencia__c', new List<String>{'Aberto', 'Andamento'} ))
                .withParent('UsuarioOcorrencia__r', 'User')
                .withParent('Pedido__r', 'Order')
                .run();
        return new Map<String,List<OrdensCarregamentoPedido__c>>{
          'ordemCarregamentoParaGerar'      => ordemCarregamentoParaGerar,
          'ordemCarregamentoComOcorrencia' => ordemCarregamentoComOcorrencia
        };
    }
    @AuraEnabled
    public static String saveUpdates(List<OrdensCarregamentoPedido__c> ordensCarregamentoOportunidadeList) {
            System.debug(LoggingLevel.INFO, 'GerenciamentoOcorrenciaController@saveUpdates -> ordensCarregamentoOportunidadeList: ' + ordensCarregamentoOportunidadeList);

           try {
            Savepoint savepoint = Database.setSavepoint();
            List<String> errorByLine = new List<String>();
            List<Database.UpsertResult> ordensCarregamentoUpsertResult = Database.upsert(ordensCarregamentoOportunidadeList, false);
            for (Database.UpsertResult upsertResult : ordensCarregamentoUpsertResult) {
                if (upsertResult.getErrors().size() > 0) {
                    errorByLine.add(upsertResult.getErrors().get(0).getMessage());
                } else {
                    errorByLine.add('');
                }
            }
            Boolean cancelDML = false;
            for (String error : errorByLine) {
                if (error != '') cancelDML = true;
            }
            if (cancelDML) {
                Database.rollback(savepoint);
                return ResponseHTTP.error(new List<String>{
                        errorByLine.get(0)
                });
            }
            return ResponseHTTP.success(null);
        }catch (Exception e){
            return ResponseHTTP.error(new List<String>{
                    e.getMessage()
            });
        }

    }
    @AuraEnabled
    public static Map<String, List<String>> getDependentPicklistValues() {
        Schema.DescribeFieldResult depend = OrdensCarregamentoPedido__c.DetalhesOcorrencia__c.getDescribe();
        Schema.sObjectField controlToken = depend.getController();
        if (controlToken == null) {
            return new Map<String, List<String>>();
        }
        Schema.DescribeFieldResult control = controlToken.getDescribe();
        List<Schema.PicklistEntry> controlEntries;
        if (control.getType() != Schema.DisplayType.Boolean) {
            controlEntries = control.getPicklistValues();
        }
        String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
        Map<String, List<String>> dependentPicklistValues = new Map<String, List<String>>();
        for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
            if (entry.isActive() && String.isNotEmpty(String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')))) {
                List<String> base64chars =
                        String.valueOf(((Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(entry))).get('validFor')).split('');
                for (Integer index = 0; index < (controlEntries != null ? controlEntries.size() : 2); index++) {
                    Object controlValue =
                            (controlEntries == null
                                    ? (Object) (index == 1)
                                    : (Object) (controlEntries[index].isActive() ? controlEntries[index].getLabel() : null)
                            );
                    Integer bitIndex = index / 6;
                    if (bitIndex > base64chars.size() - 1) {
                        break;
                    }
                    Integer bitShift = 5 - Math.mod(index, 6);
                    if (controlValue == null || (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0)
                        continue;
                    if (!dependentPicklistValues.containsKey((String) controlValue)) {
                        dependentPicklistValues.put((String) controlValue, new List<String>());
                    }
                    dependentPicklistValues.get((String) controlValue).add(entry.getLabel());
                }
            }
        }
        return dependentPicklistValues;
    }
}