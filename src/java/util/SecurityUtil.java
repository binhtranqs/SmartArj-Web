package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import model.Zone;
import service.ZoneService;

import java.io.IOException;

/**
 * Utility class tái sử dụng cho kiểm tra xác thực và quyền sở hữu tài nguyên.
 * Dùng thống nhất ở tất cả servlet để tránh IDOR.
 */
public class SecurityUtil {

    private SecurityUtil() {
        // Utility class - không instantiate
    }

    /**
     * Lấy User hiện tại từ session.
     *
     * @return User nếu đã đăng nhập, null nếu chưa
     */
    public static User requireUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null)
            return null;
        return (User) session.getAttribute("user");
    }

    /**
     * Kiểm tra zone có tồn tại và thuộc về user đang đăng nhập không.
     *
     * @param req         HttpServletRequest (để lấy session)
     * @param zoneId      ID của zone cần kiểm tra
     * @param zoneService ZoneService instance
     * @return Zone nếu hợp lệ và thuộc về user, null nếu không có quyền hoặc không
     *         tìm thấy
     */
    public static Zone requireOwnedZone(HttpServletRequest req, int zoneId, ZoneService zoneService) {
        User user = requireUser(req);
        if (user == null)
            return null;
        return zoneService.getByIdForOwner(zoneId, user.getUserId());
    }

    /**
     * Ghi response 403 Forbidden dạng JSON.
     * Gọi ngay sau khi phát hiện ownership check thất bại.
     */
    public static void sendForbidden(HttpServletResponse resp) throws IOException {
        resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write("{\"error\":\"Forbidden\"}");
    }

    /**
     * Ghi response 401 Unauthorized dạng JSON.
     */
    public static void sendUnauthorized(HttpServletResponse resp) throws IOException {
        resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write("{\"error\":\"Unauthorized\"}");
    }

    /**
     * Ghi response 400 Bad Request dạng JSON.
     */
    public static void sendBadRequest(HttpServletResponse resp, String message) throws IOException {
        resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        resp.getWriter().write("{\"error\":\"Bad Request\",\"message\":\"" + escapeJson(message) + "\"}");
    }

    /**
     * Escape ký tự đặc biệt trong chuỗi JSON đơn giản.
     */
    private static String escapeJson(String s) {
        if (s == null)
            return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}
