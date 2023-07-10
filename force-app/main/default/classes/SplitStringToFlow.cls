public class SplitStringToFlow {
 @InvocableMethod(label='Converter String em Lista')
 public static List<List<String>> convertStringToList(List<String> inputParamStrings) { 
      List<List<String>> resultList = new List<List<String>>();
        
        for(String inputParamString : inputParamStrings){
            if(String.isBlank(inputParamString)) continue;
            
            List<String> innerResultList = new List<String>();
            for(String str : inputParamString.split(';')){
                if(String.isBlank(str)) continue;
                innerResultList.add(str.trim());
            }
            resultList.add(new List<String>(innerResultList));
        }
		system.debug(resultList);
        return resultList;
 }
}