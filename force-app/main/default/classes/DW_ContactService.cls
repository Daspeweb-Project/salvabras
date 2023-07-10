public without sharing class DW_ContactService {
    List<Contact> contactNewList;
    List<Contact> contactOldList;
    Map<Id, Contact> contactNewMap;
    Map<Id, Contact> contactOldMap;
    
    
    public DW_ContactService(List<Contact> contactNewList, List<Contact> contactOldList,
                             Map<Id, Contact> contactNewMap, Map<Id, Contact> contactOldMap) {
                                 if(contactOldList == null) contactOldList = new List<Contact>();
                                 if(contactNewMap == null) contactNewMap = new Map<Id, Contact>();
                                 this.contactNewList = contactNewList;
                                 this.contactOldList = contactOldList;
                                 this.contactNewMap = contactNewMap;
                                 this.contactOldMap = contactOldMap;
                             }
    
    
    public void checkPhoneFormat(){
        Pattern pattern = Pattern.compile('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})');
        
        for(Contact contact : contactNewList) {
            Contact contactOld = (contact.Id != null && contactOldMap != null && contactOldMap.containsKey(contact.Id)) ? contactOldMap.get(contact.Id) : new Contact();
            if (contact.AssistantPhone != contactOld.AssistantPhone) {
                contact.AssistantPhone = contact.AssistantPhone.replaceAll('[^0-9]', '');
                if (contact.AssistantPhone != '' && contact.AssistantPhone != null) {
                    Matcher matcher = pattern.matcher(contact.AssistantPhone);
                    if (!matcher.matches()) {
                        contact.AssistantPhone.addError('Telefone no formato inválido');
                    } else {
                        contact.AssistantPhone = +'+55' + contact.AssistantPhone.replaceAll('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', ' ($2) $3$4-$5');
                    }
                }
            }
            
            if (contact.HomePhone != contactOld.HomePhone) {
                contact.HomePhone = contact.HomePhone.replaceAll('[^0-9]', '');
                if (contact.HomePhone != '' && contact.HomePhone != null) {
                    Matcher matcher = pattern.matcher(contact.HomePhone);
                    if (!matcher.matches()) {
                        contact.HomePhone.addError('Telefone no formato inválido');
                    } else {
                        contact.HomePhone = +'+55' + contact.HomePhone.replaceAll('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', ' ($2) $3$4-$5');
                    }
                }
            }
            
            if (contact.OtherPhone != contactOld.OtherPhone) {
                contact.OtherPhone = contact.OtherPhone.replaceAll('[^0-9]', '');
                if (contact.OtherPhone != '' && contact.OtherPhone != null) {
                    Matcher matcher = pattern.matcher(contact.OtherPhone);
                    if (!matcher.matches()) {
                        contact.OtherPhone.addError('Telefone no formato inválido');
                    } else {
                        contact.OtherPhone = +'+55' + contact.OtherPhone.replaceAll('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', ' ($2) $3$4-$5');
                    }
                }
            }
            
            if (contact.Phone != contactOld.Phone) {
                contact.Phone = contact.Phone.replaceAll('[^0-9]', '');
                if (contact.Phone != '' && contact.Phone != null) {
                    Matcher matcher = pattern.matcher(contact.Phone);
                    if (!matcher.matches()) {
                        contact.Phone.addError('Telefone no formato inválido');
                    } else {
                        contact.Phone = +'+55' + contact.Phone.replaceAll('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', ' ($2) $3$4-$5');
                    }
                }
            }
            
            if (contact.MobilePhone != contactOld.MobilePhone) {
                contact.MobilePhone = contact.MobilePhone.replaceAll('[^0-9]', '');
                if (contact.MobilePhone != '' && contact.MobilePhone != null) {
                    Matcher matcher = pattern.matcher(contact.MobilePhone);
                    if (!matcher.matches()) {
                        contact.MobilePhone.addError('Telefone no formato inválido');
                    } else {
                        contact.MobilePhone = +'+55' + contact.MobilePhone.replaceAll('([55]{2})?([0-9]{2})([0-9]{1})?([0-9]{4})([0-9]{4})', ' ($2) $3$4-$5');
                    }
                }
            }
        }
    }
}