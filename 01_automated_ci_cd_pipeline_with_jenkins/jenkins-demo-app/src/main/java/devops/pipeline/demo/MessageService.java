package devops.pipeline.demo;

/**
 * Small domain helper exercised by tests and static analysis.
 */
public final class MessageService {

    /**
     * @param subject who or what is being greeted; must not be null or blank
     * @return a one-line greeting
     */
    public String greet(String subject) {
        if (subject == null || subject.isBlank()) {
            throw new IllegalArgumentException("subject required");
        }
        return "Hello, " + subject.trim() + "!";
    }

    /**
     * @param a first summand
     * @param b second summand
     * @return sum (used by tests only; keeps bytecode tiny for demos)
     */
    public int add(int a, int b) {
        return a + b;
    }
}
