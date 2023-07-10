public without sharing class SPC {
    
    
    @AuraEnabled 
    public static String  consultaDocumento(String accId, String codProduct){
        String resultado = '';
        HttpRequestLog__c log = new HttpRequestLog__c();
        //Account ac = [SELECT Id,Documento__c FROM ACCOUNT WHERE Id = :accId];
        Account ac = (Account)DW_QueryFactory.get('Account')
            .setCondition(DW_QueryCondition.newInstance('Id', '=', accId))
            .run()
            .get(0);
        if(ac.DiasRealizarConsultaSPC__c >= 0) return 'não necessario';
        try{
            
            
            Blob headerValue = Blob.valueOf(SpcHelper.getInstance().spcServico.Usuario__c + ':' + SpcHelper.getInstance().spcServico.Senha__c);
            
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            
            String documento = ac.Documento__c.replace('-','').replace('.','');
            
            Map<String,String> mapCodigoNome = new  Map<String,String>();
            RetornoSPC__c retornoSPC = new RetornoSPC__c();
            
            retornoSPC.conta__c = accId;
            retornoSPC.CodProduto__c = codProduct;
            String ultimosTelefones = '';
            String ultimoEnderecoInformado = '';
            String alertasDocumento = '';
            String spcList = '';
            String chequeLojistaList = '';
            String ccfList = '';
            String contraOrdemList = '';
            String cOList = '';
            String creditoConcedidoList = '';
            String dadoBancarioList = '';
            String consultaRealizadaList = '';
            String chequeConsultaOnlineSRSList = '';
            String atividadeEmpresaList = '';
            String restricaoFinanceiraList = '';
            String pendenciaFinanceiraList = '';
            String sociosList = '';
            String protestoList = '';
            String capitalSocialList = '';
            String ultimaConsultaList = '';
            String consultasRealizadasList = '';
            String mensagemComplementarList = '';
            String historicoPagamentoFaixaList = '';
            String contraOrdemDiffList = '';
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint(SpcHelper.getInstance().spcServico.Url__c);
            log.Endpoint__c = SpcHelper.getInstance().spcServico.Url__c;
            log.Method__c = 'POST';
            request.setMethod('POST');
            request.setHeader('Content-Type', 'text/xml; charset=utf-8');
            request.setHeader('Authorization', authorizationHeader);
            request.setBody('<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://webservice.consulta.spcjava.spcbrasil.org/"> <soapenv:Header/> <soapenv:Body> <web:filtro> <codigo-produto>337</codigo-produto> <!--Optional:--> <tipo-consumidor>J</tipo-consumidor> <!--Optional:--> <documento-consumidor>'+documento+'</documento-consumidor> </web:filtro> </soapenv:Body></soapenv:Envelope>');
            log.RequestBody__c = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:web="http://webservice.consulta.spcjava.spcbrasil.org/"> <soapenv:Header/> <soapenv:Body> <web:filtro> <codigo-produto>337</codigo-produto> <!--Optional:--> <tipo-consumidor>J</tipo-consumidor> <!--Optional:--> <documento-consumidor>'+documento+'</documento-consumidor> </web:filtro> </soapenv:Body></soapenv:Envelope>';
            HttpResponse response = http.send(request);
            log.StatusCode__c = response.getStatusCode();
            log.ResponseBody__c = response.getBody();
            
            if(response.getStatusCode() == 200){
                Dom.Document doc = new Dom.Document();
                doc.load(response.getBody());
                
                DOM.XmlNode rootNode = doc.getRootElement();
                list<String> lstNames = new list<String>();
                list<DOM.xmlNode> lst = rootNode.getChildElements();
                for(DOM.XmlNode re : lst) {
                    if(re.getName() == 'Body') {
                        for(DOM.XmlNode re1 : re.getChildElements()) {
                            if(re1.getName() == 'resultado') {
                                for(DOM.XmlNode re2 : re1.getChildElements()) {
                                    if(re2.getName() == 'protocolo') {    
                                        retornoSPC.Name =re2.getAttribute('numero', '');
                                        retornoSPC.NumeroProtocolo__c =re2.getAttribute('digito', '');
                                    }
                                    if(re2.getName() == 'consumidor') {
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            if(re3.getName() == 'consumidor-pessoa-juridica') {
                                                retornoSPC.DataFundacao__c = Date.valueOf(String.valueOf(re3.getAttribute('data-fundacao', '')).split('T')[0]);
                                                ac.DataFundacao__c = Date.valueOf(String.valueOf(re3.getAttribute('data-fundacao', '')).split('T')[0]);
                                                retornoSPC.Email__c = re3.getAttribute('email', '');
                                                retornoSPC.NomeComercial__c = re3.getAttribute('nome-comercial', '');
                                                retornoSPC.RazaoSocial__c = re3.getAttribute('razao-social', '');
                                                retornoSPC.DescricaoSituacao__c = re3.getChildElement('situacao-cnpj', null).getAttribute('descricao-situacao', '');
                                                if(re3.getChildElement('endereco', null) != null)retornoSPC.Logradouro__c = re3.getChildElement('endereco', null).getAttribute('logradouro', '');
                                                if(re3.getChildElement('endereco', null) != null)retornoSPC.Numero__c = re3.getChildElement('endereco', null).getAttribute('numero', '');
                                                if(re3.getChildElement('endereco', null) != null)retornoSPC.complemento__c = re3.getChildElement('endereco', null).getAttribute('complemento', '');
                                                if(re3.getChildElement('endereco', null) != null)retornoSPC.Bairro__c = re3.getChildElement('endereco', null).getAttribute('bairro', '');
                                                if(re3.getChildElement('endereco', null) != null)retornoSPC.CEP__c = re3.getChildElement('endereco', null).getAttribute('cep', '');
                                                retornoSPC.NaturezaJuridica__c = re3.getChildElement('natureza-juridica', null).getAttribute('descricao', '');
                                                //retornoSPC.CodNaturezaJuridica__c = re3.getChildElement('natureza-juridica', null).getAttribute('codigo', '');
                                                retornoSPC.AtividadeEconomicaPrincipal__c = re3.getChildElement('atividade-economica-principal', null).getAttribute('descricao', '');
                                                //retornoSPC.AtividadeEconomicaSecundaria__c = re3.getChildElement('atividade-economica-secundaria', null).getAttribute('descricao', '');
                                                //AtividadeEconomicaSecundaria
                                            }
                                        }
                                    }
                                    if(re2.getName() == 'socio') {
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadesSocios__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadesSocios__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                            }
                                            if(re3.getName() == 'detalhe-socio') {
                                                sociosList += 'Nome: '+re3.getAttribute('nome', '')+', Data Entrada: '+re3.getAttribute('data-entrada', '')+'\n';
                                                sociosList += 'Documento: '+re3.getAttribute('documento', '')+', Porcentual Partipação:'+re3.getAttribute('porcentual-participacao', null)+'\n';
                                                sociosList += 'Situacao documento: '+re3.getAttribute('situacao-documento', '')+'\n';
                                            }
                                        }
                                        retornoSPC.Socios__c = sociosList;
                                    }
                                    if(re2.getName() == 'protesto') {
                                        
                                        
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadeProtesto__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadeProtesto__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)retornoSPC.DataUltimaAtualizacaoProtesto__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)ac.DataUltimaAtualizacaoProtesto__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                                if(re3.getAttribute('valor-total', '') != null)retornoSPC.ValorTotalProtesto__c = Decimal.valueOf(re3.getAttribute('valor-total', ''));
                                                if(re3.getAttribute('valor-total', '') != null)ac.ValorTotalProtesto__c = Decimal.valueOf(re3.getAttribute('valor-total', ''));
                                            }
                                            if(re3.getName() == 'detalhe-protesto') {
                                                System.debug('re3protest' +re3.getName() );
                                                protestoList += 'Nome Cartorio: '+re3.getChildElement('cartorio', null).getAttribute('nome', '')+' Cidade Cartorio: '+ re3.getChildElement('cartorio', null).getChildElement('cidade', null).getAttribute('nome', '')+'\n';
                                                protestoList += 'Data Protesto: '+re3.getAttribute('data-protesto', '')+', Valor:'+re3.getAttribute('valor', null)+'\n';
                                                protestoList += 'Natureza Anotacao: '+re3.getChildElement('natureza-anotacao', null).getAttribute('descricao-natureza-anotacao', '')+'\n';
                                            }
                                        }
                                        retornoSPC.Protesto__c = protestoList;
                                    }
                                    if(re2.getName() == 'contra-ordem-documento-diferente') {
                                        
                                        
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadeTotalContraOrdemDiff__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadeTotalContraOrdemDiff__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)retornoSPC.DataUltimaOcorrenciaContraOrdemDiff__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)ac.DataUltimaOcorrenciaContraOrdemDiff__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                            }
                                            if(re3.getName() == 'detalhe-contra-ordem-documento-diferente') {
                                                System.debug('re3protest' +re3.getName() );
                                                contraOrdemDiffList += 'Documento: '+re3.getAttribute('documento', '')+' Data Inclusao: '+ re3.getAttribute('data-inclusao', '')+'\n';
                                                contraOrdemDiffList += 'Origem: '+re3.getAttribute('origem', '')+', Informante:'+re3.getAttribute('informante', null)+'\n';
                                            }
                                        }
                                        retornoSPC.ContraOrdemDocumentoDiferente__c = contraOrdemDiffList;
                                    }
                                    if(re2.getName() == 'ultimas-consultas') {
                                        
                                        
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadeUltimasConsultas__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadeUltimasConsultas__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                            }
                                            if(re3.getName() == 'detalhe-ultimas-consultas') {
                                                System.debug('re3protest' +re3.getName() );
                                                ultimaConsultaList += 'Nome Cliente Consultante: '+re3.getAttribute('nome-cliente-consultante', '')+' Cnpj Cliente: '+ re3.getAttribute('cnpj-cliente', '')+'\n';
                                                ultimaConsultaList += 'Data Consulta: '+re3.getAttribute('data-consulta', '')+', Quantidade Consulta:'+re3.getAttribute('quantidade-consulta', null)+'\n';
                                            }
                                        }
                                        retornoSPC.UltimasConsultas__c = ultimaConsultaList;
                                        ac.UltimasConsultas__c = ultimaConsultaList;
                                    }
                                     if(re2.getName() == 'consulta-realizada') {
                                        
                                        
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadeConsultaRealizadas__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadeConsultaRealizadas__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                            }
                                            if(re3.getName() == 'detalhe-consulta-realizada') {
                                                System.debug('re3protest' +re3.getName() );
                                                consultaRealizadaList += 'Nome Associado: '+re3.getAttribute('nome-associado', '')+' Nome entidade Origem: '+ re3.getAttribute('nome-entidade-origem', '')+'\n';
                                                consultaRealizadaList += 'Data Consulta: '+re3.getAttribute('data-consulta', '')+'\n';
                                            }
                                        }
                                        retornoSPC.ConsultasRealizadas__c = consultaRealizadaList;
                                        ac.ConsultasRealizadas__c = consultaRealizadaList;
                                    }
                                    if(re2.getName() == 'historico-pagamento-por-faixa') {
                                        
                                        
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadeHistoricoPagamentoFaixa__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadeHistoricoPagamentoFaixa__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                            }
                                            if(re3.getName() == 'detalhe-historico-pagamento-por-faixa') {
                                                System.debug('re3protest' +re3.getName() );
                                                historicoPagamentoFaixaList += 'Codigo faixa: '+re3.getAttribute('codigo-faixa', '')+' Descricao Faixa: '+ re3.getAttribute('descricao-faixa', '')+'\n';
                                                historicoPagamentoFaixaList += 'Periodo: '+re3.getAttribute('descricao-periodo', '')+'\n';
                                            }
                                        }
                                        retornoSPC.HistoricoPagamentoFaixa__c = historicoPagamentoFaixaList;
                                        ac.HistoricoPagamentoFaixa__c = historicoPagamentoFaixaList;
                                    }
                                    if(re2.getName() == 'capital-social') {
                                        
                                        
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {                                            
                                            
                                            
                                            System.debug('re3protest' +re3.getName() );
                                            capitalSocialList += 'Nacionalidade: '+re3.getAttribute('nacionalidade', '')+' Natureza: '+ re3.getAttribute('natureza', '')+'\n';
                                            capitalSocialList += 'Origem: '+re3.getAttribute('origem', '')+', data ultima atualizacao:'+re3.getAttribute('data-ultima-atualizacao', null)+'\n';
                                            capitalSocialList += 'Valor Capital Autorizado: '+re3.getAttribute('valor-capital-autorizado', '')+', Valor Capital Realizado:'+re3.getAttribute('valor-capital-realizado', null)+'\n';
                                            capitalSocialList += 'Valor Capital Social: '+re3.getAttribute('valor-capital-social', '')+'\n';
                                            
                                        }
                                        retornoSPC.CapitalSocial__c = capitalSocialList;
                                        ac.CapitalSocialInfo__c = capitalSocialList;
                                    }
                                    if(re2.getName() == 'mensagem-complementar') {
                                        mensagemComplementarList += 'Origem: '+re2.getAttribute('origem', '')+'\n';
                                        mensagemComplementarList += 'mensagem: '+re2.getChildElement('mensagem', null).getText()+'\n';
                                    }
                                    retornoSPC.MensagemComplementar__c = mensagemComplementarList;
                                    /*if(re2.getName() == 'ultimo-telefone-informado') {
for(DOM.XmlNode re3 : re2.getChildElements()) {
if(re3.getName() == 'detalhe-ultimo-telefone-informado') {                                
ultimosTelefones += 'Telefone: ' + re3.getChildElement('telefone', null).getAttribute('numero-ddd', '') +'-'+ re3.getChildElement('telefone', null).getAttribute('numero', '')+'\n';
}
}
retornoSPC.UltimoTelefoneInformado__c = ultimosTelefones;
}
if(re2.getName() == 'ultimo-telefone-informado') {
for(DOM.XmlNode re3 : re2.getChildElements()) {
if(re3.getName() == 'detalhe-ultimo-telefone-informado') {                                
ultimosTelefones += 'Telefone: ' + re3.getChildElement('telefone', null).getAttribute('numero-ddd', '') +'-'+ re3.getChildElement('telefone', null).getAttribute('numero', '')+'\n';
}
}
retornoSPC.UltimoTelefoneInformado__c = ultimosTelefones;
}*/
                                    //Socios
                                    
                                    if(re2.getName() == 'alerta-documento') {
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadeAlertasDocumentos__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadeAlertasDocumentos__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                
                                            }
                                            if(re3.getName() == 'detalhe-alerta-documento') {   alertasDocumento += 'Data Inclusão: '+re3.getAttribute('data-inclusao', '')+', Data Ocorrencia: '+re3.getAttribute('data-ocorrencia', '')+', Entidade Origem: '+re3.getAttribute('entidade-origem', '')+', Motivo: '+re3.getAttribute('motivo', '')+', observacao: '+re3.getAttribute('observacao', '')+'\n';
                                                                                             for(DOM.XmlNode re4 : re3.getChildElements()) {alertasDocumento += 'Tipo Documento: '+re4.getAttribute('nome', '')+'\n';}
                                                                                            }
                                        }
                                        retornoSPC.AlertaDocumento__c = alertasDocumento;
                                    }
                                    if(re2.getName() == 'spc') {
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadeSPC__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadeRegistroSPC__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)retornoSPC.DataUltimaOcorrenciaSPC__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)ac.DataUltimaOcorrenciaSPC__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                                if(re3.getAttribute('valor-total', '') != null)retornoSPC.ValorTotalSPC__c = Decimal.valueOf(re3.getAttribute('valor-total', ''));
                                                if(re3.getAttribute('valor-total', '') != null)ac.ValorTotalSPC__c = Decimal.valueOf(re3.getAttribute('valor-total', ''));
                                            }
                                            if(re3.getName() == 'detalhe-spc') spcList += 'Nome associado: '+re3.getAttribute('nome-associado', '')+', Data Inclusão '+re3.getAttribute('data-inclusao', '')+', Data Vencimento: '+re3.getAttribute('data-vencimento', '')+', Nome Entidade: '+re3.getAttribute('nome-entidade', '')+', Contrato: '+re3.getAttribute('contrato', '')+', Comprador: '+re3.getAttribute('comprador-fiador-avalista', '')+', Valor: '+re3.getAttribute('valor', '')+'\n';
                                                                                       //spcList += 'Cidade: '+re3.getChildElement('cidade-associado', null).getAttribute('nome', '')+', Estado:'+re3.getChildElement('cidade-associado', null).getChildElement('estado', null).getAttribute('sigla-uf', '')+'\n';
                                                                                       // spcList += 'Telefone: '+re3.getChildElement('telefone-associado', null).getAttribute('numero-ddd', '')+'-'+re3.getChildElement('telefone-associado', null).getAttribute('numero', '')+'\n';
                                                                                      }
                                        retornoSPC.spc__c = spcList;
                                    }
                                    if(re2.getName() == 'restricao-financeira') {
                                        Double valorTotal = 0;
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            if(re3.getName() == 'detalhe-restricao-financeira') {
                                                //spcList += 'Nome associado: '+re3.getAttribute('nome-associado', '')+', Data Inclusão '+re3.getAttribute('data-inclusao', '')+', Data Vencimento: '+re3.getAttribute('data-vencimento', '')+', Nome Entidade: '+re3.getAttribute('nome-entidade', '')+', Contrato: '+re3.getAttribute('contrato', '')+', Comprador: '+re3.getAttribute('comprador-fiador-avalista', '')+', Valor: '+re3.getAttribute('valor', '')+'\n';
                                                restricaoFinanceiraList += 'Contrato: '+re3.getAttribute('contrato', '');
                                                restricaoFinanceiraList += ', Data Ocorrencia: '+re3.getAttribute('data-ocorrencia', '');
                                                restricaoFinanceiraList += ', Filial: '+re3.getAttribute('filial', '');
                                                restricaoFinanceiraList += ', Origem: '+re3.getAttribute('origem', '');
                                                restricaoFinanceiraList += ', Titulo Ocorrencia: '+re3.getAttribute('titulo-ocorrencia', '');
                                                restricaoFinanceiraList += ', Valor Pendencia: '+re3.getAttribute('valor-pendencia', '');
                                                valorTotal = valorTotal + Double.valueOf(re3.getAttribute('valor-pendencia', ''));
                                                for(DOM.XmlNode re4 : re3.getChildElements()) {
                                                    if(re4.getName() == 'natureza-anotacao') {restricaoFinanceiraList += ', Natureza Anotacao: '+re4.getAttribute('descricao-natureza-anotacao', '');
                                                                                              restricaoFinanceiraList += ', Natureza Anotacao Descrição: '+re4.getAttribute('descricao-complementar-natureza-anotacao', '');        
                                                                                             }
                                                    if(re4.getName() == 'subjudice') {restricaoFinanceiraList += ', Subjudice Praca : '+re4.getAttribute('praca-subjudice', '');
                                                                                      restricaoFinanceiraList += ', Subjudice Praca Distrito : '+re4.getAttribute('distrito-subjudice', '');
                                                                                      restricaoFinanceiraList += ', Subjudice Praca Vara : '+re4.getAttribute('vara-subjudice', '');
                                                                                      restricaoFinanceiraList += ', Subjudice Praca Data : '+re4.getAttribute('data-subjudice', '');
                                                                                      restricaoFinanceiraList += ', Subjudice Praca Processo : '+re4.getAttribute('processo-subjudice', '');
                                                                                      restricaoFinanceiraList += ', Subjudice Praca Mensagem : '+re4.getAttribute('mensagem-subjudice', '');        
                                                                                     }
                                                }
                                                restricaoFinanceiraList += '\n';
                                                restricaoFinanceiraList += '\n';
                                                
                                                
                                                
                                            }
                                        }
                                        retornoSPC.ValorTotalPendencia__c = valorTotal;
                                        retornoSPC.RestricaoFinanceira__c = restricaoFinanceiraList;
                                    }
                                    if(re2.getName() == 'pendencia-financeira') {
                                        Double valorTotal = 0;
                                        for(DOM.XmlNode re3 : re2.getChildElements()) {
                                            
                                            if(re3.getName() == 'resumo') {  
                                                retornoSPC.QuantidadePendenciaFinanceira__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                ac.QuantidadePendenciaFinanceira__c = Decimal.valueOf(re3.getAttribute('quantidade-total', ''));
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)retornoSPC.DataUltimaOcorrenciaPendencia__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                                if(re3.getAttribute('data-ultima-ocorrencia', '') != null)ac.DataUltimaOcorrenciaPendencia__c = Date.valueOf(re3.getAttribute('data-ultima-ocorrencia', '').split('T')[0]);
                                                if(re3.getAttribute('valor-total', '') != null)retornoSPC.ValorTotalPendenciaFinanceira__c = Decimal.valueOf(re3.getAttribute('valor-total', ''));
                                                if(re3.getAttribute('valor-total', '') != null)ac.ValorTotalPendenciaFinanceira__c = Decimal.valueOf(re3.getAttribute('valor-total', ''));
                                            }
                                            
                                            if(re3.getName() == 'detalhe-pendencia-financeira') {
                                                pendenciaFinanceiraList += 'Contrato: '+re3.getAttribute('contrato', '');
                                                pendenciaFinanceiraList += ', Data Ocorrencia: '+re3.getAttribute('data-ocorrencia', '');
                                                pendenciaFinanceiraList += ', Filial: '+re3.getAttribute('filial', '');
                                                pendenciaFinanceiraList += ', Origem: '+re3.getAttribute('origem', '');
                                                pendenciaFinanceiraList += ', Titulo Ocorrencia: '+re3.getAttribute('titulo-ocorrencia', '');
                                                pendenciaFinanceiraList += ', Valor Pendencia: '+re3.getAttribute('valor-pendencia', '');
                                                valorTotal = valorTotal + Double.valueOf(re3.getAttribute('valor-pendencia', ''));
                                                for(DOM.XmlNode re4 : re3.getChildElements()) {
                                                    if(re4.getName() == 'natureza-anotacao') {
                                                        pendenciaFinanceiraList += ', Natureza Anotacao: '+re4.getAttribute('descricao-natureza-anotacao', '');
                                                        pendenciaFinanceiraList += ', Natureza Anotacao Descrição: '+re4.getAttribute('descricao-complementar-natureza-anotacao', '');        
                                                    }if(re4.getName() == 'subjudice') {
                                                        pendenciaFinanceiraList += ', Subjudice Praca : '+re4.getAttribute('praca-subjudice', '');
                                                        pendenciaFinanceiraList += ', Subjudice Praca Distrito : '+re4.getAttribute('distrito-subjudice', '');
                                                        pendenciaFinanceiraList += ', Subjudice Praca Vara : '+re4.getAttribute('vara-subjudice', '');
                                                        pendenciaFinanceiraList += ', Subjudice Praca Data : '+re4.getAttribute('data-subjudice', '');
                                                        pendenciaFinanceiraList += ', Subjudice Praca Processo : '+re4.getAttribute('processo-subjudice', '');
                                                        pendenciaFinanceiraList += ', Subjudice Praca Mensagem : '+re4.getAttribute('mensagem-subjudice', '');        
                                                    }
                                                }
                                                pendenciaFinanceiraList += '\n';
                                                pendenciaFinanceiraList += '\n';
                                                
                                                
                                                
                                            }
                                        }
                                        //retornoSPC.ValorTotalPendenciaFinanceira__c = valorTotal;
                                        retornoSPC.PendenciaFinanceira__c = pendenciaFinanceiraList;
                                    }
                                }	
                            }
                        }
                    }
                }
                
                ac.DataAtualizacaoSPC__c = System.now();
                retornoSPC.retornoApi__c = response.getBody();
                insert retornoSPC;
                update ac;
                ac.RetornoSPC__c = retornoSPC.Id;
                update ac;
                resultado= retornoSPC.id;
            }else{resultado =  'Erro na consulta: '+response.getBody();}
        } catch(Exception e) {
            log.ResponseBody__c = e.getMessage() + e.getLineNumber() +e.getCause();
            resultado =  'Erro na consulta. Causa: '+e.getCause()+'. Mensagem: '+e.getMessage() ;}
        finally {
            log.Conta__c = ac.Id;
            log.Name = 'Integração SPC '+ac.Id+' Data Atualização ' + System.now();
            insert log;
            
        }
        return resultado;
    }
}