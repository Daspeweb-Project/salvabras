/**
 * Created by guilhermereis on 25/01/21.
 */

public with sharing class DaspeMicroservicoHelper {
    Map<String, String> stringMap = new Map<String, String>();
    private static final DaspeMicroservicoHelper instance = new DaspeMicroservicoHelper();
    public DaspeMicroservico__mdt daspeMicroservico ;
    public Mercos__mdt mercosMicroservico ;

    public static DaspeMicroservicoHelper getInstance(){
        if (instance.daspeMicroservico == null) {
            instance.daspeMicroservico = (DaspeMicroservico__mdt)DW_QueryFactory.get('DaspeMicroservico__mdt')
                .setCondition(DW_QueryCondition.newInstance('Ativo__c', '=',true))
                .run()
                .get(0);
        }
        if (instance.mercosMicroservico == null) {
            instance.mercosMicroservico = (Mercos__mdt)DW_QueryFactory.get('Mercos__mdt')
                .setCondition(DW_QueryCondition.newInstance('Ativo__c', '=',true))
                .run()
                .get(0);
        }
        return instance;
    }
    
}