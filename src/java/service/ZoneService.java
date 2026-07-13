package service;

import dao.ZoneDAO;
import model.Zone;

import java.util.List;

public class ZoneService {
    private final ZoneDAO dao = new ZoneDAO();

    public List<Zone> getAll() {
        return dao.findAll();
    }

    public List<Zone> getAllByOwner(int ownerId) {
        return dao.findByOwner(ownerId);
    }

    public Zone getById(int id) {
        return dao.findById(id);
    }

    public Zone getByIdForOwner(int id, int ownerId) {
        return dao.findByIdAndOwner(id, ownerId);
    }

    /**
     * Create zone and return new zoneId (để caller auto-seed chắc chắn).
     * - Validate bắt buộc
     * - Gọi dao.create(z)
     * - Nếu dao chưa set zoneId vào z, cố lấy lại bằng cách query (fallback)
     */
    public int create(Zone z) {
        if (z.getCityId() == null)
            throw new IllegalArgumentException("CityID is required");
        if (z.getOwnerId() == null)
            throw new IllegalArgumentException("OwnerID is required");
        if (z.getZoneName() == null || z.getZoneName().trim().isEmpty())
            throw new IllegalArgumentException("ZoneName is required");

        dao.create(z);

        // Case 1: DAO đã set ID vào entity (lý tưởng)
        if (z.getZoneId() != null) {
            return z.getZoneId();
        }

        // Case 2: DAO không set ID -> fallback: tìm lại zone vừa tạo theo owner + tên + city
        // (Giả định: owner + city + zoneName là đủ để tìm ra bản ghi mới nhất)
        Zone created = dao.findLatestByOwnerCityName(z.getOwnerId(), z.getCityId(), z.getZoneName());
        if (created != null && created.getZoneId() != null) {
            // update lại vào object truyền vào để ZoneServlet dùng luôn
            z.setZoneId(created.getZoneId());
            return created.getZoneId();
        }

        throw new IllegalStateException("Create zone succeeded but ZoneID was not returned. Check ZoneDAO.create()");
    }

    public void update(Zone z) {
        if (z.getZoneId() == null)
            throw new IllegalArgumentException("ZoneID is required");
        if (z.getCityId() == null)
            throw new IllegalArgumentException("CityID is required");
        if (z.getOwnerId() == null)
            throw new IllegalArgumentException("OwnerID is required");
        if (z.getZoneName() == null || z.getZoneName().trim().isEmpty())
            throw new IllegalArgumentException("ZoneName is required");

        dao.update(z);
    }

    public void deleteForOwner(int id, int ownerId) {
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