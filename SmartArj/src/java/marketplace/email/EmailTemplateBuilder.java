package marketplace.email;

import marketplace.model.Order;
import marketplace.model.OrderItem;

import java.math.BigDecimal;
import java.text.NumberFormat;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;

/**
 * Builds HTML email templates for order receipts/invoices.
 *
 * All methods are static — no state, fully thread-safe.
 */
public final class EmailTemplateBuilder {

    private static final NumberFormat VND_FORMAT = NumberFormat.getNumberInstance(new Locale("vi", "VN"));
    private static final DateTimeFormatter DATE_FMT = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

    private EmailTemplateBuilder() {}

    /**
     * Builds a full HTML order-confirmation email for the given order.
     *
     * @param order The order object (must include items and buyer info)
     * @return HTML string ready to be used as email body
     */
    public static String buildOrderConfirmation(Order order) {
        String buyerName    = order.getBuyerName() != null ? order.getBuyerName() : "Quý khách";
        String orderId      = String.valueOf(order.getOrderId());
        String orderDate    = order.getCreatedAt() != null ? order.getCreatedAt().format(DATE_FMT) : "—";

        // Order status: just placed → always "Chờ xác nhận"
        String orderStatus  = "⏳ Chờ xác nhận";
        String orderColor   = "#e67e22";

        // Payment status: VNPAY = already paid; COD = unpaid
        String payStatus    = "VNPAY".equalsIgnoreCase(order.getPaymentMethod()) ? "✅ Đã thanh toán (VNPAY)" : "💵 Thanh toán khi nhận hàng";
        String payColor     = "VNPAY".equalsIgnoreCase(order.getPaymentMethod()) ? "#27ae60" : "#555";

        String shipAddress  = order.getShipAddress() != null ? order.getShipAddress() : "—";
        String itemsHtml    = buildItemsRows(order.getItems());
        String total        = formatVnd(order.getTotalAmount());

        return "<!DOCTYPE html>\n" +
            "<html lang='vi'>\n" +
            "<head><meta charset='UTF-8'><meta name='viewport' content='width=device-width,initial-scale=1'>\n" +
            "<title>Xác nhận đơn hàng #" + orderId + "</title></head>\n" +
            "<body style='margin:0;padding:0;background:#f4f7f6;font-family:Arial,Helvetica,sans-serif;'>\n" +

            // Outer wrapper
            "<table width='100%' cellpadding='0' cellspacing='0' style='background:#f4f7f6;padding:32px 0;'>\n" +
            "<tr><td align='center'>\n" +
            "<table width='620' cellpadding='0' cellspacing='0' style='background:#ffffff;border-radius:12px;overflow:hidden;box-shadow:0 4px 20px rgba(0,0,0,0.08);'>\n" +

            // Header
            "<tr><td style='background:linear-gradient(135deg,#1B5E20,#2E7D32);padding:32px 36px;text-align:center;'>\n" +
            "  <div style='font-size:28px;color:#fff;font-weight:700;letter-spacing:-1px;'>🌿 SmartArj</div>\n" +
            "  <div style='color:rgba(255,255,255,0.8);font-size:13px;margin-top:4px;'>Sàn Nông Sản Thông Minh</div>\n" +
            "  <div style='margin-top:20px;background:rgba(255,255,255,0.15);border-radius:8px;padding:12px 20px;display:inline-block;'>\n" +
            "    <div style='color:#fff;font-size:11px;letter-spacing:1px;text-transform:uppercase;'>Xác nhận đơn hàng</div>\n" +
            "    <div style='color:#fff;font-size:22px;font-weight:700;margin-top:2px;'>#" + orderId + "</div>\n" +
            "  </div>\n" +
            "</td></tr>\n" +

            // Greeting
            "<tr><td style='padding:28px 36px 16px;'>\n" +
            "  <p style='margin:0 0 8px;font-size:16px;color:#1B5E20;font-weight:700;'>Xin chào " + escapeHtml(buyerName) + " 👋</p>\n" +
            "  <p style='margin:0;color:#555;font-size:14px;line-height:1.6;'>Cảm ơn bạn đã đặt hàng trên SmartArj. Đơn hàng của bạn đã được ghi nhận.</p>\n" +
            "</td></tr>\n" +

            // Order info
            "<tr><td style='padding:0 36px 20px;'>\n" +
            "  <table width='100%' cellpadding='10' cellspacing='0' style='background:#f8faf9;border-radius:10px;border:1px solid #E8F5E9;'>\n" +
            "    <tr>\n" +
            "      <td style='font-size:13px;color:#555;'>📅 Ngày đặt hàng</td>\n" +
            "      <td style='font-size:13px;color:#222;font-weight:600;text-align:right;'>" + orderDate + "</td>\n" +
            "    </tr>\n" +
            "    <tr style='border-top:1px solid #E8F5E9;'>\n" +
            "      <td style='font-size:13px;color:#555;'>📦 Trạng thái xử lý</td>\n" +
            "      <td style='font-size:13px;font-weight:700;text-align:right;color:" + orderColor + ";'>" + orderStatus + "</td>\n" +
            "    </tr>\n" +
            "    <tr style='border-top:1px solid #E8F5E9;'>\n" +
            "      <td style='font-size:13px;color:#555;'>🚚 Địa chỉ nhận hàng</td>\n" +
            "      <td style='font-size:13px;color:#222;font-weight:600;text-align:right;'>" + escapeHtml(shipAddress) + "</td>\n" +
            "    </tr>\n" +
            "    <tr style='border-top:1px solid #E8F5E9;'>\n" +
            "      <td style='font-size:13px;color:#555;'>💰 Thanh toán</td>\n" +
            "      <td style='font-size:13px;font-weight:700;text-align:right;color:" + payColor + ";'>" + payStatus + "</td>\n" +
            "    </tr>\n" +
            "  </table>\n" +
            "</td></tr>\n" +

            // Products table
            "<tr><td style='padding:0 36px 20px;'>\n" +
            "  <div style='font-size:14px;font-weight:700;color:#1B5E20;margin-bottom:12px;'>🛒 Sản phẩm đã mua</div>\n" +
            "  <table width='100%' cellpadding='0' cellspacing='0' style='border-collapse:collapse;'>\n" +
            "    <thead>\n" +
            "      <tr style='background:#1B5E20;color:#fff;font-size:12px;'>\n" +
            "        <th style='padding:10px 12px;text-align:left;border-radius:6px 0 0 0;'>Sản phẩm</th>\n" +
            "        <th style='padding:10px 12px;text-align:center;'>Số lượng</th>\n" +
            "        <th style='padding:10px 12px;text-align:right;'>Đơn giá</th>\n" +
            "        <th style='padding:10px 12px;text-align:right;border-radius:0 6px 0 0;'>Thành tiền</th>\n" +
            "      </tr>\n" +
            "    </thead>\n" +
            "    <tbody>\n" +
            itemsHtml +
            "    </tbody>\n" +
            "  </table>\n" +
            "</td></tr>\n" +

            // Total
            "<tr><td style='padding:0 36px 28px;'>\n" +
            "  <table width='100%' cellpadding='0' cellspacing='0'>\n" +
            "    <tr><td></td><td width='260' style='background:#E8F5E9;border-radius:10px;padding:16px 20px;'>\n" +
            "      <table width='100%' cellpadding='6' cellspacing='0'>\n" +
            "        <tr><td style='font-size:13px;color:#555;'>Tổng cộng:</td><td style='text-align:right;font-size:20px;font-weight:800;color:#1B5E20;'>" + total + " đ</td></tr>\n" +
            "      </table>\n" +
            "    </td></tr>\n" +
            "  </table>\n" +
            "</td></tr>\n" +

            // Footer
            "<tr><td style='background:#f8faf9;border-top:1px solid #E8F5E9;padding:20px 36px;text-align:center;'>\n" +
            "  <p style='margin:0;font-size:12px;color:#888;'>© 2026 SmartArj — Sàn Nông Sản Thông Minh. Mọi thắc mắc vui lòng liên hệ hỗ trợ.<br>Email này được tự động gửi — vui lòng không trả lời.</p>\n" +
            "</td></tr>\n" +

            "</table>\n" + // inner table end
            "</td></tr>\n" +
            "</table>\n" + // outer table end
            "</body></html>";
    }

