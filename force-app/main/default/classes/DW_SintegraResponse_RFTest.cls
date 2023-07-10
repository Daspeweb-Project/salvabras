@isTest
public with sharing class DW_SintegraResponse_RFTest {
	public static String json = '{'+
	'    "code": "0",'+
	'    "status": "OK",'+
	'    "message": "Pesquisa realizada com sucesso.",'+
	'    "atividade_principal": ['+
	'        {'+
	'            "text": "Portais, provedores de conteúdo e outros serviços de informação na internet",'+
	'            "code": "6319400"'+
	'        }'+
	'    ],'+
	'    "data_situacao": "01/09/2004",'+
	'    "complemento": "ANDAR 17 A 20 TORRE SUL ANDAR 2 TORRE NORTE ANDAR 18 A 20 TORRE NORTE",'+
	'    "nome": "GOOGLE BRASIL INTERNET LTDA.",'+
	'    "uf": "SP",'+
	'    "telefone": "(11) 2395-8400",'+
	'    "email": "googlebrasil@google.com",'+
	'    "atividades_secundarias": ['+
	'        {'+
	'            "text": "Consultoria em publicidade",'+
	'            "code": "7319004"'+
	'        },'+
	'        {'+
	'            "text": "Comércio varejista especializado de equipamentos e suprimentos de informática",'+
	'            "code": "4751201"'+
	'        },'+
	'        {'+
	'            "text": "Desenvolvimento e licenciamento de programas de computador customizáveis",'+
	'            "code": "6202300"'+
	'        },'+
	'        {'+
	'            "text": "Desenvolvimento de programas de computador sob encomenda",'+
	'            "code": "6201501"'+
	'        },'+
	'        {'+
	'            "text": "Tratamento de dados, provedores de serviços de aplicação e serviços de hospedagem na internet",'+
	'            "code": "6311900"'+
	'        },'+
	'        {'+
	'            "text": "Holdings de instituições nãofinanceiras",'+
	'            "code": "6462000"'+
	'        }'+
	'    ],'+
	'    "qsa": ['+
	'        {'+
	'            "qual": "37-Sócio Pessoa Jurídica Domiciliado no Exterior",'+
	'            "qual_rep_legal": "17-Procurador",'+
	'            "nome_rep_legal": "YUN KI LEE",'+
	'            "pais_origem": "ESTADOS UNIDOS",'+
	'            "nome": "GOOGLE INTERNATIONAL LLC"'+
	'        },'+
	'        {'+
	'            "qual": "37-Sócio Pessoa Jurídica Domiciliado no Exterior",'+
	'            "qual_rep_legal": "17-Procurador",'+
	'            "nome_rep_legal": "YUN KI LEE",'+
	'            "pais_origem": "ESTADOS UNIDOS",'+
	'            "nome": "GOOGLE LLC"'+
	'        },'+
	'        {'+
	'            "qual": "05-Administrador",'+
	'            "qual_rep_legal": "",'+
	'            "nome_rep_legal": "",'+
	'            "pais_origem": "",'+
	'            "nome": "FABIO JOSE SILVA COELHO"'+
	'        }'+
	'    ],'+
	'    "situacao": "ATIVA",'+
	'    "bairro": "ITAIM BIBI",'+
	'    "tipo_logradouro": null,'+
	'    "logradouro": "AV BRIGADEIRO FARIA LIMA",'+
	'    "numero": "3477",'+
	'    "cep": "04.538-133",'+
	'    "municipio": "São Paulo",'+
	'    "abertura": "01/09/2004",'+
	'    "sigla_natureza_juridica": "não informado",'+
	'    "natureza_juridica": "206-2 - Sociedade Empresária Limitada",'+
	'    "cnpj": "06.990.590/0001-23",'+
	'    "ultima_atualizacao": "15/08/2020 13:57:51",'+
	'    "tipo": "MATRIZ",'+
	'    "fantasia": "********",'+
	'    "efr": "*****",'+
	'    "motivo_situacao": "",'+
	'    "situacao_especial": "********",'+
	'    "data_situacao_especial": "********",'+
	'    "capital_social": "56.758.501,00,",'+
	'    "extra": null,'+
	'    "porte": "DEMAIS",'+
	'    "ibge": {'+
	'        "codigo_municipio": "3550308",'+
	'        "codigo_uf": "35"'+
	'    }'+
	'}';
    @isTest
	public static void testParse() {
		DW_SintegraResponse_RF obj = DW_SintegraResponse_RF.parse(DW_SintegraResponse_RFTest.json);
		System.assert(obj != null);
	}
}