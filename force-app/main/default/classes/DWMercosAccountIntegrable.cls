public without sharing class DWMercosAccountIntegrable  extends DW_Integrable {

    public override void callIntegration(Object obj) {
        this.deserializedRequestObject = obj;
        this.sendRequest();
    }
    
    
    public override String constructEndpoint() {
        Account account = (Account)this.deserializedRequestObject;
        if (! String.isBlank(account.CodigoExclusivoMercos__c)) {
            String url = DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoConta__c+'/'+account.CodigoExclusivoMercos__c;
            return url;
        }
        return DaspeMicroservicoHelper.getInstance().mercosMicroservico.EndpointCriacaoConta__c;
        
    }
    
    public override String setMethod() {
        Account account = (Account)this.deserializedRequestObject;
        
        if (! String.isBlank(account.CodigoExclusivoMercos__c)) {
            return 'PUT';
        }
        return 'POST';
    }
    
    public override Map<String, String> constructHeaders() {
        return new Map<String, String>{
            'Content-Type' => 'application/json',
                'ApplicationToken' =>DaspeMicroservicoHelper.getInstance().mercosMicroservico.ApplicationToken__c,
                'CompanyToken' => DaspeMicroservicoHelper.getInstance().mercosMicroservico.CompanyToken__c
                };
                    }
 
    public override Map<String, String> constructQueryParameters() {
        return new Map<String, String>();
    }

    public override String getSerializedRequest() {
        Account ac = (Account)this.deserializedRequestObject;
        
        
        
        if(DW_Helper.isNullOrBlank(ac.Name)) throw new IllegalArgumentException('O preenchimento do nome da conta é obrigatorio');
                //if(DW_Helper.isNullOrBlank(ac.Documento__c)) throw new IllegalArgumentException('O preenchimento do Documento da conta é obrigatorio');

        //if(DW_Helper.isNullOrBlank(ac.BillingPostalCode)) throw new IllegalArgumentException('O preenchimento do CEP da cobrança da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.BillingStreet)) throw new IllegalArgumentException('O preenchimento da Rua de cobrança da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.BairroCobranca__c)) throw new IllegalArgumentException('O preenchimento do Bairro Cobrança da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.BillingCity)) throw new IllegalArgumentException('O preenchimento da Cidade Cobrança da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.BillingState)) throw new IllegalArgumentException('O preenchimento do Estado de Cobrança da conta é obrigatorio');
        
        //if(DW_Helper.isNullOrBlank(ac.ShippingPostalCode)) throw new IllegalArgumentException('O preenchimento do CEP da entrega da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.ShippingStreet)) throw new IllegalArgumentException('O preenchimento da Rua de entrega da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.Bairro__c)) throw new IllegalArgumentException('O preenchimento do Bairro entrega da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.ShippingCity)) throw new IllegalArgumentException('O preenchimento da Cidade entrega da conta é obrigatorio');
        //if(DW_Helper.isNullOrBlank(ac.ShippingState)) throw new IllegalArgumentException('O preenchimento do Estado de entrega da conta é obrigatorio');
        
        List<Contact> listContact = [SELECT ID,name,Email,Email2__c,Title,MobilePhone,Phone FROM Contact WHERE AccountId = :ac.Id];
        
        AccountMercosIntegrableRequestTemplate requestTemplate = new AccountMercosIntegrableRequestTemplate(); 
        String regex =  '[^0-9]';
        
        String recordDocument = '';
        if(! String.isBlank(ac.Documento__c)){
            ac.Documento__c.replaceAll(regex, '');
        }
            
        requestTemplate.razao_social = ac.Name;
        requestTemplate.nome_fantasia = ac.NomeFantasia__c;
        requestTemplate.tipo = recordDocument.length() > 11 ? 'J' : 'F' ;
        requestTemplate.documento_dw = recordDocument;
        requestTemplate.inscricao_estadual = ! DW_Helper.isNullOrBlank(ac.InscricaoEstadual__c)? ac.InscricaoEstadual__c : '' ;
        requestTemplate.suframa = '' ;
        requestTemplate.rua =  ! DW_Helper.isNullOrBlank(ac.BillingStreet)? ac.BillingStreet : ''; 
        requestTemplate.numero =  ! DW_Helper.isNullOrBlank(ac.NumeroCobranca__c)? ac.NumeroCobranca__c : '';
        requestTemplate.complemento = ! DW_Helper.isNullOrBlank(ac.ComplementoCobranca__c)? ac.ComplementoCobranca__c : '';
        requestTemplate.bairro =  ! DW_Helper.isNullOrBlank(ac.BairroCobranca__c)? ac.BairroCobranca__c : '';
        requestTemplate.cep = ! DW_Helper.isNullOrBlank(ac.BillingPostalCode)? ac.BillingPostalCode : '';
        requestTemplate.cidade =  ! DW_Helper.isNullOrBlank(ac.BillingCity)? ac.BillingCity : '';
        requestTemplate.estado =  ! DW_Helper.isNullOrBlank(ac.BillingState)? ac.BillingState : '';
        requestTemplate.observacao = ! DW_Helper.isNullOrBlank(ac.observacao__c)? ac.observacao__c : '';
        List<AccountMercosIntegrableRequestTemplate.cls_emails> requestTemplateEmails = new List <AccountMercosIntegrableRequestTemplate.cls_emails>(); 
        if(!DW_Helper.isNullOrBlank(ac.Email__c)){
            AccountMercosIntegrableRequestTemplate.cls_emails requestTemplateEmail = new AccountMercosIntegrableRequestTemplate.cls_emails(); 
            requestTemplateEmail.email = ac.Email__c;
            requestTemplateEmails.add(requestTemplateEmail);    
        }
        
        requestTemplate.emails = requestTemplateEmails;
        
        List<AccountMercosIntegrableRequestTemplate.cls_telefones> requestTemplateTelefones = new List <AccountMercosIntegrableRequestTemplate.cls_telefones>(); 
        if(!DW_Helper.isNullOrBlank(ac.Phone)){
            AccountMercosIntegrableRequestTemplate.cls_telefones requestTemplatePhone = new AccountMercosIntegrableRequestTemplate.cls_telefones(); 
            requestTemplatePhone.numero = ac.Phone;
            requestTemplateTelefones.add(requestTemplatePhone);    
        }
        requestTemplate.telefones =  requestTemplateTelefones;
        
        List<AccountMercosIntegrableRequestTemplate.cls_contatos> requestTemplateContatos = new List <AccountMercosIntegrableRequestTemplate.cls_contatos>(); 
        if(listContact.size()>0){
            for(Contact contact : listContact){
                AccountMercosIntegrableRequestTemplate.cls_contatos requestTemplateContact = new AccountMercosIntegrableRequestTemplate.cls_contatos(); 
                requestTemplateContact.nome = contact.name;
                requestTemplateContact.cargo = contact.Title;
                List<AccountMercosIntegrableRequestTemplate.cls_emails> requestTemplateContatosEmails = new List <AccountMercosIntegrableRequestTemplate.cls_emails>(); 
                if(!DW_Helper.isNullOrBlank(contact.Email)){
                    AccountMercosIntegrableRequestTemplate.cls_emails requestTemplateEmail = new AccountMercosIntegrableRequestTemplate.cls_emails(); 
                    requestTemplateEmail.email = contact.Email;
                    requestTemplateContatosEmails.add(requestTemplateEmail);    
                }
               
                requestTemplateContact.emails = requestTemplateContatosEmails.size() > 0 ? requestTemplateContatosEmails : null;
                
                List<AccountMercosIntegrableRequestTemplate.cls_telefones> requestTemplateContatosTelefones = new List <AccountMercosIntegrableRequestTemplate.cls_telefones>(); 
                if(!DW_Helper.isNullOrBlank(contact.MobilePhone)){
                    AccountMercosIntegrableRequestTemplate.cls_telefones requestTemplateTelefone = new AccountMercosIntegrableRequestTemplate.cls_telefones(); 
                    requestTemplateTelefone.numero = contact.MobilePhone;
                    requestTemplateContatosTelefones.add(requestTemplateTelefone);    
                }
                if(!DW_Helper.isNullOrBlank(contact.Phone)){
                    AccountMercosIntegrableRequestTemplate.cls_telefones requestTemplateTelefone = new AccountMercosIntegrableRequestTemplate.cls_telefones(); 
                    requestTemplateTelefone.numero = contact.Phone;
                    requestTemplateContatosTelefones.add(requestTemplateTelefone);    
                }
               System.debug('requestTemplateContatosTelefones'+requestTemplateContatosTelefones);
                System.debug('requestTemplateContatosTelefones.size()'+requestTemplateContatosTelefones.size());
                requestTemplateContact.telefones = requestTemplateContatosTelefones.size() > 0 ? requestTemplateContatosTelefones : null;
                requestTemplateContatos.add(requestTemplateContact);
                
            }   
        }
        System.debug('requestTemplateContatos.size()'+requestTemplateContatos.size());
        requestTemplate.contatos =  requestTemplateContatos;
        
        List<AccountMercosIntegrableRequestTemplate.cls_enderecos_adicionais> requestTemplateEnderecosAdicionaisList = new List <AccountMercosIntegrableRequestTemplate.cls_enderecos_adicionais>(); 
        if(! DW_Helper.isNullOrBlank(ac.ShippingStreet) && ! DW_Helper.isNullOrBlank(ac.ShippingCity) &&  ! DW_Helper.isNullOrBlank(ac.ShippingPostalCode)){
            AccountMercosIntegrableRequestTemplate.cls_enderecos_adicionais requestTemplateEnderecosAdicionais = new AccountMercosIntegrableRequestTemplate.cls_enderecos_adicionais(); 
            requestTemplateEnderecosAdicionais.cep = ac.ShippingPostalCode;
            requestTemplateEnderecosAdicionais.endereco =   ! DW_Helper.isNullOrBlank(ac.ShippingStreet)? ac.ShippingStreet : '';
            requestTemplateEnderecosAdicionais.numero = ! DW_Helper.isNullOrBlank(ac.NumeroEntrega__c)? ac.NumeroEntrega__c : '' ;
            requestTemplateEnderecosAdicionais.complemento =  ! DW_Helper.isNullOrBlank(ac.Complemento__c)? ac.Complemento__c : '';
            requestTemplateEnderecosAdicionais.bairro =  ! DW_Helper.isNullOrBlank(ac.Bairro__c)? ac.Bairro__c : '';
            requestTemplateEnderecosAdicionais.cidade = ac.ShippingCity;
            requestTemplateEnderecosAdicionais.estado = ac.ShippingState;
            if(! DW_Helper.isNullOrBlank(ac.CodigoExclusivoMercos__c))requestTemplateEnderecosAdicionaisList.add(requestTemplateEnderecosAdicionais);
        }
        
        requestTemplate.enderecos_adicionais = requestTemplateEnderecosAdicionaisList;
        requestTemplate.excluido = false;
        requestTemplate.inscricao_estadual =  ! DW_Helper.isNullOrBlank(ac.InscricaoEstadual__c)? ac.InscricaoEstadual__c : '';
        requestTemplate.nome_excecao_fiscal = '';
        requestTemplate.segmento_id =  33746;
        requestTemplate.observacao =  ! DW_Helper.isNullOrBlank(ac.observacao_conta__c)? ac.observacao_conta__c: '';
         System.debug(' serielize' +  
                     JSON.serialize(requestTemplate).replace('documento_dw',recordDocument.length() > 11 ? 'cnpj' : 'cpf')
                     );
        return JSON.serialize(requestTemplate).replace('documento_dw',recordDocument.length() > 11 ? 'cnpj' : 'cnpj');
        
    }
  
    public override void setDeserializedResponseObject() {
       
       
    }

    public override void finish() {

    }
}