import { getFieldValue } from "lightning/uiRecordApi"
import DOCUMENTO_FIELD from '@salesforce/schema/Account.Documento__c'
import STATE_FIELD from '@salesforce/schema/Account.ShippingState'
export const _sintegraDataRequestMap = {
    receitaRederal: function () {
        return {
            cnpjIe: getFieldValue(this.account, DOCUMENTO_FIELD)?.replaceAll(/[^0-9]/g, ''),
            plugin: 'RF'
        }
    },
    sintegra: function () {
        return {
            cnpjIe: getFieldValue(this.account, DOCUMENTO_FIELD)?.replaceAll(/[^0-9]/g, ''),
            uf: getFieldValue(this.account, STATE_FIELD),
            plugin: 'ST'
        }
    },
    simplesNacional: function () {
        return {
            cnpjIe: getFieldValue(this.account, DOCUMENTO_FIELD)?.replaceAll(/[^0-9]/g, ''),
            plugin: 'SN'
        }
    },
}

export const _accountFieldsBySintegraMap = {
    receitaRederal: [
        'Name',
        'DescricaoAtividadePrincipal__c',
        'CodigoAtividadePrincipal__c',
        'DataSituacaoCadastral__c',
        'Complemento__c',
        'Phone',
        'Email__c',
        'Situacao__c',
        'Bairro__c',
        'TipoLogradouro__c',
        'BillingStreet',
        'NumeroCobranca__c',
        'BillingPostalCode',
        'BillingCity',
        'DataAbertura__c',
        'SiglaNaturezaJuridica__c',
        'TipoInscricao__c',
        'NomeFantasia__c',
        'EFR__c',
        'MotivoSituacao__c',
        'SituacaoEspecial__c',
        'DataSituacaoEspecial__c',
        'CapitalSocial__c',
        'Extra__c',
        'Porte__c',
        'CodigoMunicipioIBGE__c',
        'CodigoUfIBGE__c',
    ],
    sintegra: [
        'StatusIntegracaoSintegraWs__c',
        'NomeEmpresarial__c',
        'NomeFantasia__c',
        'InscricaoEstadual__c',
        'TipoInscricao__c',
        'SituacaoCNPJ__c',
        'SituacaoCadastralInscricaoEstadual__c',
        'DataInicioAtividade__c',
        'RegimeTributacao__c',
        'InfoInscEstadualDestinatario__c',
        'PorteEmpresa__c',
        'CodigoCNAEPrincipal__c',
        'DescricaoAtividadeEconomicaPrincipal__c',
        'BillingState',
        'BillingCity',
        'BairroCobranca__c',
        'BillingStreet',
        'ComplementoCobranca__c',
        'NumeroCobranca__c',
        'CodigoMunicipioIBGE__c',
        'CodigoUfIBGE__c',
    ],
    simplesNacional: [
        'NomeEmpresarial__c',
        'SituacaSimplesNacional__c',
        'SituacaoSimei__c',
        'SituacaoSimplesNacionalAnterior__c',
        'SituacaoSimeiAnteriror__c',
        'Agendamentos__c',
        'EventosFuturosSimplesNacional__c',
        'EventosFuturosSimei__c',
    ],
}