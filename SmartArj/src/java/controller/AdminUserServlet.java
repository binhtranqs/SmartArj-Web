package controller;

import dao.AdminAuditLogDAO;
import dao.UserDAO;
import dao.ZoneDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import model.User;
import service.AdminService;
import service.ZoneCropService;

import java.io.IOException;
import java.util.List;
import java.util.stream.Collectors;

/**
 * Quản lý danh sách user: xem, search, lock, unlock
 * GET /admin/users → danh sách user (filter: role, status, q)
 * GET /admin/users?view=X → profile user X
 * POST /admin/users?action=lock → lock user
 * POST /admin/users?action=unlock → unlock user
 */
@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AdminService adminSvc = new AdminService();
    private final AdminAuditLogDAO auditDAO = new AdminAuditLogDAO();
    private final ZoneDAO zoneDAO = new ZoneDAO();
    private final ZoneCropService zoneCropService = new ZoneCropService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = getAdmin(req, resp);
        if (admin == null)
            return;

        String view = req.getParameter("view");

        if (view != null) {
            // Xem profile user cụ thể
            try {
                int targetId = Integer.parseInt(view);
                User target = userDAO.findById(targetId);
                req.setAttribute("targetUser", target);
                req.setAttribute("auditLogs", auditDAO.findByTargetUser(targetId));
                // Load zones và crops của user này
                req.setAttribute("userZones", zoneDAO.findByOwner(targetId));
                req.setAttribute("userCrops", zoneCropService.findByOwner(targetId));
                req.getRequestDispatcher("/WEB-INF/views/admin/user_detail.jsp").forward(req, resp);
            } catch (Exception e) {
                resp.sendRedirect(req.getContextPath() + "/admin/users");
            }
            return;
        }

        // Danh sách user với filter
        String roleFilter = req.getParameter("role"); // USER | ADMIN | (null=all)
        String statusFilter = req.getParameter("status"); // active | locked | (null=all)
        String query = req.getParameter("q"); // search by username/email

        List<User> users = userDAO.findAll();

        if (roleFilter != null && !roleFilter.isEmpty())
            users = users.stream().filter(u -> roleFilter.equalsIgnoreCase(u.getRole())).collect(Collectors.toList());

        if ("locked".equals(statusFilter))
            users = users.stream().filter(u -> !Boolean.TRUE.equals(u.getIsActive())).collect(Collectors.toList());
        else if ("active".equals(statusFilter))
            users = users.stream().filter(u -> Boolean.TRUE.equals(u.getIsActive())).collect(Collectors.toList());

        if (query != null && !query.isBlank()) {
            String q = query.toLowerCase();
            users = users.stream().filter(u -> (u.getUsername() != null && u.getUsername().toLowerCase().contains(q)) ||
                    (u.getEmail() != null && u.getEmail().toLowerCase().contains(q)) ||
                    (u.getFullName() != null && u.getFullName().toLowerCase().contains(q)))
                    .collect(Collectors.toList());
        }

        req.setAttribute("users", users);
        req.setAttribute("roleFilter", roleFilter);
        req.setAttribute("statusFilter", statusFilter);
        req.setAttribute("query", query);
        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        User admin = getAdmin(req, resp);
        if (admin == null)
            return;

        String action = req.getParameter("action");
        String targetId = req.getParameter("userId");
        String reason = req.getParameter("reason");
        String newRole = req.getParameter("role");

        try {
            int tid = Integer.parseInt(targetId);
            switch (action == null ? "" : action) {
                case "lock":
                    adminSvc.lockUser(admin.getUserId(), tid, reason);
                    req.getSession().setAttribute("flash", "✅ Đã khóa tài khoản.");
                    break;
                case "unlock":
                    adminSvc.unlockUser(admin.getUserId(), tid);
                    req.getSession().setAttribute("flash", "✅ Đã mở khóa tài khoản.");
                    break;
                case "changeRole":
                    adminSvc.changeRole(admin.getUserId(), tid, newRole);
                    req.getSession().setAttribute("flash", "✅ Đã đổi role thành " + newRole);
                    break;
                default:
                    req.getSession().setAttribute("flash", "⚠️ Hành động không hợp lệ.");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("flash", "❌ Lỗi: " + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
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
