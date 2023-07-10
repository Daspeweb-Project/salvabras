@isTest
public class ResponseHTTPTest {
    @isTest static void success() {
        Account acc = new Account(
            Name ='Teste account'
        );
        insert acc;
        ResponseHTTP.success([SELECT Id FROM Account]);
        ResponseHTTP.error(new List<String>{
                acc.Id
        });
        ResponseHTTP.error(new List<String>{
                acc.Id
        }, new Map<String, Object>());
        
        ResponseHTTP.errorObj(new List<String>{
                acc.Id
        }, new Map<String, Object>());

        ResponseHTTP.successObj(acc);
    }


}