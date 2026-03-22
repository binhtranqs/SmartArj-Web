package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

import model.User;
import model.Zone;
import dao.CityDAO;
import service.WeatherSeedService;
import service.ZoneService;


@WebServlet(urlPatterns = { "/zones" })
public class ZoneServlet extends HttpServlet {

    private ZoneService zoneService;
    private WeatherSeedService weatherSeedService;
    private CityDAO cityDAO;

    // Số ngày lịch sử cần seed khi tạo zone mới
    private static final int AUTO_SEED_DAYS = 372;

    @Override
    public void init() {
        zoneService = new ZoneService();
        weatherSeedService = new WeatherSeedService();
        cityDAO = new CityDAO();
    }


    /** Lấy userId từ session; trả -1 nếu chưa login */
    private int getOwnerId(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null)
            return -1;
        User u = (User) session.getAttribute("user");
        return (u != null && u.getUserId() != null) ? u.getUserId() : -1;
    }

    private boolean isAdmin(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null)
            return false;
        User u = (User) session.getAttribute("user");
        return u != null && u.isAdmin();
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        int ownerId = getOwnerId(req);
        if (ownerId == -1) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        if (action == null)
            action = "list";

        try {
            switch (action) {
                case "new":
                    req.setAttribute("editing", false);
                    req.setAttribute("cities", cityDAO.findAll());
                    req.getRequestDispatcher("/WEB-INF/views/zones/form.jsp").forward(req, resp);
                    break;

                case "edit": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    Zone z = isAdmin(req) ? zoneService.getById(id)
                            : zoneService.getByIdAndOwner(id, ownerId);
                    if (z == null)
                        throw new RuntimeException("Zone not found or no permission: " + id);

                    req.setAttribute("editing", true);
                    req.setAttribute("zone", z);
                    req.setAttribute("cities", cityDAO.findAll());
                    req.getRequestDispatcher("/WEB-INF/views/zones/form.jsp").forward(req, resp);
                    break;
                }

                case "delete": {
                    int id = Integer.parseInt(req.getParameter("id"));
                    if (isAdmin(req)) {
                        zoneService.delete(id);
                    } else {
                        zoneService.deleteByOwner(id, ownerId);
                    }
                    resp.sendRedirect(req.getContextPath() + "/zones");
                    break;
                }

                default: {
                    List<dto.ZoneDashboardDTO> zones;
                    if (isAdmin(req)) {
                        zones = zoneService.getDashboardData();
                    } else {
                        zones = zoneService.getDashboardDataByOwner(ownerId);
                    }
                    req.setAttribute("zones", zones);
                    req.getRequestDispatcher("/WEB-INF/views/zones/list.jsp").forward(req, resp);
                    break;
                }
            }
        } catch (Exception e) {
            req.setAttribute("errorMessage", e.getMessage());
            req.setAttribute("errorDetail", e);
            req.getRequestDispatcher("/WEB-INF/views/common/error.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        req.setCharacterEncoding("UTF-8");

        int ownerId = getOwnerId(req);
        if (ownerId == -1) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String zoneIdStr = req.getParameter("zoneId");
        String cityIdStr = req.getParameter("cityId");
        String zoneName = req.getParameter("zoneName");
        String description = req.getParameter("description");

        String latStr = req.getParameter("latitude");
        String lngStr = req.getParameter("longitude");

        try {
            Zone z = new Zone();

            if (cityIdStr == null || cityIdStr.isBlank())
                throw new IllegalArgumentException("CityID is required");

            int cityId = Integer.parseInt(cityIdStr);
            z.setCityId(cityId);

            // Auto-fill từ Cities nếu form không gửi lat/lng/zoneName
            // (form đơn giản chỉ có dropdown thành phố)
            model.City city = cityDAO.findById(cityId);

            // ZoneName: dùng giá trị form nếu có, ngược lại lấy tên city
            if (zoneName == null || zoneName.isBlank()) {
                z.setZoneName(city != null ? city.getCityName() : "Zone " + cityId);
            } else {
                z.setZoneName(zoneName);
            }

            z.setDescription(description);
            z.setOwnerId(ownerId);

            // Latitude: dùng giá trị form nếu có, ngược lại lấy từ city
            if (latStr == null || latStr.isBlank()) {
                z.setLatitude(city != null ? city.getLatitude() : 0.0);
            } else {
                z.setLatitude(Double.parseDouble(latStr));
            }

            // Longitude: dùng giá trị form nếu có, ngược lại lấy từ city
            if (lngStr == null || lngStr.isBlank()) {
                z.setLongitude(city != null ? city.getLongitude() : 0.0);
            } else {
                z.setLongitude(Double.parseDouble(lngStr));
            }

            if (zoneIdStr == null || zoneIdStr.isBlank()) {
                // Create — owner is automatically set
                zoneService.create(z);

                // Auto-seed qua WeatherSeedService
                tryAutoSeedWeather(z);
            } else {
                // Update — verify ownership first
                int zoneId = Integer.parseInt(zoneIdStr);
                if (!isAdmin(req)) {
                    Zone existing = zoneService.getByIdAndOwner(zoneId, ownerId);
                    if (existing == null)
                        throw new RuntimeException("Zone not found or no permission: " + zoneId);
                }
                z.setZoneId(zoneId);
                zoneService.update(z);
            }

            resp.sendRedirect(req.getContextPath() + "/zones");
        } catch (Exception e) {
            req.setAttribute("errorMessage", e.getMessage());
            req.setAttribute("errorDetail", e);
            req.setAttribute("editing", zoneIdStr != null && !zoneIdStr.isBlank());
            req.setAttribute("zone", zFromRequest(req));
            req.setAttribute("cities", cityDAO.findAll());  // vẫn cần cities cho dropdown
            req.getRequestDispatcher("/WEB-INF/views/common/error.jsp").forward(req, resp);
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

            dto.SeedResult result = weatherSeedService.seedIfNeeded(z.getZoneId(), lat, lon, AUTO_SEED_DAYS);
            System.out.println("[AUTO-SEED] zoneId=" + z.getZoneId() + " " + result);

        } catch (Exception e) {
            System.err.println("[AUTO-SEED] failed (non-fatal): " + e.getMessage());
        }
    }

    private Zone zFromRequest(HttpServletRequest req) {
        Zone z = new Zone();
        try {
            String zoneIdStr = req.getParameter("zoneId");
            if (zoneIdStr != null && !zoneIdStr.isBlank())
                z.setZoneId(Integer.parseInt(zoneIdStr));
        } catch (Exception ignored) {
        }

        try {
            String cityIdStr = req.getParameter("cityId");
            if (cityIdStr != null && !cityIdStr.isBlank())
                z.setCityId(Integer.parseInt(cityIdStr));
        } catch (Exception ignored) {
        }

        z.setZoneName(req.getParameter("zoneName"));
        z.setDescription(req.getParameter("description"));

        try {
            String latStr = req.getParameter("latitude");
            if (latStr != null && !latStr.isBlank())
                z.setLatitude(Double.parseDouble(latStr));
        } catch (Exception ignored) {
        }

        try {
            String lngStr = req.getParameter("longitude");
            if (lngStr != null && !lngStr.isBlank())
                z.setLongitude(Double.parseDouble(lngStr));
        } catch (Exception ignored) {
        }

        return z;
    }
}
