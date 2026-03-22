package system.events.types;

import system.events.BaseEvent;

/**
 * Event fired when a user successfully upgrades to VIP status.
 *
 * Trigger points:
 * - UpgradeServlet.doPost() after paymentService.processPayment() returns true
 * - VNPayReturnServlet when a VIP payment completes (optional, depending on flow used)
 */
public class VipUpgradeEvent extends BaseEvent {

    public static final String TYPE = "VIP_UPGRADE";

    private final String username;
    private final int    packageDays;

    /**
     * @param userId     ID of the user who upgraded
     * @param username   Username or full name for display
     * @param packageDays Duration of VIP package in days (30 / 90 / 365)
     */
    public VipUpgradeEvent(Integer userId, String username, int packageDays) {
        super(userId, null,
              "User \"" + nvl(username) + "\" n\u00e2ng c\u1ea5p VIP "
              + packageLabel(packageDays));
        this.username    = username;
        this.packageDays = packageDays;
    }

    @Override
    public String getType() {
        return TYPE;
    }

    public String getUsername()    { return username; }
    public int    getPackageDays() { return packageDays; }

    private static String nvl(String s) {
        return s != null ? s : "?";
    }

    private static String packageLabel(int days) {
        if (days >= 365) return "(1 n\u0103m)";
        if (days >= 90)  return "(3 th\u00e1ng)";
        if (days >= 30)  return "(1 th\u00e1ng)";
        return "(" + days + " ng\u00e0y)";
    }
}
