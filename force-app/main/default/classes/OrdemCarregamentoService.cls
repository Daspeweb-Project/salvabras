/**
 * Created by helle on 06/07/2021.
 */

public without sharing class OrdemCarregamentoService {
    List<OrdemCarregamento__c> ordemCarregamentoNewList;
    List<OrdemCarregamento__c> ordemCarregamentoOldList;
    Map<Id, OrdemCarregamento__c> ordemCarregamentoNewMap;
    Map<Id, OrdemCarregamento__c> ordemCarregamentoOldMap;
    public OrdemCarregamentoService(List<OrdemCarregamento__c> ordemCarregamentoNewList, List<OrdemCarregamento__c> ordemCarregamentoOldList, Map<Id, OrdemCarregamento__c> ordemCarregamentoNewMap, Map<Id, OrdemCarregamento__c> ordemCarregamentoOldMap) {
        if (ordemCarregamentoOldList == null) ordemCarregamentoOldList = new List<OrdemCarregamento__c>();
        if (ordemCarregamentoNewMap == null) ordemCarregamentoNewMap = new Map<Id, OrdemCarregamento__c>();
        this.ordemCarregamentoNewList = ordemCarregamentoNewList;
        this.ordemCarregamentoOldList = ordemCarregamentoOldList;
        this.ordemCarregamentoNewMap = ordemCarregamentoNewMap;
        this.ordemCarregamentoOldMap = ordemCarregamentoOldMap;
    }
    public void checkIfHasToSendAttach() {
        Set<Id> ordemCarregamentoSet = new Set<Id>();
        Set<Id> opportunittySet = new Set<Id>();
        Set<String> nameOfFiles = new Set<String>();

        for (OrdemCarregamento__c ordemCarregamento : ordemCarregamentoNewList) {
            OrdemCarregamento__c old = this.ordemCarregamentoOldMap.get(ordemCarregamento.Id);
            if (ordemCarregamento.Status__c == 'Aguardando Expedição' && old.Status__c == 'Aguardando Faturamento') {
                ordemCarregamentoSet.add(ordemCarregamento.Id);
            }
        }
        if (ordemCarregamentoSet.size() == 0) {
            return;
        }
        List<OrdensCarregamentoPedido__c> ordensCarregamentoOportunidadeList = [
                SELECT Id,
                        Name,
                        OrdemCarregamento__c,
                        Pedido__r.OrderNumber
                FROM OrdensCarregamentoPedido__c
                WHERE OrdemCarregamento__c
                        IN :ordemCarregamentoSet
        ];
        if (ordensCarregamentoOportunidadeList.size() == 0) {
            return;
        }

        for (OrdensCarregamentoPedido__c ordemCarregamentoOpp : ordensCarregamentoOportunidadeList) {
            nameOfFiles.add('NF-'+ordemCarregamentoOpp.Pedido__r.OrderNumber+'.pdf');
            nameOfFiles.add('Boleto-'+ordemCarregamentoOpp.Pedido__r.OrderNumber+'.pdf');
        }
        
        List<ContentVersion> documentList = [SELECT Id, Title, FileType, VersionData, isLatest, ContentDocumentId FROM ContentVersion WHERE Title IN:nameOfFiles];

        Map<String, ContentVersion> documentMap = new Map<String, ContentVersion>();
        for (ContentVersion contentVersion : documentList) {
            if(!documentMap.containsKey(contentVersion.Title)){
                documentMap.put(contentVersion.Title, contentVersion);
            }
        }

        for (OrdensCarregamentoPedido__c ordemCarregamentoPedido : ordensCarregamentoOportunidadeList) {
            List<Messaging.EmailFileAttachment> lstFileAttachments = new List<Messaging.EmailFileAttachment>();
            ContentVersion nota = documentMap.get('NF-'+ordemCarregamentoPedido.Pedido__r.OrderNumber+'.pdf');
            ContentVersion boleto =  documentMap.get('Boleto-'+ordemCarregamentoPedido.Pedido__r.OrderNumber+'.pdf');
            String corpoEmail = 'Seu pedido foi faturado em anexo estamos enviando nota e o boleto!';
            if (nota != null) {
                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName(nota.Title);   
                efa.setBody(nota.VersionData);
                lstFileAttachments.add(efa);
            }
    
            if (boleto != null) {
                Messaging.EmailFileAttachment efa2 = new Messaging.EmailFileAttachment();
                efa2.setFileName(boleto.Title);   
                efa2.setBody(boleto.VersionData);
                lstFileAttachments.add(efa2);
            }

            Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
            semail.setToAddresses(new List<String>{'erick.oliveira@salvabras.com.br'});
            semail.setSubject('Pedido faturado!');
            semail.setHtmlBody('<html><head></head><body>'+corpoEmail+'<br/></body></html>');
            if (lstFileAttachments.size() > 0) {
                semail.setFileAttachments(lstFileAttachments);
            }
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
        }
    }
  
}