@IsTest
global without sharing class AtualizacaoStatusPedidoMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest httpRequest){
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(200);
        httpResponse.setBody('{"sucesso": "true"}');
        return httpResponse;
    }
}