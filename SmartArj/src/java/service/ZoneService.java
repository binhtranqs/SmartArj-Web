package service;

import dao.ZoneDAO;
import model.Zone;

import java.util.List;

public class ZoneService {
    private final ZoneDAO dao = new ZoneDAO();

    public List<Zone> getAll() {
        return dao.findAll();
    }

    public List<Zone> getByOwner(int ownerId) {
        return dao.findByOwner(ownerId);
    }

    public Zone getById(int id) {
        return dao.findById(id);
    }

    public Zone getByIdAndOwner(int id, int ownerId) {
        return dao.findByIdAndOwner(id, ownerId);
    }

    public void create(Zone z) {
        if (z.getCityId() == null)
            throw new IllegalArgumentException("CityID is required");
        dao.create(z);
    }

    public void update(Zone z) {
        if (z.getZoneId() == null)
            throw new IllegalArgumentException("ZoneID is required");
        if (z.getCityId() == null)
            throw new IllegalArgumentException("CityID is required");
        dao.update(z);
    }

    public void delete(int id) {
        if (dao.existsCropInZone(id)) {
            throw new IllegalStateException("Cannot delete zone because it still has crops.");
        }
        dao.delete(id);
    }

    public void deleteByOwner(int id, int ownerId) {
        if (dao.existsCropInZone(id)) {
            throw new IllegalStateException("Cannot delete zone because it still has crops.");
        }
        dao.deleteByIdAndOwner(id, ownerId);
    }

    public java.util.List<dto.ZoneDashboardDTO> getDashboardData() {
        return dao.getDashboardData();
    }

    public java.util.List<dto.ZoneDashboardDTO> getDashboardDataByOwner(int ownerId) {
        return dao.getDashboardDataByOwner(ownerId);
    }
}
