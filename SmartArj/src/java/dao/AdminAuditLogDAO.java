package dao;

import jakarta.persistence.*;
import model.AdminAuditLog;
import util.JPAUtil;

import java.util.List;

/**
 * DAO cho bảng AdminAuditLog
 */
public class AdminAuditLogDAO {

    /** Ghi một hành động vào log */
    public void create(AdminAuditLog log) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(log);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw new RuntimeException("Lỗi ghi audit log: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /** Tiện ích: tạo và ghi log trong 1 bước */
    public void log(Integer adminId, Integer targetUserId, String action, String note) {
        AdminAuditLog entry = new AdminAuditLog(adminId, targetUserId, action, note);
        create(entry);
    }

    /** Lấy N log gần nhất (cho dashboard) */
    public List<AdminAuditLog> findRecent(int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM AdminAuditLog a ORDER BY a.createdAt DESC",
                    AdminAuditLog.class)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Lấy log theo user mục tiêu */
    public List<AdminAuditLog> findByTargetUser(Integer targetUserId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM AdminAuditLog a WHERE a.targetUserId = :uid ORDER BY a.createdAt DESC",
                    AdminAuditLog.class)
                    .setParameter("uid", targetUserId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Lấy log theo action type */
    public List<AdminAuditLog> findByAction(String action, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT a FROM AdminAuditLog a WHERE a.action = :action ORDER BY a.createdAt DESC",
                    AdminAuditLog.class)
                    .setParameter("action", action)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
