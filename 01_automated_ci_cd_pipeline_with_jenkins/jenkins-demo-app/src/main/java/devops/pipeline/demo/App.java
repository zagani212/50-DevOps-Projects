package devops.pipeline.demo;

/**
 * Entry point for runnable JAR (build / artifact steps).
 */
public final class App {

    private App() {
    }

    /**
     * @param args CLI args (optional name)
     */
    public static void main(String[] args) {
        MessageService service = new MessageService();
        String name = args.length > 0 ? args[0] : "Jenkins demo";
        System.out.println(service.greet(name));
    }
}
