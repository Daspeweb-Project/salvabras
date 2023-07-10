/**
 * Created by guilhermereis on 05/01/21.
 */

public with sharing class DW_FieldCollector {
    public static List<String> collect(String sobj){
        List<String> fieldList = new List<String>();
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(sobj).getDescribe().fields.getMap();
        for(Schema.SObjectField sObjectField : fieldMap.values()){
            fieldList.add(sObjectField.getDescribe().getName());
        }
        return fieldList;
    }
    public static String collectStr(String sobj){
        return String.join(collect(sobj), ',');
    }
}