package marketplace.controller;

import config.VNPayConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.service.BuyerService;
import marketplace.email.ReceiptEmailService;
import model.User;
import util.VNPayUtil;

import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;

/**
 * VNPay Callback Servlet cho đơn hàng Marketplace
 * URL: /buyer/vnpay/return
 *
 * Sau khi VNPay trả về, tạo đơn hàng nếu thanh toán thành công,
 * rồi redirect đến trang kết quả.
 */
@WebServlet("/buyer/vnpay/return")
public class MarketVNPayReturnServlet extends HttpServlet {

    private final BuyerService buyerService = new BuyerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 1. Thu thập tham số VNPay
        Map<String, String> params = collectVNPayParams(req);
        String receivedHash = req.getParameter("vnp_SecureHash");
        String responseCode = params.get("vnp_ResponseCode");
        String txnRef       = params.get("vnp_TxnRef");

        // 2. Xác thực chữ ký
        boolean signatureValid = VNPayUtil.verifySignature(params, receivedHash, VNPayConfig.VNP_HASH_SECRET);

        // 3. Lấy thông tin từ session
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String sessionTxnRef  = (session != null) ? (String) session.getAttribute("vnpay_txnRef")      : null;
        String shipAddress    = (session != null) ? (String) session.getAttribute("vnpay_shipAddress")  : "";
        String note           = (session != null) ? (String) session.getAttribute("vnpay_note")         : "";
        java.util.List<Integer> selectedCartIds = (session != null) ? (java.util.List<Integer>) session.getAttribute("vnpay_selectedCartIds") : null;

        boolean success = false;
        int orderId = -1;
        String message;

        // 4. Kiểm tra txnRef khớp session
        boolean txnMatch = txnRef != null && txnRef.equals(sessionTxnRef);

        if (!signatureValid) {
            message = "Chữ ký VNPay không hợp lệ. Giao dịch bị từ chối.";
        } else if (!txnMatch) {
            message = "Mã giao dịch không khớp. Vui lòng thử lại.";
        } else if ("00".equals(responseCode)) {
            // ── THANH TOÁN THÀNH CÔNG → Tạo đơn hàng với PaymentMethod=VNPAY
            try {
                String buyerName = user.getFullName() != null ? user.getFullName() : user.getUsername();
                orderId = buyerService.checkoutSelected(
                        user.getUserId(),
                        buyerName,
                        shipAddress != null ? shipAddress : "",
                        note,
                        selectedCartIds,
                        "VNPAY");         // ← đánh dấu đã thanh toán online
                if (orderId > 0) {
                    success = true;
                    message = "Thanh toán thành công! Đơn hàng của bạn đã được đặt.";
                    // Xóa session VNPay
                    session.removeAttribute("vnpay_txnRef");
                    session.removeAttribute("vnpay_shipAddress");
                    session.removeAttribute("vnpay_note");
                    session.removeAttribute("vnpay_selectedCartIds");

                    // Send confirmation email asynchronously on a daemon thread
                    int fOrderId = orderId;
                    Thread emailThread = new Thread(() -> {
                        try {
                            new ReceiptEmailService().sendOrderPlacedEmail(fOrderId);
                        } catch (Exception e) {
                            e.printStackTrace(); // Logs isolated internally
                        }
                    }, "email-confirm-vnpay-" + orderId);
                    emailThread.setDaemon(true);
                    emailThread.start();

                } else {
                    message = "Thanh toán thành công nhưng không thể tạo đơn hàng. Liên hệ hỗ trợ.";
                }
            } catch (Exception e) {
                message = "Thanh toán thành công nhưng lỗi xử lý đơn hàng: " + e.getMessage();
            }
        } else {
            message = "Thanh toán thất bại (Mã lỗi: " + responseCode + "). Vui lòng thử lại.";
        }

        // 5. Forward đến trang kết quả
        req.setAttribute("paymentSuccess", success);
        req.setAttribute("paymentMessage", message);
        req.setAttribute("orderId", orderId > 0 ? orderId : null);
        req.setAttribute("txnRef", txnRef);
        req.setAttribute("responseCode", responseCode);
        req.getRequestDispatcher("/WEB-INF/views/marketplace/payment-result.jsp").forward(req, resp);
    }

    private Map<String, String> collectVNPayParams(HttpServletRequest req) {
        Map<String, String> params = new HashMap<>();
        Enumeration<String> names = req.getParameterNames();
        while (names.hasMoreElements()) {
            String name = names.nextElement();
            if (name != null && name.startsWith("vnp_")) {
                params.put(name, req.getParameter(name));
            }
        }
        return params;
    }
}
