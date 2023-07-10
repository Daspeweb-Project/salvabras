public class AccountMercosIntegrableRequestTemplate{
	public String razao_social;	//Loja do Zé LTDA
	public String nome_fantasia;	//Zé Store
	public String tipo;	//J
	public String documento_dw;	//46487899000110
	public String inscricao_estadual;	//ISENTO
	public String suframa;	//
	public String rua;	//Rua Abdon Batista
	public String numero;	//121
	public String complemento;	//sala 1402
	public String bairro;	//Centro
	public String cep;	//89201010
	public String cidade;	//Joinville
	public String estado;	//SC
	public String observacao;	//Cliente com ótimo histórico de pagamentos.
	public cls_emails[] emails;
	public cls_telefones[] telefones;
	public cls_contatos[] contatos;
	public cls_enderecos_adicionais[] enderecos_adicionais;
	public String nome_excecao_fiscal;	//Isento
	public Integer segmento_id;	//33746
	public boolean excluido;
	public class cls_emails {
		public String email;	//lucas@zestore.com.br
	}
	public class cls_telefones {
		public String numero;	//(21) 1111-1234
	}
	public class cls_contatos {
		public String nome;	//Lucas da Silva
		public String cargo;	//Gerente de Compras
		public cls_emails[] emails;
		public cls_telefones[] telefones;
	}
	public class cls_enderecos_adicionais {
		public String cep;	//89223-005
		public String endereco;	//Av. Rolf Wiest
		public String numero;	//277
		public String complemento;	//
		public String bairro;	//Bom Retiro
		public String cidade;	//Joinville
		public String estado;	//SC
	}
	
}