public  class DwGetSaldoSintegraIntegrable extends DW_Integrable {
        public GetSaldoSintegraWSIntegrableTempate responseTemplate;
        
        public override void callIntegration(Object obj) {
            
            this.deserializedRequestObject = obj;
            this.sendRequest();
            
        }
        public override String constructEndpoint() {
           return MetadataHelper.getInstance().daspeMicroservico.ConsultaSaldo__c + '?token=' + MetadataHelper.getInstance().daspeMicroservico.Token__c + '&';
           
        }
        public override String setMethod() {
            return 'GET';
        }
        public override Map<String, String> constructHeaders() {
            
            return new Map<String, String>{
    
                    'Content-Type' => 'application/json'
                    };
        }
        
        public override Map<String, String> constructQueryParameters() {
            Map<String, String> queryParameters = new Map<String, String>(); 
            return queryParameters;
        } 
        
        
        public override String getSerializedRequest() {
            
            return JSON.serialize('');
            
            
        }
        
         public override void setDeserializedResponseObject() {
             System.debug(LoggingLevel.ERROR,'this.requestFactoryInstance.getResponse().getBody():' + this.requestFactoryInstance.getResponse().getBody());
            
            this.responseTemplate = (GetSaldoSintegraWSIntegrableTempate) JSON.deserialize(
                this.requestFactoryInstance.getResponse().getBody(),
                GetSaldoSintegraWSIntegrableTempate.class
            );
            System.debug(LoggingLevel.ERROR,'responseTemplate:' + responseTemplate);
            this.deserializedResponseObject = responseTemplate;
        }
        
        public override void finish() {
            
        }
}