package controller;

import config.VNPayConfig;
import dao.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Transaction;
import model.User;
import service.PaymentService;
import util.VNPayUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.TimeZone;

@WebServlet("/vip/checkout")
public class VipCheckoutServlet extends HttpServlet {

    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/vip/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        User user = getCurrentUser(req);
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            int days = parsePlanDays(req.getParameter("days"));
            double price = paymentService.calculatePrice(days);
            BigDecimal amount = BigDecimal.valueOf(paymentService.calculatePrice(days))
            .setScale(0, RoundingMode.HALF_UP); // nếu giá là VND nguyên
            String providerTxnRef = "VIP" + System.currentTimeMillis();

            Transaction tx = new Transaction();
            tx.setUser(user);
            tx.setAmount(amount);
            tx.setDescription("Thanh toan goi VIP " + days + " ngay");
            tx.setPaymentMethod("VNPAY");
            tx.setStatus("PENDING");
            tx.setTransactionType("VIP");
            tx.setVipDuration(days);
            tx.setProviderTxnRef(providerTxnRef);
            transactionDAO.create(tx);
            String vnpAmount = amount.multiply(BigDecimal.valueOf(100)).toPlainString();
            Map<String, String> params = new HashMap<String, String>();
            params.put("vnp_Version", "2.1.0");
            params.put("vnp_Command", "pay");
            params.put("vnp_TmnCode", VNPayConfig.VNP_TMN_CODE);
            params.put("vnp_Amount", vnpAmount);
            params.put("vnp_CurrCode", "VND");
            params.put("vnp_TxnRef", providerTxnRef);
            params.put("vnp_OrderInfo", "Thanh toan VIP " + days + " ngay");
            params.put("vnp_OrderType", "other");
          String returnUrl =
              req.getScheme() + "://" + req.getServerName()
               + ":" + req.getServerPort()
               + req.getContextPath()
               + "/payment/vnpay/return";
            params.put("vnp_ReturnUrl", returnUrl);
            params.put("vnp_CreateDate", formatVNPayDate(new Date()));
            params.put("vnp_IpAddr", getClientIp(req));
            params.put("vnp_Locale", "vn");
            String query = VNPayUtil.buildQueryString(params);
            String secureHash = VNPayUtil.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, query);
            String paymentUrl = VNPayConfig.VNP_PAY_URL + "?" + query + "&vnp_SecureHash=" + secureHash;
            resp.sendRedirect(paymentUrl);
        } catch (Exception e) {
            req.setAttribute("errorMessage", e.getMessage());
            req.setAttribute("errorDetail", e);
            req.getRequestDispatcher("/WEB-INF/views/common/error.jsp").forward(req, resp);
        }
    }

    private User getCurrentUser(HttpServletRequest req) {
        if (req.getSession(false) == null) {
            return null;
        }
        return (User) req.getSession(false).getAttribute("user");
    }

    private int parsePlanDays(String daysParam) {
        if (daysParam == null || daysParam.trim().isEmpty()) {
            throw new IllegalArgumentException("Thiếu tham số gói VIP");
        }
        int days = Integer.parseInt(daysParam.trim());
        if (days <= 0) {
            throw new IllegalArgumentException("Số ngày VIP không hợp lệ");
        }
        return days;
    }

    private String formatVNPayDate(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        sdf.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        return sdf.format(date);
    }

    private String getClientIp(HttpServletRequest req) {
    String xForwardedFor = req.getHeader("X-Forwarded-For");
    String ip = null;

    if (xForwardedFor != null && !xForwardedFor.trim().isEmpty()) {
        ip = xForwardedFor.split(",")[0].trim();
    } else {
        ip = req.getRemoteAddr();
    }

    // VNPay sandbox hay không nhận IPv6 -> ép về IPv4 loopback
    if (ip == null || ip.isEmpty()) return "127.0.0.1";
    if (ip.equals("0:0:0:0:0:0:0:1") || ip.equals("::1") || ip.contains(":")) {
        return "127.0.0.1";
    }
    return ip;
}
}
