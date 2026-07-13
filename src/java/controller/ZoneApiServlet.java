package controller;

import com.google.gson.Gson;
import exception.AppException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Zone;
import service.ZoneService;
import util.ErrorResponder;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/zones")
public class ZoneApiServlet extends HttpServlet {

    private final ZoneService zoneService = new ZoneService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        try {
            User user = getCurrentUser(req);
            List<Zone> zones = zoneService.getAllByOwner(user.getUserId());
            resp.setContentType("application/json");
            resp.setCharacterEncoding("UTF-8");
            resp.getWriter().write(gson.toJson(zones));
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

    private User getCurrentUser(HttpServletRequest req) throws AppException {
        HttpSession session = req.getSession(false);
        if (session == null) {
            throw new AppException(401, "Unauthorized");
        }
        User user = (User) session.getAttribute("user");
        if (user == null) {
            throw new AppException(401, "Unauthorized");
        }
        return user;
    }
}
