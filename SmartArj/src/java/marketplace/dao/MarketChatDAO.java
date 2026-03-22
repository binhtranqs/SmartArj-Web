package marketplace.dao;

import marketplace.model.MarketChatMessage;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng MarketChatMessages (Buyer <-> Farmer)
 */
public class MarketChatDAO {

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null)
            throw new SQLException("Cannot get DB connection");
        return conn;
    }

    /**
     * Lấy lịch sử chat giữa 2 user về một listing cụ thể
     */
    public List<MarketChatMessage> findConversation(int user1, int user2, Integer listingId) {
        List<MarketChatMessage> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT m.MsgID, m.SenderID, us.FullName AS SenderName, " +
                        "m.ReceiverID, ur.FullName AS ReceiverName, " +
                        "m.ListingID, l.ProductName, m.Message, m.IsRead, m.SentAt " +
                        "FROM MarketChatMessages m " +
                        "JOIN Users us ON m.SenderID = us.UserID " +
                        "JOIN Users ur ON m.ReceiverID = ur.UserID " +
                        "LEFT JOIN Listings l ON m.ListingID = l.ListingID " +
                        "WHERE ((m.SenderID=? AND m.ReceiverID=?) OR (m.SenderID=? AND m.ReceiverID=?)) " +
                        "AND m.ListingID=?");
        List<Object> params = new ArrayList<>();
        params.add(user1);
        params.add(user2);
        params.add(user2);
        params.add(user1);
        params.add(listingId);

        sql.append(" ORDER BY m.SentAt ASC");

        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++)
                ps.setObject(i + 1, params.get(i));
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
     * Lấy FullName của user theo ID (dùng để hiện tên partner trong header chat)
     * Trả về "Người dùng" nếu không tìm thấy
     */
    public String findUserName(int userId) {
        String sql = "SELECT FullName FROM Users WHERE UserID=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String name = rs.getString("FullName");
                    return (name != null && !name.trim().isEmpty()) ? name.trim() : "Người dùng";
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return "Người dùng";
    }

    /**
     * Lấy danh sách partner đã chat với user, kèm tên + tin nhắn cuối
     * Trả về List<java.util.Map> có keys: partnerId, partnerName, lastMsg, lastTime
     */
    public List<java.util.Map<String, Object>> findChatPartnersWithInfo(int userId) {
        List<java.util.Map<String, Object>> result = new ArrayList<>();
        // Lấy partner cuối cùng chat, sắp xếp theo tin mới nhất
        String sql =
            "SELECT partner_id, listing_id, MAX(SentAt) AS last_time, " +
            "  (SELECT TOP 1 u2.FullName FROM Users u2 WHERE u2.UserID = partner_id) AS partner_name, " +
            "  (SELECT TOP 1 l.ProductName FROM Listings l WHERE l.ListingID = listing_id) AS product_name, " +
            "  (SELECT TOP 1 m2.Message FROM MarketChatMessages m2 " +
            "   WHERE ((m2.SenderID=? AND m2.ReceiverID=partner_id AND (m2.ListingID=listing_id OR (m2.ListingID IS NULL AND listing_id IS NULL))) OR (m2.SenderID=partner_id AND m2.ReceiverID=? AND (m2.ListingID=listing_id OR (m2.ListingID IS NULL AND listing_id IS NULL)))) " +
            "   ORDER BY m2.SentAt DESC) AS last_msg " +
            "FROM ( " +
            "  SELECT CASE WHEN SenderID=? THEN ReceiverID ELSE SenderID END AS partner_id, ListingID AS listing_id, SentAt " +
            "  FROM MarketChatMessages WHERE SenderID=? OR ReceiverID=? " +
            ") t GROUP BY partner_id, listing_id ORDER BY last_time DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            ps.setInt(2, userId);
            ps.setInt(3, userId);
            ps.setInt(4, userId);
            ps.setInt(5, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> row = new java.util.LinkedHashMap<>();
                    row.put("partnerId", rs.getInt("partner_id"));
                    row.put("partnerName", rs.getString("partner_name") != null ? rs.getString("partner_name") : "Người dùng");
                    
                    int lid = rs.getInt("listing_id");
                    if (!rs.wasNull()) {
                        row.put("listingId", lid);
                    }
                    row.put("productName", rs.getString("product_name"));
                    row.put("lastMsg", rs.getString("last_msg"));
                    Timestamp ts = rs.getTimestamp("last_time");
                    row.put("lastTime", ts != null ? ts.toLocalDateTime() : null);
                    result.add(row);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return result;
    }

    /**
     * Gửi tin nhắn
     */
    public boolean send(MarketChatMessage msg) {
        String sql = "INSERT INTO MarketChatMessages (SenderID, ReceiverID, ListingID, Message) VALUES (?,?,?,?)";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, msg.getSenderId());
            ps.setInt(2, msg.getReceiverId());
            if (msg.getListingId() != null)
                ps.setInt(3, msg.getListingId());
            else
                ps.setNull(3, Types.INTEGER);
            ps.setString(4, msg.getMessage());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("Database insert failed: " + e.getMessage(), e);
        }
    }

    /**
     * Đánh dấu đã đọc scoped by listing
     */
    public void markRead(int receiverId, int senderId, int listingId) {
        String sql = "UPDATE MarketChatMessages SET IsRead=1 WHERE ReceiverID=? AND SenderID=? AND ListingID=? AND IsRead=0";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, receiverId);
            ps.setInt(2, senderId);
            ps.setInt(3, listingId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    /**
     * Đếm tin nhắn chưa đọc
     */
    public int countUnread(int userId) {
        String sql = "SELECT COUNT(*) FROM MarketChatMessages WHERE ReceiverID=? AND IsRead=0";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0;
    }

    private MarketChatMessage mapRow(ResultSet rs) throws SQLException {
        MarketChatMessage m = new MarketChatMessage();
        m.setMsgId(rs.getInt("MsgID"));
        m.setSenderId(rs.getInt("SenderID"));
        m.setSenderName(rs.getString("SenderName"));
        m.setReceiverId(rs.getInt("ReceiverID"));
        m.setReceiverName(rs.getString("ReceiverName"));
        int lid = rs.getInt("ListingID");
        if (!rs.wasNull())
            m.setListingId(lid);
        m.setProductName(rs.getString("ProductName"));
        m.setMessage(rs.getString("Message"));
        m.setRead(rs.getBoolean("IsRead"));
        Timestamp ts = rs.getTimestamp("SentAt");
        if (ts != null)
            m.setSentAt(ts.toLocalDateTime());
        return m;
    }
}
