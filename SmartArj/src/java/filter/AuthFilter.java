package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.*;
import model.User;

import java.io.IOException;

/**
 * Filter kiểm tra authentication cho các trang cần đăng nhập
 */
@WebFilter(urlPatterns = { "/dashboard","/DashboardServlet", "/zones", "/crops", "/upgrade", "/admin", "/admin/*" })
public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;

        // Lấy session
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Nếu chưa đăng nhập
        if (user == null) {
            String requestedUrl = req.getRequestURI();
            session = req.getSession(true);
            session.setAttribute("redirectAfterLogin", requestedUrl);
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Kiểm tra quyền ADMIN cho route /admin/*
        String uri = req.getRequestURI();
        if (uri.contains("/admin") && !user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/dashboard");
            return;
        }

        // Đã đăng nhập (và đủ quyền), cho phép tiếp tục
        chain.doFilter(request, response);
    }

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {
        // Khởi tạo filter
    }

    @Override
    public void destroy() {
        // Cleanup
    }
}
