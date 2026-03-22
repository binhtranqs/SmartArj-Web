package system.listeners;

import dao.SystemEventDAO;
import system.events.Event;
import system.events.EventListener;

import java.util.logging.Logger;

/**
 * Listener that persists every published event into the SystemEvents DB table.
 *
 * This is the most critical listener — it provides the durable audit trail
 * that the Admin Events dashboard reads from.
 *
 * Contract: handle() must NEVER throw. All exceptions are caught internally
 * so that other listeners and the calling service are never affected.
 */
public class LogEventListener implements EventListener {

    private static final Logger log = Logger.getLogger(LogEventListener.class.getName());

    private final SystemEventDAO dao = new SystemEventDAO();

    @Override
    public void handle(Event event) {
        try {
            dao.insertEvent(
                    event.getType(),
                    event.getUserId(),
                    event.getEntityId(),
                    event.getDescription()
            );
            log.fine("[LogEventListener] Saved event: " + event.getType());
        } catch (Exception e) {
            // Log but never rethrow — the DB write is best-effort
            log.warning("[LogEventListener] Could not persist event "
                    + event.getType() + ": " + e.getMessage());
        }
    }
}
