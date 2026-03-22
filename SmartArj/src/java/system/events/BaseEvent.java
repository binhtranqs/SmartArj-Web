package system.events;

/**
 * Abstract base class for all domain events.
 *
 * Provides the common fields and UUID-based event ID so that
 * every concrete event only needs to implement getType() and supply
 * its domain-specific constructor data.
 */
public abstract class BaseEvent implements Event {

    /** Short random ID for log correlation (not a DB primary key) */
    private final String eventId;

    /** Unix epoch millis — set at construction time */
    private final long timestamp;

    private final Integer userId;
    private final Integer entityId;
    private final String description;

    /**
     * @param userId      ID of the user who triggered this event (nullable)
     * @param entityId    ID of the primary entity (ListingID / OrderID / etc., nullable)
     * @param description Human-readable summary for admin display
     */
    protected BaseEvent(Integer userId, Integer entityId, String description) {
        this.timestamp   = System.currentTimeMillis();
        this.eventId     = generateShortId();
        this.userId      = userId;
        this.entityId    = entityId;
        this.description = description;
    }

    // ──────────────────────────────────────────────────────────────
    // Event interface implementation
    // ──────────────────────────────────────────────────────────────

    @Override
    public long getTimestamp() {
        return timestamp;
    }

    @Override
    public Integer getUserId() {
        return userId;
    }

    @Override
    public Integer getEntityId() {
        return entityId;
    }

    @Override
    public String getDescription() {
        return description;
    }

    // ──────────────────────────────────────────────────────────────
    // Helpers
    // ──────────────────────────────────────────────────────────────

    public String getEventId() {
        return eventId;
    }

    /**
     * Converts timestamp to a LocalDateTime for display in JSP.
     */
    public java.time.LocalDateTime getLocalDateTime() {
        return java.time.Instant.ofEpochMilli(timestamp)
                .atZone(java.time.ZoneId.of("Asia/Ho_Chi_Minh"))
                .toLocalDateTime();
    }

    private static String generateShortId() {
        return java.util.UUID.randomUUID().toString().replace("-", "").substring(0, 8).toUpperCase();
    }

    @Override
    public String toString() {
        return "[" + getType() + "#" + eventId + "] " + description;
    }
}
