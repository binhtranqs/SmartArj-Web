package system.events.types;

import system.events.BaseEvent;
import java.math.BigDecimal;

/**
 * Event fired when a Buyer successfully places an order (checkout).
 *
 * Trigger point: BuyerService.checkout() after orderDAO.create() returns a valid orderID.
 */
public class OrderCreatedEvent extends BaseEvent {

    public static final String TYPE = "ORDER_CREATED";

    private final String buyerName;
    private final BigDecimal totalAmount;

    /**
     * @param buyerId     ID of the buyer who placed the order
     * @param orderId     ID of the newly created order
     * @param buyerName   Full name of the buyer
     * @param totalAmount Order total in VND
     */
    public OrderCreatedEvent(Integer buyerId, Integer orderId,
                              String buyerName, BigDecimal totalAmount) {
        super(buyerId, orderId,
              "Buyer " + nvl(buyerName) + " \u0111\u1eb7t \u0111\u01a1n h\u00e0ng #" + orderId
              + " (" + formatAmount(totalAmount) + " \u0111)");
        this.buyerName   = buyerName;
        this.totalAmount = totalAmount;
    }

    @Override
    public String getType() {
        return TYPE;
    }

    public String getBuyerName()     { return buyerName; }
    public BigDecimal getTotalAmount(){ return totalAmount; }

    private static String nvl(String s) {
        return s != null ? s : "?";
    }

    private static String formatAmount(BigDecimal amount) {
        if (amount == null) return "0";
        return String.format("%,.0f", amount);
    }
}
