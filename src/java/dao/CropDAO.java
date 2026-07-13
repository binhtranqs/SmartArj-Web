package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import java.util.List;
import model.Crop;
import util.JPAUtil;

public class CropDAO {

    public List<Crop> findAllByOwner(int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM Crop c JOIN FETCH c.zone z WHERE z.ownerId = :oid ORDER BY c.cropId",
                    Crop.class)
                    .setParameter("oid", ownerId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public Crop findByIdAndOwner(int cropId, int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Crop> list = em.createQuery(
                    "SELECT c FROM Crop c JOIN FETCH c.zone z WHERE c.cropId = :cid AND z.ownerId = :oid",
                    Crop.class)
                    .setParameter("cid", cropId)
                    .setParameter("oid", ownerId)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    public List<Crop> findAll() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM Crop c JOIN FETCH c.zone ORDER BY c.cropId",
                    Crop.class
            ).getResultList();
        } finally {
            em.close();
        }
    }

    public Crop findById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(Crop.class, id);
        } finally {
            em.close();
        }
    }

    public void create(Crop crop) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(crop);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void update(Crop crop) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(crop);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void delete(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Crop c = em.find(Crop.class, id);
            if (c != null) em.remove(c);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void deleteByIdAndOwner(int id, int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Crop c = em.createQuery(
                    "SELECT c FROM Crop c JOIN c.zone z WHERE c.cropId = :cid AND z.ownerId = :oid",
                    Crop.class)
                    .setParameter("cid", id)
                    .setParameter("oid", ownerId)
                    .getResultStream()
                    .findFirst()
                    .orElse(null);
            if (c != null) em.remove(c);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
    public Crop findLatestByZoneId(int zoneId) {
    EntityManager em = JPAUtil.getEntityManager();
    try {
        List<Crop> list = em.createQuery(
                "SELECT c FROM Crop c JOIN FETCH c.zone z " +
                "WHERE z.zoneId = :zid ORDER BY c.cropId DESC",
                Crop.class
        ).setParameter("zid", zoneId)
         .setMaxResults(1)
         .getResultList();

        return list.isEmpty() ? null : list.get(0);
    } finally {
        em.close();
    }
}
}
