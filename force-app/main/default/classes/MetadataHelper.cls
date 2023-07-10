public without sharing class MetadataHelper {
    Map<String, String> stringMap = new Map<String, String>();
    private static final MetadataHelper instance = new MetadataHelper();
    public SintegraWS__mdt daspeMicroservico ;


    public static MetadataHelper getInstance(){
        if (instance.daspeMicroservico == null) {
            instance.daspeMicroservico = (SintegraWS__mdt)DW_QueryFactory.get('SintegraWS__mdt')
                .setCondition(DW_QueryCondition.newInstance('Ativo__c', '=',true))
                .run()
                .get(0);
        }
       
        return instance;
    }
}