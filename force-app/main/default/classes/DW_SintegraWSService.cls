/**
 * Created by Guilherme Reis on 02/02/2021.
 */

public with sharing class DW_SintegraWSService {

    Map<String, Apis__mdt> apiInfoMap = new Map<String, Apis__mdt>();

    public static DW_SintegraWSServiceRFTemplateResponse getReceita(String cnpj, String type){//type opções RF, SN ou ST
        cnpj = cnpj.replaceAll('[^0-9]', '');
        DW_SintegraWSService self = new DW_SintegraWSService();
        DW_RequestFactory requestFactory = DW_RequestFactory.makeGet(self.getApiInfo('SintegraWSRF').URL__c)
                .addQueryParameter('token', self.getApiInfo('SintegraWSRF').Token__c)
                .addQueryParameter('cnpj', cnpj)
                .addQueryParameter('plugin', type)
                .send();

        if(requestFactory.getResponse().getStatusCode() == 200){
            return (DW_SintegraWSServiceRFTemplateResponse)JSON.deserialize(requestFactory.getResponse().getBody(), DW_SintegraWSServiceRFTemplateResponse.class);
        }
        return new DW_SintegraWSServiceRFTemplateResponse();
    }

    public static DW_SintegraWSServiceSFTemplateResponse getSuframa(String cnpj, String type){//type opções RF, SN ou ST
        cnpj = cnpj.replaceAll('[^0-9]', '');
        DW_SintegraWSService self = new DW_SintegraWSService();
        DW_RequestFactory requestFactory = DW_RequestFactory.makeGet(self.getApiInfo('SintegraWSRF').URL__c)
                .addQueryParameter('token', self.getApiInfo('SintegraWSRF').Token__c)
                .addQueryParameter('cnpj', cnpj)
                .addQueryParameter('plugin', type)
                .send();
        if(requestFactory.getResponse().getStatusCode() == 200){
            System.debug(LoggingLevel.INFO, 'DW_SintegraWSService@getSuframa -> :requestFactory.getResponse().getBody() ' + requestFactory.getResponse().getBody());

            return (DW_SintegraWSServiceSFTemplateResponse)JSON.deserialize(requestFactory.getResponse().getBody(), DW_SintegraWSServiceSFTemplateResponse.class);

        }
        return new DW_SintegraWSServiceSFTemplateResponse();

    }

    public static DW_SintegraWSServiceSNTemplateResponse getSimples(String cnpj, String type){//type opções RF, SN ou ST
        cnpj = cnpj.replaceAll('[^0-9]', '');
        DW_SintegraWSService self = new DW_SintegraWSService();
        DW_RequestFactory requestFactory = DW_RequestFactory.makeGet(self.getApiInfo('SintegraWSRF').URL__c)
                .addQueryParameter('token', self.getApiInfo('SintegraWSRF').Token__c)
                .addQueryParameter('cnpj', cnpj)
                .addQueryParameter('plugin', type)
                .send();
        if(requestFactory.getResponse().getStatusCode() == 200){
            return (DW_SintegraWSServiceSNTemplateResponse)JSON.deserialize(requestFactory.getResponse().getBody(), DW_SintegraWSServiceSNTemplateResponse.class);

        }
        return new DW_SintegraWSServiceSNTemplateResponse();

    }

    public static DW_SintegraWSServiceSTTemplateResponse getSintegra(String cnpj, String type){//type opções RF, SN ou ST
        cnpj = cnpj.replaceAll('[^0-9]', '');
        DW_SintegraWSService self = new DW_SintegraWSService();
        DW_RequestFactory requestFactory = DW_RequestFactory.makeGet(self.getApiInfo('SintegraWSRF').URL__c)
                .addQueryParameter('token', self.getApiInfo('SintegraWSRF').Token__c)
                .addQueryParameter('cnpj', cnpj)
                .addQueryParameter('plugin', type)
                .send();
        if(requestFactory.getResponse().getStatusCode() == 200){
            return (DW_SintegraWSServiceSTTemplateResponse)JSON.deserialize(requestFactory.getResponse().getBody(), DW_SintegraWSServiceSTTemplateResponse.class);

        }
        return new DW_SintegraWSServiceSTTemplateResponse();

    }

    private Apis__mdt getApiInfo(String key){
        if (!apiInfoMap.containsKey(key)) {
            apiInfoMap.put(key,
            [
                    SELECT Token__c, URL__c
                    FROM Apis__mdt
                    WHERE DeveloperName = :key
            ]
            );
        }
        return apiInfoMap.get(key);
    }
}