public without sharing class SendEmailInFlowInvocable {
    @InvocableMethod
    public static List<FlowOutput> runAssociateFaixaComMetaBatchFlowController(List<FlowInput> flowInputList){
        FlowInput flowInput = flowInputList.get(0);
        List<FlowOutput> flowOutputList = new List<FlowOutput>();
        List<Messaging.EmailFileAttachment> lstFileAttachments = new List<Messaging.EmailFileAttachment>();
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
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});

        return flowOutputList;
    }
    public class FlowInput{
        @InvocableVariable
        public Id recordId;
        @InvocableVariable
        public String textBody;
        @InvocableVariable
        public String subject;
        @InvocableVariable
        public String recipient;
        @InvocableVariable
        public String cc;
        @InvocableVariable
        public String cco;
        @InvocableVariable
        public  List<String> contentVersions;

        public FlowInput(){
        }
        public FlowInput(Id recordId, String textBody, String subject, String recipient, List<String> contentVersions,String cc,String cco){
            this.recordId        = recordId;
            this.textBody        = textBody;
            this.subject         = subject;
            this.recipient       = recipient;
            this.contentVersions = contentVersions;
            this.cc              = cc;
            this.cco             = cco;

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