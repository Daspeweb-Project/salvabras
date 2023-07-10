import { getFieldValue, getRecord, getRecordNotifyChange, updateRecord } from 'lightning/uiRecordApi'
import { api, LightningElement, track, wire } from 'lwc'
import DOCUMENTO_FIELD from '@salesforce/schema/Account.Documento__c'
import NAME_FIELD from '@salesforce/schema/Account.Name'
import STATE_FIELD from '@salesforce/schema/Account.ShippingState'
import DwLwcHelper from 'c/dwLwcHelper'
import getSintegraData from '@salesforce/apex/DWControllerSintegraWS.getSintegraData'
import getSintegraSaldo from '@salesforce/apex/DWControllerSintegraWS.getSintegraSaldo'
import { _accountFieldsBySintegraMap, _sintegraDataRequestMap } from './dwConsultaSintegraHelper'


export default class DwConsultaSintegra extends LightningElement {
    @api receitaRederalRequest
    @api sintegraRequest
    @api simplesNacionalRequest
    @api suframaRequest
    @api recordId
    @api showBalance

    accountId
    connnected
    account
    error
    loading
    listenChange
    sintegraOptionValue
    @track balanceValue = 0
    @track accountFields = []

    @wire(getRecord, {
        recordId: '$recordId',
        fields: [
            DOCUMENTO_FIELD,
            NAME_FIELD,
            STATE_FIELD
        ]
    }) handleWiredAccount({ error, data }) {
        if (data) this.account = data
        if (error) {
            console.error('error handleWiredAccount', JSON.parse(JSON.stringify(Object.assign(error, {}))))
            this.error = error
        }
    }

    connectedCallback() {
        if (this.connnected) return
        this.requestSintegraBalance()
        this.connnected = true
    }


    ///HANDLERS
    async handleClickToConsultSintegra() {
        try {
            if (!this._validateSintegraDataRequest()) {
                this.template.querySelector('lightning-tabset').activeTabValue = 'request-method-tab'
                return
            }
            this.loading = true
            let request = _sintegraDataRequestMap[this.sintegraOptionValue]?.call(this)
            if (!request) return alert('CORPO DE REQUISIÇÃO NÃO ENCONTRADO: ' + this.sintegraOptionValue)
            let { response } = DwLwcHelper.validateDwResponseHTTP(await getSintegraData({
                ...request,
                recordId: this.recordId
            }))
            let { status } = JSON.parse(response)
            if (status !== 'OK') throw 'Não foi possível validar a resposta da consulta'
            this.template.querySelector('lightning-tabset').activeTabValue = 'account-record-tab'
            updateRecord({
                fields: {
                    Id: this.recordId
                }
            })
            DwLwcHelper.toast.success.call(this, `Consulta para ${getFieldValue(this.account, NAME_FIELD)} realizada com sucesso!`)
        } catch (e) {
            console.error('ERROR ON getSintegraData', e)
            DwLwcHelper.toast.error.call(this, typeof e === 'string' ? e : 'Tivemos um erro ao realizar a consulta :(')
        } finally {
            this.loading = false
        }
    }

    handleChangeSintegraOption(e) {
        this.sintegraOptionValue = e.detail.value
        this.accountFields = _accountFieldsBySintegraMap[this.sintegraOptionValue] ?? []
    }

    handleClickReloadBalance(e) {
        this.requestSintegraBalance()
    }


    ///VALIDATORS
    _validateSintegraDataRequest() {
        let optionCombobox = this.template.querySelector(`[data-name="sintegra-option-combobox"]`)
        let optionValid = optionCombobox.checkValidity()
        if (!optionValid) {
            optionCombobox.reportValidity()
            return false
        }
        if ([null, undefined].includes(getFieldValue(this.account, DOCUMENTO_FIELD))) {
            DwLwcHelper.toast.warning.call(this, 'Para realizar a consulta a conta deve ter o campo documento preenchido')
            return false
        }
        return true
    }

    ///CRUDs
    async requestSintegraBalance() {
        if (!this.showBalance) return
        let inputBalance = this.template.querySelector(`[data-name="sintegra-balance-input"]`)
        try {
            inputBalance?.setCustomValidity(null)
            this.loadingBalance = true
            let { response } = DwLwcHelper.validateDwResponseHTTP(await getSintegraSaldo({
                recordId: this.recordId
            }))
            this.balanceValue = response
        } catch (e) {
            inputBalance?.setCustomValidity('Tivemos um erro ao obter o saldo')
            inputBalance?.reportValidity()
            console.error('ERROR ON getSintegraSaldo', e)
        } finally {
            this.loadingBalance = false
        }
    }

    ///GETTERS
    get sintegraOptions() {
        let options = []
        if (this.receitaRederalRequest) {
            options.push({
                label: 'Receita Federal',
                value: 'receitaRederal'
            })
        }
        if (this.sintegraRequest) {
            options.push({
                label: 'Sintegra',
                value: 'sintegra'
            })
        }
        if (this.simplesNacionalRequest) {
            options.push({
                label: 'Simples Nacional',
                value: 'simplesNacional'
            })
        }
        if (this.suframaRequest) {
            options.push({
                label: 'Suframa',
                value: 'suframa'
            })
        }
        return options
    }

    get showAccountForm() {
        return this.accountFields?.length
    }
}