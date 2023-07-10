/**
 * Created by Guilherme Reis on 02/02/2021.
 */

@IsTest
public with sharing class DW_SintegraWSServiceFlowTest {
    @IsTest
    public static void testRF(){ 
        Test.setMock(HttpCalloutMock.class, new DW_SintegraWSServiceFlowMock());
        DW_ForceErrorSingleton.getInstance().forceError = false;
        List<DW_SintegraWSServiceFlowRF.Response> responseService = DW_SintegraWSServiceFlowRF.get(new List<DW_SintegraWSServiceFlowRF.Request>{
                new DW_SintegraWSServiceFlowRF.Request('92794437000162')
        });
        //System.assertEquals('Daspe Web', responseService.get(0).fantasia);
//        System.assertEquals('Pesquisa realizada com sucesso.', responseService.get(0).message);

        DW_ForceErrorSingleton.getInstance().forceError = true;
        List<DW_SintegraWSServiceFlowRF.Response> responseService2 = DW_SintegraWSServiceFlowRF.get(new List<DW_SintegraWSServiceFlowRF.Request>{
                new DW_SintegraWSServiceFlowRF.Request('92794437000162')
        });
//        System.assertEquals(null, responseService2.get(0).fantasia);
//        System.assertEquals(null, responseService2.get(0).message);
    }

    @IsTest
    public static void testSN(){
        Test.setMock(HttpCalloutMock.class, new DW_SintegraWSServiceFlowMock());
        DW_ForceErrorSingleton.getInstance().forceError = false;
        List<DW_SintegraWSServiceFlowSN.Response> responseService = DW_SintegraWSServiceFlowSN.get(new List<DW_SintegraWSServiceFlowSN.Request>{
                new DW_SintegraWSServiceFlowSN.Request('92794437000162')
        });
//        System.assertEquals('Daspe Web 2', responseService.get(0).nome_empresarial);
//        System.assertEquals('Pesquisa realizada com sucesso.', responseService.get(0).message);

        DW_ForceErrorSingleton.getInstance().forceError = true;
        List<DW_SintegraWSServiceFlowSN.Response> responseService2 = DW_SintegraWSServiceFlowSN.get(new List<DW_SintegraWSServiceFlowSN.Request>{
                new DW_SintegraWSServiceFlowSN.Request('92794437000162')
        });
//        System.assertEquals(null, responseService2.get(0).nome_empresarial);
//        System.assertEquals(null, responseService2.get(0).message);
    }

    @IsTest
    public static void testSintegra(){
        Test.setMock(HttpCalloutMock.class, new DW_SintegraWSServiceFlowMock());
        DW_ForceErrorSingleton.getInstance().forceError = false;
        List<DW_SintegraWSServiceFlowSintegra.Response> responseService = DW_SintegraWSServiceFlowSintegra.get(new List<DW_SintegraWSServiceFlowSintegra.Request>{
                new DW_SintegraWSServiceFlowSintegra.Request('92794437000162')
        });
//        System.assertEquals('123456789ins', responseService.get(0).inscricao_estadual);
//        System.assertEquals('Pesquisa realizada com sucesso.', responseService.get(0).message);

        DW_ForceErrorSingleton.getInstance().forceError = true;
        List<DW_SintegraWSServiceFlowSintegra.Response> responseService2 = DW_SintegraWSServiceFlowSintegra.get(new List<DW_SintegraWSServiceFlowSintegra.Request>{
                new DW_SintegraWSServiceFlowSintegra.Request('92794437000162')
        });
//        System.assertEquals(null, responseService2.get(0).inscricao_estadual);
//        System.assertEquals(null, responseService2.get(0).message);
    }
    @IsTest
    public static void testSuframa(){
        Test.setMock(HttpCalloutMock.class, new DW_SintegraWSServiceFlowMock());
        DW_ForceErrorSingleton.getInstance().forceError = false;
        List<DW_SintegraWSServiceFlowSuframa.Response> responseService = DW_SintegraWSServiceFlowSuframa.get(new List<DW_SintegraWSServiceFlowSuframa.Request>{
                new DW_SintegraWSServiceFlowSuframa.Request('92794437000162')
        });


        DW_ForceErrorSingleton.getInstance().forceError = true;
        List<DW_SintegraWSServiceFlowSuframa.Response> responseService2 = DW_SintegraWSServiceFlowSuframa.get(new List<DW_SintegraWSServiceFlowSuframa.Request>{
                new DW_SintegraWSServiceFlowSuframa.Request('92794437000162')
        });
//        System.assertEquals(null, responseService2.get(0).inscricao_estadual);
//        System.assertEquals(null, responseService2.get(0).message);
    }
}