/**
 * Created by guilhermereis on 12/04/21.
 */

public with sharing class DW_Helper {
    public static Boolean isNullOrBlank(String str){
        if (str == '' || str == null) {
            return true;
        }
        return false;
    }
    public static Boolean isNullOrBlank(Object obj){
        if (obj == null) {
            return true;
        }
        return false;
    }

    public static Boolean hasSomeContent(String str){
        if (str != '' && str != null) {
            return true;
        }
        return false;
    }

    public static Boolean hasSomeContent(Object obj){
        if ( obj != null) {
            return true;
        }
        return false;
    }
    
    public static String limitedTo(String str, Integer size){
        if (hasSomeContent(str)) {
            str = str.length() > size ? str.substring(0, size) : str;
            return str;
        }
        return '';
    }

}