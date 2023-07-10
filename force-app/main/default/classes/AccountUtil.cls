public class AccountUtil {
	@InvocableMethod
    public static List<Account> atualizarCepConta(List<Preenche_CEP__e> ceps){
        List<account> contas = new list<account>();
        for(Preenche_CEP__e cep : ceps){
            Account acc = new Account(Id = cep.Id_registro__c);
            CEPClass inf = CEPUtil.getCep(cep.CEP__c);
            if(inf != null){
                acc.Cidade__c = inf.localidade;
                acc.UF__c = inf.uf;
                acc.Logradouro__c = inf.logradouro;
                acc.Bairro__c = inf.bairro;
                acc.Regi_o__c = inf.uf;
            }
            contas.add(acc);
        }
        return contas;
    }
}