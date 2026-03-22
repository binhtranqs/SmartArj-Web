package marketplace.dao;

import marketplace.model.MarketPrice;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng MarketPrices - dùng JDBC thuần (không JPA)
 */
public class MarketPriceDAO {

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null)
            throw new SQLException("Cannot get DB connection");
        return conn;
    }

    /**
     * Lấy tất cả giá thị trường mới nhất (theo ngày crawl gần nhất)
     */
    public List<MarketPrice> getLatestPrices() {
        List<MarketPrice> list = new ArrayList<>();
        String sql = "SELECT TOP 30 PriceID, ProductName, RegionName, Price, Unit, CrawledAt, SourceURL " +
                "FROM MarketPrices " +
                "ORDER BY CrawledAt DESC";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy giá thị trường theo tên sản phẩm (để hiển thị so sánh khi Farmer đăng)
     */
    public List<MarketPrice> findByProductName(String productName) {
        List<MarketPrice> list = new ArrayList<>();
        String sql = "SELECT TOP 5 PriceID, ProductName, RegionName, Price, Unit, CrawledAt, SourceURL " +
                "FROM MarketPrices " +
                "WHERE ProductName LIKE ? " +
                "ORDER BY CrawledAt DESC";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + productName + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy giá trung bình thị trường theo tên sản phẩm
     */
    public java.math.BigDecimal getAveragePrice(String productName) {
        String sql = "SELECT AVG(Price) FROM MarketPrices WHERE ProductName LIKE ? AND CrawledAt >= DATEADD(day,-7,GETDATE())";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, "%" + productName + "%");
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getBigDecimal(1) != null) {
                    return rs.getBigDecimal(1);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Xoá dữ liệu cũ (giữ lại 7 ngày gần nhất)
     */
    public void deleteOlderThan(int days) {
        String sql = "DELETE FROM MarketPrices WHERE CrawledAt < DATEADD(day,-?,GETDATE())";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, days);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Xoá toàn bộ dữ liệu đã crawl trong ngày hôm nay
     * → để insert đè dữ liệu mới, tránh trùng lặp mỗi lần crawl
     */
    public int deleteTodayPrices() {
        String sql = "DELETE FROM MarketPrices WHERE CAST(CrawledAt AS DATE) = CAST(GETDATE() AS DATE)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            return ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * Lưu danh sách giá crawl được
     */
    public int batchInsert(List<MarketPrice> prices) {
        String sql = "INSERT INTO MarketPrices (ProductName, RegionName, Price, Unit, SourceURL) VALUES (?,?,?,?,?)";
        int count = 0;
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            for (MarketPrice mp : prices) {
                ps.setString(1, mp.getProductName());
                ps.setString(2, mp.getRegionName());
                ps.setBigDecimal(3, mp.getPrice());
                ps.setString(4, mp.getUnit() != null ? mp.getUnit() : "đ/kg");
                ps.setString(5, mp.getSourceUrl());
                ps.addBatch();
            }
            int[] results = ps.executeBatch();
            for (int r : results)
                count += (r >= 0 ? 1 : 0);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return count;
    }

    /**
     * Map ResultSet → MarketPrice
     */
    private MarketPrice mapRow(ResultSet rs) throws SQLException {
        MarketPrice mp = new MarketPrice();
        mp.setPriceId(rs.getInt("PriceID"));
        mp.setProductName(rs.getString("ProductName"));
        mp.setRegionName(rs.getString("RegionName"));
        mp.setPrice(rs.getBigDecimal("Price"));
        mp.setUnit(rs.getString("Unit"));
        Timestamp ts = rs.getTimestamp("CrawledAt");
        if (ts != null)
            mp.setCrawledAt(ts.toLocalDateTime());
        mp.setSourceUrl(rs.getString("SourceURL"));
        return mp;
    }
}
