@IsTest
public class MySimpleClass_Test {

    @IsTest
    static void testWithName() {
        // Test with valid value
        String result = MySimpleClass.getGreeting('Siddharth');
        System.assertEquals('Hello, Siddharth!', result);
    }

    @IsTest
    static void testWithBlankName() {
        // Test with blank value
        String result = MySimpleClass.getGreeting('');
        System.assertEquals('Hello, Guest!', result);
    }
}
