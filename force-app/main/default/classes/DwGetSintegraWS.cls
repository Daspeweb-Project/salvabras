public without sharing class DwGetSintegraWS {
    public static String callSintegra(id recordId, String plugin, String cpf, String dataNascimento, String cnpjIe, String uf) {
        String resultado = '';
        HttpRequestLog__c log = new HttpRequestLog__c();
        Account ac = [SELECT  Id,Documento__c,DataUltimaConsultaSaldoSintegraWS__c,StatusIntegracaoSaldoSintegraWS__c FROM account WHERE Id = :recordId];
        
        try{ 
            DwGetSintegraIntegrable dwGetSaldoIntegrable = new DwGetSintegraIntegrable(plugin, cpf, dataNascimento, cnpjIe, uf);
            dwGetSaldoIntegrable.callIntegration(ac);
            if(DW_Helper.hasSomeContent(dwGetSaldoIntegrable.requestFactoryInstance) && DW_Helper.hasSomeContent(dwGetSaldoIntegrable.requestFactoryInstance.getLog())){
                log = dwGetSaldoIntegrable.requestFactoryInstance.getLog();
            } 
            if(dwGetSaldoIntegrable.isError){
                ac.StatusIntegracaoSintegraWs__c = 'Integrado com erro';
                log.ResponseBody__c = dwGetSaldoIntegrable.errorMessage;
            }
            
            ///SINTEGRA
            if (plugin == 'ST') {
                GetSintegraWSIntegrableTempate responseTemplate = (GetSintegraWSIntegrableTempate)dwGetSaldoIntegrable.deserializedResponseObject;
                ac = DwGetSintegraWS.handleResponseAsST(ac, responseTemplate);
                System.debug('responseTemplate:' + responseTemplate);
                resultado = JSON.serialize(responseTemplate);
            } 
            ///SIMPLES NACIONAL
            else if (plugin == 'SN') {
                DW_SintegraResponse_SN responseTemplate = (DW_SintegraResponse_SN)dwGetSaldoIntegrable.deserializedResponseObject;
                ac = DwGetSintegraWS.handleResponseAsSN(ac, responseTemplate);
                System.debug('responseTemplate:' + responseTemplate);
                resultado = JSON.serialize(responseTemplate);
            } 
            ///RECEITA FEDERAL CNPJ
            else if (plugin == 'RF') {
                DW_SintegraResponse_RF responseTemplate = (DW_SintegraResponse_RF)dwGetSaldoIntegrable.deserializedResponseObject;
                ac = DwGetSintegraWS.handleResponseAsRF(ac, responseTemplate);
                System.debug('responseTemplate:' + responseTemplate);
                resultado = JSON.serialize(responseTemplate);
            } 
            ///RECEITA FEDERAL CPF
            else if (plugin == 'CPF') {
                DW_SintegraResponse_CPF responseTemplate = (DW_SintegraResponse_CPF)dwGetSaldoIntegrable.deserializedResponseObject;
                ac = DwGetSintegraWS.handleResponseAsCPF(ac, responseTemplate);
                System.debug('responseTemplate:' + responseTemplate);
                resultado = JSON.serialize(responseTemplate);
            }
        }catch (Exception e){
            ac.StatusIntegracaoSintegraWs__c = 'Integrado com erro';   
            if(resultado == '') resultado = e.getMessage() + e.getStackTraceString();
            System.debug(LoggingLevel.ERROR, '@@@DwGetSintegraWS e.getMessage()' + e.getMessage());
            System.debug(LoggingLevel.ERROR, '@@@DwGetSintegraWS e.getStackTraceString()' + e.getStackTraceString());
        }finally {
            ac.DataUltimaConsultaSintegraWS__c= System.now();
            log.Conta__c = ac.Id;
            log.Name = 'Integração de  Sintegra WS conta '+ac.Id;
            insert log;
            update ac;
        }
        
        return resultado;
    }
    
    private static Account handleResponseAsST(Account account, GetSintegraWSIntegrableTempate responseTemplate) {
        if(responseTemplate.status == 'ERROR'){
            throw new StringException(responseTemplate.message);
        }
        account.StatusIntegracaoSintegraWs__c = 'Integrado com sucesso';  
        account.NomeEmpresarial__c = responseTemplate.nome_empresarial;
        account.NomeFantasia__c = responseTemplate.nome_fantasia;
        account.InscricaoEstadual__c = responseTemplate.inscricao_estadual;
        account.TipoInscricao__c = responseTemplate.tipo_inscricao;
        if(! DW_Helper.isNullOrBlank(responseTemplate.data_situacao_cadastral) )account.DataSituacaoCadastral__c = Date.parse(String.valueOf(responseTemplate.data_situacao_cadastral).replace('-', '/'));
        account.SituacaoCNPJ__c = responseTemplate.situacao_cnpj;
        account.SituacaoCadastralInscricaoEstadual__c =responseTemplate.situacao_ie;
        account.DataInicioAtividade__c = responseTemplate.data_inicio_atividade;
        account.RegimeTributacao__c = responseTemplate.regime_tributacao;
        account.InfoInscEstadualDestinatario__c =responseTemplate.informacao_ie_como_destinatario;
        account.PorteEmpresa__c =responseTemplate.porte_empresa;
        account.CodigoCNAEPrincipal__c= responseTemplate.cnae_principal != null  ? responseTemplate.cnae_principal.code : '' ;
        account.DescricaoAtividadeEconomicaPrincipal__c =responseTemplate.cnae_principal != null  ? responseTemplate.cnae_principal.text : '' ;
        if(! DW_Helper.isNullOrBlank(responseTemplate.data_fim_atividade) )account.DataQualEmpresaCancelada__c = Date.parse(String.valueOf(responseTemplate.data_fim_atividade).replace('-', '/'));
        account.BillingState =responseTemplate.uf;
        account.BillingCity =responseTemplate.municipio;
        account.BairroCobranca__c = responseTemplate.bairro;
        account.BillingStreet  = createStreetFormula(responseTemplate.logradouro, responseTemplate.numero, responseTemplate.complemento, responseTemplate.bairro );
        account.ComplementoCobranca__c = responseTemplate.complemento;
        account.NumeroCobranca__c = responseTemplate.numero;
        account.CodigoMunicipioIBGE__c =responseTemplate.ibge != null  ? responseTemplate.ibge.codigo_municipio : '' ;
        account.CodigoMunicipioIBGE__c =responseTemplate.ibge != null  ? responseTemplate.ibge.codigo_municipio : '' ;
        account.CodigoUfIBGE__c =responseTemplate.ibge != null  ? responseTemplate.ibge.codigo_uf : '' ;
        return account;
    }
    
    private static Account handleResponseAsSN(Account account, DW_SintegraResponse_SN responseTemplate) {
        if(responseTemplate.status == 'ERROR'){
            throw new StringException(responseTemplate.message);
        }
        account.StatusIntegracaoSintegraWs__c = 'Integrado com sucesso';  
        account.NomeEmpresarial__c = responseTemplate.nome_empresarial;
        account.SituacaSimplesNacional__c = responseTemplate.situacao_simples_nacional;
        account.SituacaoSimei__c = responseTemplate.situacao_simei;
        account.SituacaoSimplesNacionalAnterior__c = responseTemplate.situacao_simples_nacional_anterior;
        account.SituacaoSimeiAnteriror__c = responseTemplate.situacao_simei_anterior;
        account.Agendamentos__c = responseTemplate.agendamentos;
        account.EventosFuturosSimplesNacional__c = responseTemplate.eventos_futuros_simples_nacional;
        account.EventosFuturosSimei__c = responseTemplate.eventos_futuros_simples_simei;
        return account;
    }
    
    private static Account handleResponseAsRF(Account account, DW_SintegraResponse_RF responseTemplate) {
        if(responseTemplate.status == 'ERROR'){
            throw new StringException(responseTemplate.message);
        }

        account.StatusIntegracaoSintegraWs__c = 'Integrado com sucesso';  
        account.Name = responseTemplate.nome;
        account.DescricaoAtividadePrincipal__c = responseTemplate.atividade_principal?.get(0)?.text;
        account.CodigoAtividadePrincipal__c = responseTemplate.atividade_principal?.get(0)?.code;
        account.DataSituacaoCadastral__c = responseTemplate.data_situacao != null ? Date.valueOf(String.valueOf(responseTemplate.data_situacao).replaceAll('([0-9]{2})/([0-9]{2})/([0-9]{4})', '$3-$2-$1')) : null;
        account.Complemento__c = responseTemplate.complemento;
        account.Phone = formatPhone(responseTemplate.telefone);
        account.Email__c = responseTemplate.email;
        account.Situacao__c = responseTemplate.situacao;
        account.Bairro__c = responseTemplate.bairro;
        account.TipoLogradouro__c = responseTemplate.tipo_logradouro;
        account.BillingStreet = createStreetFormula(responseTemplate.logradouro, responseTemplate.numero, responseTemplate.complemento, responseTemplate.bairro);   
        account.NumeroCobranca__c = responseTemplate.numero;
        account.BillingPostalCode = responseTemplate.cep;
        account.BillingCity =responseTemplate.municipio;
        account.DataAbertura__c = responseTemplate.abertura != null ? Date.valueOf(String.valueOf(responseTemplate.abertura).replaceAll('([0-9]{2})/([0-9]{2})/([0-9]{4})', '$3-$2-$1')) : null;
        account.SiglaNaturezaJuridica__c = responseTemplate.sigla_natureza_juridica;
        account.TipoInscricao__c = responseTemplate.tipo;
        account.NomeFantasia__c = responseTemplate.fantasia;
        account.EFR__c = responseTemplate.efr;
        account.MotivoSituacao__c = responseTemplate.motivo_situacao;
        account.SituacaoEspecial__c = responseTemplate.situacao_especial;
        account.DataSituacaoEspecial__c = responseTemplate.data_situacao_especial;
        account.CapitalSocial__c = responseTemplate.capital_social != null ? Double.valueOf(String.valueOf(responseTemplate.capital_social).replaceAll('\\.', '').replaceAll(',', '.')) : null;
        // account.Extra__c = responseTemplate.extra;
        account.Porte__c = responseTemplate.porte;
        account.CodigoMunicipioIBGE__c = responseTemplate.ibge?.codigo_municipio;
        account.CodigoUfIBGE__c = responseTemplate.ibge?.codigo_uf;
        return account;
    }
    
    private static Account handleResponseAsCPF(Account account, DW_SintegraResponse_CPF responseTemplate) {
        if(responseTemplate.status == 'ERROR'){
            throw new StringException(responseTemplate.message);
        }
        
        return account;
    }
    
    private  static String createStreetFormula(String rua, String numero, String complemento, String bairro){
        rua =  rua.replace(',', '');
        numero =  numero.replace(',', '');
        complemento =  complemento.replace(',', '');
        bairro =  bairro.replace(',', '');
        
        String enderecoCompleto = (rua != null ? rua : 'Sem rua' ) + ', '+  (numero != null ?  numero : 'S/N')+', ' + 
            (complemento != null ? complemento  + ', ' : '')+(bairro != null ? bairro : 'Sem bairro' );        
        return enderecoCompleto;
    }
    
    private  static String formatPhone(String telefoneResponse){
        String[] telefonesCompleto = telefoneResponse.split('/');        
        String primeiroTelefone = telefonesCompleto.get(0).trim();
        Pattern pattern = Pattern.compile('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})');
        primeiroTelefone = primeiroTelefone.replaceAll('[^0-9]', '');
        if (primeiroTelefone != '' && primeiroTelefone != null) {
            Matcher matcher = pattern.matcher(primeiroTelefone);
            if (!matcher.matches()) {
                return ''; // Telefone inválido
            } else {
                primeiroTelefone= +'+55' + primeiroTelefone.replaceAll('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', ' ($2) $3$4-$5');
            }
        }
        
        return primeiroTelefone;
    }
    
}