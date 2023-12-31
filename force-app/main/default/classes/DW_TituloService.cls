public class DW_TituloService {
	List<Titulo__c> titulotNewList;
    List<Titulo__c> titulotOldList;
    Map<Id, Titulo__c> titulotNewMap;
    Map<Id, Titulo__c> titulotOldMap;    
    
    public DW_TituloService(List<Titulo__c> titulotNewList, List<Titulo__c> titulotOldList,
                                Map<Id, Titulo__c> titulotNewMap, Map<Id, Titulo__c> titulotOldMap) {
                                    if(titulotOldList == null) titulotOldList = new List<Titulo__c>();
                                    if(titulotNewMap == null) titulotNewMap = new Map<Id, Titulo__c>();
                                    this.titulotNewList = titulotNewList;
                                    this.titulotOldList = titulotOldList;
                                    this.titulotNewMap = titulotNewMap;
                                    this.titulotOldMap = titulotOldMap;
                                }
    
    public void persisteAccTitulo(){
        verificaCriaContaHistoricoTitulo();
        ajustaContaPedidoComTitulo();
    }
    
    public void ajustaContaPedidoComTitulo(){
        for (Titulo__c tt : titulotNewList){
            if(tt.CodigoCliente__c != null && tt.Conta__r.CodigoERP__c != null){
                System.debug('CodigoCliente__c '+ tt.CodigoCliente__c);
                System.debug('Conta '+ tt.Conta__r.CodigoERP__c);

                List<Account> accList = getAccByCodigoERP(tt.CodigoCliente__c);
                if(accList.size()>0){
                    tt.Conta__c = accList.get(0).id;
                }else{
                    System.debug(LoggingLevel.ERROR, '@@ajustaContaPedidoComTitulo.ajustaContaPedidoComTitulo() e.getMessage: ' + 'Erro ao perssitir conta na NF'); 
                }
            }
        }
    }
    
    public void verificaCriaContaHistoricoTitulo(){
        List<Account> listaContaERP = new List<Account>();        
        for (Titulo__c tt : titulotNewList){
            if(tt.CodigoCliente__c != null && tt.Conta__r.CodigoERP__c != null){
                List<Account> accList = getAccByCodigoERP(tt.CodigoCliente__c);
                if(accList.size() == 0){
                    Account acc = criarContaHistoricoTitulo(tt.CodigoCliente__c);
                    listaContaERP.add(acc);
                }
            }
        }
        if(listaContaERP.size()>0)
       	 insert listaContaERP;    
    }
    
    public Account criarContaHistoricoTitulo(String codigoERP){
        Account acc = new Account();
        acc.Name = 'Conta Histórico Título';
        acc.CodigoERP__c = codigoERP;
        return acc;
    }
    
    public List<Account> getAccByCodigoERP(String codigoERP){
        List<Account> accList = DW_QueryFactory.get('Account').setCondition(DW_QueryCondition.newInstance('CodigoERP__c', new List<String>{codigoERP})).run();
        return accList;
    }
    
}