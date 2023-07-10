/**
 * Created by guilhermereis on 06/11/21.
 */

@IsTest
public with sharing class DW_IntegrableHelperTest {
    @IsTest
    public static void main(){
        Account acc = TestFactory.createAccountClienteType();
        acc.Name = null;
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(new Set<Id>{acc.Id}, new List<Account>{acc}, 'teste mensagem');
        acc.Name = 'Teste';
        DW_IntegrableHelper.tryToSaveRecordsOrPostOnChatter(new Set<Id>{acc.Id}, new List<Account>{acc}, 'teste mensagem');
    }
}