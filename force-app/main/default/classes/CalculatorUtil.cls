public class CalculatorUtil {
    public static Integer addNumbers(Integer a, Integer b) {
        // Handle null values safely
        if(a == null || b == null) {
            return 0;
        }
        return a + b;
    }
}
