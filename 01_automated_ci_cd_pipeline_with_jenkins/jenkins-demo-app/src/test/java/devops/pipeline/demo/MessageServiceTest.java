package devops.pipeline.demo;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

import org.junit.jupiter.api.Test;

class MessageServiceTest {

    private final MessageService service = new MessageService();

    @Test
    void greetTrimsWhitespace() {
        assertEquals("Hello, world!", service.greet("  world  "));
    }

    @Test
    void greetRejectsBlank() {
        assertThrows(IllegalArgumentException.class, () -> service.greet(" "));
    }

    @Test
    void addSumsInts() {
        assertEquals(3, service.add(1, 2));
    }
}
