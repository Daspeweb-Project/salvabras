@isTest
public with sharing class DW_SintegraResponse_CPFTest {
    @isTest
	static void testParse() {
		String json=		'{'+
		'	"code": "0",'+
		'	"status": "OK",'+
		'	"message": "Pesquisa realizada com sucesso.",'+
		'	"cpf": "026.315.210-60",'+
		'	"nome": "ISABELLA ALVES",'+
		'	"genero": "F",'+
		'	"data_nascimento": "13/02/1985",'+
		'	"situacao_cadastral": "REGULAR",'+
		'	"data_inscricao": "18/05/2001",'+
		'	"digito_verificador": "00",'+
		'	"comprovante": "93BA.8U8B.6CAA.47F1",'+
		'	"version": "2"'+
		'}'+
		'         ';
		DW_SintegraResponse_CPF obj = DW_SintegraResponse_CPF.parse(json);
		System.assert(obj != null);
	}
}