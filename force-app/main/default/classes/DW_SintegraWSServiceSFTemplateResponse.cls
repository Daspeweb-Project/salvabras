/**
 * Created by hellenmartins on 20/10/2021.
 */

global class DW_SintegraWSServiceSFTemplateResponse {
    global String code;//SF
    global String status;//SF
    global String message;//RF ST SN SF
    global String telefone;//RF SF
    global String cnpj;//RF ST SN SF
    public String nome_empresarial; // ST SN SF

    public String inscricao_suframa; //SF
    public String razao_social; //SF
    public String endereco_eletronico; //SF
    public String situacao_cadastral; //SF
    public String data_validade_cadastral; //SF
    public String url_comprovante; //SF
    global natureza_juridica natureza_juridica; //SF
    global List<Incentivos> incentivos;//SF
    global endereco endereco;//SF
    global atividade_principal atividade_principal;
    global List<atividade_principal> atividade_secundaria;
    global file_return file_return;
    public class natureza_juridica {
        public String codigo;
        public String descricao;
    }
    global class endereco {
        global String uf;
        global String cep;
        global String municipio;
        global String bairro;
        global String logradouro;
        global String numero;
        global String complemento;
    }
    //SF
    public class Incentivos {
        public String tributo;
        public String beneficio;
        public String finalidade;
        public String base_legal;
    }

    global class atividade_principal {
        global String text;
        global String code;
        global String descricao;
        global String atividade_exercida;
    }

    global class file_return {
        global String url_file;
    }

    public DW_SintegraWSServiceSFTemplateResponse() {
        this.code = '';
        this.razao_social = '';
    }

}