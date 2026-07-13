package controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import exception.AppException;

import dto.SeedResult;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import model.User;
import model.Zone;

import service.AuthService;
import service.ZoneService;
import service.WeatherSeedService;
import util.ErrorResponder;
import util.ParamUtil;

import java.io.IOException;
import java.time.LocalDate;

/**
 * Thin controller — seed logic lives entirely in WeatherSeedService.
 * GET /api/seed-weather?zoneId=X&days=372
 */
@WebServlet("/api/seed-weather")
public class SeedWeatherServlet extends HttpServlet {

    private final AuthService authService = new AuthService();
    private final ZoneService zoneService = new ZoneService();
    private final WeatherSeedService seedService = new WeatherSeedService();
    private final Gson gson = new Gson();

    private static final int DEFAULT_DAYS = 372;
    private static final int MAX_DAYS = 372;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");

            User user = authService.getCurrentUser(req.getSession(false));
            if (user == null) {
                throw new AppException(401, "Vui lòng đăng nhập");
            }

            int zoneId = ParamUtil.requireInt(req, "zoneId", "Missing parameter: zoneId", "zoneId must be a number");
            int days = ParamUtil.getIntOrDefault(req, "days", DEFAULT_DAYS, "days must be a number");
            if (days < 1) {
                days = 1;
            }
            if (days > MAX_DAYS) {
                days = MAX_DAYS;
            }

            Zone zone = zoneService.getByIdForOwner(zoneId, user.getUserId());
            if (zone == null) {
                throw new AppException(403, "Zone not found or you don't have permission");
            }

            Double latObj = zone.getLatitude();
            Double lonObj = zone.getLongitude();
            if (latObj == null || lonObj == null) {
                throw new AppException(400, "Zone chưa có Latitude/Longitude");
            }
            double lat = latObj;
            double lon = lonObj;

            if (Math.abs(lat) < 0.000001 || Math.abs(lon) < 0.000001) {
                throw new AppException(400, "Latitude/Longitude không hợp lệ (đang = 0).");
            }
            if (lat < -90 || lat > 90 || lon < -180 || lon > 180) {
                throw new AppException(400, "Latitude/Longitude ngoài phạm vi hợp lệ.");
            }

            LocalDate end = LocalDate.now();
            LocalDate start = end.minusDays(days - 1);

            SeedResult result = seedService.seedRange(zoneId, lat, lon, start, end);
            JsonObject ok = new JsonObject();
            ok.addProperty("status", "success");
            ok.addProperty("zoneId", zoneId);
            ok.addProperty("daysRequested", result.getRequestedDays());
            ok.addProperty("rangeStart", start.toString());
            ok.addProperty("rangeEnd", end.toString());
            ok.addProperty("inserted", result.getInsertedCount());
            ok.addProperty("skippedExisting", result.getSkippedExistingCount());
            ok.addProperty("failed", result.getFailedCount());
            resp.getWriter().print(gson.toJson(ok));
        } catch (AppException e) {
            try {
                ErrorResponder.handle(req, resp, e);
            } catch (Exception ignored) {
                if (!resp.isCommitted()) {
                    ErrorResponder.sendApiError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal Server Error");
                }
            }
        } catch (Exception e) {
            try {
                ErrorResponder.handle(req, resp, new AppException(502, "Seed error: " + e.getMessage(), e));
            } catch (Exception ignored) {
                if (!resp.isCommitted()) {
                    ErrorResponder.sendApiError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal Server Error");
                }
            }
        }
    }
}
