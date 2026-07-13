package controller;

import exception.AppException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

import model.Crop;
import model.Zone;
import model.User;
import service.CropService;
import service.ZoneService;
import util.ErrorResponder;
import util.ParamUtil;

@WebServlet("/crops")
public class CropServlet extends HttpServlet {

    private final CropService cropService = new CropService();
    private final ZoneService zoneService = new ZoneService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int ownerId = getCurrentUser(req).getUserId();
            String action = ParamUtil.getString(req, "action");

            if ("new".equals(action)) {
                showForm(req, resp, new Crop(), false);
                return;
            }

            if ("edit".equals(action)) {
                int id = ParamUtil.requireInt(req, "id", "Missing parameter: id", "id must be a number");
                Crop crop = cropService.getByIdForOwner(id, ownerId);
                if (crop == null) {
                    throw new AppException(403, "Bạn không có quyền xem/sửa Crop này");
                }
                showForm(req, resp, crop, true);
                return;
            }

            if ("delete".equals(action)) {
                int id = ParamUtil.requireInt(req, "id", "Missing parameter: id", "id must be a number");
                cropService.deleteForOwner(id, ownerId);
                resp.sendRedirect(req.getContextPath() + "/crops");
                return;
            }

            req.setAttribute("crops", cropService.getAllByOwner(ownerId));
            req.getRequestDispatcher("/WEB-INF/views/crops/list.jsp").forward(req, resp);
        } catch (Exception e) {
            ErrorResponder.handle(req, resp, e);
        }
    }

    private void showForm(HttpServletRequest req, HttpServletResponse resp,
                          Crop crop, boolean editing)
            throws ServletException, IOException {

        try {
            int ownerId = getCurrentUser(req).getUserId();
            List<Zone> zones = zoneService.getAllByOwner(ownerId);

            req.setAttribute("crop", crop);
            req.setAttribute("zones", zones);
            req.setAttribute("editing", editing);

            req.getRequestDispatcher("/WEB-INF/views/crops/form.jsp").forward(req, resp);
        } catch (AppException e) {
            ErrorResponder.handle(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int ownerId = getCurrentUser(req).getUserId();
            Integer cropId = ParamUtil.getIntOrNull(req, "id", "id must be a number");
            String cropName = ParamUtil.requireString(req, "cropName", "Crop name is required");
            int zoneId = ParamUtil.requireInt(req, "zoneId", "Zone is required", "zoneId must be a number");

            // Threshold fields
            Double minTemp = ParamUtil.getDoubleOrNull(req, "minTemp", "minTemp must be a number");
            Double maxTemp = ParamUtil.getDoubleOrNull(req, "maxTemp", "maxTemp must be a number");
            Double minHumid = ParamUtil.getDoubleOrNull(req, "minHumid", "minHumid must be a number");
            Double maxHumid = ParamUtil.getDoubleOrNull(req, "maxHumid", "maxHumid must be a number");

            Zone zone = zoneService.getByIdForOwner(zoneId, ownerId);
            if (zone == null) {
                throw new AppException(403, "Bạn không có quyền gán Crop vào Zone này");
            }

            Crop crop = new Crop();
            crop.setCropName(cropName);
            crop.setZone(zone);

            // Set thresholds
            crop.setMinTemp(minTemp);
            crop.setMaxTemp(maxTemp);
            crop.setMinHumid(minHumid);
            crop.setMaxHumid(maxHumid);

            validateThresholds(crop);

            if (cropId == null) {
                cropService.create(crop);
            } else {
                crop.setCropId(cropId);
                Crop existing = cropService.getByIdForOwner(crop.getCropId(), ownerId);
                if (existing == null) {
                    throw new AppException(403, "Bạn không có quyền sửa Crop này");
                }
                cropService.update(crop);
            }

            resp.sendRedirect(req.getContextPath() + "/crops");

        } catch (Exception e) {
            ErrorResponder.handle(req, resp, e);
        }
    }

    private void validateThresholds(Crop crop) {
        // Basic guardrails
        if (crop.getMinTemp() != null && crop.getMaxTemp() != null && crop.getMinTemp() > crop.getMaxTemp()) {
            throw new IllegalArgumentException("MinTemp phải <= MaxTemp");
        }
        if (crop.getMinHumid() != null && crop.getMaxHumid() != null && crop.getMinHumid() > crop.getMaxHumid()) {
            throw new IllegalArgumentException("MinHumid phải <= MaxHumid");
        }

        if (crop.getMinHumid() != null && (crop.getMinHumid() < 0 || crop.getMinHumid() > 100)) {
            throw new IllegalArgumentException("MinHumid phải nằm trong 0..100");
        }
        if (crop.getMaxHumid() != null && (crop.getMaxHumid() < 0 || crop.getMaxHumid() > 100)) {
            throw new IllegalArgumentException("MaxHumid phải nằm trong 0..100");
        }
        if (crop.getMinTemp() != null && (crop.getMinTemp() < -20 || crop.getMinTemp() > 60)) {
            throw new IllegalArgumentException("MinTemp không hợp lệ (-20..60)");
        }
        if (crop.getMaxTemp() != null && (crop.getMaxTemp() < -20 || crop.getMaxTemp() > 60)) {
            throw new IllegalArgumentException("MaxTemp không hợp lệ (-20..60)");
        }
    }

    private User getCurrentUser(HttpServletRequest req) throws AppException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            throw new AppException(401, "Unauthorized");
        }
        User currentUser = (User) session.getAttribute("user");
        if (currentUser == null) {
            throw new AppException(401, "Unauthorized");
        }
        return currentUser;
    }
}
