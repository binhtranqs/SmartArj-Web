package service;

import dao.CropDAO;
import java.util.List;
import model.Crop;

public class CropService {

    private final CropDAO cropDAO = new CropDAO();

    public List<Crop> getAll() {
        return cropDAO.findAll();
    }

    public List<Crop> getAllByOwner(int ownerId) {
        return cropDAO.findAllByOwner(ownerId);
    }

    public Crop getById(int id) {
        return cropDAO.findById(id);
    }

    public Crop getByIdForOwner(int id, int ownerId) {
        return cropDAO.findByIdAndOwner(id, ownerId);
    }

    public void create(Crop crop) {
        cropDAO.create(crop);
    }

    public void update(Crop crop) {
        cropDAO.update(crop);
    }

    public void delete(int id) {
        cropDAO.delete(id);
    }

    public void deleteForOwner(int id, int ownerId) {
        cropDAO.deleteByIdAndOwner(id, ownerId);
    }
}
