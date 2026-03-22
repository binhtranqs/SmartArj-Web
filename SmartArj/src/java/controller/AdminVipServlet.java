package controller;

import dao.VipRequestDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import service.AdminService;

import java.io.IOException;

/**
 * Admin VIP Workflow
 * GET /admin/vip → danh sách PENDING requests
 * POST /admin/vip?action=approve&id=X → approve
 * POST /admin/vip?action=reject&id=X → reject
 */
@WebServlet("/admin/vip")
public class AdminVipServlet extends HttpServlet {

    private final VipRequestDAO vipDAO = new VipRequestDAO();
    private final AdminService adminSvc = new AdminService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = getAdmin(req, resp);
        if (admin == null)
            return;

        req.setAttribute("pendingRequests", vipDAO.findPending());
        req.getRequestDispatcher("/WEB-INF/views/admin/vip_queue.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = getAdmin(req, resp);
        if (admin == null)
            return;

        String action = req.getParameter("action");
        String idStr = req.getParameter("id");
        String note = req.getParameter("note");

        try {
            int requestId = Integer.parseInt(idStr);
            if ("approve".equals(action)) {
                adminSvc.approveVip(admin.getUserId(), requestId, note);
                req.getSession().setAttribute("flash", "✅ Đã approve VIP request #" + requestId);
            } else if ("reject".equals(action)) {
                adminSvc.rejectVip(admin.getUserId(), requestId, note);
                req.getSession().setAttribute("flash", "❌ Đã reject VIP request #" + requestId);
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flash", "⚠️ Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/vip");
    }

    private User getAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return null;
        }
        return user;
    }
}
