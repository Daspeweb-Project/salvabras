@isTest
public with sharing class DW_SintegraResponse_SNTest {
    @isTest
	static void testParse() {
		String json=		'{'+
		'	"code": "0",'+
		'	"status": "OK",'+
		'	"message": "Pesquisa realizada com sucesso.",'+
		'	"cnpj": "06990590000123",'+
		'	"cnpj_matriz": "06.990.590/0001-23",'+
		'	"nome_empresarial": "GOOGLE BRASIL INTERNET LTDA.",'+
		'	"situacao_simples_nacional": "NÃO optante pelo Simples Nacional",'+
		'	"situacao_simei": "NÃO optante pelo SIMEI",'+
		'	"situacao_simples_nacional_anterior": "Não Existem",'+
		'	"situacao_simei_anterior": "Não Existem",'+
		'	"agendamentos": "Não Existem",'+
		'	"eventos_futuros_simples_nacional": "Não Existem",'+
		'	"eventos_futuros_simples_simei": "Não Existem"'+
		'}';
		DW_SintegraResponse_SN obj = DW_SintegraResponse_SN.parse(json);
		System.assert(obj != null);
	}
}