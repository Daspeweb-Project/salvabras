/**
 * Created by Guilherme Reis on 02/02/2021.
 */

global class DW_SintegraWSServiceTemplateResponse{
    global String code;//RF ST SN
    global String status;//RF ST SN
    global String message;//RF ST SN
    global String data_situacao;//RF
    global String complemento;//RF
    global String nome;//RF
     global String uf;//RF ST
    global String telefone;//RF
    global String email;//RF
    global String situacao;//RF
    global String bairro;//RF ST
    global String tipo_logradouro;//RF
    global String logradouro;//RF ST
    global String numero;//RF ST
    global String cep;//RF ST
    global String municipio;//RF ST
    global String abertura;//RF
    global String sigla_natureza_juridica;//RF
    global String natureza_juridica;//RF
    global String cnpj;//RF ST SN
    global String ultima_atualizacao;//RF
    global String tipo;//RF
    global String fantasia;//RF
    global String efr;//RF
    global String motivo_situacao;//RF
    global String situacao_especial;//RF
    global String data_situacao_especial;//RF
    global String capital_social;//RF
    global String extra;//RF
    global String porte;//RF
    global String version;//RF ST SN

    public String nome_empresarial; // ST SN
    public String inscricao_estadual; // ST
    public String tipo_inscricao; // ST
    public String data_situacao_cadastral; // ST
    public String situacao_cnpj; // ST
    public String situacao_ie; // ST
    public String nome_fantasia; // ST
    public String data_inicio_atividade; // ST
    public String regime_tributacao; // ST
    public String informacao_ie_como_destinatario; // ST
    public String porte_empresa; // ST
    public String data_fim_atividade; // ST

    public String cnpj_matriz; //SN
    public String situacao_simples_nacional; //SN
    public String situacao_simei; //SN
    public String situacao_simples_nacional_anterior; //SN
    public String situacao_simei_anterior; //SN
    public String agendamentos; //SN
    public String eventos_futuros_simples_nacional; //SN
    public String eventos_futuros_simples_simei; //SN
    public String optanteSN; //SN


    public Ibge ibge; // RF ST
    public Cnae_principal cnae_principal; //ST

    global List<Atividade_principal> atividade_principal;//RF
    global List<Atividade_principal> atividades_secundarias;//RF
    global List<Qsa> qsa;//RF

    public class Cnae_principal {
        public String code;
        public String text;
    }

    global class Ibge {
        global String codigo_municipio;
        global String codigo_uf;
    }

    global class Atividade_principal {
        global String text;
        global String code;
    }

    global class Qsa {
        global String qual;
        global String qual_rep_legal;
        global String nome_rep_legal;
        global String pais_origem;
        global String nome;
    }

    public DW_SintegraWSServiceTemplateResponse(){
        this.code = '';
    }

}