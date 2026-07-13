package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.persistence.Query;
import util.JPAUtil;

import java.sql.Date;

/**
 * DAO for Forecasts table (SQL Server).
 * Upsert by (ZoneID, ForecastDate).
 */
public class ForecastDAO {

    /**
     * Upsert a single forecast row.
     * @param zoneId ZoneID
     * @param forecastDate yyyy-MM-dd (java.sql.Date)
     * @param temperature Celsius
     */
    public void upsertTemperature(int zoneId, Date forecastDate, Double temperature) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();

            // MERGE for SQL Server
            String sql =
                    "MERGE Forecasts AS target " +
                    "USING (SELECT ? AS ZoneID, ? AS ForecastDate) AS src " +
                    "ON (target.ZoneID = src.ZoneID AND target.ForecastDate = src.ForecastDate) " +
                    "WHEN MATCHED THEN " +
                    "  UPDATE SET Temperature = ?, CreatedAt = GETDATE() " +
                    "WHEN NOT MATCHED THEN " +
                    "  INSERT (ZoneID, ForecastDate, Temperature, CreatedAt) VALUES (?, ?, ?, GETDATE());";

            Query q = em.createNativeQuery(sql);
            q.setParameter(1, zoneId);
            q.setParameter(2, forecastDate);
            q.setParameter(3, temperature);
            q.setParameter(4, zoneId);
            q.setParameter(5, forecastDate);
            q.setParameter(6, temperature);

            q.executeUpdate();
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    /**
     * Delete forecast rows older than N days (optional maintenance).
     */
    public int deleteOlderThanDays(int days) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            String sql = "DELETE FROM Forecasts WHERE ForecastDate < DATEADD(day, -?, CAST(GETDATE() AS date))";
            Query q = em.createNativeQuery(sql);
            q.setParameter(1, days);
            int n = q.executeUpdate();
            tx.commit();
            return n;
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }
}
