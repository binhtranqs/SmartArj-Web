package service;

import dao.CropCatalogDAO;
import model.CropCatalog;
import java.util.List;
import java.util.Date;

public class CropCatalogService {
    private final CropCatalogDAO dao;

    public CropCatalogService() {
        this.dao = new CropCatalogDAO();
    }

    public List<CropCatalog> findAllCatalog() {
        return dao.findAllCatalog();
    }

    public List<CropCatalog> findByCategory(String category) {
        return dao.findByCategory(category);
    }

    public CropCatalog findById(int id) {
        return dao.findById(id);
    }

    public boolean addCustomCrop(String name, String category, Double minTemp, Double maxTemp, Double minHumid,
            Double maxHumid, String imageUrl, String description) {
        CropCatalog c = new CropCatalog();
        c.setCropName(name);
        c.setCategory(category);
        c.setMinTemp(minTemp);
        c.setMaxTemp(maxTemp);
        c.setMinHumid(minHumid);
        c.setMaxHumid(maxHumid);
        c.setImageUrl(imageUrl);
        c.setDescription(description);
        c.setIsSystemProvided(false);
        c.setCreatedAt(new Date());

        return dao.addCropCatalog(c);
    }
}
