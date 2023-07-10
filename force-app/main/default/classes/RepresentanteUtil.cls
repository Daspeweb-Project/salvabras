public class RepresentanteUtil {
	@InvocableMethod
    public static List<Representante__c> atualizarCepTransportadora(List<Preenche_CEP__e> ceps){
        List<Representante__c> representantes = new list<Representante__c>();
        for(Preenche_CEP__e cep : ceps){
            Representante__c representante = new Representante__c(Id = cep.id_registro__c);
            CEPClass inf = CEPUtil.getCep(cep.CEP__c);
            if(inf != null){
                representante.Cidade__c = inf.localidade;
                representante.UF__c = inf.uf;
                representante.Logradouro__c = inf.logradouro;
                representante.Bairro__c = inf.bairro;
            }
            representantes.add(representante);
        }
        return representantes;
    }
}