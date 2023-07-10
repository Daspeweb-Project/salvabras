public without sharing class DW_AccountService {
    List<Account> accountNewList;
    List<Account> accountOldList;
    Map<Id, Account> accountNewMap;
    Map<Id, Account> accountOldMap;
    
    public DW_AccountService(List<Account> accountNewList, List<Account> accountOldList,Map<Id, Account> accountNewMap, Map<Id, Account> accountOldMap) {
        if(accountOldList == null) accountOldList = new List<Account>();
        if(accountNewMap == null) accountNewMap = new Map<Id, Account>();
        this.accountNewList = accountNewList;
        this.accountOldList = accountOldList;
        this.accountNewMap = accountNewMap;
        this.accountOldMap = accountOldMap;
    }
    
    public void splitStreetAddress(){
        for (Account account : accountNewList){
            Account accountOld = (this.accountOldMap != null && this.accountOldMap.containsKey(account.Id)) ? this.accountOldMap.get(account.Id) : new Account();
            if ((account.BillingStreet != accountOld.BillingStreet || accountOld.Id == null) && account.BillingStreet != '' && account.BillingStreet != null) {
                List<String> addressLineList = account.BillingStreet.split(',');
                if (addressLineList.size() < 3 || addressLineList.size() > 4) {
                    account.BillingStreet.addError('Insira o endereço no seguinte padrão: Rua de Tal, 999, loja 2, Bairro de Tal');
                    continue;
                }
                String street = addressLineList.get(0);
                String numbr = '';
                String complement = '';
                String neighbouerhood = '';
                if (addressLineList.size() == 4) {
                    numbr = addressLineList.get(1);
                    complement = addressLineList.get(2);
                    neighbouerhood = addressLineList.get(3);
                }else{
                    numbr = addressLineList.get(1);
                    complement = '';
                    neighbouerhood = addressLineList.get(2);
                }
                validaTamanoCamposEndereco(account, street, numbr, complement,neighbouerhood);
                account.NumeroCobranca__c = numbr;
                account.BairroCobranca__c = neighbouerhood;
                account.ComplementoCobranca__c = complement;
            }
            if ((account.ShippingStreet != accountOld.ShippingStreet || accountOld.Id == null)  && account.ShippingStreet != '' && account.ShippingStreet != null) {
                List<String> addressLineList = account.ShippingStreet.split(',');
                if (addressLineList.size() < 3 || addressLineList.size() > 4) {
                    account.ShippingStreet.addError('Insira o endereço no seguinte padrão: Rua de Tal, 999, loja 2, Bairro de Tal');
                    continue;
                }
                String street =  addressLineList.get(0);
                String numbr = '';
                String complement = '';
                String neighbouerhood = '';
                if (addressLineList.size() == 4) {
                    numbr = addressLineList.get(1);
                    complement = addressLineList.get(2);
                    neighbouerhood = addressLineList.get(3);
                }else{
                    numbr = addressLineList.get(1);
                    complement = '';
                    neighbouerhood = addressLineList.get(2);
                }
                validaTamanoCamposEndereco(account, street, numbr, complement,neighbouerhood);
                account.NumeroEntrega__c = numbr; 
                account.Bairro__c = neighbouerhood;
                account.Complemento__c = complement;
            }
        }
    }
    
    public void checkDocumentFormat(){
        Pattern patternCNPJ = Pattern.compile('([0-9]{2}[\\.]?[0-9]{3}[\\.]?[0-9]{3}[\\/]?[0-9]{4}[-]?[0-9]{2})');
        Pattern patternCPF = Pattern.compile('([0-9]{3}[\\.]?[0-9]{3}[\\.]?[0-9]{3}[-]?[0-9]{2})');
        for(Account account : accountNewList){
            Account accountOld = (account.Id != null && accountOldMap != null && accountOldMap.containsKey(account.Id)) ? accountOldMap.get(account.Id) : new Account();
            if (account.Documento__c != accountOld.Documento__c) {
                account.Documento__c = account.Documento__c.replaceAll('[^0-9]', '');
                if (account.Documento__c != '' && account.Documento__c != null) {
                    Matcher matcherCNPJ = patternCNPJ.matcher(account.Documento__c);
                    Matcher matcherCPF = patternCPF.matcher(account.Documento__c);
                    if (!matcherCNPJ.matches() && !matcherCPF.matches()) {
                        account.Documento__c.addError('Documento inválido');
                    }else if(matcherCNPJ.matches()){
                        account.Documento__c = account.Documento__c.replaceAll('([0-9]{2})([0-9]{3})([0-9]{3})([0-9]{4})([0-9]{2})', '$1.$2.$3/$4-$5');
                    }else if(matcherCPF.matches()){
                        account.Documento__c = account.Documento__c.replaceAll('([0-9]{3})([0-9]{3})([0-9]{3})([0-9]{2})', '$1.$2.$3-$4');
                    }
                }
            }
        }
    }
    
    public void checkPostalCodesFormat(){
        Pattern pattern = Pattern.compile('([0-9]{5})([0-9]{3})');
        for(Account account : accountNewList){
            Account accountOld = (account.Id != null && accountOldMap != null && accountOldMap.containsKey(account.Id)) ? accountOldMap.get(account.Id) : new Account();
            if (account.BillingPostalCode != accountOld.BillingPostalCode) {
                
                if (account.BillingPostalCode != '' && account.BillingPostalCode != null) {
                    account.BillingPostalCode = account.BillingPostalCode.replaceAll('[^0-9]', '');    
                    Matcher billingMatcher = pattern.matcher(account.BillingPostalCode);
                    if (!billingMatcher.matches()){
                        System.debug('Cep inválido '+ account.BillingPostalCode);
                        account.BillingPostalCode.addError('CEP inválido ');
                    } else{
                        account.BillingPostalCode = account.BillingPostalCode.replaceAll('([0-9]{5})([0-9]{3})', '$1-$2');
                    }
                }
            }
            
            if (account.ShippingPostalCode != accountOld.ShippingPostalCode) {
                account.BillingPostalCode = DW_Helper.hasSomeContent(account.BillingPostalCode) ? account.BillingPostalCode : '';
                account.ShippingPostalCode = DW_Helper.hasSomeContent(account.ShippingPostalCode) ? account.ShippingPostalCode : '';
               // account.ShippingPostalCode = account.BillingPostalCode.replaceAll('[^0-9]', '');
                if (account.ShippingPostalCode != '' && account.ShippingPostalCode != null) {
                    Matcher shippingMatcher = pattern.matcher(account.ShippingPostalCode);
                    if (!shippingMatcher.matches()){
                        account.ShippingPostalCode.addError('CEP inválido '+account.ShippingPostalCode);
                    } else{
                        account.ShippingPostalCode = account.ShippingPostalCode.replaceAll('([0-9]{5})([0-9]{3})', '$1-$2');
                    }
                }
            }
        }
    }
    
    public void checkPhoneFormat(){
        Pattern pattern = Pattern.compile('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})');
        for(Account account : accountNewList) {
            Account accountOld = (account.Id != null && accountOldMap != null && accountOldMap.containsKey(account.Id)) ? accountOldMap.get(account.Id) : new Account();
            if (account.Phone != accountOld.Phone) {
                account.Phone = account.Phone.replaceAll('[^0-9]', '');
                if (account.Phone != '' && account.Phone != null) {
                    Matcher matcher = pattern.matcher(account.Phone);
                    if (!matcher.matches()) {
                        account.Phone.addError('Telefone no formato inválido');
                    } else {
                        account.Phone = +'+55' + account.Phone.replaceAll('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', ' ($2) $3$4-$5');
                    }
                }
            }
        }
    }
    
    public void validaTamanoCamposEndereco(Account account, String rua, String numero, String complemento, String bairro){
        if(rua.length()>80){
            account.ShippingStreet.addError('Rua maior que 80 caracteres');
        }
        if(numero.length()>10){
            account.ShippingStreet.addError('Número maior que 10 caracteres');
        }
        if(complemento!= ''  && complemento.length()>50){
            account.ShippingStreet.addError('Complemento maior que 50 caracteres');
        }
        if(bairro.length()>40){
            account.ShippingStreet.addError('Bairro maior que 40 caracteres');
        }
    }
    
}