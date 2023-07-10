/**
 * Created by Willian Levandoski on 12/09/21.
 */


public with sharing class AccountIntegrable extends DW_Integrable{
    public AccountIntegrableResponseTemplate responseTemplate;
    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }

    public override String constructEndpoint() {
       	Account account = (Account)this.deserializedRequestObject;
        if(account.NomeTipoRegistro__c == 'Transportadora'){
            return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndpointCriacaoTransportadora__c;
        }else if(account.NomeTipoRegistro__c == 'Vendedor'){
            return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndpointCriacaoVendedor__c;
        }else if(account.NomeTipoRegistro__c == 'Cliente'){
            return DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndpointCriacaoConta__c ;
        }else{
            return 'Não foi encontrado nenhum tipo de registro nessa conta';
        }
    }

    public override String setMethod() {
        return 'POST';
    }

    public override Map<String, String> constructHeaders() {
        return new Map<String, String>{
            //'Authorization' => 'Bearer ' + DaspeMicroservicoHelper.getInstance().daspeMicroservico.Token__c,
            'Content-Type' => 'application/json'
            //'Accept' => 'application/json'
        };
    }

    public override Map<String, String> constructQueryParameters() {
        return new Map<String, String>();
    }
    
    public override String getSerializedRequest() {
        Account account = (Account)this.deserializedRequestObject;
        if(account.NomeTipoRegistro__c == 'Transportadora'){
            return getTransportadoraRequest();
        }else if(account.NomeTipoRegistro__c == 'Vendedor'){
            return getVendedores();
        }else if(account.NomeTipoRegistro__c == 'Cliente'){
            return getClienteRequest();
        }else{
            return 'Não foi encontrado nenhum tipo de registro nessa conta';
        }
    }
    
    public String getVendedores(){
      	VendedoresIntegrableResquestTemplate.Vendedores requestTemplate = new VendedoresIntegrableResquestTemplate.Vendedores();
        VendedoresIntegrableResquestTemplate template = new VendedoresIntegrableResquestTemplate();
        template.Vendedores = new List<VendedoresIntegrableResquestTemplate.Vendedores>();
        template.Vendedores.add(requestTemplate);
        
        Account account = (Account)this.deserializedRequestObject;        
		requestTemplate.CodEmp = '01';
		requestTemplate.CodFil =  '01'; 
        requestTemplate.TpCadastro =  DW_Helper.hasSomeContent(account.CodigoERPVendedor__c) ? '4' : '3';
        requestTemplate.Codemitente = DW_Helper.hasSomeContent(account.CodigoERPVendedor__c) ? account.CodigoERPVendedor__c: '';
        requestTemplate.nomeemit =  getString(DW_Helper.limitedTo(getString(account.Name), 60));
        requestTemplate.nomeabrev = account.Name.length() > 20 ? getString(account.Name.subString(0,19)) : getString(account.Name);
        List<String> billingStreetSplit = account.BillingStreet.split(',');
        String endereco = billingStreetSplit.get(0).trim() //rua
            + ', ' + billingStreetSplit.get(1).trim() //n?mero
            + (billingStreetSplit.size() == 3 ? '' : (', ' + billingStreetSplit.get(2).trim())); //complemente, se houver
        requestTemplate.endereco = getString(DW_Helper.limitedTo(endereco, 80));
        
      String bairro = getString(account.Bairro__c);
        if(billingStreetSplit.size() == 3){
        	bairro =  getString(billingStreetSplit.get(2).trim()); //Rua, Numero, Bairro
        }else if(billingStreetSplit.size() == 4){
            bairro =  getString(billingStreetSplit.get(3).trim()); //Rua, Numero,Complemento, Bairro
        }
      	requestTemplate.bairro = getString(DW_Helper.limitedTo(bairro,40));
        
        requestTemplate.estado = getString(account.BillingState);
        requestTemplate.cidade = getString(account.BillingCity);
        requestTemplate.pais = getString(account.pais_conta__c ,'0105');
        requestTemplate.email = getString(account.Email__c);
        requestTemplate.cep = getString(account.BillingPostalCode).replaceAll('[^0-9]', '');
        requestTemplate.ddd = account.Phone.replaceAll('[^0-9]', '').replaceAll('([+55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', '$2');
        requestTemplate.cel = account.Phone.replaceAll('[^0-9]', '').replaceAll('([+55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', '$3$4$5');
        
        requestTemplate.cnpj = account.Documento__c.replaceAll('[^0-9]', '');
        requestTemplate.ie = getString(account.inscricao_estadual_conta__c);
        requestTemplate.status = account.StatusConta__c == 'Ativo' ? '2' : '1';
        requestTemplate.comis = account.Comissao__c;
		requestTemplate.pgbaixa = 100;
		requestTemplate.tipoven = getString(account.TipoVendedor__c).subString(0,1).toUpperCase();
		requestTemplate.bicm = 'N';
		requestTemplate.bicmret = 'N';
		requestTemplate.biss = 'N';
		requestTemplate.bipi =  'N';
		requestTemplate.bfrete = 'N';
        return JSON.serialize(template);
    }
    
    public String getClienteRequest() {
        Account account = (Account)this.deserializedRequestObject;
        if(DW_Helper.isNullOrBlank(account.StatusCadastro__c)) throw new IllegalArgumentException('Status do cadastro é obrigatório para integração');
        if(account.StatusCadastro__c != 'Finalizado') throw new IllegalArgumentException('Status do cadastro deve estar como Finalizado para integração');
        if(DW_Helper.isNullOrBlank(account.StatusConta__c)) throw new IllegalArgumentException('Status da conta é obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.NomeFantasia__c)) throw new IllegalArgumentException('Nome fantasia obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.BillingStreet)) throw new IllegalArgumentException('Rua de cobrança obrigatória para integração');
        if(DW_Helper.isNullOrBlank(account.BillingState)) throw new IllegalArgumentException('Estado de cobrança obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.BillingCity)) throw new IllegalArgumentException('Cidade de cobrança obrigatória para integração');
        if(DW_Helper.isNullOrBlank(account.BillingState)) throw new IllegalArgumentException('Estado de cobrança obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.BillingPostalCode)) throw new IllegalArgumentException('CEP de cobrança obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.CodigoMunicipioCobranca__c)) throw new IllegalArgumentException('Código município de cobrança (IBGE) obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.ShippingStreet)) throw new IllegalArgumentException('Rua de entrega obrigatória para integração');
        if(DW_Helper.isNullOrBlank(account.ShippingState)) throw new IllegalArgumentException('Estado de entrega obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.ShippingCity)) throw new IllegalArgumentException('Cidade de entrega obrigatória para integração');
        if(DW_Helper.isNullOrBlank(account.ShippingState)) throw new IllegalArgumentException('Estado de entrega obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.ShippingPostalCode)) throw new IllegalArgumentException('CEP de entrega obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.CodigoMunicipio__c)) throw new IllegalArgumentException('Código município de entrega (IBGE) obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.RamoAtividadeConta__c)) throw new IllegalArgumentException('Ramo de atividade obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.Documento__c)) throw new IllegalArgumentException('Documento obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.DataAberturaEmpresa__c)) throw new IllegalArgumentException('Data de abertura da empresa obrigatório para integração');
        AccountContactRelation accountContactRelation = new AccountContactRelation();
        for(AccountContactRelation acr : account.AccountContactRelations){
            if(acr.Roles != null && acr.Roles.contains('Financeiro')){
                accountContactRelation = acr;
            }
        }
        if(accountContactRelation.Id == null) throw new IllegalArgumentException('Pelo menos um contato com papel "financeiro" é obrigatório para integração');
        if(accountContactRelation.Id != null){
            if(DW_Helper.isNullOrBlank(accountContactRelation.TelefoneContato__c)) throw new IllegalArgumentException('Telefone do contato obrigatório para integração');
            if(DW_Helper.isNullOrBlank(accountContactRelation.EmailContato__c)) throw new IllegalArgumentException('Email do contato obrigatório para integração');
        }

        AccountIntegrableRequestTemplate.Clientes requestTemplate = new AccountIntegrableRequestTemplate.Clientes();
        AccountIntegrableRequestTemplate template = new AccountIntegrableRequestTemplate();
        template.Clientes = new List<AccountIntegrableRequestTemplate.Clientes>();
        template.Clientes.add(requestTemplate);

		requestTemplate.CodEmp = '01';
		requestTemplate.CodFil =  '01'; 
        requestTemplate.Cod_estabel = account.Documento__c.replaceAll('[^0-9]', '').replaceAll('([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '$4').subString(2, 4) ;//ok
        requestTemplate.Cod_estabel = '01' ;//ok
        requestTemplate.TpCadastro = DW_Helper.hasSomeContent(account.CodigoERP__c) ? '4': '3';//ok
        requestTemplate.Cod_emitente =  DW_Helper.hasSomeContent(account.CodigoERP__c) ? account.CodigoERP__c: '';//ok
        requestTemplate.nome_emit = DW_Helper.limitedTo(getString(account.Name), 60);//ok
        requestTemplate.nome_abrev =  DW_Helper.limitedTo(account.NomeFantasia__c,20);//ok
        
        List<String> billingStreetSplit = account.BillingStreet.split(',');
        requestTemplate.endereco = DW_Helper.limitedTo(billingStreetSplit.get(0).trim(), 40) + ', ' + DW_Helper.limitedTo(billingStreetSplit.get(1).trim(), 10);//ok
        String complemento = DW_Helper.limitedTo(billingStreetSplit.size() == 3 ? '' : (billingStreetSplit.get(2).trim()), 50);//ok
        requestTemplate.Complemento = complemento;
        String bairro = getString(account.Bairro__c);
        if(billingStreetSplit.size() == 3){
        	bairro =  getString(billingStreetSplit.get(2).trim()); //Rua, Numero, Bairro
        }else if(billingStreetSplit.size() == 4){
            bairro =  getString(billingStreetSplit.get(3).trim()); //Rua, Numero,Complemento, Bairro
        }
      	requestTemplate.bairro = DW_Helper.limitedTo(bairro,40);
        requestTemplate.estado = getString(account.BillingState);//ok
        requestTemplate.cidade = getString(account.BillingCity);//ok
        requestTemplate.ibgecidade = account.CodigoMunicipioCobranca__c.replaceAll('([0-9]{2})([0-9]{1,9})', '$2');//ok
        requestTemplate.cep = account.BillingPostalCode.replaceAll('[^0-9]', '');//ok
        requestTemplate.pais = getString(account.pais_conta__c ,'105');//ok
        requestTemplate.paisbacen = getString(account.pais_bacen_conta__c,'01058');//ok
        requestTemplate.cnpj = account.Documento__c.replaceAll('[^0-9]', '');//ok
        requestTemplate.ie = account.InscricaoEstadual__c;//ok
        requestTemplate.im = getString(account.InscricaoMunicipalConta__c );//ok
        requestTemplate.site = DW_Helper.isNullOrBlank(account.Website) ? 'deconhecido.com.br': account.Website;
        requestTemplate.status = account.StatusConta__c == 'Ativo' ? '2' : '1';//ok
        List<String> shippingStreetList = account.ShippingStreet.split(',');
        requestTemplate.endentrega = DW_Helper.limitedTo(shippingStreetList.get(0).trim(), 40) + ', ' + DW_Helper.limitedTo(shippingStreetList.get(1).trim(), 10);//ok
        requestTemplate.CompEntrega = DW_Helper.limitedTo(shippingStreetList.size() == 3 ? '' : (shippingStreetList.get(2).trim()), 50);//ok
         String bairroEntrega = getString(account.Bairro__c);
        if(shippingStreetList.size() == 3){
        	bairroEntrega =  getString(shippingStreetList.get(2).trim()); //Rua, Numero, Bairro
        }else if(shippingStreetList.size() == 4){
            bairroEntrega =  getString(shippingStreetList.get(3).trim()); //Rua, Numero,Complemento, Bairro
        }
        requestTemplate.bairroentrega = getString(DW_Helper.limitedTo(bairroEntrega,40));     
        requestTemplate.munentrega = getString(account.ShippingCity);//ok
        requestTemplate.codmunentrega = account.CodigoMunicipio__c.replaceAll('([0-9]{2})([0-9]{1,9})', '$2');//ok
        requestTemplate.estentrega = getString(account.ShippingState);//ok
        requestTemplate.cepentrega = account.ShippingPostalCode.replaceAll('[^0-9]', '');//ok
        requestTemplate.simpnacional = account.SituacaSimplesNacional__c == 'Optante pelo Simples Nacional' ? '1' : '2';//ok
        requestTemplate.DtAbertura = account.DataAberturaEmpresa__c.format();//ok
        requestTemplate.Natureza = '6101';//account.NaturezaIntegracao__c != null ? account.NaturezaIntegracao__c.replaceAll('[^0-9]', ''):'';
        requestTemplate.Suframa = DW_Helper.hasSomeContent(account.InscricaoSuframa__c) ? account.InscricaoSuframa__c : '';
        requestTemplate.Vendedor = account.CodigoERPVendedorUsuario__c;//ok
        requestTemplate.Contribuinte = account.Contribuinte__c ? '1' : '2';
        requestTemplate.TipoPessoa = account.Documento__c.replaceAll('[^0-9]', '').length() == 14 ? 'CI' : 'PF';//ok
        //requestTemplate.ccontabil = account.PerfilConta__c == 'Home center' ? '1120100002' : '1120100001 ';//ok
        requestTemplate.ccontabil = '';//ok
        requestTemplate.pessoa = account.Documento__c.replaceAll('[^0-9]', '').length() == 14 ? 'J' : 'F';//ok
        requestTemplate.tipo = getTipo(account.RamoAtividadeConta__c);
		requestTemplate.RamoAtividade = account.RamoAtividadeConta__c;
        
        requestTemplate.FomeZero = (requestTemplate.tipo == 'F' && (requestTemplate.estado == 'RJ' || requestTemplate.estado == 'AL' || requestTemplate.estado == 'PI' ))
                ? '1'
                : '2';
		


        for(AccountContactRelation acr : account.AccountContactRelations){
            if(acr.Roles != null && acr.Roles.contains('Financeiro')){
                requestTemplate.ddd = acr.TelefoneContato__c.replaceAll('[^0-9]', '').replaceAll('([+55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', '$2');//ok
                requestTemplate.telefone = acr.TelefoneContato__c.replaceAll('[^0-9]', '').replaceAll('([+55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', '$3$4$5');//ok
                String contato = getString(acr.NomeContato__c);
                requestTemplate.contato = getString(DW_Helper.limitedTo(contato,15));
                requestTemplate.email = getString(acr.EmailContato__c);//ok
            }
        }
      	System.debug('JSON_lsReponseApi Clientes: '+JSON.serialize(template).replace('_','-'));
        return JSON.serialize(template).replace('_','-');
    }
    
        public String getTipo(String ramoAtividade) {
            if(ramoAtividade.toLowerCase().contains('varejo') || ramoAtividade.toLowerCase().contains('home') || ramoAtividade.toLowerCase().contains('distribuidor') || ramoAtividade.toLowerCase().contains('atacadista') || ramoAtividade.toLowerCase().contains('revenda')){
                return 'R';
                }else if(ramoAtividade.toLowerCase().contains('exportação')){
                return 'X';
            }else{
                return 'F';
            }   
        }
    
    public String getTransportadoraRequest() {
        Account account = (Account)this.deserializedRequestObject;
        AccountTransportadorasResquestTemplate.Transportadoras requestTemplate = new AccountTransportadorasResquestTemplate.Transportadoras();
        AccountTransportadorasResquestTemplate template = new AccountTransportadorasResquestTemplate();
        template.Transportadoras = new List<AccountTransportadorasResquestTemplate.Transportadoras>();
        
        template.Transportadoras.add(requestTemplate);

        if(DW_Helper.isNullOrBlank(account.BillingStreet)) throw new IllegalArgumentException('Rua de cobrança obrigatória para integração');
        if(DW_Helper.isNullOrBlank(account.BillingState)) throw new IllegalArgumentException('Estado de cobrança obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.BillingCity)) throw new IllegalArgumentException('Cidade de cobrança obrigatória para integração');
        if(DW_Helper.isNullOrBlank(account.BillingState)) throw new IllegalArgumentException('Estado de cobrança obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.BillingPostalCode)) throw new IllegalArgumentException('CEP de cobrança obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.CodigoMunicipioCobranca__c)) throw new IllegalArgumentException('Código de munícipio de cobrança obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.Email__c)) throw new IllegalArgumentException('Email obrigatório para integração');
        if(DW_Helper.isNullOrBlank(account.Documento__c)) throw new IllegalArgumentException('Documento de cobrança obrigatório para integração');

     	requestTemplate.CodEmp = '01';
		requestTemplate.CodFil = '01';
        requestTemplate.TpCadastro =  DW_Helper.hasSomeContent(account.CodigoERPTransportadora__c) ? '4' : '3';
        requestTemplate.Codemitente =  DW_Helper.hasSomeContent(account.CodigoERPTransportadora__c) ? account.CodigoERPTransportadora__c: '';
        requestTemplate.nomeemit =  DW_Helper.limitedTo(getString(account.Name), 60);
        requestTemplate.nomeabrev = account.Name.length() > 20 ? getString(account.Name.subString(0,19)) : getString(account.Name);
        List<String> billingStreetSplit = account.BillingStreet.split(',');
        requestTemplate.endereco = getString(billingStreetSplit.get(0).trim() + ', ' + billingStreetSplit.get(1).trim()
            + (billingStreetSplit.size() == 3 ? '' : (', ' + billingStreetSplit.get(2).trim()))); //complemento, se houver

        requestTemplate.bairro = getString(DW_Helper.limitedTo(account.Bairro__c, 40));
        requestTemplate.estado = getString(account.BillingState);
        requestTemplate.cidade = getString(account.BillingCity);
        requestTemplate.ibgecidade = account.CodigoMunicipioCobranca__c.replaceAll('([0-9]{2})([0-9]{1,9})', '$2');
        requestTemplate.paisbacen = getString(account.pais_bacen_conta__c,'01058');
        requestTemplate.email = getString(account.Email__c);
        requestTemplate.cep = account.BillingPostalCode.replaceAll('[^0-9]', '');
        requestTemplate.ddd = account.Phone.replaceAll('[^0-9]', '').replaceAll('([+55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', '$2');
        requestTemplate.tel = account.Phone.replaceAll('[^0-9]', '').replaceAll('([+55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', '$3$4$5');
        requestTemplate.cnpj = account.Documento__c.replaceAll('[^0-9]', '');
        requestTemplate.ie = getString(account.InscricaoEstadual__c);
        requestTemplate.hPage = DW_Helper.isNullOrBlank(account.Website) ? 'https://deconhecido.com.br' : getString(account.Website);
        requestTemplate.complemento = '';
        return JSON.serialize(template).replace('_','-');
    }

    public override void setDeserializedResponseObject() {
        this.responseTemplate = (AccountIntegrableResponseTemplate)JSON.deserialize(
            this.requestFactoryInstance.getResponse().getBody(), AccountIntegrableResponseTemplate.class
        );
        this.deserializedResponseObject = responseTemplate;
    } 
    
    public override void finish() {

    }
    public static String getDate(Date d) {
        return d.year() + '-' + d.month() + '-' + d.day();
    }
    
    public  String  getString(String objeto){
    	return getString(objeto, '');
    }
    
    public  String  getString(String objeto, String padrao){
        if(objeto!= null || objeto == ''){
			return removeAcentos(objeto.toUpperCase());
        }else{
            return removeAcentos(padrao.toUpperCase());
        }		
	}
    
    public String removeAcentos(String str){
      str = str.replaceAll('[ÂÀÁÄÃ]','A'); 
      str = str.replaceAll('[ÊÈÉË]','E'); 
      str = str.replaceAll('ÎÍÌÏ','I'); 
      str = str.replaceAll('[ÔÕÒÓÖ]','O'); 
      str = str.replaceAll('[ÛÙÚÜ]','U'); 
      str = str.replaceAll('Ç','C'); 
      str = str.replaceAll('Ý','Y'); 
      str = str.replaceAll('Ñ','N'); 
      return str; 
    }
}