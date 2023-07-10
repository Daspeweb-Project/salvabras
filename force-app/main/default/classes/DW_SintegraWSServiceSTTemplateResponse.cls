/**
 * Created by hellenmartins on 21/10/2021.
 */

global with sharing class DW_SintegraWSServiceSTTemplateResponse {
    global String code;//ST
    global String status;//ST
    global String message;//ST
    global String uf;//ST
    global String bairro;//ST
    global String logradouro;//ST
    global String numero;//ST
    global String cep;//ST
    global String municipio;//ST
    global String cnpj;//ST
    global String version;//ST

    public String nome_empresarial; //ST
    public String inscricao_estadual; //ST
    public String tipo_inscricao; //ST
    public String data_situacao_cadastral; //ST
    public String situacao_cnpj; //ST
    public String situacao_ie; //ST
    public String nome_fantasia; //ST
    public String data_inicio_atividade; //ST
    public String regime_tributacao; //ST
    public String informacao_ie_como_destinatario; //ST
    public String porte_empresa; // ST
    public String data_fim_atividade; // ST


    public Ibge ibge; //ST
    public Cnae_principal cnae_principal; //ST


    public class Cnae_principal {
        public String code;
        public String text;
    }

    global class Ibge {
        global String codigo_municipio;
        global String codigo_uf;
    }


    public DW_SintegraWSServiceSTTemplateResponse(){
        this.code = '';
    }
}