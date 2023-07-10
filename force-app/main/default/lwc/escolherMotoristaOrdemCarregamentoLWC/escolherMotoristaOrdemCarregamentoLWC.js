import { LightningElement,api,wire, track } from 'lwc';
import { CloseActionScreenEvent } from 'lightning/actions';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getVehicle from '@salesforce/apex/GerenciarTransporteController.getVehicle';
import getDriver from '@salesforce/apex/GerenciarTransporteController.getDriver';
import getPraca from '@salesforce/apex/GerenciarTransporteController.getPraca';
import save from '@salesforce/apex/GerenciarTransporteController.save';

export default class EscolherMotoristaOrdemCarregamentoLWC extends LightningElement {
    hasRendered = false;
    cars;
    typeTruck;
    driver;
    praca;


    @track
    isLoading =false
    @track
    options = [];

    @track
    optionsDriver = [];

    @track
    optionsPraca = [];

    _recordId

    @api 
    set recordId(value) {
        console.log('okoko')
        this._recordId = value;
        getVehicle({
           orderId : value
        }).then(result => {
            let opt  = result.map(item => {
                return {label: item.Name + ' - Capacidade de carga m³: ' + item.MetroCubicoCapacidadeCarga__c, value: item.Id}
            }); 
            this.options = opt

        });

    }    
    @wire(getVehicle) wiredVehicles ({ error, data }) {
        try {
            if (data) {
                let opt  = data.map(item => {
                    return {label: item.Name + ' - Capacidade de carga m³: ' + item.MetroCubicoCapacidadeCarga__c, value: item.Id}
                }); 
                this.options = opt
           } else if (error) { 
               this.cars = error;  
          } 
        } catch (error) {
            console.error(error);
        }
   
    }

    get recordId() {
        return this._recordId;
    }



    handleChange(event) {
        try {
            this.typeTruck = event.detail.value;
            this.driver = null
            this.praca = null
            getDriver({
                vehicleId:  this.typeTruck ,
            }).then(result => {
                console.log(result)
                let driver = result.map(item =>{ 
                    return {label: item.Name, value: item.Id}
                })
                this.optionsDriver = driver
            });
        } catch (error) {
            console.error(error);
        }
       
    }
    handleChangeDriver(event) {
       
        try {
            this.driver = event.detail.value;
            this.praca = null
            getPraca({
                moristaId: this.driver,
                vehicleId:  this.typeTruck
            }).then(result => {
                console.log(result)
                let praca = result.map(item =>{ 
                    item.Valor__c != null ? item.Valor__c:0

                    return {label: item.Name + ' - Valor: ' + item.Valor__c.toLocaleString('pt-BR', {
                        style: 'currency',
                        currency: 'BRL',
                    }), value: item.Id}
                })
                console.log(praca);
                this.optionsPraca = praca
            });
        } catch (error) {
            console.error(error);
        }

    }

    handleChangePraca(event) {
       
        try {
            this.praca = event.detail.value;
        
        } catch (error) {
            console.error(error);
        }

    }
    handleConclude(event) {
        try {
            this.isLoading = true
            save({
                ordemCarregamentoId: this._recordId,
                motoristaId: this.driver,
                vehicleId:  this.typeTruck,
                pracaId: this.praca
            }).then(result => {
                this.isLoading = false
                let data = JSON.parse(result)
                if(data.success){
                    const evt = new ShowToastEvent({
                        title: 'Sucesso!',
                        message: 'Veículo vinculado com sucesso!',
                        variant: 'success'
                    });
                    this.dispatchEvent(evt);
                    this.dispatchEvent(new CloseActionScreenEvent());
                    eval("$A.get('e.force:refreshView').fire();")
                }else{
                    const evt = new ShowToastEvent({
                        title: 'Ops',
                        message: data.errorList[0],
                        variant: 'error'
                    });
                    this.dispatchEvent(evt);
                }
            });
        } catch (error) {
            console.error(error);
        }

    }
    

    closeQuickAction() {
        this.dispatchEvent(new CloseActionScreenEvent());
    }
}