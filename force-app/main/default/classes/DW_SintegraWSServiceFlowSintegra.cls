global class DW_SintegraWSServiceFlowSintegra{
    @InvocableMethod(label='Buscar dados no Sintegra')
    global static List<Response> get(List<Request> requestList){
        try {
            DW_SintegraWSServiceSTTemplateResponse responseFromSintegraService
                = DW_SintegraWSService.getSintegra(requestList.get(0).cnpj, 'ST');
            System.debug(LoggingLevel.INFO, 'DW_SintegraWSServiceFlowSintegra@get -> : responseFromSintegraService' + responseFromSintegraService);

            Response response = new Response();
            response.message = responseFromSintegraService.message;
            response.code = responseFromSintegraService.code;
            response.version = responseFromSintegraService.version;
            response.cnpj = responseFromSintegraService.cnpj;
            response.nome_empresarial = responseFromSintegraService.nome_empresarial;
            
  			System.debug('Inscricao - '+responseFromSintegraService.inscricao_estadual);            

            if(responseFromSintegraService.inscricao_estadual == null || responseFromSintegraService.inscricao_estadual == 'null' || responseFromSintegraService.inscricao_estadual== ''){
               	response.inscricao_estadual = 'ISENTO';
            }else{
            	response.inscricao_estadual = responseFromSintegraService.inscricao_estadual;
            }
            
            response.tipo_inscricao = responseFromSintegraService.tipo_inscricao;
            response.data_situacao_cadastral = responseFromSintegraService.data_situacao_cadastral;
            response.situacao_cnpj = responseFromSintegraService.situacao_cnpj;
            response.situacao_ie = responseFromSintegraService.situacao_ie;
            response.nome_fantasia = responseFromSintegraService.nome_fantasia;
            response.data_inicio_atividade = responseFromSintegraService.data_inicio_atividade;
            response.regime_tributacao = responseFromSintegraService.regime_tributacao;
            response.informacao_ie_como_destinatario = responseFromSintegraService.informacao_ie_como_destinatario;
            response.porte_empresa = responseFromSintegraService.porte_empresa;
            response.data_fim_atividade = responseFromSintegraService.data_fim_atividade;
            response.regime_tributacao = responseFromSintegraService.regime_tributacao;
            response.uf = responseFromSintegraService.uf;
            response.logradouro = DW_Helper.limitedTo(responseFromSintegraService.logradouro, 50);
            response.numero = responseFromSintegraService.numero;
            response.municipio = responseFromSintegraService.municipio;
            response.cep = responseFromSintegraService.cep.replaceAll('[^0-9]', '');
            response.bairro = responseFromSintegraService.bairro;
            //			response.fullResponse = responseFromSintegraService;
            if(DW_Helper.hasSomeContent(response.data_situacao_cadastral) && response.data_situacao_cadastral.contains('**')){
                response.data_situacao_cadastral = null;
            }
            if(DW_Helper.hasSomeContent(response.data_fim_atividade) && response.data_fim_atividade.contains('**')){
                response.data_fim_atividade = null;
            }
            if(DW_Helper.hasSomeContent(response.data_situacao_cadastral) && response.data_situacao_cadastral.contains('**')){
                response.data_situacao_cadastral = null;
            }
            if(DW_Helper.hasSomeContent(response.data_inicio_atividade) && response.data_inicio_atividade.contains('**')){
                response.data_inicio_atividade = null;
            }
            
            if(responseFromSintegraService.ibge != NULL){
                response.codigo_municipio = responseFromSintegraService.ibge.codigo_municipio;
            }Else {response.codigo_municipio ='0000';}
            return new List<Response>{response};
                
                } catch (Exception e) {
                    return new List<Response>{
                        new Response('Endereço não encontrado. \n' + e.getMessage() + '\n' + e.getStackTraceString())
                            };
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
        @InvocableVariable(required=true) global String message;
        @InvocableVariable(required=true) global String errorMessage;
        @InvocableVariable(required=true) global String code;
        @InvocableVariable(required=true) global String cnpj;
        @InvocableVariable(required=true) global String version;
        @InvocableVariable(required=true) public String nome_empresarial;
        @InvocableVariable(required=true) public String inscricao_estadual;
        @InvocableVariable(required=true) public String tipo_inscricao;
        @InvocableVariable(required=true) public String data_situacao_cadastral;
        @InvocableVariable(required=true) public String situacao_cnpj;
        @InvocableVariable(required=true) public String situacao_ie;
        @InvocableVariable(required=true) public String nome_fantasia;
        @InvocableVariable(required=true) public String data_inicio_atividade;
        @InvocableVariable(required=true) public String regime_tributacao;
        @InvocableVariable(required=true) public String informacao_ie_como_destinatario;
        @InvocableVariable(required=true) public String porte_empresa;
        @InvocableVariable(required=true) public String data_fim_atividade;
        @InvocableVariable(required=true) public String logradouro;
        @InvocableVariable(required=true) public String cep;
        @InvocableVariable(required=true) public String uf;
        @InvocableVariable(required=true) public String municipio;
        @InvocableVariable(required=true) public String numero;
        @InvocableVariable(required=true) public String bairro;
        @InvocableVariable(required=true) global String codigo_municipio;
        public Response(){
        }
        public Response(String errorMessage){
            this.errorMessage = errorMessage;
        }
    }
}