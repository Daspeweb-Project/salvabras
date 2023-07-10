public with sharing class NotaFiscalIntegrableResponseTemplate{
	public list<NFs> NFs{get;set;}

	public class NFs{
		public String numtit{get;set;}
		public List<itens> itens{get;set;}
		public String cliente{get;set;}
		public String serie{get;set;}
		public String condpgt{get;set;}
		public String documento{get;set;}
		public String dtemissa{get;set;}
		public String loja{get;set;}
	}

	public class itens{
		public Decimal total{get;set;}
		public String item{get;set;}
		public Decimal prcven{get;set;}
		public Integer quantidade{get;set;}
		public String produto{get;set;}
		public String tes{get;set;}
	}

	// if error
	public Integer errorCode{get;set;}
	public String errorMessage{get;set;}
}