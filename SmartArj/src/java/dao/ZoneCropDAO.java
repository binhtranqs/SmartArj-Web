package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import model.ZoneCrop;
import util.JPAUtil;
import java.util.List;

public class ZoneCropDAO {

    public List<ZoneCrop> findByZoneId(int zoneId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT zc FROM ZoneCrop zc JOIN FETCH zc.cropCatalog WHERE zc.zoneId = :zoneId ORDER BY zc.createdAt DESC",
                    ZoneCrop.class)
                    .setParameter("zoneId", zoneId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public List<ZoneCrop> findByOwner(int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT zc FROM ZoneCrop zc JOIN FETCH zc.cropCatalog WHERE zc.zoneId IN (SELECT z.zoneId FROM Zone z WHERE z.ownerId = :ownerId) ORDER BY zc.createdAt DESC",
                    ZoneCrop.class)
                    .setParameter("ownerId", ownerId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public boolean assignCrop(ZoneCrop zoneCrop) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            Long count = em.createQuery(
                    "SELECT COUNT(zc) FROM ZoneCrop zc WHERE zc.zoneId = :zoneId AND zc.cropCatalog.cropCatalogId = :catalogId",
                    Long.class)
                    .setParameter("zoneId", zoneCrop.getZoneId())
                    .setParameter("catalogId", zoneCrop.getCropCatalog().getCropCatalogId())
                    .getSingleResult();

            if (count != null && count > 0)
                return false;

            tx.begin();
            em.persist(zoneCrop);
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

    public boolean removeCrop(int zoneCropId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            ZoneCrop zc = em.find(ZoneCrop.class, zoneCropId);
            if (zc != null) {
                em.remove(zc);
                tx.commit();
                return true;
            }
            return false;
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
