@IsTest
public class GetGeolocationsBatchTest {
    @IsTest
    public static void main(){
        Account acc = TestFactory.createAccountClienteType();
        Test.setMock(HttpCalloutMock.class, new GetGeolocationsMock());

        Test.startTest();
             GetGeolocationsBatch.runEveryNMinutesInBusinessHours(6);
             GetGeolocationsBatch.cancelThisSchedule();
             Database.executeBatch(new GetGeolocationsBatch());
        Test.stopTest();
    }

    @IsTest
    public static void main2(){
        Account acc = TestFactory.createAccountClienteType();
        Test.setMock(HttpCalloutMock.class, new GetGeolocationsMock());

        Test.startTest();
             GetGeolocationsBatch.scheduleThisClass(null);
        Test.stopTest();
    }

    @IsTest
    public static void main3(){
        Account acc = TestFactory.createAccountClienteType();
        Test.setMock(HttpCalloutMock.class, new GetGeolocationsMock());

        Test.startTest();
             GetGeolocationsBatch.runEveryNMinutes(10);
             Database.executeBatch(new GetGeolocationsBatch());
        Test.stopTest();
    }

}