package system.events.types;

import system.events.BaseEvent;

/**
 * Event fired when a VNPay payment callback returns successfully (responseCode == "00"
 * and signature is valid).
 *
 * Trigger point: VNPayReturnServlet.doGet() inside the success branch,
 * after the DB transaction has been committed.
 */
public class PaymentSuccessEvent extends BaseEvent {

    public static final String TYPE = "PAYMENT_SUCCESS";

    private final String txnRef;
    private final double amount;
    private final int    vipDays;

    /**
     * @param userId  ID of the user who paid
     * @param txnRef  VNPay transaction reference (vnp_TxnRef)
     * @param amount  Amount paid in VND
     * @param vipDays VIP duration in days (0 if not a VIP payment)
     */
    public PaymentSuccessEvent(Integer userId, String txnRef, double amount, int vipDays) {
        super(userId, null,
              "Thanh to\u00e1n VNPay th\u00e0nh c\u00f4ng \u2014 " + txnRef
              + " \u2014 " + String.format("%,.0f", amount) + " \u0111"
              + (vipDays > 0 ? " (VIP " + vipDays + " ng\u00e0y)" : ""));
        this.txnRef  = txnRef;
        this.amount  = amount;
        this.vipDays = vipDays;
    }

    @Override
    public String getType() {
        return TYPE;
    }

    public String getTxnRef()  { return txnRef; }
    public double getAmount()   { return amount; }
    public int    getVipDays()  { return vipDays; }
}
