package marketplace.service;

import marketplace.dao.*;
import marketplace.model.*;

import java.util.List;

/**
 * Service cho các chức năng Marketplace (browse, search, filter)
 */
public class MarketplaceService {

    private final ListingDAO listingDAO = new ListingDAO();
    private final MarketPriceDAO marketPriceDAO = new MarketPriceDAO();
    private final RegionDAO regionDAO = new RegionDAO();

    /**
     * Lấy tất cả listing ACTIVE
     */
    public List<Listing> getAllActiveListings() {
        return listingDAO.findAllActive();
    }

    /**
     * Tìm kiếm + lọc listing
     */
    public List<Listing> searchListings(String keyword, Integer regionId,
            double minPrice, double maxPrice) {
        return listingDAO.findByFilters(keyword, regionId, minPrice, maxPrice, 100);
    }

    /**
     * Lấy chi tiết listing
     */
    public Listing getListingById(int id) {
        Listing listing = listingDAO.findById(id);
        if (listing != null && listing.getProductName() != null) {
            // Gắn thêm market price reference
            java.math.BigDecimal marketAvg = marketPriceDAO.getAveragePrice(listing.getProductName());
            listing.setMarketPrice(marketAvg);
        }
        return listing;
    }

    /**
     * Lấy market prices mới nhất (cho ticker bar)
     */
    public List<MarketPrice> getLatestMarketPrices() {
        return marketPriceDAO.getLatestPrices();
    }

    /**
     * Lấy tất cả regions (cho filter)
     */
    public List<Region> getAllRegions() {
        return regionDAO.findAll();
    }

    /**
     * Đếm listing active
     */
    public int countActiveListings() {
        return listingDAO.countActive();
    }

    /**
     * Lấy danh sách sản phẩm gợi ý cho buyer dựa trên lịch sử mua hàng
     *
     * @param buyerId ID của buyer
     * @param limit   số gợi ý tối đa
     * @return danh sách Listing gợi ý, rỗng nếu chưa có lịch sử
     */
    public List<Listing> getRecommendedListings(int buyerId, int limit) {
        return listingDAO.findRecommendedByBuyer(buyerId, limit);
    }

    /**
     * Lấy tên các sản phẩm buyer đã từng mua (hiển thị tag gợi ý)
     *
     * @param buyerId ID của buyer
     * @return danh sách tên sản phẩm (distinct)
     */
    public List<String> getBoughtProductNames(int buyerId) {
        return listingDAO.findBoughtProductNames(buyerId);
    }
}
