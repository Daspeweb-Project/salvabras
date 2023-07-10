@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global static HTTPResponse respond(HTTPRequest req) {        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{"cep": "06230-110",  "logradouro": "Rua Anhanguera",  "complemento": "",  "bairro": "Piratininga",  "localidade": "Osasco",  "uf": "SP",  "ibge": "3534401",  "gia": "4923",  "ddd": "11",  "siafi": "6789"}');
        res.setStatusCode(200);
        return res;
    }
}