package dao;

import jakarta.persistence.*;
import model.VipRequest;
import util.JPAUtil;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DAO cho bảng VipRequests
 */
public class VipRequestDAO {

    /** Tạo yêu cầu VIP mới */
    public void create(VipRequest req) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(req);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw new RuntimeException("Lỗi tạo VIP request: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /** Lấy tất cả PENDING requests */
    public List<VipRequest> findPending() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT r FROM VipRequest r WHERE r.status = 'PENDING' ORDER BY r.createdAt ASC",
                    VipRequest.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Lấy theo UserID */
    public List<VipRequest> findByUser(Integer userId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT r FROM VipRequest r WHERE r.userId = :uid ORDER BY r.createdAt DESC",
                    VipRequest.class)
                    .setParameter("uid", userId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Approve: cập nhật status + reviewer */
    public VipRequest approve(Integer requestId, Integer reviewerId, String reviewNote) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            VipRequest req = em.find(VipRequest.class, requestId);
            if (req == null)
                throw new RuntimeException("Request không tồn tại");
            req.setStatus("APPROVED");
            req.setReviewedBy(reviewerId);
            req.setReviewedAt(LocalDateTime.now());
            req.setReviewNote(reviewNote);
            tx.commit();
            return req;
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw new RuntimeException("Lỗi approve: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /** Reject: cập nhật status + reviewer */
    public void reject(Integer requestId, Integer reviewerId, String reviewNote) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            VipRequest req = em.find(VipRequest.class, requestId);
            if (req == null)
                throw new RuntimeException("Request không tồn tại");
            req.setStatus("REJECTED");
            req.setReviewedBy(reviewerId);
            req.setReviewedAt(LocalDateTime.now());
            req.setReviewNote(reviewNote);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw new RuntimeException("Lỗi reject: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /** Đếm số PENDING */
    public long countPending() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT COUNT(r) FROM VipRequest r WHERE r.status = 'PENDING'", Long.class)
                    .getSingleResult();
        } finally {
            em.close();
        }
    }
}
