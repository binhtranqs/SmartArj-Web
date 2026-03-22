package test;

import marketplace.service.BuyerService;
import java.util.Collections;

public class TestCheckout {
    public static void main(String[] args) {
        BuyerService buyerService = new BuyerService();
        try {
            System.out.println("Starting checkout for User 19...");
            // Truyền null hoặc Collections.emptyList() sẽ checkout toàn bộ giỏ hàng.
            // Để tránh lỗi "nhiều nông dân", ta mô phỏng việc chọn cụ thể 1 cart item (ví dụ: cartId = 1)
            int orderId = buyerService.checkoutSelected(19, "vu", "Test Address", "Test Note", java.util.Arrays.asList(1), "VNPAY");
            System.out.println("Checkout successful, OrderID = " + orderId);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
