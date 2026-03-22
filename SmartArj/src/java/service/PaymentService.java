package service;

import dao.TransactionDAO;
import dao.UserDAO;
import model.Transaction;
import model.User;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Service xử lý thanh toán và nâng cấp VIP
 */
public class PaymentService {

    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final UserDAO userDAO = new UserDAO();

    /**
     * Tạo giao dịch nâng cấp VIP
     */
    public Transaction createVIPUpgrade(User user, int days, double amount, String paymentMethod) {
        Transaction transaction = new Transaction();
        transaction.setUser(user);
        transaction.setAmount(BigDecimal.valueOf(amount));
        transaction.setTransactionType("VIP_UPGRADE");
        transaction.setStatus("PENDING");
        transaction.setPaymentMethod(paymentMethod);
        transaction.setVipDuration(days);
        transaction.setDescription("Nâng cấp VIP " + days + " ngày");
        transaction.setTransactionDate(LocalDateTime.now());

        transactionDAO.create(transaction);
        return transaction;
    }

    /**
     * Xử lý thanh toán (giả lập cho development)
     * Trong production sẽ tích hợp với VNPay, MoMo, etc.
     */
    public boolean processPayment(Transaction transaction) {
        try {
            // Giả lập xử lý thanh toán
            // Trong thực tế sẽ gọi API của payment gateway

            // Giả sử thanh toán thành công
            transaction.setStatus("COMPLETED");
            transactionDAO.update(transaction);

            // Nâng cấp user lên VIP
            upgradeToVIP(transaction.getUser(), transaction.getVipDuration());

            return true;
        } catch (Exception e) {
            transaction.setStatus("FAILED");
            transactionDAO.update(transaction);
            return false;
        }
    }

    /**
     * Nâng cấp user lên VIP
     */
    public void upgradeToVIP(User user, int days) {
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime expiryDate;

        // Nếu user đã là VIP và chưa hết hạn, cộng thêm ngày
        if (user.isVIP()) {
            expiryDate = user.getVipExpiryDate().plusDays(days);
        } else {
            // Nếu chưa phải VIP hoặc đã hết hạn, tính từ hôm nay
            expiryDate = now.plusDays(days);
        }

        user.setAccountType("VIP");
        user.setVipExpiryDate(expiryDate);
        userDAO.update(user);
    }

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
