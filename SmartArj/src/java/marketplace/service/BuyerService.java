package marketplace.service;

import marketplace.dao.*;
import marketplace.model.*;
import system.events.EventPublisher;
import system.events.types.OrderCreatedEvent;

import java.math.BigDecimal;
import java.util.List;

/**
 * Service cho Buyer: giỏ hàng, đặt hàng, reviews
 */
public class BuyerService {

    private final CartDAO cartDAO = new CartDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final ListingDAO listingDAO = new ListingDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    /**
     * Lấy giỏ hàng
     */
    public List<CartItem> getCart(Integer buyerId) {
        return cartDAO.findByBuyer(buyerId);
    }

    /**
     * Số item trong giỏ hàng
     */
    public int getCartCount(Integer buyerId) {
        return cartDAO.countByBuyer(buyerId);
    }

    /**
     * Thêm vào giỏ
     */
    public int addToCart(Integer buyerId, int listingId, BigDecimal qty) {
        // Validate listing còn ACTIVE
        Listing listing = listingDAO.findById(listingId);
        if (listing == null || !listing.isActive()) {
            throw new RuntimeException("Sản phẩm không còn khả dụng");
        }
        // Validate số lượng: kiểm tra cả phần đã có trong giỏ + mới thêm
        BigDecimal existingQty = cartDAO.getCartQtyForListing(buyerId, listingId);
        BigDecimal totalRequested = existingQty.add(qty);
        if (listing.getQuantity().compareTo(totalRequested) < 0) {
            BigDecimal remaining = listing.getQuantity().subtract(existingQty);
            if (remaining.compareTo(BigDecimal.ZERO) <= 0) {
                throw new RuntimeException("Bạn đã thêm tối đa số lượng có thể mua của sản phẩm này");
            }
            throw new RuntimeException("Chỉ còn " + remaining.stripTrailingZeros().toPlainString()
                    + " " + (listing.getUnit() != null ? listing.getUnit() : "") + " có thể đặt thêm");
        }
        return cartDAO.addToCart(buyerId, listingId, qty);
    }

    /**
     * Cập nhật số lượng của một sản phẩm trong giỏ hàng
     */
    public boolean updateCartQty(Integer buyerId, int cartId, BigDecimal qty) {
        // Lấy giỏ hàng ra để đối chiếu xem quantity có vượt quá số lượng trong kho không
        List<CartItem> cart = cartDAO.findByBuyer(buyerId);
        CartItem targetItem = null;
        for (CartItem ci : cart) {
            if (ci.getCartId() == cartId) {
                targetItem = ci;
                break;
            }
        }
        if (targetItem != null) {
            // Ép buộc không được vượt quá số lượng có sẵn trong kho
            if (qty.compareTo(targetItem.getAvailableQty()) > 0) {
                qty = targetItem.getAvailableQty();
            }
        }
        return cartDAO.updateQty(cartId, buyerId, qty);
    }

    /**
     * Xóa khỏi giỏ
     */
    public boolean removeFromCart(int cartId, Integer buyerId) {
        return cartDAO.removeFromCart(cartId, buyerId);
    }

    /**
     * Checkout - tạo đơn hàng từ giỏ hàng
     * Giỏ hàng phải từ cùng 1 farmer
     */
    public int checkout(Integer buyerId, String shipAddress, String note) {
        return checkout(buyerId, shipAddress, note, "COD");
    }

    /**
     * Checkout với phương thức thanh toán cụ thể
     * paymentMethod = "COD" → UNPAID (trả khi nhận)
     * paymentMethod = "VNPAY" → UNPAID ban đầu, sẽ cập nhật thành PAID sau callback
     */
    public int checkout(Integer buyerId, String shipAddress, String note, String paymentMethod) {
        return checkoutSelected(buyerId, null, shipAddress, note, null, paymentMethod);
    }

    /**
     * Checkout chỉ những items được chọn trong giỏ hàng (có checkbox).
     * Nếu selectedCartIds null/empty → checkout toàn bộ giỏ hàng.
     *
     * @param buyerName tên buyer để ghi vào Event (có thể null)
     * @param selectedCartIds danh sách CartID được tick, null = tất cả
     */
    public int checkoutSelected(Integer buyerId, String buyerName,
                                String shipAddress, String note,
                                List<Integer> selectedCartIds) {
        return checkoutSelected(buyerId, buyerName, shipAddress, note, selectedCartIds, "COD");
    }

