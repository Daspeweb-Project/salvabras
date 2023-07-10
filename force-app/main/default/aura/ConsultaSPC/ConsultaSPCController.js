({
    init: function (component, event, helper) {
        let idAccount = component.get("v.record");
        component.set("v.isNotVisiblePickList", false);
        component.set("v.documento", idAccount.Documento__c);
        if(idAccount.Documento__c.length < 15 ){
            component.set("v.isNotVisiblePickList", true);
            component.set("v.isErrorValidation", true);
            component.set("v.isLoading", false);
            component.set("v.msgValidation", 'O número de caracteres do campo Documento não é compativel com um CNPJ.');
            return;
        }
        /*let action = component.get("c.consultaProdutos");
        
        action.setParams({
            'accId': component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            let valueReturn = JSON.parse(response.getReturnValue());
            
            let optionArr = [];
            let options = Object.keys(valueReturn);
            for (var prop in valueReturn) {    
                let objChose = {};
                objChose.label = prop +' : '+ valueReturn[prop],
                objChose.value = valueReturn[prop]
                
                optionArr.push(objChose);
            }
            component.set("v.isNotVisiblePickList", true);
            component.set("v.optionsProducts", optionArr);
            
        });
        $A.enqueueAction(action);*/
        let optionArr = [];
        let objChose = {};
        objChose.label = 'SPC RELATORIO COMPLETO' +' : '+ '337',
        objChose.value = '337'
        objChose.selected = true
        optionArr.push(objChose);
        component.set("v.isNotVisiblePickList", true);
        component.set("v.optionsProducts", optionArr);
        component.set("v.value", '337');
        
    },
    handleChange: function (component, event, helper) {
       component.set("v.isErrorValidation", false);
        
        
    },
    consultaSPC: function (component, event, helper) {
        component.set("v.isErrorValidation", false);
        component.set("v.isLoading", true);
        let valueProduto = component.get("v.value");
        
        if(valueProduto === ''){
            component.set("v.isErrorValidation", true);
            component.set("v.isLoading", false);
            component.set("v.msgValidation", 'Não foi selecionado o produto desejado.');
            return;
        }
        
        let action = component.get("c.consultaDocumento");
        
        action.setParams({
            'accId': component.get("v.recordId"),
            'codProduct' : component.get("v.value")
        });
        action.setCallback(this, function (response) {
            let valueReturn = response.getReturnValue();
            component.set("v.isLoading", false);
            if(valueReturn.length > 20){
            	component.set("v.messagemSucceOrError", valueReturn);    
            }else{
                
                let navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": valueReturn,
                    "slideDevName": "related"
                });
                navEvt.fire();    
            }
            
            
        });
        $A.enqueueAction(action);
        
    }
})