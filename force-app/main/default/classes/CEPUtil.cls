public class CEPUtil {
	public static CEPClass getCep(String cep){
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://viacep.com.br/ws/'+cep+'/json/');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = (Test.isRunningTest()) ? MockHttpResponseGenerator.respond(req) : http.send(req);  
        return (res.getStatusCode() == 200) ? CEPClass.parse(res.getBody()) : null;
    }
}