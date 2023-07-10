public class DwGetSaldoSintegraWSMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"code":"0","status":"OK","message":"Pesquisa realizada com sucesso.","qtd_consultas_disponiveis":"1000"}');
        res.setStatusCode(200);
        return res;
    }
}