    public int checkoutSelected(Integer buyerId, String buyerName,
                                String shipAddress, String note,
                                List<Integer> selectedCartIds, String paymentMethod) {
        List<CartItem> allCart = cartDAO.findByBuyer(buyerId);

        // Lọc theo selectedCartIds (nếu rỗng thì lấy tất cả)
        List<CartItem> cart;
        if (selectedCartIds == null || selectedCartIds.isEmpty()) {
            cart = allCart;
        } else {
            cart = new java.util.ArrayList<>();
            for (CartItem ci : allCart) {
                if (selectedCartIds.contains(ci.getCartId())) cart.add(ci);
            }
        }

        if (cart.isEmpty()) {
            throw new RuntimeException("Giỏ hàng trống");
        }

        // Chỉ checkout các items còn khả dụng (ACTIVE và còn hàng)
        List<CartItem> availableCart = new java.util.ArrayList<>();
        List<String> unavailableNames = new java.util.ArrayList<>();
        for (CartItem ci : cart) {
            if (ci.isAvailable()) {
                // Đảm bảo số lượng ở thời điểm checkout không vượt quá kho
                if (ci.getQuantity().compareTo(ci.getAvailableQty()) > 0) {
                    throw new RuntimeException("Sản phẩm '" + ci.getProductName() + "' chỉ còn " 
                            + ci.getAvailableQty() + " trong kho. Vui lòng cập nhật lại số lượng!");
                }
                availableCart.add(ci);
            } else {
                String name = ci.getProductName() != null ? ci.getProductName() : "Sản phẩm #" + ci.getListingId();
                unavailableNames.add(name);
            }
        }

        if (availableCart.isEmpty()) {
            throw new RuntimeException(
                "Không thể đặt hàng: tất cả sản phẩm đã hết hàng hoặc không còn bán.");
        }
        if (!unavailableNames.isEmpty()) {
            throw new RuntimeException(
                "Vui lòng xóa khỏi giỏ hàng trước khi thanh toán: "
                + String.join(", ", unavailableNames) + " (đã hết hàng).");
        }

        // Validate tất cả items từ cùng 1 farmer
        Integer farmerId = availableCart.get(0).getFarmerId();
        for (CartItem item : availableCart) {
            if (!item.getFarmerId().equals(farmerId)) {
                throw new RuntimeException(
                        "Giỏ hàng chứa sản phẩm từ nhiều nông dân. Vui lòng đặt riêng từng người bán.");
            }
        }

        // Build Order
        BigDecimal total = BigDecimal.ZERO;
        Order order = new Order();
        order.setBuyerId(buyerId);
        order.setFarmerId(farmerId);
        order.setShipAddress(shipAddress);
        order.setNote(note);
        order.setPaymentMethod(paymentMethod != null ? paymentMethod.toUpperCase() : "COD");
        order.setPaymentStatus("VNPAY".equalsIgnoreCase(paymentMethod) ? "PAID" : "UNPAID");

        List<OrderItem> items = new java.util.ArrayList<>();
        for (CartItem ci : availableCart) {
            OrderItem oi = new OrderItem();
            oi.setListingId(ci.getListingId());
            oi.setQuantity(ci.getQuantity());
            oi.setUnitPrice(ci.getUnitPrice());
            items.add(oi);
            total = total.add(ci.getSubTotal());
        }
        order.setTotalAmount(total);
        order.setItems(items);

        int orderId = orderDAO.create(order);
        if (orderId > 0) {
            // Chỉ xóa những items đã được checkout khỏi giỏ
            if (selectedCartIds != null && !selectedCartIds.isEmpty()) {
                for (CartItem ci : availableCart) {
                    cartDAO.removeFromCart(ci.getCartId(), buyerId);
                }
            } else {
                cartDAO.clearCart(buyerId);
            }
            // Publish event
            EventPublisher.publish(new OrderCreatedEvent(
                    buyerId, orderId, buyerName, order.getTotalAmount()));
        }
        return orderId;
    }

    /**
     * Lấy lịch sử đơn hàng của buyer
     */
    public List<Order> getMyOrders(Integer buyerId) {
        return orderDAO.findByBuyer(buyerId);
    }

    /**
     * Hủy đơn hàng
     */
    public boolean cancelOrder(int orderId, Integer buyerId) {
        Order order = orderDAO.findById(orderId);
        if (order == null || !order.getBuyerId().equals(buyerId)) {
            return false;
        }
        if (!order.isPending()) {
            throw new RuntimeException("Chỉ có thể hủy đơn hàng đang chờ xác nhận");
        }
        return orderDAO.updateStatus(orderId, "CANCELLED", buyerId);
    }

    /**
     * Gửi đánh giá
     */
    public boolean submitReview(Integer buyerId, int farmerId, Integer listingId,
            Integer orderId, int rating, String comment) {
        if (orderId != null && reviewDAO.hasReviewed(buyerId, orderId)) {
            throw new RuntimeException("Bạn đã đánh giá đơn hàng này rồi");
        }
        Review review = new Review();
        review.setBuyerId(buyerId);
        review.setFarmerId(farmerId);
        review.setListingId(listingId);
        review.setOrderId(orderId);
        review.setRating(rating);
        review.setComment(comment);
        return reviewDAO.create(review);
    }
}
