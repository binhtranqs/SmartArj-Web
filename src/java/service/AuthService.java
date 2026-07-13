package service;

import dao.UserDAO;
import jakarta.servlet.http.HttpSession;
import model.User;
import util.PasswordUtil;

import java.time.LocalDateTime;

/**
 * Service xử lý authentication (đăng nhập, đăng ký, đăng xuất)
 */
public class AuthService {

    private final UserDAO userDAO = new UserDAO();

    /**
     * Đăng ký user mới
     * 
     * @return User đã tạo, hoặc null nếu lỗi
     */
    public User register(String username, String email, String password, String fullName, Integer cityId) {
        // Kiểm tra username đã tồn tại
        if (userDAO.usernameExists(username)) {
            throw new RuntimeException("Tên đăng nhập đã tồn tại");
        }

        // Kiểm tra email đã tồn tại
        if (userDAO.emailExists(email)) {
            throw new RuntimeException("Email đã được sử dụng");
        }

        // Kiểm tra độ mạnh mật khẩu
        if (!PasswordUtil.isStrongPassword(password)) {
            throw new RuntimeException("Mật khẩu phải có ít nhất 6 ký tự");
        }

        // Tạo user mới
        User user = new User();
        user.setUsername(username);
        user.setEmail(email);
        user.setPasswordHash(PasswordUtil.hashPassword(password));
        user.setFullName(fullName);
        user.setCityId(cityId); // Set CityID
        user.setAccountType("FREE"); // Mặc định là FREE
        user.setCreatedAt(LocalDateTime.now());
        user.setIsActive(true);

        userDAO.create(user);
        return user;
    }

    /**
     * Đăng nhập
     * 
     * @return User nếu thành công, null nếu thất bại
     */
    public User login(String username, String password) {
        User user = userDAO.checkLogin(username, password);
        if (user == null) {
            throw new RuntimeException("Tên đăng nhập hoặc mật khẩu không đúng");
        }

        if (!user.getIsActive()) {
            throw new RuntimeException("Tài khoản đã bị khóa");
        }

        return user;
    }

    /**
     * Đăng xuất
     */
    public void logout(HttpSession session) {
        if (session != null) {
            session.invalidate();
        }
    }

    /**
     * Kiểm tra user đã đăng nhập chưa
     */
    public boolean isAuthenticated(HttpSession session) {
        return session != null && session.getAttribute("user") != null;
    }

    /**
     * Lấy user hiện tại từ session
     */
    public User getCurrentUser(HttpSession session) {
        if (session == null) {
            return null;
        }
        return (User) session.getAttribute("user");
    }

    /**
     * Lưu user vào session
     */
    public void setCurrentUser(HttpSession session, User user) {
        if (session != null && user != null) {
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 phút
        }
    }

    /**
     * Refresh thông tin user từ database
     */
    public User refreshUser(User user) {
        if (user == null || user.getUserId() == null) {
            return null;
        }
        return userDAO.findById(user.getUserId());
    }
}
