public class DW_SintegraWSServiceRFTemplateResponse {

	public String code;
	public String status;
	public String message;
	public String cnpj;
	public String nome;
	public String fantasia;
	public String cep;
	public String uf;
	public String municipio;
	public String bairro;
	public String tipo_logradouro;
	public String logradouro;
	public String numero;
	public String complemento;
	public String telefone;
	public String email;
	public String capital_social;
	public String data_situacao;
	public String data_situacao_especial;
	public String abertura;
	public String motivo_situacao;
	public String sigla_natureza_juridica;
	public String natureza_juridica;
	public String situacao;
	public String situacao_especial;
	public String tipo;
	public List<Atividade_principal> atividade_principal;
	public List<Atividade_principal> atividades_secundarias;
	public List<Qsa> qsa;
	public String ultima_atualizacao;
	public String efr;
	public Extra extra;
	public String porte;
	public Ibge ibge;
	public List<Extra> cnpjs_do_grupo;
	public String inscricao_municipal;
	public String version;

	public class Extra {
	}

	public class Ibge {
		public String codigo_municipio;
		public String codigo_uf;
	}

	public class Atividade_principal {
		public String code;
		public String text;
	}

	public class Qsa {
		public String qual;
		public String qual_rep_legal;
		public String nome_rep_legal;
		public String pais_origem;
		public String nome;
		public String faixa_etaria;
	}

}