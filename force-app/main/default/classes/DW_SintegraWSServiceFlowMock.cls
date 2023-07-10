/**
 * Created by Guilherme Reis on 02/02/2021.
 */

@IsTest
global class DW_SintegraWSServiceFlowMock implements HttpCalloutMock  {
    global HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse(); 
        if(DW_ForceErrorSingleton.getInstance().forceError){
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(500); 
            return res;
        }
        if(req.getEndpoint().contains('RF')){
            DW_SintegraWSServiceTemplateResponse template = new DW_SintegraWSServiceTemplateResponse();
            template.fantasia = 'Daspe Web';
            template.message = 'Pesquisa realizada com sucesso.';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(template));
            res.setStatusCode(200);
            return res;
        }
        if(req.getEndpoint().contains('SN')){
            DW_SintegraWSServiceTemplateResponse template = new DW_SintegraWSServiceTemplateResponse();
            template.nome_empresarial = 'Daspe Web 2';
            template.message = 'Pesquisa realizada com sucesso.';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(template));
            res.setStatusCode(200);
            return res;
        }
        if(req.getEndpoint().contains('ST')){
            DW_SintegraWSServiceTemplateResponse template = new DW_SintegraWSServiceTemplateResponse();
            template.inscricao_estadual = '123456789ins';
            template.message = 'Pesquisa realizada com sucesso.';
            res.setHeader('Content-Type', 'application/json');
            res.setBody(JSON.serialize(template));
            res.setStatusCode(200);
            return res;
        }
        if(req.getEndpoint().contains('SF')){
            DW_SintegraWSServiceTemplateResponse template = new DW_SintegraWSServiceTemplateResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"code":"0","status":"OK","message":"Pesquisa realizada com sucesso.","nome_empresarial":"Superintendencia da zona franca de manaus","cnpj":"04407029000143","inscricao_suframa":"200100564","endereco_eletronico":"sthephannie.sousa@suframa.gov.br","telefone":"9233217300","situacao_cadastral":"ATIVA","data_validade_cadastral":"","natureza_juridica":{"codigo":"1104","descricao":" Autarquia Federal"},"endereco":{"logradouro":"Avenida ministro mario andreazza","numero":"1424","complemento":"","bairro":"Distrito industrial","cep":"69075-830","municipio":"Manaus","uf":"AM"},"atividade_principal":{"codigo":"8411600 ADMINISTR","descricao":"Ação pública em geral","atividade_exercida":true},"atividade_secundaria":[{"codigo":"8411600 ADMINISTR","descricao":"Ação pública em geral","atividade_exercida":false}],"incentivos":[{"tributo":"IPI","beneficio":"Isenção","finalidade":"Consumo Interno, Industrialização e Utilização","base_legal":"Decreto 7.212 de 2010 (Art. 81)"}],"file_return":{"ext_file":"pdf","url_file":"https://sintegraws.com.br/api/v1/suframa/tipo-retorno/comprovante-pdf/7143d11f-4c5c-4b0b-97fa-7a17a5ebf8c3"},"version":"1"}');
            res.setStatusCode(200);
            return res;
        }
        return null;
    }
}