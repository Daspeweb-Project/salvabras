global with sharing class GetGeolocationsBatch implements Schedulable, Database.Batchable<SObject>, Database.AllowsCallouts{
    global static void scheduleThisClass(String cron){
        cron = cron == null ? '0 0 * * * ?' : cron;
        System.schedule('GetGeolocationsBatch ' + cron, cron , new GetGeolocationsBatch());
    }
    
    global static void runEveryNMinutes(Integer each) {
        for (Integer i = 0; i < 60; i += each){
            String cron = '0 ' + i + ' * * * ?';
            System.schedule('GetGeolocationsBatch ' + cron, cron, new GetGeolocationsBatch());
        }
    }
    
    global static void runEveryNMinutesInBusinessHours(Integer each) {
        for (Integer minute = 0; minute < 60; minute += each){
            for (Integer hour = 0; hour <= 23; hour ++){
                if(hour > 8 && hour < 20 && !Test.isRunningTest()){
                    String cron = '0 ' + minute + ' ' + hour + ' * * ?';
                    System.schedule('GetGeolocationsBatch ' + cron, cron, new GetGeolocationsBatch());
                }
            }
        }
    }
    
    global static void cancelThisSchedule() {
        CronTrigger[] asyncApexJob = [
            SELECT Id, CronJobDetail.name
            FROM CronTrigger
            WHERE CronJobDetail.name LIKE '%GetGeolocationsBatch%'
        ];
        for (CronTrigger job : asyncApexJob){
            System.abortJob(job.Id);
        }
    }
    
    public void execute(SchedulableContext param1) {
        Database.executeBatch(new GetGeolocationsBatch(), 1);
    }
    
    public Iterable<SObject> start(Database.BatchableContext param1) {
       return [SELECT Id,
                      ShippingLatitude,
                      ShippingLongitude,
                      ShippingStreet,
                      ShippingCity,
                      ShippingState,
                      ShippingCountry,
                      ShippingPostalCode,
                      BillingLatitude,
                      BillingLongitude,
                      BillingStreet,
                      BillingCity,
                      BillingState, 
                      BillingCountry,
                      BillingPostalCode
                FROM Account 
                WHERE (ShippingLatitude = null AND ShippingStreet != null AND ShippingStreet != null AND ShippingCity != null AND ShippingState != null AND ShippingCountry != null AND ShippingPostalCode != null)
                 OR (BillingLatitude = null and BillingStreet != null AND BillingStreet!= null AND BillingCity != null AND BillingState != null AND BillingCountry != null AND BillingPostalCode != null)
            ];
    }
    
    public void execute(Database.BatchableContext param1, List<Account> accountList) {
        List<Account> accountToUpdate = new List<Account>();
        for(Account acc : accountList){
            String bilingAddress='';
            String shippingAddress='';

            if(acc.BillingStreet!=null){
                bilingAddress += acc.BillingStreet+',';
            }
            if(acc.BillingCity !=null){
                bilingAddress += acc.BillingCity+',';
            }
            if(acc.BillingState!=null){
                bilingAddress +=acc.BillingState+',';
            }
            if(acc.BillingCountry!=null){
                bilingAddress += acc.BillingCountry+',';
            }
            if(acc.BillingPostalCode!=null){
                bilingAddress += acc.BillingPostalCode+',';
            }

            if(acc.ShippingStreet!=null){
                shippingAddress += acc.ShippingStreet+',';
            }
            if(acc.ShippingCity !=null){
                shippingAddress += acc.ShippingCity+',';
            }
            if(acc.ShippingState!=null){
                shippingAddress +=acc.ShippingState+',';
            }
            if(acc.ShippingCountry!=null){
                shippingAddress += acc.ShippingCountry+',';
            }
            if(acc.ShippingPostalCode!=null){
                shippingAddress += acc.ShippingPostalCode+',';
            }
            GeolocationResponseTemplate geocodeBilling = new GeolocationResponseTemplate();
            GeolocationResponseTemplate geocodeShipping = new GeolocationResponseTemplate();

            if (bilingAddress != null && bilingAddress != '') {
                HttpRequest req = new HttpRequest();
                bilingAddress = EncodingUtil.urlEncode(bilingAddress,'UTF-8');
                req.setEndPoint('https://maps.googleapis.com/maps/api/geocode/json?address='+bilingAddress+'&sensor=true&key=AIzaSyDUFUmwW_2gaRCvIxBYZvS5o5vAq7N4Y6o');
                req.setMethod('GET');
                Http http = new Http();
                HttpResponse res;
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    geocodeBilling = (GeolocationResponseTemplate)JSON.deserialize(
                        res.getBody(),
                        GeolocationResponseTemplate.class);
                }
            }

            if (shippingAddress != null && shippingAddress != '') {
                HttpRequest req = new HttpRequest();
                shippingAddress = EncodingUtil.urlEncode(shippingAddress,'UTF-8');
                req.setEndPoint('https://maps.googleapis.com/maps/api/geocode/json?address='+shippingAddress+'&sensor=true&key=AIzaSyDUFUmwW_2gaRCvIxBYZvS5o5vAq7N4Y6o');
                req.setMethod('GET');
                Http http = new Http();
                HttpResponse res;
                res = http.send(req);
                if (res.getStatusCode() == 200) {
                    geocodeShipping = (GeolocationResponseTemplate)JSON.deserialize(
                        res.getBody(),
                        GeolocationResponseTemplate.class);
                }
            }
            Boolean attRecords = false;
            if (geocodeBilling.results != null) {
                Double lat  = geocodeBilling?.results[0]?.geometry?.location?.lat;
                Double lng = geocodeBilling?.results[0]?.geometry?.location?.lng;
                if (lat != null && lng != null) {
                    attRecords = true;
                    acc.BillingLatitude = lat;
                    acc.BillingLongitude = lng;
                }
            }

            if (geocodeShipping.results != null) {
                Double lat  = geocodeShipping?.results[0]?.geometry?.location?.lat;
                Double lng = geocodeShipping?.results[0]?.geometry?.location?.lng;
                if (lat != null && lng != null) {
                    attRecords = true;
                    acc.ShippingLatitude = lat;
                    acc.ShippingLongitude = lng;
                }
            }
            if (attRecords) {
                accountToUpdate.add(new Account(
                    Id = acc.Id,
                    ShippingLatitude = acc.ShippingLatitude,
                    ShippingLongitude= acc.ShippingLongitude,
                    BillingLatitude  = acc.BillingLatitude,
                    BillingLongitude = acc.BillingLongitude
                ));
            }
        }
        System.debug('@@@accountToUpdate ... ' + accountToUpdate);

        if (accountToUpdate.size() > 0) {
            update accountToUpdate;
        }
        
    }
    
    public void finish(Database.BatchableContext param1) {
        
    }
}