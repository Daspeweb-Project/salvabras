/**
 * Created by hellenmartins on 06/04/2022.
 */

({
    doInit: function (component, event, helper) {
        var utilityAPI = component.find("utilitybar");
        utilityAPI.getAllUtilityInfo().then(function (response) {
            console.log('@@@@response', response);

            if (typeof response !== 'undefined') {
                        utilityAPI.openUtility();
            }
        });

        const empApi = component.find('empApi');
        const channel = '/event/OrdemCarregamentoEvt__e';
        const replayId = -1;
        empApi.subscribe(channel, replayId, $A.getCallback(eventReceived => {
            let objectPayload = eventReceived.data.payload;
            console.log('RECEIVING .. .. ',objectPayload );

            if (objectPayload != null){
                var navService = component.find("navService");
                var pageReference = {
                    "type": "standard__recordPage", //example for opening a record page, see bottom for other supported types
                    "attributes": {
                        "recordId": objectPayload.ObjectId__c, //place your record id here that you wish to open
                        "actionName": "view"
                    }
                }

                navService.generateUrl(pageReference)
                    .then($A.getCallback(function(url) {
                            console.log('success: ' + url); //you can also set the url to an aura attribute if you wish
                            window.open(url,'_blank'); //this opens your page in a seperate tab here
                        }),
                        $A.getCallback(function(error) {
                            console.log('error: ' + error);
                        }));
            }
        })).then(subscription => {
            component.set('v.subscription', subscription);
        });

    }
})