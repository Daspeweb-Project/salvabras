@IsTest
global class GetGeolocationsMock implements HttpCalloutMock  {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse(); 
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200); 
        res.setBody('{ "results" : [ { "address_components" : [ { "long_name" : "50", "short_name" : "50", "types" : [ "street_number" ] }, { "long_name" : "Rua Senador Joaquim Pedro Salgado Filho", "short_name" : "R. Sen. Joaquim Pedro Salgado Filho", "types" : [ "route" ] }, { "long_name" : "Bento Gonçalves", "short_name" : "Bento Gonçalves", "types" : [ "administrative_area_level_4", "political" ] }, { "long_name" : "Bento Gonçalves", "short_name" : "Bento Gonçalves", "types" : [ "administrative_area_level_2", "political" ] }, { "long_name" : "Rio Grande do Sul", "short_name" : "RS", "types" : [ "administrative_area_level_1", "political" ] }, { "long_name" : "Brazil", "short_name" : "BR", "types" : [ "country", "political" ] }, { "long_name" : "95700-000", "short_name" : "95700-000", "types" : [ "postal_code" ] } ], "formatted_address" : "R. Sen. Joaquim Pedro Salgado Filho, 50 - Bento Gonçalves, RS, 95700-000, Brazil", "geometry" : { "location" : { "lat" : -29.1718893, "lng" : -51.5141412 }, "location_type" : "RANGE_INTERPOLATED", "viewport" : { "northeast" : { "lat" : -29.1704461697085, "lng" : -51.5128026197085 }, "southwest" : { "lat" : -29.1731441302915, "lng" : -51.5155005802915 } } }, "partial_match" : true, "place_id" : "ElFSLiBTZW4uIEpvYXF1aW0gUGVkcm8gU2FsZ2FkbyBGaWxobywgNTAgLSBCZW50byBHb27Dp2FsdmVzLCBSUywgOTU3MDAtMDAwLCBCcmF6aWwiMBIuChQKEgnf5KtnSyMclRH-NkKJ01x2TBAyKhQKEgmhoc1WSCMclRFx8eJqNac4Qg", "types" : [ "street_address" ] } ], "status" : "OK" }');
        return res;
    }
}