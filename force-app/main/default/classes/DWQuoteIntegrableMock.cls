@IsTest
global class DWQuoteIntegrableMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest httpRequest){
        HttpResponse httpResponse = new HttpResponse();        
        httpResponse.setBody('{ "produtos": [ { "impostos": { "02-BASE ICMS": 109.9, "03-VL. COFINS": 2.7, "04-VL ICMS": 19.78, "05-VALOR NF": 109.9, "06-VALPS2": 0.59, "01-BASE CALC.": 109.9 }, "item": 1, "produto": "8301400004" }, { "impostos": { "02-BASE ICMS": 499.98, "03-VL. COFINS": 12.3, "04-VL ICMS": 90, "05-VALOR NF": 499.98, "06-VALPS2": 2.66, "01-BASE CALC.": 499.98 }, "item": 2, "produto": "8431201102" }, { "impostos": { "02-BASE ICMS": 2.6, "03-VL. COFINS": 0.07, "04-VL ICMS": 0.47, "05-VALOR NF": 2.6, "06-VALPS2": 0.01, "01-BASE CALC.": 2.6 }, "item": 3, "produto": "7318160004" } ]}');
        httpResponse.setStatusCode(201);
        return httpResponse;
        
    }
}