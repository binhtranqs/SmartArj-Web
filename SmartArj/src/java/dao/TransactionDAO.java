package dao;

import jakarta.persistence.*;
import model.Transaction;
import model.User;
import util.JPAUtil;

import java.util.List;

/**
 * DAO để thao tác với bảng Transactions
 */
public class TransactionDAO {

    /**
     * Tạo transaction mới
     */
    public void create(Transaction transaction) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = null;
        try {
            tx = em.getTransaction();
            tx.begin();
            em.persist(transaction);
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi tạo transaction: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Cập nhật transaction
     */
    public void update(Transaction transaction) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = null;
        try {
            tx = em.getTransaction();
            tx.begin();
            em.merge(transaction);
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật transaction: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm transaction theo ID
     */
    public Transaction findById(Integer transactionId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(Transaction.class, transactionId);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm transaction theo mã tham chiếu provider (VD: VNPay TxnRef)
     */
    public Transaction findByProviderTxnRef(String providerTxnRef) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Transaction> results = em.createQuery(
                    "SELECT t FROM Transaction t WHERE t.providerTxnRef = :providerTxnRef",
                    Transaction.class)
                    .setParameter("providerTxnRef", providerTxnRef)
                    .setMaxResults(1)
                    .getResultList();
            return results.isEmpty() ? null : results.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Lấy tất cả transactions của một user
     */
    public List<Transaction> findByUser(User user) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT t FROM Transaction t WHERE t.user = :user ORDER BY t.transactionDate DESC",
                    Transaction.class)
                    .setParameter("user", user)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy transactions thành công của user
     */
    public List<Transaction> findCompletedByUser(User user) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT t FROM Transaction t WHERE t.user = :user AND t.status = 'COMPLETED' ORDER BY t.transactionDate DESC",
                    Transaction.class)
                    .setParameter("user", user)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy tất cả transactions (cho admin)
     */
    public List<Transaction> findAll() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT t FROM Transaction t ORDER BY t.transactionDate DESC",
                    Transaction.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Tính tổng doanh thu
     */
    public Double getTotalRevenue() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Double result = em.createQuery(
                    "SELECT SUM(t.amount) FROM Transaction t WHERE t.status = 'COMPLETED'",
                    Double.class)
                    .getSingleResult();
            return result != null ? result : 0.0;
        } finally {
            em.close();
        }
    }
}
