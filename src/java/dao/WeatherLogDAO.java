package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.TypedQuery;
import model.WeatherLog;
import util.JPAUtil;

import java.util.List;

public class WeatherLogDAO {

    public List<WeatherLog> findLatestByZone(int zoneId, int limit) {
    EntityManager em = JPAUtil.getEntityManager();
    try {
        // 1) Lấy mới nhất trước để đúng "gần hôm nay"
        TypedQuery<WeatherLog> q = em.createQuery(
                "SELECT w FROM WeatherLog w " +
                "JOIN FETCH w.zone z " +
                "WHERE z.zoneId = :zid " +
                "ORDER BY w.recordedAt DESC",
                WeatherLog.class
        );
        q.setParameter("zid", zoneId);
        q.setMaxResults(limit);
        List<WeatherLog> list = q.getResultList();

        // 2) Vì chart thường vẽ theo thời gian tăng dần,
        // nếu muốn vẽ từ cũ->mới thì đảo list lại.
        java.util.Collections.reverse(list);

        return list;
    } finally {
        em.close();
    }
}

    /**
     * Lấy lịch sử WeatherLogs theo số ngày gần nhất (ASC để vẽ chart đúng thứ tự).
     */
    public List<WeatherLog> findHistoryByZoneDays(int zoneId, int days, int limit) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            java.util.Calendar cal = java.util.Calendar.getInstance();
            cal.add(java.util.Calendar.DAY_OF_YEAR, -Math.max(days, 1));
            java.util.Date from = cal.getTime();

            TypedQuery<WeatherLog> q = em.createQuery(
                    "SELECT w FROM WeatherLog w JOIN FETCH w.zone z " +
                    "WHERE z.zoneId = :zid AND w.recordedAt >= :from " +
                    "ORDER BY w.recordedAt ASC",
                    WeatherLog.class);
            q.setParameter("zid", zoneId);
            q.setParameter("from", from);
            if (limit > 0) q.setMaxResults(limit);
            return q.getResultList();
        } finally {
            em.close();
        }
    }
}
