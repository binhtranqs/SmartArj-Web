package marketplace.service;

import marketplace.dao.*;
import marketplace.model.*;
import system.events.EventPublisher;
import system.events.types.ListingCreatedEvent;

import java.math.BigDecimal;
import java.util.List;

/**
 * Service cho Farmer: quản lý listings, xem orders, doanh thu
 */
public class FarmerService {

    private final ListingDAO listingDAO = new ListingDAO();
    private final OrderDAO orderDAO = new OrderDAO();
    private final MarketPriceDAO marketPriceDAO = new MarketPriceDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    /**
     * Lấy tất cả listing của farmer
     */
    public List<Listing> getMyListings(int farmerId) {
        return listingDAO.findByFarmer(farmerId);
    }

    /**
     * Lấy đơn hàng nhận được
     */
    public List<Order> getMyOrders(int farmerId) {
        return orderDAO.findByFarmer(farmerId);
    }

    /**
     * Tổng doanh thu
     */
    public BigDecimal getTotalRevenue(int farmerId) {
        return orderDAO.getTotalRevenueByFarmer(farmerId);
    }

    /**
     * Tạo listing mới
     */
    public int createListing(Listing listing) {
        int listingId = listingDAO.create(listing);
        if (listingId > 0) {
            // EVENT: notify admin that a new listing was posted
            EventPublisher.publish(new ListingCreatedEvent(
                    listing.getFarmerId(), listingId,
                    listing.getProductName(), listing.getFarmerName()));
        }
        return listingId;
    }

    /**
     * Cập nhật listing (chỉ farmer của listing đó)
     */
    public boolean updateListing(Listing listing) {
        return listingDAO.update(listing);
    }

    /**
     * Xóa listing
     */
    public boolean deleteListing(int listingId, int farmerId) {
        return listingDAO.delete(listingId, farmerId);
    }

    /**
     * Đổi trạng thái listing: ACTIVE ↔ SOLD_OUT
     * Farmer dùng để tạm ẩn hoặc mở bán lại sản phẩm.
     */
    public boolean toggleListingStatus(int listingId, int farmerId, String newStatus) {
        if (!"ACTIVE".equals(newStatus) && !"SOLD_OUT".equals(newStatus) && !"HIDDEN".equals(newStatus)) {
            return false; // Chỉ cho phép các status hợp lệ
        }
        return listingDAO.updateStatus(listingId, farmerId, newStatus);
    }

    /**
     * Lấy listing chi tiết (để edit)
     */
    public Listing getMyListing(int listingId, int farmerId) {
        Listing l = listingDAO.findById(listingId);
        if (l != null && l.getFarmerId() != null && l.getFarmerId() == farmerId) {
            return l;
        }
        return null; // Không phải listing của farmer này
    }

    /**
     * Cập nhật trạng thái order (confirm, ship, complete).
     * Khi status = CONFIRMED: tự động trừ số lượng kho cho từng sản phẩm trong đơn.
     */
    public boolean updateOrderStatus(int orderId, String status, int farmerId) {
        boolean ok = orderDAO.updateStatus(orderId, status, farmerId);
        if (ok && "CONFIRMED".equals(status)) {
            // Trừ kho: load items của đơn hàng rồi decreaseQuantity từng listing
            List<OrderItem> items = orderDAO.findItemsByOrder(orderId);
            for (OrderItem item : items) {
                if (item.getQuantity() != null && item.getQuantity().compareTo(java.math.BigDecimal.ZERO) > 0) {
                    listingDAO.decreaseQuantity(item.getListingId(), item.getQuantity());
                }
            }
        }
        return ok;
    }

    /**
     * Đánh dấu đơn hàng đã thanh toán (gọi khi COMPLETED - COD nhận tiền mặt)
     */
    public boolean markOrderPaid(int orderId) {
        return orderDAO.updatePaymentStatus(orderId, "PAID", null);
    }

    /**
     * Lấy market price reference theo tên sản phẩm
     */
    public List<MarketPrice> getMarketPriceReference(String productName) {
        return marketPriceDAO.findByProductName(productName);
    }

    /**
     * Lấy reviews của farmer
     */
    public List<Review> getMyReviews(int farmerId) {
        return reviewDAO.findByFarmer(farmerId);
    }

    /**
     * Đánh giá trung bình
     */
    public double getAverageRating(int farmerId) {
        return reviewDAO.getAverageRating(farmerId);
    }

    /**
     * Dashboard stats
     */
    public java.util.Map<String, Object> getDashboardStats(int farmerId) {
        java.util.Map<String, Object> stats = new java.util.LinkedHashMap<>();
        List<Listing> listings = getMyListings(farmerId);
        List<Order> orders = getMyOrders(farmerId);
        long activeListings = listings.stream().filter(Listing::isActive).count();
        long pendingOrders = orders.stream().filter(Order::isPending).count();
        long completedOrders = orders.stream().filter(Order::isCompleted).count();

        stats.put("totalListings", listings.size());
        stats.put("activeListings", activeListings);
        stats.put("totalOrders", orders.size());
        stats.put("pendingOrders", pendingOrders);
        stats.put("completedOrders", completedOrders);
        stats.put("totalRevenue", getTotalRevenue(farmerId));
        stats.put("avgRating", getAverageRating(farmerId));
        return stats;
    }
}