    private static String buildItemsRows(List<OrderItem> items) {
        if (items == null || items.isEmpty()) {
            return "<tr><td colspan='4' style='text-align:center;color:#aaa;padding:16px;font-size:13px;'>Không có sản phẩm</td></tr>\n";
        }
        StringBuilder sb = new StringBuilder();
        boolean odd = true;
        for (OrderItem item : items) {
            String bg = odd ? "#ffffff" : "#f8fdf9";
            odd = !odd;
            BigDecimal subtotal = item.getQuantity() != null && item.getUnitPrice() != null
                ? item.getQuantity().multiply(item.getUnitPrice())
                : BigDecimal.ZERO;
            sb.append("<tr style='background:").append(bg).append(";'>\n")
              .append("  <td style='padding:12px;border-bottom:1px solid #f0f0f0;font-size:13px;color:#333;'>")
              .append(escapeHtml(item.getProductName() != null ? item.getProductName() : "—"))
              .append("</td>\n")
              .append("  <td style='padding:12px;border-bottom:1px solid #f0f0f0;font-size:13px;color:#333;text-align:center;'>")
              .append(item.getQuantity() != null ? item.getQuantity().stripTrailingZeros().toPlainString() : "0")
              .append("</td>\n")
              .append("  <td style='padding:12px;border-bottom:1px solid #f0f0f0;font-size:13px;color:#333;text-align:right;'>")
              .append(formatVnd(item.getUnitPrice())).append(" đ")
              .append("</td>\n")
              .append("  <td style='padding:12px;border-bottom:1px solid #f0f0f0;font-size:13px;font-weight:700;color:#1B5E20;text-align:right;'>")
              .append(formatVnd(subtotal)).append(" đ")
              .append("</td>\n")
              .append("</tr>\n");
        }
        return sb.toString();
    }

    private static String formatVnd(BigDecimal amount) {
        if (amount == null) return "0";
        return VND_FORMAT.format(amount);
    }

    private static String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
