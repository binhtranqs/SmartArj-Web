package marketplace.controller;

import config.VNPayConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import marketplace.model.*;
import marketplace.service.BuyerService;
import marketplace.email.ReceiptEmailService;
import model.User;
import util.VNPayUtil;

import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

/**
 * Buyer Cart & Checkout Servlet
 * URL: /buyer/cart, /buyer/cart/add, /buyer/cart/remove, /buyer/checkout
 */
@WebServlet(urlPatterns = {
        "/buyer/cart",
        "/buyer/cart/add",
        "/buyer/cart/update",
        "/buyer/cart/remove",
        "/buyer/checkout"
})
public class BuyerCartServlet extends HttpServlet {

    private final BuyerService buyerService = new BuyerService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User user = requireLogin(req, resp);
        if (user == null) return;

        String path = req.getServletPath();

        if (path.endsWith("/cart")) {
            List<CartItem> cart = buyerService.getCart(user.getUserId());
            BigDecimal total = cart.stream()
                    .filter(CartItem::isAvailable)          // chỉ tính tổng cho items khả dụng
                    .map(CartItem::getSubTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            long unavailableCount = cart.stream().filter(c -> !c.isAvailable()).count();
            req.setAttribute("cartItems", cart);
            req.setAttribute("cartTotal", total);
            req.setAttribute("unavailableCount", unavailableCount);
            req.getRequestDispatcher("/WEB-INF/views/marketplace/cart.jsp").forward(req, resp);

        } else if (path.endsWith("/checkout")) {
            // Lấy selectedIds từ query params (truyền từ cart.jsp checkbox form)
            String[] cartIdParams = req.getParameterValues("cartId");
            List<Integer> selectedIds = parseCartIds(cartIdParams);

            List<CartItem> cart = buyerService.getCart(user.getUserId());
            List<CartItem> selectedCart = filterCart(cart, selectedIds);
            if (selectedCart.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/buyer/cart?error=empty");
                return;
            }
            BigDecimal total = selectedCart.stream()
                    .map(CartItem::getSubTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add);
            req.setAttribute("cartItems", selectedCart);
            req.setAttribute("cartTotal", total);
            req.setAttribute("selectedCartIds", selectedIds);
            req.getRequestDispatcher("/WEB-INF/views/marketplace/checkout.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User user = requireLogin(req, resp);
        if (user == null) return;

        String path = req.getServletPath();

        if (path.endsWith("/add")) {
            handleAddToCart(req, resp, user);
        } else if (path.endsWith("/remove")) {
            handleRemoveFromCart(req, resp, user);
        } else if (path.endsWith("/update")) {
            handleUpdateCart(req, resp, user);
        } else if (path.endsWith("/checkout")) {
            handleCheckout(req, resp, user);
        }
    }

    // ── Add to cart ──────────────────────────────────────────────────────────
    // Hỗ trợ cả AJAX (param ajax=1) và form POST thông thường
    private void handleAddToCart(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        boolean isAjax = "1".equals(req.getParameter("ajax"));
        try {
            int listingId = Integer.parseInt(req.getParameter("listingId"));
            String qtyStr = req.getParameter("quantity");
            BigDecimal qty = (qtyStr != null && !qtyStr.isEmpty())
                    ? new BigDecimal(qtyStr) : BigDecimal.ONE;
            int cartId = buyerService.addToCart(user.getUserId(), listingId, qty);

            // Handle Buy Now flow directly to checkout
            if ("buy_now".equals(req.getParameter("action"))) {
                resp.sendRedirect(req.getContextPath() + "/buyer/checkout?cartId=" + cartId);
                return;
            }

            if (isAjax) {
                // AJAX: trả về JSON 200 (không redirect)
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"ok\":true}");
            } else {
                String redirect = req.getParameter("redirect");
                if (redirect != null && !redirect.isEmpty()) {
                    resp.sendRedirect(req.getContextPath() + "/" + redirect + "?success=added_to_cart");
                } else {
                    resp.sendRedirect(req.getContextPath() + "/marketplace?success=added_to_cart");
                }
            }
        } catch (Exception e) {
            if (isAjax) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"ok\":false,\"msg\":\"" + escapeJson(e.getMessage()) + "\"}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/marketplace?error=" + escape(e.getMessage()));
            }
        }
    }

    // ── Remove from cart ──────────────────────────────────────────────────────
    private void handleRemoveFromCart(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        try {
            int cartId = Integer.parseInt(req.getParameter("cartId"));
            buyerService.removeFromCart(cartId, user.getUserId());
        } catch (Exception e) {
            // ignore
        }
        resp.sendRedirect(req.getContextPath() + "/buyer/cart");
    }

    // ── Update cart ───────────────────────────────────────────────────────────
    private void handleUpdateCart(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException {
        try {
            int cartId = Integer.parseInt(req.getParameter("cartId"));
            String qtyStr = req.getParameter("quantity");
            if (qtyStr != null && !qtyStr.isEmpty()) {
                BigDecimal qty = new BigDecimal(qtyStr);
                buyerService.updateCartQty(user.getUserId(), cartId, qty);
            }
            resp.sendRedirect(req.getContextPath() + "/buyer/cart");
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/buyer/cart?error=" + escape(e.getMessage()));
        }
    }

    // ── Checkout dispatcher ───────────────────────────────────────────────────
    private void handleCheckout(HttpServletRequest req, HttpServletResponse resp, User user)
            throws IOException, ServletException {
        String shipAddress = req.getParameter("shipAddress");
        String note = req.getParameter("note");
        String paymentMethod = req.getParameter("paymentMethod");
        // Lấy danh sách cartId được chọn (từ checkout form)
        String[] cartIdParams = req.getParameterValues("cartId");
        List<Integer> selectedIds = parseCartIds(cartIdParams);

        if (shipAddress == null || shipAddress.trim().isEmpty()) {
            req.setAttribute("error", "Vui l\u00f2ng nh\u1eadp \u0111\u1ecba ch\u1ec9 giao h\u00e0ng");
            doGet(req, resp);
            return;
        }
        if (paymentMethod == null) paymentMethod = "COD";

        if ("VNPAY".equalsIgnoreCase(paymentMethod)) {
            handleVNPayCheckout(req, resp, user, shipAddress.trim(), note, selectedIds);
        } else {
            handleCODCheckout(req, resp, user, shipAddress.trim(), note, selectedIds);
        }
    }

    // ── COD: tạo đơn hàng chỉ từ items được chọn ─────────────────────────────
    private void handleCODCheckout(HttpServletRequest req, HttpServletResponse resp,
                                   User user, String shipAddress, String note,
                                   List<Integer> selectedIds)
            throws IOException, ServletException {
        try {
            String buyerName = user.getFullName() != null ? user.getFullName() : user.getUsername();
            int orderId = buyerService.checkoutSelected(user.getUserId(), buyerName, shipAddress, note, selectedIds);
            if (orderId > 0) {
                // Send confirmation email asynchronously on a daemon thread
                Thread emailThread = new Thread(() -> {
                    try {
                        new ReceiptEmailService().sendOrderPlacedEmail(orderId);
                    } catch (Exception e) {
                        e.printStackTrace(); // Logs isolated internally without breaking checkout
                    }
                }, "email-confirm-order-" + orderId);
                emailThread.setDaemon(true);
                emailThread.start();

                resp.sendRedirect(req.getContextPath() + "/buyer/orders?success=order_placed&orderId=" + orderId);
            } else {
                req.setAttribute("error", "Kh\u00f4ng th\u1ec3 t\u1ea1o \u0111\u01a1n h\u00e0ng. Vui l\u00f2ng th\u1eed l\u1ea1i.");
                doGet(req, resp);
            }
        } catch (RuntimeException e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }

    // ── VNPay: lưu session → redirect VNPay ──────────────────────────────────
    private void handleVNPayCheckout(HttpServletRequest req, HttpServletResponse resp,
                                     User user, String shipAddress, String note,
                                     List<Integer> selectedIds)
            throws IOException {
        try {
            List<CartItem> cart = buyerService.getCart(user.getUserId());
            List<CartItem> selected = filterCart(cart, selectedIds);
            if (selected.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/buyer/cart?error=empty");
                return;
            }
            BigDecimal totalAmount = selected.stream()
                    .map(CartItem::getSubTotal)
                    .reduce(BigDecimal.ZERO, BigDecimal::add)
                    .setScale(0, RoundingMode.HALF_UP);

            HttpSession session = req.getSession();
            session.setAttribute("vnpay_shipAddress", shipAddress);
            session.setAttribute("vnpay_note", note);
            session.setAttribute("vnpay_selectedCartIds", selectedIds);

            String txnRef = "MKT" + user.getUserId() + "_" + System.currentTimeMillis();
            session.setAttribute("vnpay_txnRef", txnRef);

            String vnpAmount = totalAmount.multiply(BigDecimal.valueOf(100)).toPlainString();
            Map<String, String> params = new HashMap<>();
            params.put("vnp_Version", "2.1.0");
            params.put("vnp_Command", "pay");
            params.put("vnp_TmnCode", VNPayConfig.VNP_TMN_CODE);
            params.put("vnp_Amount", vnpAmount);
            params.put("vnp_CurrCode", "VND");
            params.put("vnp_TxnRef", txnRef);
            params.put("vnp_OrderInfo", "Thanh toan don hang SmartAgri " + txnRef);
            params.put("vnp_OrderType", "other");
            String returnUrl = req.getScheme() + "://" + req.getServerName()
                    + ":" + req.getServerPort()
                    + req.getContextPath()
                    + "/buyer/vnpay/return";
            params.put("vnp_ReturnUrl", returnUrl);
            params.put("vnp_CreateDate", formatVNPayDate(new Date()));
            params.put("vnp_IpAddr", getClientIp(req));
            params.put("vnp_Locale", "vn");

            String query = VNPayUtil.buildQueryString(params);
            String secureHash = VNPayUtil.hmacSHA512(VNPayConfig.VNP_HASH_SECRET, query);
            String paymentUrl = VNPayConfig.VNP_PAY_URL + "?" + query + "&vnp_SecureHash=" + secureHash;
            resp.sendRedirect(paymentUrl);

        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/buyer/checkout?error=vnpay_failed");
        }
    }

    // ── Helpers ───────────────────────────────────────────────────────────────
    private List<Integer> parseCartIds(String[] params) {
        List<Integer> ids = new java.util.ArrayList<>();
        if (params == null) return ids;
        for (String p : params) {
            try { ids.add(Integer.parseInt(p.trim())); } catch (NumberFormatException ignored) {}
        }
        return ids;
    }

    private List<CartItem> filterCart(List<CartItem> cart, List<Integer> selectedIds) {
        if (selectedIds == null || selectedIds.isEmpty()) return new java.util.ArrayList<CartItem>();
        List<CartItem> result = new java.util.ArrayList<>();
        for (CartItem ci : cart) {
            if (selectedIds.contains(ci.getCartId())) result.add(ci);
        }
        // Bug fix: trả result (có thể rỗng) thay vì fallback về toàn bộ giỏ hàng
        return result;
    }

    private String formatVNPayDate(Date date) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        sdf.setTimeZone(TimeZone.getTimeZone("Asia/Ho_Chi_Minh"));
        return sdf.format(date);
    }

    private String getClientIp(HttpServletRequest req) {
        String xFor = req.getHeader("X-Forwarded-For");
        String ip = (xFor != null && !xFor.isEmpty()) ? xFor.split(",")[0].trim() : req.getRemoteAddr();
        if (ip == null || ip.isEmpty() || ip.equals("0:0:0:0:0:0:0:1") || ip.equals("::1") || ip.contains(":"))
            return "127.0.0.1";
        return ip;
    }

    private User requireLogin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login?redirect=buyer/cart");
            return null;
        }
        return (User) session.getAttribute("user");
    }

    private String escape(String s) {
        return s == null ? "" : s.replace(" ", "+");
    }

    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n");
    }
}
