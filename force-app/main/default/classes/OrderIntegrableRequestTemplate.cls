/**
 * Created by guilhermereis on 08/02/21.
 */

public without sharing class OrderIntegrableRequestTemplate {

	public List<Pedido> PEDIDO;

	public class Itens {
		public String Item;
		public String Produto; 
		public Double Qtde;
       // public Double C6_UNSVEN;
        //public Double Unsven;
		public Double Preco;
		public String Operacao;
		public String DataEntrega;
		public String PedidoCliente;
	}

	public class Pedido {
		public Cabecalho CABECALHO;
		public List<Itens> ITENS;
	}

	public class Cabecalho {
		public String CodEmp;
        public String PresencaCom;
		public String CodFil;
		public String TpCadastro;
		public String Pedido;
		public String TipoPv;
		public String Cliente;
		public String Loja;
		public String Transportadora;
		public String Cond_ESPACE_Pagto;
		public String Vendedor1;
		public String Vendedor2;
		public String TipoFrete;
		public Double PesoBruto;
		public Double PesoLiquido;
		public Double Volume;
		public String Especie;
		public String MensagemNota;
		public String MensagemPadrao;
		public String DataEntregaCab;
		public String Natureza;
        public String MotivoBonificacao;
        public String PedidoSF;
	}
}