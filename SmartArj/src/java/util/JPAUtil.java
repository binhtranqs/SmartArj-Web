package util;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityManagerFactory;
import jakarta.persistence.Persistence;

public class JPAUtil {

    private static EntityManagerFactory emf;

    static {
        try {
            emf = Persistence.createEntityManagerFactory("SmartAgriPU");
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
}
