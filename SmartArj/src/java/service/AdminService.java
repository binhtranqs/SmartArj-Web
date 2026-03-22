package service;

import dao.AdminAuditLogDAO;
import dao.UserDAO;
import dao.VipRequestDAO;
import model.User;
import model.VipRequest;

import java.time.LocalDateTime;

/**
 * Service xử lý các tác vụ quản trị:
 * Lock/Unlock user, Approve/Reject VIP, ghi Audit Log
 */
public class AdminService {

    private final UserDAO userDAO = new UserDAO();
    private final AdminAuditLogDAO auditDAO = new AdminAuditLogDAO();
    private final VipRequestDAO vipRequestDAO = new VipRequestDAO();

    // -------------------------------------------------------
    // USER MANAGEMENT
    // -------------------------------------------------------

    /**
     * Khóa tài khoản user
     * 
     * @param adminId      admin đang thực hiện
     * @param targetUserId user bị khóa
     * @param reason       lý do khóa
     */
    public void lockUser(Integer adminId, Integer targetUserId, String reason) {
        User target = userDAO.findById(targetUserId);
        if (target == null)
            throw new RuntimeException("Không tìm thấy user ID=" + targetUserId);
        if (target.isAdmin())
            throw new RuntimeException("Không thể khóa tài khoản Admin");

        target.setIsActive(false);
        target.setLockReason(reason);
        userDAO.update(target);

        auditDAO.log(adminId, targetUserId, "LOCK_USER",
                "Lý do: " + (reason != null ? reason : "Không rõ"));
    }

    /**
     * Mở khóa tài khoản user
     */
    public void unlockUser(Integer adminId, Integer targetUserId) {
        User target = userDAO.findById(targetUserId);
        if (target == null)
            throw new RuntimeException("Không tìm thấy user ID=" + targetUserId);

        target.setIsActive(true);
        target.setLockReason(null);
        target.setLockedUntil(null);
        userDAO.update(target);

        auditDAO.log(adminId, targetUserId, "UNLOCK_USER", "Tài khoản được mở khóa");
    }

    /**
     * Đổi role user (USER ↔ ADMIN)
     */
    public void changeRole(Integer adminId, Integer targetUserId, String newRole) {
        User target = userDAO.findById(targetUserId);
        if (target == null)
            throw new RuntimeException("Không tìm thấy user");
        target.setRole(newRole);
        userDAO.update(target);
        auditDAO.log(adminId, targetUserId, "CHANGE_ROLE", "Role mới: " + newRole);
    }

    // -------------------------------------------------------
    // VIP WORKFLOW
    // -------------------------------------------------------

    /**
     * Approve VIP request → cập nhật user thành VIP với hạn theo durationDays
     */
    public void approveVip(Integer adminId, Integer requestId, String reviewNote) {
        VipRequest req = vipRequestDAO.approve(requestId, adminId, reviewNote);

        User user = userDAO.findById(req.getUserId());
        if (user != null) {
            user.setAccountType("VIP");
            user.setVipExpiryDate(LocalDateTime.now().plusDays(req.getDurationDays()));
            userDAO.update(user);
        }
        auditDAO.log(adminId, req.getUserId(), "APPROVE_VIP",
                "RequestID=" + requestId + " | " + req.getDurationDays() + " ngày");
    }

    /**
     * Reject VIP request
     */
    public void rejectVip(Integer adminId, Integer requestId, String reviewNote) {
        vipRequestDAO.reject(requestId, adminId, reviewNote);

        // Lấy userId để ghi log
        java.util.List<model.VipRequest> all = vipRequestDAO.findByUser(0);
        // Ghi log mà không cần userId (dùng null target)
        auditDAO.log(adminId, null, "REJECT_VIP", "RequestID=" + requestId + " | " + reviewNote);
    }

    // -------------------------------------------------------
    // AUDIT LOG
    // -------------------------------------------------------

    /** Ghi một hành động tùy ý vào audit log */
    public void logAction(Integer adminId, Integer targetUserId, String action, String note) {
        auditDAO.log(adminId, targetUserId, action, note);
    }
}
