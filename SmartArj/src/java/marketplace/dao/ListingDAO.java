package marketplace.dao;

import marketplace.model.Listing;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng Listings - dùng JDBC thuần
 */
public class ListingDAO {

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null)
            throw new SQLException("Cannot get DB connection");
        return conn;
    }

    /**
     * Lấy tất cả listing ACTIVE, JOIN với Users + Regions
     */
    public List<Listing> findAllActive() {
        return findByFilters(null, null, 0, 0, 50);
    }

    /**
     * Tìm listing với bộ lọc
     * 
     * @param productSearch tên sản phẩm (LIKE)
     * @param regionId      ID vùng (0 = tất cả)
     * @param minPrice      giá tối thiểu (0 = không lọc)
     * @param maxPrice      giá tối đa (0 = không lọc)
     * @param limit         số lượng tối đa
     */
    public List<Listing> findByFilters(String productSearch, Integer regionId,
            double minPrice, double maxPrice, int limit) {
        List<Listing> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT TOP " + (limit > 0 ? limit : 50) + " " +
                        "l.ListingID, l.FarmerID, u.FullName AS FarmerName, u.Email AS FarmerEmail, " +
                        "l.ProductName, l.Description, l.RegionID, r.RegionName, " +
                        "l.Price, l.Unit, l.Quantity, l.ImageURL, l.Status, l.CreatedAt, l.UpdatedAt " +
                        "FROM Listings l " +
                        "LEFT JOIN Users u ON l.FarmerID = u.UserID " +
                        "LEFT JOIN Regions r ON l.RegionID = r.RegionID " +
                        "WHERE l.Status = 'ACTIVE' ");
        List<Object> params = new ArrayList<>();

        if (productSearch != null && !productSearch.trim().isEmpty()) {
            sql.append("AND l.ProductName LIKE ? ");
            params.add("%" + productSearch.trim() + "%");
        }
        if (regionId != null && regionId > 0) {
            sql.append("AND l.RegionID = ? ");
            params.add(regionId);
        }
        if (minPrice > 0) {
            sql.append("AND l.Price >= ? ");
            params.add(minPrice);
        }
        if (maxPrice > 0) {
            sql.append("AND l.Price <= ? ");
            params.add(maxPrice);
        }
        sql.append("ORDER BY l.CreatedAt DESC");

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy listing theo ID
     */
    public Listing findById(int listingId) {
        String sql = "SELECT l.ListingID, l.FarmerID, u.FullName AS FarmerName, u.Email AS FarmerEmail, " +
                "l.ProductName, l.Description, l.RegionID, r.RegionName, " +
                "l.Price, l.Unit, l.Quantity, l.ImageURL, l.Status, l.CreatedAt, l.UpdatedAt " +
                "FROM Listings l " +
                "LEFT JOIN Users u ON l.FarmerID = u.UserID " +
                "LEFT JOIN Regions r ON l.RegionID = r.RegionID " +
                "WHERE l.ListingID = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, listingId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Lấy tất cả listing của một farmer
     */
    public List<Listing> findByFarmer(int farmerId) {
        List<Listing> list = new ArrayList<>();
        String sql = "SELECT l.ListingID, l.FarmerID, u.FullName AS FarmerName, u.Email AS FarmerEmail, " +
                "l.ProductName, l.Description, l.RegionID, r.RegionName, " +
                "l.Price, l.Unit, l.Quantity, l.ImageURL, l.Status, l.CreatedAt, l.UpdatedAt " +
                "FROM Listings l " +
                "LEFT JOIN Users u ON l.FarmerID = u.UserID " +
                "LEFT JOIN Regions r ON l.RegionID = r.RegionID " +
                "WHERE l.FarmerID = ? " +
                "ORDER BY l.CreatedAt DESC";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next())
                    list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Tạo listing mới
     */
    public int create(Listing l) {
        String sql = "INSERT INTO Listings (FarmerID, ProductName, Description, RegionID, Price, Unit, Quantity, ImageURL, Status) "
                +
                "VALUES (?,?,?,?,?,?,?,?,?)";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, l.getFarmerId());
            ps.setString(2, l.getProductName());
            ps.setString(3, l.getDescription());
            if (l.getRegionId() != null)
                ps.setInt(4, l.getRegionId());
            else
                ps.setNull(4, Types.INTEGER);
            ps.setBigDecimal(5, l.getPrice());
            ps.setString(6, l.getUnit() != null ? l.getUnit() : "kg");
            ps.setBigDecimal(7, l.getQuantity());
            ps.setString(8, l.getImageUrl());
            ps.setString(9, l.getStatus() != null ? l.getStatus() : "ACTIVE");
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next())
                    return keys.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return -1;
    }

    /**
     * Cập nhật listing
     */
    public boolean update(Listing l) {
        String sql = "UPDATE Listings SET ProductName=?, Description=?, RegionID=?, Price=?, Unit=?, Quantity=?, ImageURL=?, Status=?, UpdatedAt=GETDATE() "
                +
                "WHERE ListingID=? AND FarmerID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, l.getProductName());
            ps.setString(2, l.getDescription());
            if (l.getRegionId() != null)
                ps.setInt(3, l.getRegionId());
            else
                ps.setNull(3, Types.INTEGER);
            ps.setBigDecimal(4, l.getPrice());
            ps.setString(5, l.getUnit());
            ps.setBigDecimal(6, l.getQuantity());
            ps.setString(7, l.getImageUrl());
            ps.setString(8, l.getStatus());
            ps.setInt(9, l.getListingId());
            ps.setInt(10, l.getFarmerId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Xóa listing (chỉ farmer của listing đó)
     */
    public boolean delete(int listingId, int farmerId) {
        // B\u01b0\u1edbc 1: x\u00f3a CartItems ch\u1ee9a listing n\u00e0y tr\u01b0\u1edbc \u0111\u1ec3 tr\u00e1nh h\u00e0ng "ma" trong gi\u1ecf h\u00e0ng
        String cleanCart = "DELETE FROM CartItems WHERE ListingID=?";
        String sql = "DELETE FROM Listings WHERE ListingID=? AND FarmerID=?";
        try (Connection conn = getConnection()) {
            // X\u00f3a cart items
            try (PreparedStatement ps = conn.prepareStatement(cleanCart)) {
                ps.setInt(1, listingId);
                ps.executeUpdate();
            }
            // X\u00f3a listing ch\u00ednh
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setInt(1, listingId);
                ps.setInt(2, farmerId);
                return ps.executeUpdate() > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật status của listing (ACTIVE / SOLD_OUT / HIDDEN)
     * Farmer dùng để "Mở bán lại" khi nhập thêm hàng
     */
    public boolean updateStatus(int listingId, int farmerId, String status) {
        String sql = "UPDATE Listings SET Status=?, UpdatedAt=GETDATE() WHERE ListingID=? AND FarmerID=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, listingId);
            ps.setInt(3, farmerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Giảm số lượng kho sau khi farmer xác nhận / giao hàng.
     * Nếu quantity còn lại <= 0, tự động chuyển status -> SOLD_OUT.
     *
     * @param listingId ID sản phẩm
     * @param qty       số lượng cần trừ (BigDecimal)
     * @return true nếu cập nhật thành công
     */
    public boolean decreaseQuantity(int listingId, java.math.BigDecimal qty) {
        // Trừ số lượng, cập nhật UpdatedAt
        String sqlUpdate = "UPDATE Listings SET " +
                "Quantity = CASE WHEN Quantity - ? < 0 THEN 0 ELSE Quantity - ? END, " +
                "Status  = CASE WHEN Quantity - ? <= 0 THEN 'SOLD_OUT' ELSE Status END, " +
                "UpdatedAt = GETDATE() " +
                "WHERE ListingID = ?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
            ps.setBigDecimal(1, qty);
            ps.setBigDecimal(2, qty);
            ps.setBigDecimal(3, qty);
            ps.setInt(4, listingId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Gợi ý sản phẩm cho buyer dựa theo lịch sử mua hàng.
     * Lấy các listing ACTIVE mới nhất có ProductName khớp với
     * các sản phẩm buyer đã từng mua (so sánh LIKE theo từ khóa).
     *
     * @param buyerId ID của buyer đã đăng nhập
     * @param limit   số lượng gợi ý tối đa trả về
     * @return danh sách Listing gợi ý, rỗng nếu chưa có lịch sử
     */
    public List<Listing> findRecommendedByBuyer(int buyerId, int limit) {
        List<Listing> result = new ArrayList<>();

        // Bước 1: lấy 5 tên SP được mua gần nhất từ Listings
        // Dùng GROUP BY và ORDER BY MAX(CreatedAt) để lấy các SP mới mua nhất
        String sqlKeywords =
            "SELECT TOP 5 l2.ProductName " +
            "FROM OrderItems oi " +
            "JOIN Orders o  ON oi.OrderID  = o.OrderID " +
            "JOIN Listings l2 ON oi.ListingID = l2.ListingID " +
            "WHERE o.BuyerID = ? AND l2.ProductName IS NOT NULL " +
            "GROUP BY l2.ProductName " +
            "ORDER BY MAX(o.CreatedAt) DESC";

        List<String> keywords = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sqlKeywords)) {
            ps.setInt(1, buyerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String name = rs.getString("ProductName"); // lấy từ Listings.ProductName
                    if (name != null && !name.trim().isEmpty()) {
                        String[] parts = name.trim().split("\\s+");
                        String extracted = "";
                        int idx = 0;
                        while(idx < parts.length) {
                             String p = parts[idx].toLowerCase();
                             // Bỏ qua các từ định danh số lượng / bao bì
                             if(p.equals("trái") || p.equals("quả") || p.equals("thùng") || 
                                p.equals("hộp") || p.equals("gói") || p.equals("bó") || 
                                p.equals("nải") || p.equals("kg") || p.equals("combo")) {
                                 idx++; 
                                 continue;
                             }
                             extracted = p;
                             // Tiếng Việt có nhiều từ ghép 2 âm tiết phổ biến trong nông sản:
                             if ((p.equals("cà") || p.equals("hồ") || p.equals("dưa") || 
                                  p.equals("lúa") || p.equals("đậu") || p.equals("hạt")) && idx + 1 < parts.length) {
                                 extracted = p + " " + parts[idx+1].toLowerCase();
                             }
                             break;
                        }
                        // Lấy từ khóa nếu độ dài >= 2 (VD: Bơ, Ớt, Gà... đều hợp lệ)
                        if (!extracted.isEmpty() && extracted.length() >= 2 && !keywords.contains(extracted)) {
                            keywords.add(extracted);
                        }
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            return result;
        }

        if (keywords.isEmpty()) {
            return result;
        }

        // Bước 2: xây dựng câu truy vấn LIKE cho từng từ khóa
        StringBuilder sql = new StringBuilder(
            "SELECT TOP " + limit + " " +
            "l.ListingID, l.FarmerID, u.FullName AS FarmerName, u.Email AS FarmerEmail, " +
            "l.ProductName, l.Description, l.RegionID, r.RegionName, " +
            "l.Price, l.Unit, l.Quantity, l.ImageURL, l.Status, l.CreatedAt, l.UpdatedAt " +
            "FROM Listings l " +
            "LEFT JOIN Users u ON l.FarmerID = u.UserID " +
            "LEFT JOIN Regions r ON l.RegionID = r.RegionID " +
            "WHERE l.Status = 'ACTIVE' AND ("
        );

        List<String> queryParams = new ArrayList<>();
        // WHERE clause
        for (int i = 0; i < keywords.size(); i++) {
            if (i > 0) sql.append(" OR ");
            sql.append("LOWER(l.ProductName) LIKE ?");
            queryParams.add("%" + keywords.get(i) + "%");
        }
        
        // ORDER BY clause: Ưu tiên GỢI Ý các từ khóa MỚI NHẤT (index càng nhỏ càng được đẩy lên đầu)
        sql.append(") ORDER BY ");
        for (int i = 0; i < keywords.size(); i++) {
            sql.append("CASE WHEN LOWER(l.ProductName) LIKE ? THEN ").append(i).append(" ELSE 100 END ASC, ");
            queryParams.add("%" + keywords.get(i) + "%");
        }
        // Các sản phẩm cùng chỉ số ưu tiên thì món nào MỚI ĐĂNG sẽ lên trên
        sql.append("l.CreatedAt DESC");

        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < queryParams.size(); i++) {
                ps.setString(i + 1, queryParams.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    result.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Lấy các từ khóa sản phẩm buyer đã từng mua (để hiển thị tag gợi ý)
     *
     * @param buyerId ID của buyer
     * @return danh sách tên sản phẩm đã mua (distinct)
     */
    public List<String> findBoughtProductNames(int buyerId) {
        List<String> names = new ArrayList<>();
        // Cập nhật: Chỉ lấy top 5 tên sản phẩm GẦN NHẤT
        String sql =
            "SELECT TOP 5 l2.ProductName " +
            "FROM OrderItems oi " +
            "JOIN Orders o   ON oi.OrderID  = o.OrderID " +
            "JOIN Listings l2 ON oi.ListingID = l2.ListingID " +
            "WHERE o.BuyerID = ? AND l2.ProductName IS NOT NULL " +
            "GROUP BY l2.ProductName " +
            "ORDER BY MAX(o.CreatedAt) DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String n = rs.getString("ProductName");
                    if (n != null && !n.trim().isEmpty()) names.add(n.trim());
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return names;
    }

    /**
     * Đếm tổng listing ACTIVE
     */
    public int countActive() {
        String sql = "SELECT COUNT(*) FROM Listings WHERE Status='ACTIVE'";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next())
                return rs.getInt(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Map ResultSet → Listing
     */
    private Listing mapRow(ResultSet rs) throws SQLException {
        Listing l = new Listing();
        l.setListingId(rs.getInt("ListingID"));
        l.setFarmerId(rs.getInt("FarmerID"));
        l.setFarmerName(rs.getString("FarmerName"));
        l.setFarmerEmail(rs.getString("FarmerEmail"));
        l.setProductName(rs.getString("ProductName"));
        l.setDescription(rs.getString("Description"));
        int rid = rs.getInt("RegionID");
        if (!rs.wasNull())
            l.setRegionId(rid);
        l.setRegionName(rs.getString("RegionName"));
        l.setPrice(rs.getBigDecimal("Price"));
        l.setUnit(rs.getString("Unit"));
        l.setQuantity(rs.getBigDecimal("Quantity"));
        l.setImageUrl(rs.getString("ImageURL"));
        l.setStatus(rs.getString("Status"));
        Timestamp ca = rs.getTimestamp("CreatedAt");
        if (ca != null)
            l.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("UpdatedAt");
        if (ua != null)
            l.setUpdatedAt(ua.toLocalDateTime());
        return l;
    }
}
