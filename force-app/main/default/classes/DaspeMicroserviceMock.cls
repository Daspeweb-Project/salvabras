/**
* Created by Willian Levandoski on 12/01/21.
*/
@IsTest
global with sharing class DaspeMicroserviceMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest httpRequest){
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(500);
        DaspeMicroservico__mdt daspeMicroservicoHelper = ((List<DaspeMicroservico__mdt>) DW_QueryFactory.get('DaspeMicroservico__mdt')
                .setCondition(DW_QueryCondition.newInstance('Ativo__c', '=',true))
                .run()).get(0);

        Mercos__mdt daspeMicroservicoMercosHelper = ((List<Mercos__mdt>) DW_QueryFactory.get('Mercos__mdt')
                .setCondition(DW_QueryCondition.newInstance('Ativo__c', '=',true))
                .run()).get(0);

        String endpoint = httpRequest.getEndpoint();
        if (endpoint != null && endpoint != '' && endpoint.indexOf('?') > 0) {
            endpoint = endpoint.substring(0, endpoint.indexOf('?'));
        }
        if(httpRequest.getEndpoint().contains(daspeMicroservicoMercosHelper.EndPointCriacaoVinculoTabelaPreco__c)) {
            httpResponse.setBody('{"id":1985467,"numero":7,"itens":[{"id":14967528},{"id":14967529}]}');
            httpResponse.setStatusCode(201);
            httpResponse.setHeader('MeusPedidosID', 'sdsdwd');
            return httpResponse;
        }
        if(httpRequest.getEndpoint().contains(daspeMicroservicoMercosHelper.EndpointCriacaoTransportadora__c)) {
            httpResponse.setBody('{"id":1985467,"numero":7,"itens":[{"id":14967528},{"id":14967529}]}');
            httpResponse.setStatusCode(201);
            httpResponse.setHeader('MeusPedidosID', 'sdsdwd');
            return httpResponse;
        }
        if(httpRequest.getEndpoint().contains(daspeMicroservicoMercosHelper.EndpointCriacaoPedido__c)) {
            httpResponse.setBody('{"id":1985467,"numero":7,"itens":[{"id":14967528},{"id":14967529}]}');
            httpResponse.setStatusCode(201);
            httpResponse.setHeader('MeusPedidosID', 'sdsdwd');
            return httpResponse;
        }
        if(httpRequest.getEndpoint().contains(daspeMicroservicoMercosHelper.EndPointCriacaoProduto__c)) {
            httpResponse.setBody('{ "A1_PESSOA": "J", "A1_TIPO": "F", "A1_NOME": "TESTEUF2", "A1_NREDUZ": "TESEUFUF2", "A1_CGC": "", "A1_CEP": "5467000", "A1_END": "R BERLIOZ, 225", "A1_BAIRRO": "ALTO DE PINHEIROS", "A1_MUN": "SAO PAULO", "A1_EST": "SP", "IMPOSTOS": { "A1_NATUREZ": "6101", "A1_CONTRIB": 1, "A1_ALIQ": 2.2 }}');
            httpResponse.setStatusCode(201);
            httpResponse.setHeader('MeusPedidosID', 'sdsdwd');
            return httpResponse;
        }
        if(httpRequest.getEndpoint().contains(daspeMicroservicoMercosHelper.EndpointCriacaoTitulos__c)) {
            httpResponse.setBody('{ "A1_PESSOA": "J", "A1_TIPO": "F", "A1_NOME": "TESTEUF2", "A1_NREDUZ": "TESEUFUF2", "A1_CGC": "", "A1_CEP": "5467000", "A1_END": "R BERLIOZ, 225", "A1_BAIRRO": "ALTO DE PINHEIROS", "A1_MUN": "SAO PAULO", "A1_EST": "SP", "IMPOSTOS": { "A1_NATUREZ": "6101", "A1_CONTRIB": 1, "A1_ALIQ": 2.2 }}');
            httpResponse.setStatusCode(201);
            httpResponse.setHeader('MeusPedidosID', 'sdsdwd');
            return httpResponse;
        }
        if(httpRequest.getEndpoint().contains(daspeMicroservicoHelper.EndPointCriacaoPreCadastro__c)) {
            httpResponse.setBody('{ "A1_PESSOA": "J", "A1_TIPO": "F", "A1_NOME": "TESTEUF2", "A1_NREDUZ": "TESEUFUF2", "A1_CGC": "", "A1_CEP": "5467000", "A1_END": "R BERLIOZ, 225", "A1_BAIRRO": "ALTO DE PINHEIROS", "A1_MUN": "SAO PAULO", "A1_EST": "SP", "IMPOSTOS": { "A1_NATUREZ": "6101", "A1_CONTRIB": 1, "A1_ALIQ": 2.2 }}');
            httpResponse.setStatusCode(201);
            return httpResponse;
        }
        if(httpRequest.getEndpoint().contains(daspeMicroservicoHelper.EndpointCriacaoConta__c)) {
            AccountIntegrableResponseTemplate responseTemplate = new AccountIntegrableResponseTemplate();
            responseTemplate.Retorno = new List<AccountIntegrableResponseTemplate.Retorno>();
            AccountIntegrableResponseTemplate.Retorno retorno = new AccountIntegrableResponseTemplate.Retorno();
            retorno.codigo = 'XXX';
            retorno.codigoERP = 'C04470';
            retorno.loja = '01';
            responseTemplate.Retorno.add(retorno);
            httpResponse.setBody(JSON.serialize(responseTemplate));
            httpResponse.setStatusCode(201);
            return httpResponse;
        }else if(httpRequest.getEndpoint().contains(daspeMicroservicoHelper.EndpointCriacaoTransportadora__c)) {
            AccountIntegrableResponseTemplate responseTemplate = new AccountIntegrableResponseTemplate();
            responseTemplate.Retorno = new List<AccountIntegrableResponseTemplate.Retorno>();
            AccountIntegrableResponseTemplate.Retorno retorno = new AccountIntegrableResponseTemplate.Retorno();
            retorno.codigo = 'XXX';
            retorno.codigoERP = 'T00778';
            retorno.loja = '01';
            responseTemplate.Retorno.add(retorno);
            httpResponse.setBody(JSON.serialize(responseTemplate));
            httpResponse.setStatusCode(201);
            return httpResponse;
        }else if(httpRequest.getEndpoint().contains(daspeMicroservicoHelper.EndpointCriacaoVendedor__c)) {
            AccountIntegrableResponseTemplate responseTemplate = new AccountIntegrableResponseTemplate();
            responseTemplate.Retorno = new List<AccountIntegrableResponseTemplate.Retorno>();
            AccountIntegrableResponseTemplate.Retorno retorno = new AccountIntegrableResponseTemplate.Retorno();
            retorno.codigo = 'XXX';
            retorno.codigoERP = 'V00082';
            retorno.loja = '01';
            responseTemplate.Retorno.add(retorno);
            httpResponse.setBody(JSON.serialize(responseTemplate));
            httpResponse.setStatusCode(201);
            return httpResponse;
        }else if(httpRequest.getEndpoint().contains(daspeMicroservicoHelper.EndpointCriacaoPedido__c)) {
            OrderIntegrableResponseTemplate.cls_Retorno retorno = new OrderIntegrableResponseTemplate.cls_Retorno();
            retorno.Pedido = 'C04470';
            OrderIntegrableResponseTemplate responseTemplate = new OrderIntegrableResponseTemplate();
            responseTemplate.Retorno = new List<OrderIntegrableResponseTemplate.cls_Retorno>{retorno};
            httpResponse.setBody(JSON.serialize(responseTemplate));
            httpResponse.setStatusCode(201);
            return httpResponse;
        }else{
            return httpResponse;
        }
    }
}