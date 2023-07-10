/**
 * Created by guilhermereis on 10/12/2020.
 */

public with sharing class OrderIntegrableResponseTemplate{
	public cls_Retorno[] Retorno;
	public class cls_Retorno {
		public String SessionId;	//3957
		public String referencia;	//SEM ERROS
		public String codigo;	//XXX
		public String Pedido;	//020741
		public String descricao;	//Processo realizado com sucesso. Pedido de venda TOTVS incluido: 020741.
	}
}