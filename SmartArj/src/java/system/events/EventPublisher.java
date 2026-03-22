package system.events;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.logging.Logger;

/**
 * Central event bus for the SmartAgri Event System.
 *
 * Design decisions:
 * - Static singleton: no DI container, works with plain Servlet architecture.
 * - CopyOnWriteArrayList: registrations happen once at app startup
 *   (via AppStartupListener), reads happen on every servlet request thread —
 *   ideal read-heavy scenario for CoW semantics.
 * - Fire-and-forget: each listener runs synchronously but exceptions are
 *   isolated per-listener so one bad listener never blocks others.
 *
 * Usage:
 *   // At startup:
 *   EventPublisher.registerListener(new LogEventListener());
 *
 *   // In service layer:
 *   EventPublisher.publish(new ListingCreatedEvent(...));
 */
public final class EventPublisher {

    private static final Logger log = Logger.getLogger(EventPublisher.class.getName());

    /** Thread-safe listener registry */
    private static final List<EventListener> LISTENERS = new CopyOnWriteArrayList<>();

    /** Utility class — prevent instantiation */
    private EventPublisher() {}

    /**
     * Register a listener. Typically called once during application startup.
     *
     * @param listener the listener to register
     */
    public static void registerListener(EventListener listener) {
        if (listener == null) return;
        LISTENERS.add(listener);
        log.fine("[EventPublisher] Registered listener: " + listener.getClass().getSimpleName());
    }

    /**
     * Publish an event to all registered listeners.
     * Each listener is invoked synchronously in registration order.
     * Exceptions from individual listeners are caught and logged — they never
     * propagate to the caller or affect other listeners.
     *
     * @param event the event to publish
     */
    public static void publish(Event event) {
        if (event == null) return;
        log.fine("[EventPublisher] Publishing: " + event.getType() + " — " + event.getDescription());

        for (EventListener listener : LISTENERS) {
            try {
                listener.handle(event);
            } catch (Exception e) {
                // Isolate listener failures — never let them break the caller
                log.warning("[EventPublisher] Listener "
                        + listener.getClass().getSimpleName()
                        + " failed on event " + event.getType()
                        + ": " + e.getMessage());
            }
        }
    }

    /**
     * Returns the number of registered listeners (useful for health checks / tests).
     */
    public static int listenerCount() {
        return LISTENERS.size();
    }

    /**
     * Clears all listeners. Intended for testing only.
     */
    static void clearListeners() {
        LISTENERS.clear();
    }
}
