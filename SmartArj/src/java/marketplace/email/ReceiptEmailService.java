package marketplace.email;

import marketplace.dao.OrderDAO;
import marketplace.model.Order;
import util.DBContext;
import util.EmailUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.logging.Logger;

/**
 * Service responsible for building and sending order confirmation emails.
 *
 * Call: ReceiptEmailService.sendOrderPlacedEmail(orderId)
 * right after order creation — no events, no listeners needed.
 *
 * All exceptions are caught locally. Failures never propagate upward.
 */
public class ReceiptEmailService {

    private static final Logger log = Logger.getLogger(ReceiptEmailService.class.getName());

    private final OrderDAO orderDAO = new OrderDAO();

    /**
     * Send an order confirmation email immediately after order creation.
     * Call this right after orderId is obtained — no event system needed.
     *
     * @param orderId  ID of the newly created order
     */
    public void sendOrderPlacedEmail(int orderId) {
        try {
            Order order = orderDAO.findById(orderId);
            if (order == null) {
                log.warning("[ReceiptEmailService] Order #" + orderId + " not found — email skipped.");
                return;
            }

            String buyerEmail = getBuyerEmail(order.getBuyerId());
            if (buyerEmail == null || buyerEmail.isBlank()) {
                log.warning("[ReceiptEmailService] Buyer #" + order.getBuyerId() + " has no email — email skipped.");
                return;
            }

            String html    = EmailTemplateBuilder.buildOrderConfirmation(order);
            String subject = "Xác nhận đơn hàng #" + orderId + " - SmartAgri";

            boolean sent = EmailUtil.sendHtmlEmail(buyerEmail, subject, html);
            if (sent) {
                log.info("[ReceiptEmailService] Confirmation sent for order #" + orderId + " to " + buyerEmail);
            } else {
                log.warning("[ReceiptEmailService] Confirmation FAILED for order #" + orderId + " to " + buyerEmail);
            }
        } catch (Exception e) {
            log.severe("[ReceiptEmailService] Unexpected error for order #" + orderId + ": " + e.getMessage());
        }
    }

    /**
     * Fetches the email address of a user by their ID.
     */
    private String getBuyerEmail(int userId) {
        String sql = "SELECT Email FROM Users WHERE UserID = ?";
        try (Connection conn = new DBContext().getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getString("Email");
            }
        } catch (Exception e) {
            log.warning("[ReceiptEmailService] Could not fetch email for user #" + userId + ": " + e.getMessage());
        }
        return null;
    }
}
