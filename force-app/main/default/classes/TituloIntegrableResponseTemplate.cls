public with sharing class TituloIntegrableResponseTemplate{
	public List<titulos> titulos{get;set;}

	public class titulos{
		public String num{get;set;}
		public String filial{get;set;}
		public String prefixo{get;set;}
		public String parcela{get;set;}
		public String tipo{get;set;}
	}

	// if error
	public Integer errorCode{get;set;}
	public String errorMessage{get;set;}
}