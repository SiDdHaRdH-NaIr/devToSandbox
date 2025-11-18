@IsTest
public class ApexHelloTest {

    @IsTest
    static void testHelloSalesforce() {
        // Call method
        String result = ApexHello.helloSalesforce('Hello', 'Salesforce');

        // Validate result
        System.assertEquals('Hello Salesforce', result, 'The concatenated string did not match.');
    }

    @IsTest
    static void testAddNum() {
        // Call method
        Integer sum = ApexHello.addNum(5, 7);

        // Validate result
        System.assertEquals(12, sum, 'The sum returned by addNum is incorrect.');
    }
}