public with sharing class CotacaoUtil {
    public static Decimal transformarProcentagem(String perct){
        try{
            return  Decimal.valueOf(perct.split('%')[0])/100;
        }catch(Exception e){
            return 0;
        }
    }
}