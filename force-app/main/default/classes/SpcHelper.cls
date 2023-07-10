public with sharing class SpcHelper {
Map<String, String> stringMap = new Map<String, String>();
    private static final SpcHelper instance = new SpcHelper();
    public ApiSpc__mdt	 spcServico ;

    public static SpcHelper getInstance(){
        if (instance.spcServico == null) {
            instance.spcServico = (ApiSpc__mdt)DW_QueryFactory.get('ApiSpc__mdt')
                .setCondition(DW_QueryCondition.newInstance('Ativo__c', '=',true))
                .run()
                .get(0);
        }
        return instance;
    }
}