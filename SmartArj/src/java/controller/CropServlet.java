package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import dao.ZoneDAO;
import model.Zone;
import model.User;
import java.util.List;

@WebServlet(name = "CropServlet", urlPatterns = { "/crops" })
public class CropServlet extends HttpServlet {
    private ZoneDAO zoneDAO;

    @Override
    public void init() {
        zoneDAO = new ZoneDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        User user = (User) request.getSession().getAttribute("user");
        if (user != null) {
            List<Zone> zones = zoneDAO.findByOwner(user.getUserId());
            request.setAttribute("userZones", zones);
        }
        request.getRequestDispatcher("/WEB-INF/views/crops/list.jsp").forward(request, response);
    }
}
