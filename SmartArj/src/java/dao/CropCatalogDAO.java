package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import model.CropCatalog;
import util.JPAUtil;
import java.util.List;

public class CropCatalogDAO {

    public List<CropCatalog> findAllCatalog() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT c FROM CropCatalog c ORDER BY c.category, c.cropName", CropCatalog.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<CropCatalog> findByCategory(String category) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em
                    .createQuery("SELECT c FROM CropCatalog c WHERE c.category = :cat ORDER BY c.cropName",
                            CropCatalog.class)
                    .setParameter("cat", category)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public CropCatalog findById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(CropCatalog.class, id);
        } finally {
            em.close();
        }
    }

    public boolean addCropCatalog(CropCatalog catalog) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(catalog);
            tx.commit();
            return true;
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            e.printStackTrace();
            return false;
        } finally {
            em.close();
        }
    }
}
