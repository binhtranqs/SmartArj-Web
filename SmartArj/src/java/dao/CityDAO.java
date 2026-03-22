package dao;

import model.City;
import util.JPAUtil;

import jakarta.persistence.EntityManager;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng Cities.
 * Dùng native query để lấy danh sách thành phố cho dropdown trong form Zone.
 */
public class CityDAO {

    /**
     * Trả về tất cả thành phố, sắp xếp theo CityID tăng dần.
     */
    @SuppressWarnings("unchecked")
    public List<City> findAll() {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT CityID, CityName, Region, Latitude, Longitude " +
                    "FROM Cities ORDER BY CityID"
            ).getResultList();

            List<City> cities = new ArrayList<>();
            for (Object[] row : rows) {
                City c = new City();
                c.setCityId(((Number) row[0]).intValue());
                c.setCityName((String) row[1]);
                c.setRegion((String) row[2]);
                c.setLatitude(row[3] != null ? ((Number) row[3]).doubleValue() : null);
                c.setLongitude(row[4] != null ? ((Number) row[4]).doubleValue() : null);
                cities.add(c);
            }
            return cities;
        } catch (Exception e) {
            e.printStackTrace();
            return new ArrayList<>();
        } finally {
            em.close();
        }
    }

    /**
     * Tìm một City theo ID.
     */
    public City findById(int cityId) {
        EntityManager em = JPAUtil.getEntityManager();
        try {
            List<Object[]> rows = em.createNativeQuery(
                    "SELECT CityID, CityName, Region, Latitude, Longitude " +
                    "FROM Cities WHERE CityID = ?"
            ).setParameter(1, cityId).getResultList();

            if (rows.isEmpty()) return null;
            Object[] row = rows.get(0);
            City c = new City();
            c.setCityId(((Number) row[0]).intValue());
            c.setCityName((String) row[1]);
            c.setRegion((String) row[2]);
            c.setLatitude(row[3] != null ? ((Number) row[3]).doubleValue() : null);
            c.setLongitude(row[4] != null ? ((Number) row[4]).doubleValue() : null);
            return c;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        } finally {
            em.close();
        }
    }
}
