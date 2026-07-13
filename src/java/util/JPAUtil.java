package util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;
import java.util.HashMap;
import java.util.Map;

public class JPAUtil {

    private static EntityManagerFactory emf;

    static {
        try {
            emf = Persistence.createEntityManagerFactory("SmartAgriPU", buildOverrides());
        } catch (Throwable t) {
            System.err.println("❌ Failed to init EntityManagerFactory (SmartAgriPU).");
            t.printStackTrace();
            throw new ExceptionInInitializerError(t);
        }
    }

    public static EntityManager getEntityManager() {
        return emf.createEntityManager();
    }

    public static void shutdown() {
        if (emf != null && emf.isOpen()) emf.close();
    }

    private static Map<String, String> buildOverrides() {
        Map<String, String> props = new HashMap<String, String>();
        putIfPresent(props, "jakarta.persistence.jdbc.url", "SMARTARJ_DB_URL");
        putIfPresent(props, "jakarta.persistence.jdbc.user", "SMARTARJ_DB_USER");
        putIfPresent(props, "jakarta.persistence.jdbc.password", "SMARTARJ_DB_PASSWORD");
        return props;
    }

    private static void putIfPresent(Map<String, String> props, String propertyName, String envName) {
        String value = System.getProperty(envName);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(envName);
        }
        if (value != null && !value.trim().isEmpty()) {
            props.put(propertyName, value);
        }
    }
}
