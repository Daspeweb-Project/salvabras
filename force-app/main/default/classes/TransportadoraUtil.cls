public class TransportadoraUtil {
	@InvocableMethod
    public static List<Transportadora__c> atualizarCepTransportadora(List<Preenche_CEP__e> ceps){
        List<Transportadora__c> transportadoras = new list<Transportadora__c>();
        for(Preenche_CEP__e cep : ceps){
            Transportadora__c transportadora = new Transportadora__c(Id = cep.Id_registro__c);
            CEPClass inf = CEPUtil.getCep(cep.CEP__c);
            if(inf != null){
                transportadora.Cidade__c = inf.localidade;
                transportadora.UF__c = inf.uf;
                transportadora.Logradouro__c = inf.logradouro;
                transportadora.Bairro__c = inf.bairro;
            }
                transportadoras.add(transportadora);
        }
        return transportadoras;
    }
}