package dao;

import jakarta.persistence.*;
import model.ChatLog;
import util.JPAUtil;

import java.util.List;

/**
 * DAO cho bảng ChatLogs
 */
public class ChatLogDAO {

    /** Ghi một chat log */
    public void create(ChatLog log) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(log);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            // Không throw – logging không được làm crash chatbot
            System.err.println("[ChatLogDAO] Lỗi ghi log: " + e.getMessage());
        } finally {
            em.close();
        }
    }

    /** Lấy N message gần nhất (cho admin page) */
    public List<ChatLog> findRecent(int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT c FROM ChatLog c ORDER BY c.createdAt DESC",
                    ChatLog.class)
                    .setMaxResults(limit)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** Top intents theo số lần xuất hiện (native query) */
    public List<Object[]> getTopIntents(int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createNativeQuery(
                    "SELECT TOP " + limit + " Intent, COUNT(*) AS Cnt " +
                            "FROM ChatLogs WHERE Intent IS NOT NULL " +
                            "GROUP BY Intent ORDER BY Cnt DESC")
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /** AI call rate: tổng, aiCalled, dbAnswer */
    public Object[] getStats() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return (Object[]) em.createNativeQuery(
                    "SELECT COUNT(*), SUM(CAST(AiCalled AS INT)), SUM(CAST(WasDbAnswer AS INT)), AVG(LatencyMs) " +
                            "FROM ChatLogs")
                    .getSingleResult();
        } catch (Exception e) {
            return new Object[] { 0, 0, 0, 0 };
        } finally {
            em.close();
        }
    }
    /** Lấy số tin nhắn hôm nay */
    public long getTodayMessageCount() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Number result = (Number) em.createNativeQuery(
                    "SELECT COUNT(*) FROM ChatLogs " +
                            "WHERE CreatedAt >= CAST(GETDATE() AS DATE) " +
                            "AND CreatedAt < CASt(DATEADD(day, 1, GETDATE()) AS DATE)")
                    .getSingleResult();
            return result != null ? result.longValue() : 0;
        } catch (Exception e) {
            return 0;
        } finally {
            em.close();
        }
    }

    /** Lấy số user tương tác hôm nay */
    public long getTodayActiveUsers() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Number result = (Number) em.createNativeQuery(
                    "SELECT COUNT(DISTINCT UserId) FROM ChatLogs " +
                            "WHERE CreatedAt >= CAST(GETDATE() AS DATE) " +
                            "AND CreatedAt < CAST(DATEADD(day, 1, GETDATE()) AS DATE)")
                    .getSingleResult();
            return result != null ? result.longValue() : 0;
        } catch (Exception e) {
            return 0;
        } finally {
            em.close();
        }
    }

    /** Lấy số lượng AI responses hôm nay */
    public long getTodayAiResponses() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Number result = (Number) em.createNativeQuery(
                    "SELECT COUNT(*) FROM ChatLogs " +
                            "WHERE CreatedAt >= CAST(GETDATE() AS DATE) " +
                            "AND CreatedAt < CAST(DATEADD(day, 1, GETDATE()) AS DATE) " +
                            "AND AiCalled = 1")
                    .getSingleResult();
            return result != null ? result.longValue() : 0;
        } catch (Exception e) {
            return 0;
        } finally {
            em.close();
        }
    }

    /**
     * Dữ liệu thống kê 7 ngày: số tin nhắn, số trả lời của AI
     * 
     * @return List Object[] với index 0 = log_date, 1 = total_msgs, 2 = ai_responses
     */
    public List<Object[]> getWeeklyChatActivity() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            // Đảm bảo lấy đúng mốc 0h của 6 ngày trước
            return em.createNativeQuery(
                    "SELECT " +
                            "  CAST(CreatedAt AS DATE) as log_date, " +
                            "  COUNT(*) as total_msgs, " +
                            "  SUM(CAST(AiCalled AS INT)) as ai_responses " +
                            "FROM ChatLogs " +
                            "WHERE CreatedAt >= CAST(DATEADD(day, -6, GETDATE()) AS DATE) " +
                            "  AND CreatedAt < CAST(DATEADD(day, 1, GETDATE()) AS DATE) " +
                            "GROUP BY CAST(CreatedAt AS DATE) " +
                            "ORDER BY log_date ASC")
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy danh sách các câu hỏi gần đây kèm tên User.
     * Index 0: Tên User, 1: Message, 2: Nguồn trả lời (AI?), 3: Thời gian
     */
    public List<Object[]> getRecentQuestionsWithUser(int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createNativeQuery(
                    "SELECT TOP " + limit + " " +
                            "  ISNULL(u.Username, N'Khách') as Username, " +
                            "  c.Message, " +
                            "  CASE WHEN c.AiCalled = 1 THEN 'AI' ELSE 'DB' END as Source, " +
                            "  c.CreatedAt " +
                            "FROM ChatLogs c " +
                            "LEFT JOIN Users u ON c.UserID = u.UserID " +
                            "WHERE c.Message IS NOT NULL " +
                            "ORDER BY c.CreatedAt DESC")
                    .getResultList();
        } finally {
            em.close();
        }
    }

    /**
     * Lấy Top câu hỏi phổ biến nhất trong ngày hôm nay.
     * Index 0: Message, 1: Số lần hỏi
     */
    public List<Object[]> getTopAskedQuestions(int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createNativeQuery(
                    "SELECT TOP " + limit + " " +
                            "  LTRIM(RTRIM(Message)) AS CleanMessage, " +
                            "  COUNT(*) AS Total " +
                            "FROM ChatLogs " +
                            "WHERE CreatedAt >= CAST(GETDATE() AS DATE) " +
                            "  AND CreatedAt < CASt(DATEADD(day, 1, GETDATE()) AS DATE) " +
                            "  AND Message IS NOT NULL " +
                            "  AND LTRIM(RTRIM(Message)) <> '' " +
                            "GROUP BY LTRIM(RTRIM(Message)) " +
                            "ORDER BY Total DESC")
                    .getResultList();
        } finally {
            em.close();
        }
    }
}
