@IsTest
global class DWDANFEIntegrableMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest httpRequest){
        HttpResponse httpResponse = new HttpResponse();        
        httpResponse.setBody('{ "base64": "dsfeef"}');
        httpResponse.setStatusCode(201);
        return httpResponse;
        
    }
}