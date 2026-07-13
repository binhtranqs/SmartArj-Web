package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import service.AlertService;
import java.io.IOException;

/**
 * Servlet để trigger việc kiểm tra cảnh báo thủ công hoặc qua Cron Job
 */
@WebServlet("/check-alerts")
public class CheckAlertsServlet extends HttpServlet {

    private final AlertService alertService = new AlertService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            alertService.checkAndGenerateAlerts();
            resp.setStatus(200);
            resp.getWriter().write("Alert check completed successfully.");
        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(500, "Error checking alerts: " + e.getMessage());
        }
    }
}
