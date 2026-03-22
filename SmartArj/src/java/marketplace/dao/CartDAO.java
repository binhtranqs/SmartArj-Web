package marketplace.dao;

import marketplace.model.CartItem;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng CartItems
 */
public class CartDAO {

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null)
            throw new SQLException("Cannot get DB connection");
        return conn;
    }

    /**
     * Lấy giỏ hàng của buyer (JOIN Listings + Users)
     */
    public List<CartItem> findByBuyer(int buyerId) {
        List<CartItem> list = new ArrayList<>();
        // Bug fix: dùng LEFT JOIN thay vì INNER JOIN và bỏ WHERE l.Status='ACTIVE'
        // để items trong cart không bị biến mất khi listing bị SOLD_OUT/HIDDEN/xóa.
        // listingStatus và availableQty được map để UI hiển thị trạng thái phù hợp.
        String sql = "SELECT c.CartID, c.BuyerID, c.ListingID, l.ProductName, " +
                "u.FullName AS FarmerName, l.FarmerID, r.RegionName, " +
                "l.Price AS UnitPrice, l.Unit, l.ImageURL, c.Quantity, c.AddedAt, " +
                "l.Status AS ListingStatus, l.Quantity AS AvailableQty " +
                "FROM CartItems c " +
                "LEFT JOIN Listings l ON c.ListingID = l.ListingID " +
                "LEFT JOIN Users u ON l.FarmerID = u.UserID " +
                "LEFT JOIN Regions r ON l.RegionID = r.RegionID " +
                "WHERE c.BuyerID = ? " +
                "ORDER BY c.AddedAt DESC";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    CartItem ci = new CartItem();
                    ci.setCartId(rs.getInt("CartID"));
                    ci.setBuyerId(rs.getInt("BuyerID"));
                    ci.setListingId(rs.getInt("ListingID"));
                    ci.setProductName(rs.getString("ProductName"));
                    ci.setFarmerName(rs.getString("FarmerName"));
                    ci.setFarmerId(rs.getInt("FarmerID"));
                    ci.setRegionName(rs.getString("RegionName"));
                    ci.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                    ci.setUnit(rs.getString("Unit"));
                    ci.setImageUrl(rs.getString("ImageURL"));
                    ci.setQuantity(rs.getBigDecimal("Quantity"));
                    ci.setListingStatus(rs.getString("ListingStatus"));
                    ci.setAvailableQty(rs.getBigDecimal("AvailableQty"));
                    Timestamp ts = rs.getTimestamp("AddedAt");
                    if (ts != null)
                        ci.setAddedAt(ts.toLocalDateTime());
                    list.add(ci);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Thêm vào giỏ (nếu đã có thì cộng thêm số lượng)
     */
    public int addToCart(int buyerId, int listingId, BigDecimal qty) {
        // Check if already in cart
        String checkSql = "SELECT CartID, Quantity FROM CartItems WHERE BuyerID=? AND ListingID=?";
        try (Connection conn = getConnection();
                PreparedStatement check = conn.prepareStatement(checkSql)) {
            check.setInt(1, buyerId);
            check.setInt(2, listingId);
            try (ResultSet rs = check.executeQuery()) {
                if (rs.next()) {
                    // Update quantity
                    int cartId = rs.getInt("CartID");
                    BigDecimal existing = rs.getBigDecimal("Quantity");
                    String updateSql = "UPDATE CartItems SET Quantity=? WHERE CartID=?";
                    try (PreparedStatement ps = conn.prepareStatement(updateSql)) {
                        ps.setBigDecimal(1, existing.add(qty));
                        ps.setInt(2, cartId);
                        ps.executeUpdate();
                    }
                    return cartId;
                }
            }
            // Insert new
            String insertSql = "INSERT INTO CartItems (BuyerID, ListingID, Quantity) VALUES (?,?,?)";
            try (PreparedStatement ps = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, buyerId);
                ps.setInt(2, listingId);
                ps.setBigDecimal(3, qty);
                ps.executeUpdate();
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        return generatedKeys.getInt(1);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("DB Add to Cart Error: " + e.getMessage(), e);
        }
        return -1;
    }

    /**
     * Xóa item khỏi giỏ
     */
    public boolean removeFromCart(int cartId, int buyerId) {
        String sql = "DELETE FROM CartItems WHERE CartID=? AND BuyerID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, buyerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa toàn bộ giỏ hàng của buyer sau checkout
     */
    public void clearCart(int buyerId) {
        String sql = "DELETE FROM CartItems WHERE BuyerID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Đếm số item trong giỏ hàng
     */
    public int countByBuyer(int buyerId) {
        String sql = "SELECT COUNT(*) FROM CartItems WHERE BuyerID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Cập nhật số lượng item trong giỏ (dùng cho tăng/giảm số kí trong cart)
     */
    public boolean updateQty(int cartId, int buyerId, BigDecimal qty) {
        if (qty == null || qty.compareTo(BigDecimal.ZERO) <= 0) {
            return removeFromCart(cartId, buyerId);
        }
        String sql = "UPDATE CartItems SET Quantity=? WHERE CartID=? AND BuyerID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBigDecimal(1, qty);
            ps.setInt(2, cartId);
            ps.setInt(3, buyerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Lấy tổng số lượng của một listing đang có trong giỏ của buyer.
     * Dùng để validate: existingQty + newQty <= stockQty khi add to cart.
     */
    public BigDecimal getCartQtyForListing(int buyerId, int listingId) {
        String sql = "SELECT ISNULL(SUM(Quantity), 0) FROM CartItems WHERE BuyerID=? AND ListingID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            ps.setInt(2, listingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }
}
