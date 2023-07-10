/**
* Created by rafael.vidal on 09/06/22.
*/
public without sharing class CustomNotification {
    
    public static void notifyUsers(Set<String> recipientsIds, String targetId, String objeto, String objetoName) {
        
        // Get the Id for our custom notification type
        List<CustomNotificationType> notificationTypeList = 
            [SELECT Id, DeveloperName 
             FROM CustomNotificationType 
             WHERE DeveloperName='Aviso_erro_integrao_pedido_e_conta'];
        
        if(notificationTypeList.size()>0){
            CustomNotificationType notificationType = notificationTypeList.get(0);
            
            // Create a new custom notification
            Messaging.CustomNotification notification = new Messaging.CustomNotification();
            
            // Set the contents for the notification
            notification.setTitle('Erro de integração da '+objeto+' '+objetoName);
            notification.setBody('Id da ' +objeto+' igual '+ targetId);
            
            // Set the notification type and target
            notification.setNotificationTypeId(notificationType.Id);
            notification.setTargetId(targetId);
            
            // Actually send the notification
            try {
                notification.send(recipientsIds);
            }
            catch (Exception e) {
                System.debug('Problema de envio da notificação: ' + e.getMessage());
            }
            
        }
    }
    
}