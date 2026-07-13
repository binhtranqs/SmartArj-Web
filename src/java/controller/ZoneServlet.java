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

import model.Zone;
import model.User;

import service.ZoneService;
import service.WeatherSeedService;
import util.ErrorResponder;
import util.ParamUtil;

@WebServlet(urlPatterns = { "/zones" })
public class ZoneServlet extends HttpServlet {

    private ZoneService zoneService;
    private WeatherSeedService weatherSeedService;

    // Số ngày lịch sử cần seed khi tạo zone mới (phải đủ cho AI: encoder=365 +
    // pred=7)
    private static final int AUTO_SEED_DAYS = 372;

    @Override
    public void init() {
        zoneService = new ZoneService();
        weatherSeedService = new WeatherSeedService();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            int ownerId = getCurrentUser(req).getUserId();
            String action = ParamUtil.getStringOrDefault(req, "action", "list");

            switch (action) {
                case "new":
                    req.setAttribute("editing", false);
                    req.getRequestDispatcher("/WEB-INF/views/zones/form.jsp").forward(req, resp);
                    break;

                case "edit": {
                    int id = ParamUtil.requireInt(req, "id", "Missing parameter: id", "id must be a number");
                    Zone z = zoneService.getByIdForOwner(id, ownerId);
                    if (z == null) {
                        throw new AppException(404, "Zone not found: " + id);
                    }

                    req.setAttribute("editing", true);
                    req.setAttribute("zone", z);
                    req.getRequestDispatcher("/WEB-INF/views/zones/form.jsp").forward(req, resp);
                    break;
                }

                case "delete": {
                    int id = ParamUtil.requireInt(req, "id", "Missing parameter: id", "id must be a number");
                    zoneService.deleteForOwner(id, ownerId);
                    resp.sendRedirect(req.getContextPath() + "/zones");
                    break;
                }

                default: {
                    List<dto.ZoneDashboardDTO> zones = zoneService.getDashboardDataByOwner(ownerId);
                    req.setAttribute("zones", zones);
                    req.getRequestDispatcher("/WEB-INF/views/zones/list.jsp").forward(req, resp);
                    break;
                }
            }
        } catch (Exception e) {
            ErrorResponder.handle(req, resp, e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");
        Zone z = new Zone();

        try {
            int ownerId = getCurrentUser(req).getUserId();
            Integer zoneId = ParamUtil.getIntOrNull(req, "zoneId", "zoneId must be a number");

            z.setCityId(ParamUtil.requireInt(req, "cityId", "CityID is required", "cityId must be a number"));
            z.setZoneName(ParamUtil.getString(req, "zoneName"));
            z.setDescription(ParamUtil.getString(req, "description"));
            z.setLatitude(ParamUtil.getDoubleOrNull(req, "latitude", "latitude must be a number"));
            z.setLongitude(ParamUtil.getDoubleOrNull(req, "longitude", "longitude must be a number"));
            z.setOwnerId(ownerId);

            boolean isCreate = (zoneId == null);

            if (isCreate) {
                zoneService.create(z);

                // ✅ Auto-seed qua WeatherSeedService (single source of truth)
                tryAutoSeedWeather(z);

            } else {
                z.setZoneId(zoneId);

                Zone existing = zoneService.getByIdForOwner(z.getZoneId(), ownerId);
                if (existing == null) {
                    throw new AppException(403, "Bạn không có quyền sửa Zone này");
                }
                zoneService.update(z);
            }

            resp.sendRedirect(req.getContextPath() + "/zones");

        } catch (Exception e) {
            Integer zoneId = null;
            try {
                zoneId = ParamUtil.getIntOrNull(req, "zoneId", "zoneId must be a number");
            } catch (AppException ignored) {
            }
            req.setAttribute("editing", zoneId != null);
            req.setAttribute("zone", zFromRequest(req));
            ErrorResponder.handle(req, resp, e);
        }
    }

    // =====================================================================
    // Auto-seed: gọi WeatherSeedService, không crash nếu thất bại
    // =====================================================================
    private void tryAutoSeedWeather(Zone z) {
        try {
            if (z.getZoneId() == null) {
                System.out.println("[AUTO-SEED] zoneId is null after create.");
                return;
            }

            Double latObj = z.getLatitude();
            Double lonObj = z.getLongitude();
            if (latObj == null || lonObj == null) {
                System.out.println("[AUTO-SEED] skip: missing lat/lon");
                return;
            }

            double lat = latObj;
            double lon = lonObj;

            if (Math.abs(lat) < 0.000001 || Math.abs(lon) < 0.000001) {
                System.out.println("[AUTO-SEED] skip: lat/lon = 0");
                return;
            }
            if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                System.out.println("[AUTO-SEED] skip: lat/lon out of range");
                return;
            }

            // ✅ Gọi service — không còn inline logic
            dto.SeedResult result = weatherSeedService.seedIfNeeded(z.getZoneId(), lat, lon, AUTO_SEED_DAYS);
            System.out.println("[AUTO-SEED] zoneId=" + z.getZoneId() + " " + result);

        } catch (Exception e) {
            // Seeding failure KHÔNG được crash zone creation
            System.err.println("[AUTO-SEED] failed (non-fatal): " + e.getMessage());
        }
    }

    private Zone zFromRequest(HttpServletRequest req) {
        Zone z = new Zone();
        try {
            Integer zoneId = ParamUtil.getIntOrNull(req, "zoneId", "zoneId must be a number");
            if (zoneId != null) {
                z.setZoneId(zoneId);
            }
        } catch (Exception ignored) {
        }
        try {
            Integer cityId = ParamUtil.getIntOrNull(req, "cityId", "cityId must be a number");
            if (cityId != null) {
                z.setCityId(cityId);
            }
        } catch (Exception ignored) {
        }
        z.setZoneName(ParamUtil.getString(req, "zoneName"));
        z.setDescription(ParamUtil.getString(req, "description"));
        try {
            z.setLatitude(ParamUtil.getDoubleOrNull(req, "latitude", "latitude must be a number"));
        } catch (Exception ignored) {
        }
        try {
            z.setLongitude(ParamUtil.getDoubleOrNull(req, "longitude", "longitude must be a number"));
        } catch (Exception ignored) {
        }
        return z;
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
