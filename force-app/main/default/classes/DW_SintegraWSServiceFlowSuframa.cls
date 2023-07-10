/**
 * Created by hellenmartins on 20/10/2021.
 */

global class DW_SintegraWSServiceFlowSuframa {
    @InvocableMethod(label='Buscar dados Suframa no Sintegra')
    global static List<Response> get(List<Request> requestList) {
        try {

            DW_SintegraWSServiceSFTemplateResponse responseFromSintegraService
                    = DW_SintegraWSService.getSuframa(requestList.get(0).cnpj, 'SF');

            Response response = new Response();
            response.code = responseFromSintegraService.code;
            response.status = responseFromSintegraService.status;
            response.message = responseFromSintegraService.message;
            response.cnpj = responseFromSintegraService.cnpj;
            response.inscricao_suframa = responseFromSintegraService.inscricao_suframa;
            response.razao_social = responseFromSintegraService.razao_social;
            response.endereco_eletronico = responseFromSintegraService.endereco_eletronico;
            response.telefone = responseFromSintegraService.telefone;
            response.situacao_cadastral = responseFromSintegraService.situacao_cadastral;
            response.nome = responseFromSintegraService.nome_empresarial;

            if (DW_Helper.hasSomeContent(responseFromSintegraService.endereco)) {
                response.uf = responseFromSintegraService.endereco.uf;
                response.cep = responseFromSintegraService.endereco.cep.replaceAll('[^0-9]', '');
                response.municipio = responseFromSintegraService.endereco.municipio;
                response.bairro = responseFromSintegraService.endereco.bairro;
                response.logradouro = responseFromSintegraService.endereco.logradouro;
                response.numero = responseFromSintegraService.endereco.numero;
                response.complemento = responseFromSintegraService.endereco.complemento;
            }

            if (DW_Helper.hasSomeContent(responseFromSintegraService.file_return)) {
                response.url_comprovante = responseFromSintegraService.file_return.url_file;
            }

            if (DW_Helper.hasSomeContent(responseFromSintegraService.atividade_principal)) {
                response.atividade_principal = responseFromSintegraService.atividade_principal.descricao;
            }
            if (DW_Helper.hasSomeContent(responseFromSintegraService.atividade_secundaria)) {
                response.atividade_secundaria = responseFromSintegraService.atividade_secundaria[0].descricao;
            }
            if (DW_Helper.hasSomeContent(responseFromSintegraService.natureza_juridica)) {
                response.natureza_juridica = responseFromSintegraService.natureza_juridica.descricao;
            }

            if (DW_Helper.hasSomeContent(responseFromSintegraService.incentivos)) {
                response.incentivo_fiscal1 = 'Tributo : ' + responseFromSintegraService.incentivos[0].tributo +
                                             ' - Beneficio: ' + responseFromSintegraService.incentivos[0].beneficio +
                                             ' - Finalidade: '+ responseFromSintegraService.incentivos[0].finalidade +
                                             ' - Base legal: '+ responseFromSintegraService.incentivos[0].base_legal;
                if (responseFromSintegraService.incentivos.size() > 1) {
                    response.incentivo_fiscal2 = 'Tributo : ' + responseFromSintegraService.incentivos[1].tributo +
                            ' - Beneficio: ' + responseFromSintegraService.incentivos[1].beneficio +
                            ' - Finalidade: '+ responseFromSintegraService.incentivos[1].finalidade +
                            ' - Base legal: '+ responseFromSintegraService.incentivos[1].base_legal;
                }else{
                    response.incentivo_fiscal2 = 'INFORMAÇÃO NÃO OBTIDA';
                }
            }

            if (String.isBlank(responseFromSintegraService.razao_social)) {
                response.razao_social = 'INFORMAÇÃO NÃO OBTIDA';
            }

            if (DW_Helper.hasSomeContent(responseFromSintegraService.data_validade_cadastral) && !responseFromSintegraService.data_validade_cadastral.contains('**')) {
                response.data_validade_cadastral = Date.parse(responseFromSintegraService.data_validade_cadastral);
            }

            return new List<Response>{
                    response
            };

        } catch (Exception e) {
            return new List<Response>{
                    new Response('Endereço não encontrado. \n' + e.getMessage() + '\n' + e.getStackTraceString())
            };
        }
    }

    global class Request {
        @InvocableVariable(required=true)
        global String cnpj;
        public Request() {
        }
        public Request(String cnpj) {
            this.cnpj = cnpj;
        }
    }

    global class Response {
        @InvocableVariable(required=true) global String fantasia;
        @InvocableVariable(required=true) global String cnpj;
        @InvocableVariable(required=true) global Date data_validade_cadastral;
        @InvocableVariable(required=true) global String inscricao_suframa;
        @InvocableVariable(required=true) global String atividade_principal;
        @InvocableVariable(required=true) global String atividade_secundaria;
        @InvocableVariable(required=true) global String incentivo_fiscal1;
        @InvocableVariable(required=true) global String incentivo_fiscal2;
        @InvocableVariable(required=true) global String natureza_juridica;
        @InvocableVariable(required=true) global String razao_social;
        @InvocableVariable(required=true) global String endereco_eletronico;
        @InvocableVariable(required=true) global String situacao_cadastral;
        @InvocableVariable(required=true) global String url_comprovante;
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

        public Response() {
        }
        public Response(String errorMessage) {
            this.errorMessage = errorMessage;
        }
    }
}