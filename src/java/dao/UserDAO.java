package dao;

import jakarta.persistence.*;
import model.User;
import util.JPAUtil;
import util.PasswordUtil;

import java.time.LocalDateTime;
import java.util.List;

/**
 * DAO để thao tác với bảng Users
 */
public class UserDAO {

    /**
     * Tìm user theo username
     */
    public User findByUsername(String username) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                    "SELECT u FROM User u WHERE u.username = :username",
                    User.class);
            query.setParameter("username", username);
            List<User> results = query.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm user theo email
     */
    public User findByEmail(String email) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            TypedQuery<User> query = em.createQuery(
                    "SELECT u FROM User u WHERE u.email = :email",
                    User.class);
            query.setParameter("email", email);
            List<User> results = query.getResultList();
            return results.isEmpty() ? null : results.get(0);
        } finally {
            em.close();
        }
    }

    /**
     * Tìm user theo ID
     */
    public User findById(Integer userId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(User.class, userId);
        } finally {
            em.close();
        }
    }

    /**
     * Tạo user mới
     */
    public void create(User user) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = null;
        try {
            tx = em.getTransaction();
            tx.begin();
            em.persist(user);
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi tạo user: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Cập nhật user
     */
    public void update(User user) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = null;
        try {
            tx = em.getTransaction();
            tx.begin();
            em.merge(user);
            tx.commit();
        } catch (Exception e) {
            if (tx != null && tx.isActive()) {
                tx.rollback();
            }
            throw new RuntimeException("Lỗi khi cập nhật user: " + e.getMessage(), e);
        } finally {
            em.close();
        }
    }

    /**
     * Kiểm tra đăng nhập
     * 
     * @return User nếu đúng, null nếu sai
     */
    public User checkLogin(String username, String plainPassword) {
        User user = findByUsername(username);
        if (user == null) {
            return null;
        }

        // Kiểm tra mật khẩu
        if (PasswordUtil.checkPassword(plainPassword, user.getPasswordHash())) {
            // ✅ Nếu user còn dùng hash legacy (SHA-256), tự động migrate sang BCrypt
            // để "fix triệt để" bảo mật mà không làm mất tài khoản demo.
            if (user.getPasswordHash() != null && !user.getPasswordHash().startsWith("$2a$")) {
                user.setPasswordHash(PasswordUtil.hashPassword(plainPassword));
            }

            // Cập nhật last login
            user.setLastLogin(LocalDateTime.now());
            update(user);

            // IMPORTANT: Return fresh user from DB to avoid detached entity issues
            return findById(user.getUserId());
        }

        return null;
    }

    /**
     * Kiểm tra username đã tồn tại chưa
     */
    public boolean usernameExists(String username) {
        return findByUsername(username) != null;
    }

    /**
     * Kiểm tra email đã tồn tại chưa
     */
    public boolean emailExists(String email) {
        return findByEmail(email) != null;
    }

    /**
     * Lấy tất cả users (cho admin)
     */
    public List<User> findAll() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT u FROM User u ORDER BY u.createdAt DESC", User.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Đếm số lượng VIP users
     */
    public long countVIPUsers() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT COUNT(u) FROM User u WHERE u.accountType = 'VIP' AND u.vipExpiryDate > :now",
                    Long.class)
                    .setParameter("now", LocalDateTime.now())
                    .getSingleResult();
        } finally {
            em.close();
        }
    }
}
