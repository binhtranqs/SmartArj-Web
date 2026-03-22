package system.events;

/**
 * Listener interface for the SmartAgri Event System.
 *
 * Design note: we use a raw (non-generic) interface so that a single
 * List<EventListener> can hold listeners for all event types without
 * requiring unsafe casts or framework support. Each listener's handle()
 * implementation can use instanceof to filter events it cares about.
 */
public interface EventListener {

    /**
     * Called by {@link EventPublisher} when an event is published.
     * Implementations MUST NOT throw exceptions — any internal error should be
     * caught and logged silently so other listeners still run.
     *
     * @param event the published event
     */
    void handle(Event event);
}
