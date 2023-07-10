@IsTest
global class DWDANFEERRORIntegrableMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest httpRequest){
        HttpResponse httpResponse = new HttpResponse();        
        httpResponse.setBody('{ "base64": "dsfeef"}');
        httpResponse.setStatusCode(505);
        return httpResponse;
        
    }
}