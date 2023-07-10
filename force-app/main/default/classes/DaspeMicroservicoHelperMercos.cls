public class DaspeMicroservicoHelperMercos {
     Map<String, String> stringMap = new Map<String, String>();
    private static final DaspeMicroservicoHelperMercos instance = new DaspeMicroservicoHelperMercos();
    public Mercos__mdt mercosMicroservico ;

    public static DaspeMicroservicoHelperMercos getInstance(){
        
        if (instance.mercosMicroservico == null) {
            instance.mercosMicroservico = (Mercos__mdt)DW_QueryFactory.get('Mercos__mdt')
                .setCondition(DW_QueryCondition.newInstance('Ativo__c', '=',true))
                .run()
                .get(0);
        }
        return instance;
    }

}