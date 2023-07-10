@isTest
public class SplitStringToFlowTest {

    @isTest
    public static void testConvertStringToListUtilMethod() {
        String str = '1;2;3';
        List<List<String>> res = SplitStringToFlow.convertStringToList(new List<String>{str});
        System.assertEquals(res.get(0), new list<String>{'1','2','3'});
    }
}