/**
 * Created by hellenmartins on 21/10/2021.
 */

global class DW_SintegraWSServiceSNTemplateResponse {
    global String code;//SN
    global String status;//SN
    global String message;//SN
    global String cnpj;//SN
    global String version;//SN
    public String nome_empresarial; //SN
    public String cnpj_matriz; //SN
    public String situacao_simples_nacional; //SN
    public String situacao_simei; //SN
    public String situacao_simples_nacional_anterior; //SN
    public String situacao_simei_anterior; //SN
    public String agendamentos; //SN
    public String eventos_futuros_simples_nacional; //SN
    public String eventos_futuros_simples_simei; //SN


    public DW_SintegraWSServiceSNTemplateResponse(){
        this.code = '';
    }

}