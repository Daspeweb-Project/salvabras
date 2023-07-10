/**
 * Created by Guilherme Reis on 02/02/2021.
 */

public with sharing class DW_ForceErrorSingleton {
    public Boolean forceError = false; 
    private static final DW_ForceErrorSingleton instance = new DW_ForceErrorSingleton();
    public static DW_ForceErrorSingleton getInstance(){
        return instance;
    }
}