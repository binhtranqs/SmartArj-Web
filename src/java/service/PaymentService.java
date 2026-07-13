package service;

import dao.UserDAO;
import model.User;

/**
 * Service xử lý thanh toán và nâng cấp VIP
 */
public class PaymentService {

    private final UserDAO userDAO = new UserDAO();

    /**
     * Kiểm tra và hạ cấp VIP đã hết hạn
     */
    public void checkAndDowngradeExpiredVIP(User user) {
        if (user.isVIPExpired()) {
            user.setAccountType("FREE");
            userDAO.update(user);
        }
    }

    /**
     * Tính giá VIP theo số ngày
     */
    public double calculatePrice(int days) {
        if (days == 30) {
            return 99000; // 1 tháng
        } else if (days == 90) {
            return 249000; // 3 tháng (giảm 15%)
        } else if (days == 365) {
            return 899000; // 1 năm (giảm 25%)
        } else {
            // Tính theo ngày: 3,500 VND/ngày
            return days * 3500;
        }
    }

    /**
     * Lấy tên gói VIP
     */
    public String getPackageName(int days) {
        if (days == 30)
            return "VIP 1 Tháng";
        if (days == 90)
            return "VIP 3 Tháng";
        if (days == 365)
            return "VIP 1 Năm";
        return "VIP " + days + " Ngày";
    }
}
