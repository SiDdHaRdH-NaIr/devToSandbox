@IsTest
public class CalculatorUtil_Test {

    @IsTest
    static void testAddNumbers_Normal() {
        Integer result = CalculatorUtil.addNumbers(5, 10);
        System.assertEquals(15, result);
    }

    @IsTest
    static void testAddNumbers_WithNulls() {
        Integer result = CalculatorUtil.addNumbers(null, 10);
        System.assertEquals(0, result);

        // second scenario: both null
        Integer result2 = CalculatorUtil.addNumbers(null, null);
        System.assertEquals(0, result2);
    }
}
