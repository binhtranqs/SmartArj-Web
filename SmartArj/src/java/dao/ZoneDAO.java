package dao;

import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import model.Zone;
import util.JPAUtil;

import java.util.List;

public class ZoneDAO {

    public List<Zone> findByOwner(int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery(
                    "SELECT z FROM Zone z WHERE z.ownerId = :oid ORDER BY z.zoneId DESC",
                    Zone.class)
                    .setParameter("oid", ownerId)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public Zone findByIdAndOwner(int id, int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Zone> list = em.createQuery(
                    "SELECT z FROM Zone z WHERE z.zoneId = :id AND z.ownerId = :oid",
                    Zone.class)
                    .setParameter("id", id)
                    .setParameter("oid", ownerId)
                    .getResultList();
            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }

    public List<Zone> findAll() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.createQuery("SELECT z FROM Zone z ORDER BY z.zoneId DESC", Zone.class)
                    .getResultList();
        } finally {
            em.close();
        }
    }

    public Zone findById(int id) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return em.find(Zone.class, id);
        } finally {
            em.close();
        }
    }

    public void create(Zone z) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.persist(z);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public void update(Zone z) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            em.merge(z);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
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
            Zone z = em.find(Zone.class, id);
            if (z != null)
                em.remove(z);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public boolean existsCropInZone(int zoneId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            Long cnt = em.createQuery(
                    "SELECT COUNT(zc) FROM ZoneCrop zc WHERE zc.zoneId = :id",
                    Long.class)
                    .setParameter("id", zoneId)
                    .getSingleResult();
            return cnt != null && cnt > 0;
        } finally {
            em.close();
        }
    }

    public String getCityName(int cityId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            return (String) em.createNativeQuery("SELECT CityName FROM Cities WHERE CityID = ?")
                    .setParameter(1, cityId)
                    .getSingleResult();
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }

    public java.util.List<dto.ZoneDashboardDTO> getDashboardData() {
        EntityManager em = JPAUtil.getEntityManager();
        java.util.List<dto.ZoneDashboardDTO> list = new java.util.ArrayList<>();
        String sql = "SELECT \n" +
                "    z.ZoneID, z.ZoneName, z.Latitude, z.Longitude, \n" +
                "    c.CityName, \n" +
                "    cr.CropName, cr.MinTemp, cr.MaxTemp,\n" +
                "    w.Temperature, w.Humidity, w.Wind, w.Rainfall, w.RecordedAt, \n" +
                "    (SELECT COUNT(*) FROM Alerts a WHERE a.ZoneID = z.ZoneID AND a.IsRead = 0) as AlertCount\n" +
                "FROM Zones z\n" +
                "LEFT JOIN Cities c ON z.CityID = c.CityID\n" +
                "LEFT JOIN LATERAL (SELECT cc.CropName, cc.MinTemp, cc.MaxTemp FROM ZoneCrops zc JOIN CropCatalog cc ON zc.CropCatalogID = cc.CropCatalogID WHERE zc.ZoneID = z.ZoneID ORDER BY zc.CreatedAt DESC LIMIT 1) cr ON true\n"
                +
                "LEFT JOIN LATERAL (SELECT * FROM WeatherLogs wl WHERE wl.ZoneID = z.ZoneID ORDER BY RecordedAt DESC LIMIT 1) w ON true";

        try {
            java.util.List<Object[]> results = em.createNativeQuery(sql).getResultList();

            for (Object[] row : results) {
                dto.ZoneDashboardDTO dto = new dto.ZoneDashboardDTO();
                model.Zone zone = new model.Zone();

                // Native Query returns Objects, need careful casting
                zone.setZoneId((Integer) row[0]);
                zone.setZoneName((String) row[1]);
                zone.setLatitude(row[2] != null ? ((Number) row[2]).doubleValue() : null);
                zone.setLongitude(row[3] != null ? ((Number) row[3]).doubleValue() : null);
                dto.setZone(zone);

                dto.setCityName((String) row[4]);
                dto.setCropName((String) row[5]);

                // Weather Data
                Double temp = row[8] != null ? ((Number) row[8]).doubleValue() : 0.0;
                dto.setCurrentTemp(temp);
                dto.setCurrentHumidity(row[9] != null ? ((Number) row[9]).doubleValue() : 0.0);
                dto.setCurrentWind(row[10] != null ? ((Number) row[10]).doubleValue() : 0.0);
                dto.setCurrentRain(row[11] != null ? ((Number) row[11]).doubleValue() : 0.0);

                // Time
                java.sql.Timestamp ts = (java.sql.Timestamp) row[12];
                if (ts != null) {
                    long diff = (System.currentTimeMillis() - ts.getTime()) / 60000;
                    if (diff < 60) dto.setLastUpdated(diff + " mins ago");
                    else if (diff < 1440) dto.setLastUpdated((diff / 60) + " hours ago");
                    else dto.setLastUpdated((diff / 1440) + " days ago");
                } else {
                    dto.setLastUpdated("No Data");
                }

                // Status Calculation
                Double minTemp = row[6] != null ? ((Number) row[6]).doubleValue() : null;
                Double maxTemp = row[7] != null ? ((Number) row[7]).doubleValue() : null;

                if (ts == null || minTemp == null || maxTemp == null) {
                    dto.setStatus("Normal");
                } else {
                    if (temp > maxTemp || temp < minTemp) {
                        dto.setStatus("Danger");
                    } else if (temp > maxTemp - 2 || temp < minTemp + 2) {
                        dto.setStatus("Warning");
                    } else {
                        dto.setStatus("Normal");
                    }
                }

                dto.setAlertCount(row[13] != null ? ((Number) row[13]).intValue() : 0);
                dto.setSparklineData(getSparklineData(zone.getZoneId()));

                list.add(dto);
            }
        } finally {
            em.close();
        }
        return list;
    }

    private java.util.List<Double> getSparklineData(int zoneId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            String sql = "SELECT Temperature FROM WeatherLogs WHERE ZoneID = ? ORDER BY RecordedAt DESC LIMIT 7";
            java.util.List<Object> results = em.createNativeQuery(sql)
                    .setParameter(1, zoneId)
                    .getResultList();

            java.util.List<Double> data = new java.util.ArrayList<>();
            for (Object obj : results) {
                if (obj != null)
                    data.add(0, ((Number) obj).doubleValue());
            }
            return data;
        } finally {
            em.close();
        }
    }

    public void deleteByIdAndOwner(int id, int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            Zone z = em.createQuery(
                    "SELECT z FROM Zone z WHERE z.zoneId = :id AND z.ownerId = :oid",
                    Zone.class)
                    .setParameter("id", id)
                    .setParameter("oid", ownerId)
                    .getResultStream()
                    .findFirst()
                    .orElse(null);
            if (z != null)
                em.remove(z);
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive())
                tx.rollback();
            throw e;
        } finally {
            em.close();
        }
    }

    public java.util.List<dto.ZoneDashboardDTO> getDashboardDataByOwner(int ownerId) {
        EntityManager em = JPAUtil.getEntityManager();
        java.util.List<dto.ZoneDashboardDTO> list = new java.util.ArrayList<>();
        String sql = "SELECT \n" +
                "    z.ZoneID, z.ZoneName, z.Latitude, z.Longitude, \n" +
                "    c.CityName, \n" +
                "    cr.CropName, cr.MinTemp, cr.MaxTemp,\n" +
                "    w.Temperature, w.Humidity, w.Wind, w.Rainfall, w.RecordedAt, \n" +
                "    (SELECT COUNT(*) FROM Alerts a WHERE a.ZoneID = z.ZoneID AND a.IsRead = 0) as AlertCount\n" +
                "FROM Zones z\n" +
                "LEFT JOIN Cities c ON z.CityID = c.CityID\n" +
                "LEFT JOIN LATERAL (SELECT cc.CropName, cc.MinTemp, cc.MaxTemp FROM ZoneCrops zc JOIN CropCatalog cc ON zc.CropCatalogID = cc.CropCatalogID WHERE zc.ZoneID = z.ZoneID ORDER BY zc.CreatedAt DESC LIMIT 1) cr ON true\n"
                +
                "LEFT JOIN LATERAL (SELECT * FROM WeatherLogs wl WHERE wl.ZoneID = z.ZoneID ORDER BY RecordedAt DESC LIMIT 1) w ON true\n"
                +
                "WHERE z.OwnerID = ?";

        try {
            java.util.List<Object[]> results = em.createNativeQuery(sql)
                    .setParameter(1, ownerId)
                    .getResultList();

            for (Object[] row : results) {
                dto.ZoneDashboardDTO dto = new dto.ZoneDashboardDTO();
                model.Zone zone = new model.Zone();

                zone.setZoneId((Integer) row[0]);
                zone.setZoneName((String) row[1]);
                zone.setLatitude(row[2] != null ? ((Number) row[2]).doubleValue() : null);
                zone.setLongitude(row[3] != null ? ((Number) row[3]).doubleValue() : null);
                dto.setZone(zone);

                dto.setCityName((String) row[4]);
                dto.setCropName((String) row[5]);

                Double temp = row[8] != null ? ((Number) row[8]).doubleValue() : 0.0;
                dto.setCurrentTemp(temp);
                dto.setCurrentHumidity(row[9] != null ? ((Number) row[9]).doubleValue() : 0.0);
                dto.setCurrentWind(row[10] != null ? ((Number) row[10]).doubleValue() : 0.0);
                dto.setCurrentRain(row[11] != null ? ((Number) row[11]).doubleValue() : 0.0);

                java.sql.Timestamp ts = (java.sql.Timestamp) row[12];
                if (ts != null) {
                    long diff = (System.currentTimeMillis() - ts.getTime()) / 60000;
                    if (diff < 60) dto.setLastUpdated(diff + " mins ago");
                    else if (diff < 1440) dto.setLastUpdated((diff / 60) + " hours ago");
                    else dto.setLastUpdated((diff / 1440) + " days ago");
                } else {
                    dto.setLastUpdated("No Data");
                }

                Double minTemp = row[6] != null ? ((Number) row[6]).doubleValue() : null;
                Double maxTemp = row[7] != null ? ((Number) row[7]).doubleValue() : null;

                if (ts == null || minTemp == null || maxTemp == null) {
                    dto.setStatus("Normal");
                } else {
                    if (temp > maxTemp || temp < minTemp) {
                        dto.setStatus("Danger");
                    } else if (temp > maxTemp - 2 || temp < minTemp + 2) {
                        dto.setStatus("Warning");
                    } else {
                        dto.setStatus("Normal");
                    }
                }

                dto.setAlertCount(row[13] != null ? ((Number) row[13]).intValue() : 0);
                dto.setSparklineData(getSparklineData(zone.getZoneId()));
                list.add(dto);
            }
        } finally {
            em.close();
        }
        return list;
    }

    public Zone findLatestByOwnerCityName(int ownerId, int cityId, String zoneName) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Zone> list = em.createQuery(
                    "SELECT z FROM Zone z WHERE z.ownerId = :oid AND z.cityId = :cid AND z.zoneName = :zn ORDER BY z.zoneId DESC",
                    Zone.class)
                    .setParameter("oid", ownerId)
                    .setParameter("cid", cityId)
                    .setParameter("zn", zoneName)
                    .setMaxResults(1)
                    .getResultList();

            return list.isEmpty() ? null : list.get(0);
        } finally {
            em.close();
        }
    }
}
