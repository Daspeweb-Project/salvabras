/**
 * Created by hellenmartins on 17/11/2021.
 */

({
    init: function (cmp, event, helper) {
        cmp.set('v.columns', [{label: 'Nome', fieldName: 'Name', sortable: true, type: 'text'},
            {label: 'Nº Pedido', fieldName: 'NumeroPedido__c', type: 'text'},
            {label: 'Conta', fieldName: 'Conta__c', type: 'text'},
            {label: 'Status Pedido', fieldName: 'StatusPedido__c', type: 'text'}
        ])
        cmp.set('v.columnsOcorrencia', [{label: 'Nome', fieldName: 'Name', sortable: true, type: 'text'},
            {label: 'Nº Pedido', fieldName: 'NumeroPedido__c', type: 'text'},
            {label: 'Responsável', fieldName: 'NomeResponsavel', type: 'text'},
            {label: 'Ocorrência', fieldName: 'Ocorrencia__c', type: 'text'},
            {label: 'Detalhes Ocorrência', fieldName: 'DetalhesOcorrencia__c', type: 'text'},
            {label: 'Status', fieldName: 'StatusOcorrencia__c', type: 'text'}
        ])
        var action = cmp.get("c.getOrdensCarregamentoOportunidades")
        action.setParams({
            orderId: cmp.get('v.recordId'),
        })
        action.setCallback(this, function (data) {
            try{
                let result = data.getReturnValue()
                console.log('@@@@@@result ... ', result)
                result.ordemCarregamentoComOcorrencia.map(item =>{
                    item.NomeResponsavel = item.UsuarioOcorrencia__r != null ? item.UsuarioOcorrencia__r.Name: ''
                    console.log('@@@@@item ... ', item)

                })
                cmp.set('v.ordemOportunidadeList', result.ordemCarregamentoParaGerar)
                cmp.set('v.ordemOportunidadeComOccorrenciaList', result.ordemCarregamentoComOcorrencia)
            }catch (e) {
                console.error(e)
            }

        });
        $A.enqueueAction(action)

        var action2 = cmp.get("c.getDependentPicklistValues")
        action2.setCallback(this, function (data) {
            let pickListValues = data.getReturnValue();
            let ocorrencia = []
            Object.keys(pickListValues).map(item => {
                ocorrencia.push({value: item, label: item})
            })
            cmp.set('v.ocorrencias', ocorrencia)
            cmp.set('v.pickListValues', pickListValues)
        });
        $A.enqueueAction(action2)

    },
    handleChange: function (cmp, event, helper) {
        let pickListValues = cmp.get('v.pickListValues')
        let valueOcorrencia = cmp.get('v.valueOcorrencia')
        let detalhes = []
        pickListValues[valueOcorrencia].map(value => {
            detalhes.push({value: value, label: value})
        })
        cmp.set('v.detalhes', detalhes)
        cmp.set('v.disabled', false)
    },
    saveOccurrence: function (cmp, event, helper) {
        let ordemOppToUpdate = []
        let ocorrencia = cmp.get('v.valueOcorrencia')
        let detalhe = cmp.get('v.valueDetalhes')
        let justificativa = cmp.get('v.justificativa')
        cmp.find("table-ordem-opp").getSelectedRows().map(order => {
            ordemOppToUpdate.push({
                Id: order.Id,
                Ocorrencia__c: ocorrencia,
                DetalhesOcorrencia__c: detalhe,
                JustificativaOcorrencia__c: justificativa,
                StatusOcorrencia__c: 'Aberto'
            })
        })
        cmp.set('v.displaySpinner', true)
        var action = cmp.get("c.saveUpdates")
        action.setParams({
            ordensCarregamentoOportunidadeList: ordemOppToUpdate,
        })
        action.setCallback(this, function (data) {
            cmp.set('v.displaySpinner', false)
            let toastEvent = $A.get("e.force:showToast");
            let result = JSON.parse(data.getReturnValue())
            if (result.success) {
                toastEvent.setParams({
                    "message": "Ocorrência gerada com sucesso!",
                    "title": '',
                    "type": "success",
                    "duration": 500,
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire()
                $A.get('e.force:closeQuickAction').fire()

            } else {
                toastEvent.setParams({
                    "message": result.errorList[0],
                    "title": 'Erro',
                    "type": "error",
                    "duration": 500,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action)

    },
    concludeOccurrence: function (cmp, event, helper) {
        let ordemOppToUpdate = []
        cmp.find("concluir-ocorrencia").getSelectedRows().map(order => {
            ordemOppToUpdate.push({
                Id: order.Id,
                StatusOcorrencia__c: 'Concluído'
            })
        })
        cmp.set('v.displaySpinner', true)
        var action = cmp.get("c.saveUpdates")
        action.setParams({
            ordensCarregamentoOportunidadeList: ordemOppToUpdate,
        })
        action.setCallback(this, function (data) {
            console.log(data.getReturnValue())
            cmp.set('v.displaySpinner', false)
            let toastEvent = $A.get("e.force:showToast");
            let result = JSON.parse(data.getReturnValue())
            if (result.success) {
                toastEvent.setParams({
                    "message": "Ocorrência concluída com sucesso!",
                    "title": '',
                    "type": "success",
                    "duration": 500,
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire()
                $A.get('e.force:closeQuickAction').fire()

            } else {
                toastEvent.setParams({
                    "message": result.errorList[0],
                    "title": 'Erro',
                    "type": "error",
                    "duration": 500,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action)
    },
    emAndamentoOccurrence: function (cmp, event, helper) {
        let ordemOppToUpdate = []
        cmp.find("concluir-ocorrencia").getSelectedRows().map(order => {
            ordemOppToUpdate.push({
                Id: order.Id,
                StatusOcorrencia__c: 'Andamento'
            })
        })
        cmp.set('v.displaySpinner', true)
        var action = cmp.get("c.saveUpdates")
        action.setParams({
            ordensCarregamentoOportunidadeList: ordemOppToUpdate,
        })
        action.setCallback(this, function (data) {
            console.log(data.getReturnValue())
            cmp.set('v.displaySpinner', false)
            let toastEvent = $A.get("e.force:showToast");
            let result = JSON.parse(data.getReturnValue())
            if (result.success) {
                toastEvent.setParams({
                    "message": "Status Marcado como Em Andamento",
                    "title": '',
                    "type": "success",
                    "duration": 500,
                });
                toastEvent.fire();
                $A.get('e.force:refreshView').fire()
                $A.get('e.force:closeQuickAction').fire()

            } else {
                toastEvent.setParams({
                    "message": result.errorList[0],
                    "title": 'Erro',
                    "type": "error",
                    "duration": 500,
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action)
    }

});