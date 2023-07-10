public without sharing class EnviaEmailEntegueFlow {
    @InvocableMethod(label='envia email entregue')
    public static List<FlowOutput> sendEmailEntregue(List<FlowInput> flowInputList){
        FlowInput flowInput = flowInputList.get(0);
        List<FlowOutput> flowOutputList = new List<FlowOutput>();
        List<OrdensCarregamentoPedido__c> ordemCarregamentoParaGerar = (List<OrdensCarregamentoPedido__c>)DW_QueryFactory.get('OrdensCarregamentoPedido__c')
                .withParent('Pedido__r', 'Order')
                .setCondition(DW_QueryCondition.newInstance('Id', flowInput.ordemCarregamentoId))
                .run();

        Messaging.Email[] messages = new Messaging.Email[0];

        for (OrdensCarregamentoPedido__c ordemCarregamento: ordemCarregamentoParaGerar) {
            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setSubject('Pedido Entregue');
            semail.setHtmlBody('Seu pedido '+ordemCarregamento.Pedido__r.OrderNumber +' foi entregue!');
            semail.setToAddresses(new List<String>{'erick.oliveira@salvabras.com.br'});

            messages.add(semail);

        }
        Messaging.sendEmail(messages);


      /*  List<Messaging.EmailFileAttachment> lstFileAttachments = new List<Messaging.EmailFileAttachment>();
        Set<Id> contentVersion = new Set<Id>();
        if(flowInput.contentVersions != null){
            for (String contentVersionId : flowInput.contentVersions) {
                contentVersion.add(contentVersionId);
            }
            List<ContentVersion> docToSendList = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :contentVersion];
            for (ContentVersion content : docToSendList) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(content.Title+'-'+content.Title+'.'+content.FileType);   
                efa.setBody(content.VersionData);
                lstFileAttachments.add(efa);
            }
        }
       
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
       
        semail.setSubject(flowInput.subject);
        semail.setHtmlBody(flowInput.textBody);
        
        if (lstFileAttachments.size() > 0) {
            semail.setFileAttachments(lstFileAttachments);
        }
        if(flowInput.recipient != null){
            semail.setToAddresses(flowInput.recipient.split(';'));
        }
        if (flowInput.cc != null) {
            semail.setCcAddresses(flowInput.cc.split(';'));
        }
        if (flowInput.cco != null) {
            semail.setBccAddresses(flowInput.cco.split(';'));   
        }        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});*/

        return flowOutputList;
    }
    public class FlowInput{
        @InvocableVariable
        public  List<String> ordemCarregamentoId;

        public FlowInput(){
        }
        public FlowInput(List<String> ordemCarregamentoId){
            this.ordemCarregamentoId        = ordemCarregamentoId;
        }
    }

    public class FlowOutput{
        @InvocableVariable
        public Boolean isDispatched;
        public FlowOutput(Boolean isDispatched){
            this.isDispatched = isDispatched;
        }
    }
}