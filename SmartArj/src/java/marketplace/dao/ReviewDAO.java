package marketplace.dao;

import marketplace.model.Review;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng Reviews
 */
public class ReviewDAO {

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null)
            throw new SQLException("Cannot get DB connection");
        return conn;
    }

    /**
     * Lấy reviews của farmer
     */
    public List<Review> findByFarmer(int farmerId) {
        List<Review> list = new ArrayList<>();
        String sql = "SELECT r.ReviewID, r.BuyerID, ub.FullName AS BuyerName, " +
                "r.FarmerID, uf.FullName AS FarmerName, " +
                "r.ListingID, l.ProductName, r.OrderID, r.Rating, r.Comment, r.CreatedAt " +
                "FROM Reviews r " +
                "JOIN Users ub ON r.BuyerID = ub.UserID " +
                "JOIN Users uf ON r.FarmerID = uf.UserID " +
                "LEFT JOIN Listings l ON r.ListingID = l.ListingID " +
                "WHERE r.FarmerID = ? ORDER BY r.CreatedAt DESC";
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
     * Trung bình rating của farmer
     */
    public double getAverageRating(int farmerId) {
        String sql = "SELECT AVG(CAST(Rating AS FLOAT)) FROM Reviews WHERE FarmerID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getDouble(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    /**
     * Kiểm tra buyer đã review cho order chưa
     */
    public boolean hasReviewed(int buyerId, int orderId) {
        String sql = "SELECT 1 FROM Reviews WHERE BuyerID=? AND OrderID=?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
            ps.setInt(2, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Thêm review
     */
    public boolean create(Review review) {
        String sql = "INSERT INTO Reviews (BuyerID, FarmerID, ListingID, OrderID, Rating, Comment) VALUES (?,?,?,?,?,?)";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, review.getBuyerId());
            ps.setInt(2, review.getFarmerId());
            if (review.getListingId() != null)
                ps.setInt(3, review.getListingId());
            else
                ps.setNull(3, Types.INTEGER);
            if (review.getOrderId() != null)
                ps.setInt(4, review.getOrderId());
            else
                ps.setNull(4, Types.INTEGER);
            ps.setInt(5, review.getRating());
            ps.setString(6, review.getComment());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    private Review mapRow(ResultSet rs) throws SQLException {
        Review r = new Review();
        r.setReviewId(rs.getInt("ReviewID"));
        r.setBuyerId(rs.getInt("BuyerID"));
        r.setBuyerName(rs.getString("BuyerName"));
        r.setFarmerId(rs.getInt("FarmerID"));
        r.setFarmerName(rs.getString("FarmerName"));
        int lid = rs.getInt("ListingID");
        if (!rs.wasNull())
            r.setListingId(lid);
        r.setProductName(rs.getString("ProductName"));
        int oid = rs.getInt("OrderID");
        if (!rs.wasNull())
            r.setOrderId(oid);
        r.setRating(rs.getInt("Rating"));
        r.setComment(rs.getString("Comment"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        if (ts != null)
            r.setCreatedAt(ts.toLocalDateTime());
        return r;
    }
}
