package system.events;

/**
 * Core Event interface for the SmartAgri Event System.
 * All domain events must implement this interface.
 *
 * Design: minimal contract — every event must declare what it is (type),
 * when it happened (timestamp), a human-readable label (description),
 * and optional actor/entity IDs for auditing.
 */
public interface Event {

    /** Event type constant, e.g. "LISTING_CREATED", "ORDER_CREATED" */
    String getType();

    /** Unix epoch millis when the event was created */
    long getTimestamp();

    /** Human-readable summary for admin display */
    String getDescription();

    /**
     * The user (farmer / buyer / system) who triggered this event.
     * May be null for system-generated events (e.g. scheduled crawler).
     */
    Integer getUserId();

    /**
     * The primary entity involved (ListingID, OrderID, etc.).
     * May be null for events with no single entity.
     */
    Integer getEntityId();
}
