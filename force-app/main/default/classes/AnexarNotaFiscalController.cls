/**
 * Created by helle on 03/08/2021.
 */

public with sharing class AnexarNotaFiscalController {
   @AuraEnabled
   public static List<OrdensCarregamentoPedido__c> getOppotunityToGetNf(String orderId) {
       return [SELECT Id, Name,Pedido__c
               FROM OrdensCarregamentoPedido__c
               WHERE OrdemCarregamento__c = :orderId
               AND JaTemNF__c = FALSE
               ORDER BY CreatedDate
            ];
   }
   @AuraEnabled
   public static String attachNfToOrder(String orderId) {
        try {
        Set<Id> pedidoSet = new Set<Id>();
        OrdensCarregamentoPedido__c ocPedido = [SELECT Id, Name,Pedido__c,Pedido__r.OrderNumber,OrdemCarregamento__c FROM OrdensCarregamentoPedido__c WHERE Id = :orderId LIMIT 1];
        List<NotaFiscal__c> notaFiscal = [SELECT Id, Name FROM NotaFiscal__c WHERE Pedido__c = :ocPedido.Pedido__c AND TipoNotaFiscal__c = 'N'];
        System.debug('antes do if');

        if (notaFiscal.size() > 0) {
                        System.debug('dentro do if');

            List<String> notaSplit = notaFiscal.get(0).Name.split('/');

            AnexoTemplate template = new AnexoTemplate();
            template.nota = notaSplit.get(0);
            template.serie = notaSplit.get(1);
            System.debug('antes do req');

            HttpRequest req = new HttpRequest();
            Http http = new Http();
            req.setMethod('POST');
            req.setEndpoint(DaspeMicroservicoHelper.getInstance().daspeMicroservico.EndpointBuscarArquivos__c);
            req.setHeader('Accept', 'application/json');
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(template));
            req.setTimeout(120000);
            HTTPResponse res = http.send(req);
            System.debug('res . .. '+ res.getBody());
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                List<String> listName = res.getBody().split('"');
                System.debug('listName . .. '+listName);

                String contentDanfe = listName.get(3);
                String contentXML = listName.get(11);
                String contentBoleto = listName.get(7);
                String nomeNota = ocPedido.Pedido__r.OrderNumber;
                if (contentDanfe != '') {
                    ContentVersion conVerDanfe = new ContentVersion();
                    conVerDanfe.ContentLocation = 'S';
                    conVerDanfe.Title = 'NF-' + nomeNota + '.pdf';
                    conVerDanfe.PathOnClient = conVerDanfe.Title;
                    conVerDanfe.VersionData = !Test.isRunningTest() ?EncodingUtil.base64Decode(contentDanfe) : Blob.valueOf('Unit Test Attachment Body');
                    insert conVerDanfe;
    
                    Id conDocDanfe = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVerDanfe.Id].ContentDocumentId;
                    ContentDocumentLink conDocLinkDanfe = new ContentDocumentLink();
                    conDocLinkDanfe.LinkedEntityId = ocPedido.OrdemCarregamento__c;
                    conDocLinkDanfe.ContentDocumentId = conDocDanfe;
                    conDocLinkDanfe.ShareType = 'I';
                    conDocLinkDanfe.Visibility = 'AllUsers';
                    insert conDocLinkDanfe;
                }
    
                if (contentXML != '') {
                    ContentVersion conVerXML = new ContentVersion();
                    conVerXML.ContentLocation = 'S';
                    conVerXML.Title = 'NF-' + nomeNota + '.xml';
                    conVerXML.PathOnClient = conVerXML.Title;
                    conVerXML.VersionData = !Test.isRunningTest() ? EncodingUtil.base64Decode(contentXML) : Blob.valueOf('Unit Test Attachment Body');
                    insert conVerXML;
    
                    Id conDocXml = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVerXML.Id].ContentDocumentId;
                    ContentDocumentLink conDocLinkXml = new ContentDocumentLink();
                    conDocLinkXml.LinkedEntityId = ocPedido.OrdemCarregamento__c;
                    conDocLinkXml.ContentDocumentId = conDocXml;
                    conDocLinkXml.ShareType = 'I';
                    conDocLinkXml.Visibility = 'AllUsers';
                    insert conDocLinkXml;
                }
                if (contentBoleto != '') {
                    ContentVersion conVerBoleto = new ContentVersion();
                    conVerBoleto.ContentLocation = 'S';
                    conVerBoleto.Title = 'Boleto-' + nomeNota + '.pdf';
                    conVerBoleto.PathOnClient = conVerBoleto.Title;
                    conVerBoleto.VersionData = !Test.isRunningTest() ? EncodingUtil.base64Decode(contentBoleto) : Blob.valueOf('Unit Test Attachment Body');
                    insert conVerBoleto;
    
                    Id conDocBoleto = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :conVerBoleto.Id].ContentDocumentId;
                    ContentDocumentLink conDocLinkBoleto = new ContentDocumentLink();
                    conDocLinkBoleto.LinkedEntityId = ocPedido.OrdemCarregamento__c;
                    conDocLinkBoleto.ContentDocumentId = conDocBoleto;
                    conDocLinkBoleto.ShareType = 'I';
                    conDocLinkBoleto.Visibility = 'AllUsers';
                    insert conDocLinkBoleto;
                }
                ocPedido.JaTemNF__c = true;
                update ocPedido;
                return 'ok';
            }         
            return 'erro na integração';  
        }
        return 'nota não encontrada';
        } catch (Exception e) {
            System.debug(e.getMessage());
            return e.getMessage();
        }
        
   }

    public class AnexoTemplate {
	    public String nota;
	    public String serie;    
    }
}