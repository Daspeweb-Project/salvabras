/**
 * Created by vinit on 09/02/2021.
 */

public without sharing class ResponseHTTP {
    public Boolean success;
    public Boolean error;
    public List<String> errorList = new List<String>();
    public Object dataMap = new Map<String, Object>();

    public static String success(Object dataMap){
        ResponseHTTP response = new ResponseHTTP();
        response.success = true;
        response.error = false;
        response.dataMap = dataMap;
        return JSON.serialize(response);
    }

    public static ResponseHTTP successObj(Object dataMap){
        ResponseHTTP response = new ResponseHTTP();
        response.success = true;
        response.error = false;
        response.dataMap = dataMap;
        return response;
    }

    public static String error(List<String> errorList){
        ResponseHTTP response = new ResponseHTTP();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        return JSON.serialize(response);
    }
    public static ResponseHTTP errorObj(List<String> errorList){
        ResponseHTTP response = new ResponseHTTP();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        return response;
    }

    public static String error(List<String> errorList, Object dataMap){
        ResponseHTTP response = new ResponseHTTP();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        response.dataMap = dataMap;
        return JSON.serialize(response);
    }
    public static ResponseHTTP errorObj(List<String> errorList, Object dataMap){
        ResponseHTTP response = new ResponseHTTP();
        response.success = false;
        response.error = true;
        response.errorList = errorList;
        response.dataMap = dataMap;
        return response;
    }
    
}