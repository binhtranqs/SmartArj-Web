package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import model.WeatherLog;
import model.Zone;
import service.DashboardService;
import service.ZoneService;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.List;

@WebServlet(urlPatterns = { "/api/weather" })
public class WeatherApiServlet extends HttpServlet {

    private final DashboardService service = new DashboardService();
    private final ZoneService zoneService = new ZoneService();
    private final SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json; charset=UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.setStatus(401);
            resp.getWriter().write("{\"error\":\"Unauthorized\"}");
            return;
        }
        User user = (User) session.getAttribute("user");
        int ownerId = user.getUserId() != null ? user.getUserId() : -1;
        boolean isAdmin = user.isAdmin();

        int zoneId = Integer.parseInt(req.getParameter("zoneId"));

        // Verify ownership
        if (!isAdmin) {
            Zone z = zoneService.getByIdAndOwner(zoneId, ownerId);
            if (z == null) {
                // Return empty if no permission
                resp.getWriter().write("{\"labels\":[],\"values\":[]}");
                return;
            }
        }

        String metric = req.getParameter("metric"); // temperature/humidity/...
        int limit = req.getParameter("limit") == null ? 60 : Integer.parseInt(req.getParameter("limit"));

        List<WeatherLog> logs = service.getData(zoneId, limit);

        StringBuilder sb = new StringBuilder();
        sb.append("{\"labels\":[");
        for (int i = 0; i < logs.size(); i++) {
            sb.append("\"").append(fmt.format(logs.get(i).getRecordedAt())).append("\"");
            if (i < logs.size() - 1)
                sb.append(",");
        }
        sb.append("],\"values\":[");

        for (int i = 0; i < logs.size(); i++) {
            WeatherLog w = logs.get(i);
            Double v = pickMetric(w, metric);
            sb.append(v == null ? "null" : v);
            if (i < logs.size() - 1)
                sb.append(",");
        }
        sb.append("]}");

        resp.getWriter().write(sb.toString());
    }

    private Double pickMetric(WeatherLog w, String metric) {
        if (metric == null)
            metric = "temperature";
        return switch (metric.toLowerCase()) {
            case "humidity" -> w.getHumidity();
            case "rainfall" -> w.getRainfall();
            case "wind" -> w.getWind();
            case "radiation" -> w.getRadiation();
            default -> w.getTemperature();
        };
    }
}
