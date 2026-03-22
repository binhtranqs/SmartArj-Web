package scheduler;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import service.AlertService;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

@WebListener
public class AlertScheduler implements ServletContextListener {

    private ScheduledExecutorService scheduler;

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AlertScheduler] Starting background alert check task...");
        scheduler = Executors.newSingleThreadScheduledExecutor();

        final AlertService alertService = new AlertService();
        // Run every 60 seconds, starting after 10 seconds
        scheduler.scheduleAtFixedRate(new AlertCheckTask(alertService), 10, 60, TimeUnit.SECONDS);
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AlertScheduler] Stopping background alert check task...");
        if (scheduler != null) {
            scheduler.shutdown();
        }
    }

    private static final class AlertCheckTask implements Runnable {
        private final AlertService alertService;

        private AlertCheckTask(AlertService alertService) {
            this.alertService = alertService;
        }

        @Override
        public void run() {
            try {
                System.out.println("[AlertScheduler] Running automatic alert check...");
                alertService.checkAndGenerateAlerts();
            } catch (Exception e) {
                System.err.println("[AlertScheduler] Error in alert check task:");
                e.printStackTrace();
            }
        }
    }
}
