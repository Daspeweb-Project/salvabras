/**
* Created by Guilherme Reis on 02/02/2021.
*/

global class DW_SintegraWSServiceFlowRF{
    @InvocableMethod(label='Buscar dados da Receita Federal no Sintegra')
    global static List<Response> get(List<Request> requestList){
        try {  
            DW_SintegraWSServiceRFTemplateResponse responseFromSintegraService
                = DW_SintegraWSService.getReceita(requestList.get(0).cnpj, 'RF');
            System.debug(LoggingLevel.INFO, 'DW_SintegraWSServiceFlowRF@get -> : responseFromSintegraService' + responseFromSintegraService);

            Response response = new Response();
            System.debug('Resposta '+responseFromSintegraService);
            response.fantasia = responseFromSintegraService.fantasia;
            response.message = responseFromSintegraService.message;
            response.code = responseFromSintegraService.code;
            response.status = responseFromSintegraService.status;
            //response.data_situacao = responseFromSintegraService.data_situacao;
            String complemento = responseFromSintegraService.complemento;
            response.complemento = DW_Helper.limitedTo(complemento, 47);
            String nome = responseFromSintegraService.nome;
            response.nome = DW_Helper.limitedTo(nome,60);
            response.uf = responseFromSintegraService.uf;
            response.telefone = responseFromSintegraService.telefone;
            response.email = responseFromSintegraService.email;
            String bairro = responseFromSintegraService.bairro;
            
            if(bairro  != null)bairro = bairro.replace('(', '');
            if(bairro != null)bairro = bairro.replace(')', '');
            response.bairro = DW_Helper.limitedTo(bairro, 39);
            //response.tipo_logradouro = responseFromSintegraService.tipo_logradouro;
            String logradouro = '';
            if(responseFromSintegraService.logradouro != null) logradouro = responseFromSintegraService.logradouro.replace(',', '');
            response.logradouro = DW_Helper.limitedTo(logradouro, 50);
            if(responseFromSintegraService.numero != null)response.numero = responseFromSintegraService.numero.replace(',', '');
            if(responseFromSintegraService.cep != null)response.cep = responseFromSintegraService.cep.replaceAll('[^0-9]', '');
            response.municipio = responseFromSintegraService.municipio;
            response.sigla_natureza_juridica = responseFromSintegraService.sigla_natureza_juridica;
            response.natureza_juridica = responseFromSintegraService.natureza_juridica;
            response.ultima_atualizacao = responseFromSintegraService.ultima_atualizacao;
            response.tipo = responseFromSintegraService.tipo;
            response.motivo_situacao = responseFromSintegraService.motivo_situacao;
            response.situacao_especial = responseFromSintegraService.situacao_especial;
            response.situacao = responseFromSintegraService.situacao;
            //response.extra = responseFromSintegraService.extra;
            response.porte = responseFromSintegraService.porte;
            response.version = responseFromSintegraService.version;
            
            if(DW_Helper.hasSomeContent(responseFromSintegraService.abertura) && !responseFromSintegraService.abertura.contains('**')){
                response.abertura = Date.parse(responseFromSintegraService.abertura);
            }
            
            if(DW_Helper.hasSomeContent(responseFromSintegraService.capital_social)){
                String capitalFormated = responseFromSintegraService.capital_social.replace('.', ',');
                Double capitalDouble = Double.valueOf(responseFromSintegraService.capital_social);
                response.capital_social = capitalDouble;
            }else{
                 response.capital_social = 0;
            }
            
            if(DW_Helper.hasSomeContent(responseFromSintegraService.ibge)){
                String codigoMunicipio = responseFromSintegraService.ibge.codigo_municipio;
                response.codigo_municipio = codigoMunicipio.leftPad(6, '0');
            }
            
            return new List<Response>{response};
                
                } catch (Exception e) {
                    return new List<Response>{new Response('Endereço não encontrado. \n' + e.getMessage() + '\n' + e.getStackTraceString())};
                        }
    }
    
    global class Request{
        @InvocableVariable(required=true)
        global String cnpj;
        public Request(){}
        public Request(String cnpj){
            this.cnpj = cnpj;
        }
    }
    
    global class Response{
        @InvocableVariable(required=true) global String fantasia;
        @InvocableVariable(required=true) global String message;
        @InvocableVariable(required=true) global String errorMessage;
        @InvocableVariable(required=true) global String code;
        @InvocableVariable(required=true) global String status;
        @InvocableVariable(required=true) global String data_situacao;
        @InvocableVariable(required=true) global String complemento;
        @InvocableVariable(required=true) global String nome;
        @InvocableVariable(required=true) global String uf;
        @InvocableVariable(required=true) global String telefone;
        @InvocableVariable(required=true) global String email;
        @InvocableVariable(required=true) global String situacao;
        @InvocableVariable(required=true) global String bairro;
        @InvocableVariable(required=true) global String tipo_logradouro;
        @InvocableVariable(required=true) global String logradouro;
        @InvocableVariable(required=true) global String numero;
        @InvocableVariable(required=true) global String cep;
        @InvocableVariable(required=true) global String municipio;
        @InvocableVariable(required=true) global Date abertura;
        @InvocableVariable(required=true) global String sigla_natureza_juridica;
        @InvocableVariable(required=true) global String natureza_juridica;
        @InvocableVariable(required=true) global String ultima_atualizacao;
        @InvocableVariable(required=true) global String tipo;
        @InvocableVariable(required=true) global String motivo_situacao;
        @InvocableVariable(required=true) global String situacao_especial;
        @InvocableVariable(required=true) global String data_situacao_especial;
        @InvocableVariable(required=true) global Double capital_social;
        @InvocableVariable(required=true) global String extra;
        @InvocableVariable(required=true) global String porte;
        @InvocableVariable(required=true) global String version;
        @InvocableVariable(required=true) global String codigo_municipio;
        
        public Response(){
        }
        public Response(String errorMessage){
            this.errorMessage = errorMessage;
        }
    }
}