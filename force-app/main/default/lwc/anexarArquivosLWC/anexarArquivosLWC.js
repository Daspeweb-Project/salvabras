import { LightningElement, api, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { CloseActionScreenEvent } from 'lightning/actions';

import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import getOppotunityToGetNf from '@salesforce/apex/AnexarNotaFiscalController.getOppotunityToGetNf';
import attachNfToOrder from '@salesforce/apex/AnexarNotaFiscalController.attachNfToOrder';

export default class AnexarArquivosLWC extends LightningElement {
    rendered = false
    orders = []
    orderCount = ''
    @api recordId

    @wire(CurrentPageReference)
    getStateParameters(currentPageReference) {
        if (currentPageReference) {
            this.recordId = currentPageReference.state.recordId;
        }
    }

    renderedCallback() {
        if (this.rendered) {
            return
        }
        this.rendered = true

        this.invokeApexMethods();
    }
 
    async invokeApexMethods() {
        try {
            await getOppotunityToGetNf({orderId: this.recordId})
            .then(response =>{
                this.orders = response;
                this.callNotes()
            })

           
        } catch(error) {
            console.log(error);
        } finally {
            console.log('Finally Block');
        }
    }
    async callNotes() {
        let orders = this.orders
        let maxIndex = orders.length - 1
        for (const [index, order] of orders.entries()) {
            console.log('order ...', order);
            console.log('index ...', index);

            await attachNfToOrder( {orderId: order.Id})
            .then((response =>{
                   if(index == maxIndex){
                      this.dispatchEvent(new CloseActionScreenEvent());
                      this.updateRecordView()
                      this.showToast('Sucesso!', 'Todas a notas foram consultadas, favor verifique na guia de arquivos!', 'Success', 'dismissable');
                   }
                   this.orderCount = orders[index].Id
            }))
            .catch(error =>{
               console.log('error', error)
            })
        }
        
    }

    showToast(title, message, variant, mode) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: mode
        });
        this.dispatchEvent(event);
    }

    updateRecordView() {
        setTimeout(() => {
             eval("$A.get('e.force:refreshView').fire();");
        }, 3000); 
     }
}