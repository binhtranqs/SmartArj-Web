package controller;

import exception.AppException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.WeatherLog;
import model.Zone;
import service.DashboardService;
import service.ZoneService;
import util.ErrorResponder;
import util.ParamUtil;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(urlPatterns = { "/api/weather" })
public class WeatherApiServlet extends HttpServlet {

    private final DashboardService service = new DashboardService();
    private final ZoneService zoneService = new ZoneService();
    private final SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            resp.setContentType("application/json; charset=UTF-8");

            User user = getCurrentUser(req);
            int zoneId = ParamUtil.requireInt(req, "zoneId", "Missing required parameter: zoneId", "zoneId must be a number");

            Zone zone = zoneService.getByIdForOwner(zoneId, user.getUserId());
            if (zone == null) {
                throw new AppException(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
            }

            String metric = ParamUtil.getString(req, "metric");
            int limit = ParamUtil.getIntOrDefault(req, "limit", 60, "limit must be a number");

            List<WeatherLog> logs = service.getData(zoneId, limit);

            StringBuilder sb = new StringBuilder();
            sb.append("{\"labels\":[");
            for (int i = 0; i < logs.size(); i++) {
                sb.append("\"").append(fmt.format(logs.get(i).getRecordedAt())).append("\"");
                if (i < logs.size() - 1) {
                    sb.append(",");
                }
            }
            sb.append("],\"values\":[");

            for (int i = 0; i < logs.size(); i++) {
                WeatherLog w = logs.get(i);
                Double v = pickMetric(w, metric);
                sb.append(v == null ? "null" : v);
                if (i < logs.size() - 1) {
                    sb.append(",");
                }
            }
            sb.append("]}");

            resp.getWriter().write(sb.toString());
        } catch (Exception e) {
            try {
                ErrorResponder.handle(req, resp, e);
            } catch (Exception ignored) {
                if (!resp.isCommitted()) {
                    ErrorResponder.sendApiError(resp, HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Internal Server Error");
                }
            }
        }
    }

    private Double pickMetric(WeatherLog w, String metric) {
        if (metric == null) {
            metric = "temperature";
        }

        switch (metric.toLowerCase()) {
            case "humidity":
                return w.getHumidity();
            case "rainfall":
                return w.getRainfall();
            case "wind":
                return w.getWind();
            case "radiation":
                return w.getRadiation();
            default:
                return w.getTemperature();
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
