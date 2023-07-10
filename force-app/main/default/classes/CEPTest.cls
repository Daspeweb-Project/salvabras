@isTest
public class CEPTest {
	@testSetup
    public static void setup(){
        
    }
    @isTest
    public static void cepConta(){
        List<Preenche_CEP__e> ceps = new List<Preenche_CEP__e>();
        Account conta = new Account();
        conta.Name = 'teste';
        conta.CEP__c = '06230110';
        conta.CNPJ_CPF__c = '14794512074';
        insert conta;
        update conta;
        Preenche_CEP__e cep = new Preenche_CEP__e(Objeto__c = 'conta', Id_registro__c = conta.Id, CEP__c = conta.CEP__c);
        ceps.add(cep);
        List<Account> contaReturn = AccountUtil.atualizarCepConta(ceps);
        System.debug(contaReturn);
    }
    @isTest
    public static void cepTransportadora(){
        List<Preenche_CEP__e> ceps = new List<Preenche_CEP__e>();
        Transportadora__c transportadora = new Transportadora__c();
        transportadora.Name = 'teste';
        transportadora.CEP__c = '06230110';
        transportadora.CNPJ_Transportadora__c = '16557984000146';
        transportadora.Email_Transportadora__c = 'test@gmail.com';
        transportadora.Coleta_Transportadora__c = 'Sim';
        transportadora.Telefone_Transportadora__c = '855222222';
        insert transportadora;
        update transportadora;
        Preenche_CEP__e cep = new Preenche_CEP__e(Objeto__c = 'transportadora', Id_registro__c = transportadora.Id, CEP__c = transportadora.CEP__c);
        ceps.add(cep);
        List<Transportadora__c> transportadoraReturn = TransportadoraUtil.atualizarCepTransportadora(ceps);
        System.debug(transportadoraReturn);
    }
    @isTest
    public static void cepRepresentante(){
        List<Preenche_CEP__e> ceps = new List<Preenche_CEP__e>();
        Representante__c representante = new Representante__c();
        representante.Name = 'teste';
        representante.CEP__c = '06230110';
        representante.CNPJ_Representante__c = '16557984000146';
        representante.Telefone_Representante__c = '855222222';
        representante.Email_Representante__c = 'test@gmail.com';
        insert representante;
        update representante;
        Preenche_CEP__e cep = new Preenche_CEP__e(Objeto__c = 'representante', Id_registro__c = representante.Id, CEP__c = representante.CEP__c);
        ceps.add(cep);
        List<Representante__c> representanteReturn = RepresentanteUtil.atualizarCepTransportadora(ceps);
        System.debug(representanteReturn);
    }
}