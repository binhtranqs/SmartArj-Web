package controller;

import config.VNPayConfig;
import jakarta.persistence.EntityManager;
import jakarta.persistence.EntityTransaction;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Transaction;
import model.User;
import system.events.EventPublisher;
import system.events.types.PaymentSuccessEvent;
import util.JPAUtil;
import util.VNPayUtil;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/payment/vnpay/return")
public class VNPayReturnServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

        Map<String, String> params = collectVNPayParams(req);
        String receivedHash = req.getParameter("vnp_SecureHash");

        String txnRef = params.get("vnp_TxnRef");
        String responseCode = params.get("vnp_ResponseCode");
        String providerTxnId = params.get("vnp_TransactionNo");

        boolean signatureValid = VNPayUtil.verifySignature(params, receivedHash, VNPayConfig.VNP_HASH_SECRET);

        boolean success = false;
        String message;
        Transaction transaction = null;

        EntityManager em = JPAUtil.getEntityManager();
        EntityTransaction dbTx = em.getTransaction();

        try {
            dbTx.begin();

            transaction = findByProviderTxnRef(em, txnRef);
            if (transaction == null) {
                message = "Không tìm thấy giao dịch";
            } else if (!signatureValid) {
                // signature invalid => do NOT mark success
                if (!"SUCCESS".equalsIgnoreCase(transaction.getStatus())) {
                    transaction.setStatus("FAILED");
                }
                message = "Chữ ký không hợp lệ";
            } else if ("00".equals(responseCode)) {
                // success
                if (!"SUCCESS".equalsIgnoreCase(transaction.getStatus())) {
                    transaction.setStatus("SUCCESS");
                    transaction.setProviderTxnId(providerTxnId);
                    applyVipUpgrade(transaction.getUser(), transaction.getVipDuration());
                }
                success = true;
                message = "Thanh toán thành công";

                // EVENT: VNPay payment confirmed
                Integer uid = (transaction.getUser() != null) ? transaction.getUser().getUserId() : null;
                int vipDays = (transaction.getVipDuration() != null) ? transaction.getVipDuration() : 0;
                double amt  = (transaction.getAmount() != null) ? transaction.getAmount().doubleValue() : 0d;
                EventPublisher.publish(new PaymentSuccessEvent(uid, txnRef, amt, vipDays));
            } else {
                // failed
                if (!"SUCCESS".equalsIgnoreCase(transaction.getStatus())) {
                    transaction.setStatus("FAILED");
                }
                message = "Thanh toán thất bại";
            }

            dbTx.commit();
        } catch (Exception e) {
            if (dbTx.isActive())
                dbTx.rollback();
            throw new ServletException("Lỗi xử lý callback VNPay", e);
        } finally {
            em.close();
        }

        // Sync session user if the transaction belongs to current session user
        if (transaction != null && req.getSession(false) != null) {
            Object sessionUserObj = req.getSession(false).getAttribute("user");
            if (sessionUserObj instanceof User) {
                User sessionUser = (User) sessionUserObj;
                if (transaction.getUser() != null
                        && transaction.getUser().getUserId() != null
                        && transaction.getUser().getUserId().equals(sessionUser.getUserId())) {
                    sessionUser.setAccountType(transaction.getUser().getAccountType());
                    sessionUser.setVipExpiryDate(transaction.getUser().getVipExpiryDate());
                    req.getSession(false).setAttribute("user", sessionUser);
                }
            }
        }

        req.setAttribute("paymentSuccess", success);
        req.setAttribute("paymentMessage", message);
        req.setAttribute("signatureValid", signatureValid);
        req.setAttribute("responseCode", responseCode);
        req.setAttribute("transaction", transaction);

        req.getRequestDispatcher("/WEB-INF/views/payment/result.jsp").forward(req, resp);
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

    private Transaction findByProviderTxnRef(EntityManager em, String providerTxnRef) {
        if (providerTxnRef == null || providerTxnRef.trim().isEmpty())
            return null;

        List<Transaction> rows = em.createQuery(
                "SELECT t FROM Transaction t JOIN FETCH t.user WHERE t.providerTxnRef = :ref",
                Transaction.class)
                .setParameter("ref", providerTxnRef)
                .setMaxResults(1)
                .getResultList();

        return rows.isEmpty() ? null : rows.get(0);
    }

    private void applyVipUpgrade(User user, Integer vipDuration) {
        if (user == null || vipDuration == null || vipDuration <= 0)
            return;

        LocalDateTime now = LocalDateTime.now();
        LocalDateTime currentExpiry = user.getVipExpiryDate();
        LocalDateTime nextExpiry = (currentExpiry == null || currentExpiry.isBefore(now))
                ? now.plusDays(vipDuration)
                : currentExpiry.plusDays(vipDuration);

        user.setVipExpiryDate(nextExpiry);
        user.setAccountType("VIP");
    }
}
