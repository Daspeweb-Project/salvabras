/**
 * Created by Guilherme Reis on 02/02/2021.
 */

global class DW_SintegraWSServiceFlowSN{
    @InvocableMethod(label='Buscar dados da Simples Nacional no Sintegra')
    global static List<Response> get(List<Request> requestList){
        try {
            DW_SintegraWSServiceSNTemplateResponse responseFromSintegraService
                    = DW_SintegraWSService.getSimples(requestList.get(0).cnpj, 'SN');

            Response response = new Response();
            response.message = responseFromSintegraService.message;
			
			 System.debug('Menssage '+responseFromSintegraService);
            
            
            response.code = responseFromSintegraService.code;
            response.status = responseFromSintegraService.status;
            response.version = responseFromSintegraService.version;
            response.nome_empresarial = responseFromSintegraService.nome_empresarial;
            response.cnpj_matriz = responseFromSintegraService.cnpj_matriz;        
            response.situacao_simei = responseFromSintegraService.situacao_simei;
            response.situacao_simples_nacional_anterior = responseFromSintegraService.situacao_simples_nacional_anterior;
            response.situacao_simei_anterior = responseFromSintegraService.situacao_simei_anterior;
            response.agendamentos = responseFromSintegraService.agendamentos;
            response.eventos_futuros_simples_nacional = responseFromSintegraService.eventos_futuros_simples_nacional;
            response.eventos_futuros_simples_simei = responseFromSintegraService.eventos_futuros_simples_simei;
            response.situacao_simples_nacional = responseFromSintegraService.situacao_simples_nacional;
            if(responseFromSintegraService.situacao_simples_nacional.startsWith('Optante pelo Simples')){
             response.OptanteSN  = 'Pendente';
                System.debug('Situação Simples Optante '+responseFromSintegraService.situacao_simples_nacional);
            }else{
                System.debug('Situação Simples Não Optante '+responseFromSintegraService.situacao_simples_nacional);
            }


//			response.fullResponse = responseFromSintegraService;
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
        @InvocableVariable(required=true) global String status;
        @InvocableVariable(required=true) global String version;
        @InvocableVariable(required=true) public String nome_empresarial;
        @InvocableVariable(required=true) public String cnpj_matriz;
        @InvocableVariable(required=true) public String situacao_simples_nacional;
        @InvocableVariable(required=true) public String situacao_simei;
        @InvocableVariable(required=true) public String situacao_simples_nacional_anterior;
        @InvocableVariable(required=true) public String situacao_simei_anterior;
        @InvocableVariable(required=true) public String agendamentos;
        @InvocableVariable(required=true) public String eventos_futuros_simples_nacional;
        @InvocableVariable(required=true) public String eventos_futuros_simples_simei;
        @InvocableVariable(required=true) public String OptanteSN;


        public Response(){
        }
        public Response(String errorMessage){
            this.errorMessage = errorMessage;
        }
    }
}