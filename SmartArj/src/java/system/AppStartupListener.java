package system;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import system.events.EventPublisher;
import system.listeners.LogEventListener;

import java.util.logging.Logger;

/**
 * Application startup listener that registers all Event listeners with
 * the EventPublisher exactly once when the webapp is deployed.
 *
 * Uses the same @WebListener mechanism as CrawlerScheduler, which is
 * already proven to work in this project.
 *
 * Execution order: Servlet container calls all @WebListeners during
 * contextInitialized in declaration/annotation order before any HTTP
 * requests are served — so listeners are guaranteed to be ready.
 */
@WebListener
public class AppStartupListener implements ServletContextListener {

    private static final Logger log = Logger.getLogger(AppStartupListener.class.getName());

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        log.info("[AppStartupListener] Initializing SmartAgri Event System...");

        // Register the DB persistence listener (writes every event to SystemEvents table)
        EventPublisher.registerListener(new LogEventListener());

        log.info("[AppStartupListener] Event system ready. Listeners registered: "
                + EventPublisher.listenerCount());
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        // EventPublisher uses no resources that need cleanup
        log.info("[AppStartupListener] Application shutting down.");
    }
}
