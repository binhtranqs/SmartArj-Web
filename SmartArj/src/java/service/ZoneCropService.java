package service;

import dao.ZoneCropDAO;
import model.ZoneCrop;
import model.CropCatalog;
import java.util.List;
import java.util.Date;

public class ZoneCropService {
    private final ZoneCropDAO dao;

    public ZoneCropService() {
        this.dao = new ZoneCropDAO();
    }

    public List<ZoneCrop> findByZoneId(int zoneId) {
        return dao.findByZoneId(zoneId);
    }

    public List<ZoneCrop> findByOwner(int ownerId) {
        return dao.findByOwner(ownerId);
    }

    public boolean assignCrop(int zoneId, int cropCatalogId) {
        ZoneCrop zc = new ZoneCrop();
        zc.setZoneId(zoneId);

        CropCatalog cat = new CropCatalog();
        cat.setCropCatalogId(cropCatalogId);
        zc.setCropCatalog(cat);

        zc.setCreatedAt(new Date());
        return dao.assignCrop(zc);
    }

    public boolean removeCrop(int zoneCropId) {
        return dao.removeCrop(zoneCropId);
    }
}
