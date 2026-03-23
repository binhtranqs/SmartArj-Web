package marketplace.dao;

import marketplace.model.Order;
import marketplace.model.OrderItem;
import util.DBContext;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng Orders + OrderItems - dùng JDBC thuần
 */
public class OrderDAO {

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null)
            throw new SQLException("Cannot get DB connection");
        return conn;
    }

    /**
     * Lấy orders của buyer
     */
    public List<Order> findByBuyer(int buyerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.OrderID, o.BuyerID, ub.FullName AS BuyerName, " +
                "o.FarmerID, uf.FullName AS FarmerName, " +
                "o.TotalAmount, o.Status, o.Note, o.ShipAddress, o.PaymentMethod, o.PaymentStatus, o.VnpTxnRef, o.CreatedAt, o.UpdatedAt " +
                "FROM Orders o " +
                "JOIN Users ub ON o.BuyerID = ub.UserID " +
                "JOIN Users uf ON o.FarmerID = uf.UserID " +
                "WHERE o.BuyerID = ? ORDER BY o.CreatedAt DESC";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, buyerId);
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
     * Lấy orders nhận được của farmer
     */
    public List<Order> findByFarmer(int farmerId) {
        List<Order> list = new ArrayList<>();
        String sql = "SELECT o.OrderID, o.BuyerID, ub.FullName AS BuyerName, " +
                "o.FarmerID, uf.FullName AS FarmerName, " +
                "o.TotalAmount, o.Status, o.Note, o.ShipAddress, o.PaymentMethod, o.PaymentStatus, o.VnpTxnRef, o.CreatedAt, o.UpdatedAt " +
                "FROM Orders o " +
                "JOIN Users ub ON o.BuyerID = ub.UserID " +
                "JOIN Users uf ON o.FarmerID = uf.UserID " +
                "WHERE o.FarmerID = ? ORDER BY o.CreatedAt DESC";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Order o = mapRow(rs);
                    o.setItems(findItemsByOrder(o.getOrderId())); // load items for expand panel
                    list.add(o);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    /**
     * Lấy order theo ID
     */
    public Order findById(int orderId) {
        String sql = "SELECT o.OrderID, o.BuyerID, ub.FullName AS BuyerName, " +
                "o.FarmerID, uf.FullName AS FarmerName, " +
                "o.TotalAmount, o.Status, o.Note, o.ShipAddress, o.PaymentMethod, o.PaymentStatus, o.VnpTxnRef, o.CreatedAt, o.UpdatedAt " +
                "FROM Orders o " +
                "JOIN Users ub ON o.BuyerID = ub.UserID " +
                "JOIN Users uf ON o.FarmerID = uf.UserID " +
                "WHERE o.OrderID = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Order o = mapRow(rs);
                    o.setItems(findItemsByOrder(orderId));
                    return o;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Tạo order mới + order items (transaction)
     */
    public int create(Order order) {
        String sqlOrder = "INSERT INTO Orders (BuyerID, FarmerID, TotalAmount, Status, Note, ShipAddress, PaymentMethod, PaymentStatus) VALUES (?,?,?,?,?,?,?,?)";
        String sqlItem  = "INSERT INTO OrderItems (OrderID, ListingID, Quantity, UnitPrice) VALUES (?,?,?,?)";

        try (Connection conn = getConnection()) {
            conn.setAutoCommit(false);
            try {
                int orderId;
                try (PreparedStatement ps = conn.prepareStatement(sqlOrder, Statement.RETURN_GENERATED_KEYS)) {
                    ps.setInt(1, order.getBuyerId());
                    ps.setInt(2, order.getFarmerId());
                    ps.setBigDecimal(3, order.getTotalAmount());
                    ps.setString(4, "PENDING");
                    ps.setString(5, order.getNote());
                    ps.setString(6, order.getShipAddress());
                    ps.setString(7, order.getPaymentMethod() != null ? order.getPaymentMethod() : "COD");
                    ps.setString(8, order.getPaymentStatus() != null ? order.getPaymentStatus() : "UNPAID");
                    ps.executeUpdate();
                    try (ResultSet keys = ps.getGeneratedKeys()) {
                        if (!keys.next())
                            throw new SQLException("No generated key");
                        orderId = keys.getInt(1);
                    }
                }

                if (order.getItems() != null) {
                    try (PreparedStatement ps = conn.prepareStatement(sqlItem)) {
                        for (OrderItem item : order.getItems()) {
                            ps.setInt(1, orderId);
                            ps.setInt(2, item.getListingId());
                            ps.setBigDecimal(3, item.getQuantity());
                            ps.setBigDecimal(4, item.getUnitPrice());
                            ps.addBatch();
                        }
                        ps.executeBatch();
                    }
                }

                conn.commit();
                return orderId;
            } catch (Exception e) {
                conn.rollback();
                e.printStackTrace();
                throw new RuntimeException("DB Checkout Error: " + e.getMessage(), e);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            throw new RuntimeException("DB Connection/Commit Error: " + e.getMessage(), e);
        }
    }

    /**
     * Cập nhật trạng thái order
     */
    public boolean updateStatus(int orderId, String status, int actorId) {
        String sql = "UPDATE Orders SET Status=?, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderID=? AND (BuyerID=? OR FarmerID=?)";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, orderId);
            ps.setInt(3, actorId);
            ps.setInt(4, actorId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Cập nhật trạng thái thanh toán (gọi sau khi VNPay callback thành công)
     */
    public boolean updatePaymentStatus(int orderId, String paymentStatus, String vnpTxnRef) {
        String sql;
        if (vnpTxnRef != null) {
            sql = "UPDATE Orders SET PaymentStatus=?, VnpTxnRef=?, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderID=?";
        } else {
            sql = "UPDATE Orders SET PaymentStatus=?, UpdatedAt=CURRENT_TIMESTAMP WHERE OrderID=?";
        }
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, paymentStatus);
            if (vnpTxnRef != null) {
                ps.setString(2, vnpTxnRef);
                ps.setInt(3, orderId);
            } else {
                ps.setInt(2, orderId);
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Tổng doanh thu của farmer
     */
    public BigDecimal getTotalRevenueByFarmer(int farmerId) {
        String sql = "SELECT COALESCE(SUM(TotalAmount),0) FROM Orders WHERE FarmerID=? AND Status='COMPLETED'";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, farmerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return rs.getBigDecimal(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    /**
     * Đếm tổng đơn hàng
     */
    public int countAll() {
        String sql = "SELECT COUNT(*) FROM Orders";
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
     * Tổng doanh thu hệ thống
     */
    public BigDecimal getTotalRevenue() {
        String sql = "SELECT COALESCE(SUM(TotalAmount),0) FROM Orders WHERE Status='COMPLETED'";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql);
                ResultSet rs = ps.executeQuery()) {
            if (rs.next())
                return rs.getBigDecimal(1);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return BigDecimal.ZERO;
    }

    public List<OrderItem> findItemsByOrder(int orderId) {
        List<OrderItem> items = new ArrayList<>();
        String sql = "SELECT oi.ItemID, oi.OrderID, oi.ListingID, COALESCE(l.ProductName, 'Sản phẩm đã xóa') AS ProductName, oi.Quantity, oi.UnitPrice " +
                "FROM OrderItems oi " +
                "LEFT JOIN Listings l ON oi.ListingID = l.ListingID " +
                "WHERE oi.OrderID = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    OrderItem item = new OrderItem();
                    item.setItemId(rs.getInt("ItemID"));
                    item.setOrderId(rs.getInt("OrderID"));
                    item.setListingId(rs.getInt("ListingID"));
                    item.setProductName(rs.getString("ProductName"));
                    item.setQuantity(rs.getBigDecimal("Quantity"));
                    item.setUnitPrice(rs.getBigDecimal("UnitPrice"));
                    items.add(item);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }

    private Order mapRow(ResultSet rs) throws SQLException {
        Order o = new Order();
        o.setOrderId(rs.getInt("OrderID"));
        o.setBuyerId(rs.getInt("BuyerID"));
        o.setBuyerName(rs.getString("BuyerName"));
        o.setFarmerId(rs.getInt("FarmerID"));
        o.setFarmerName(rs.getString("FarmerName"));
        o.setTotalAmount(rs.getBigDecimal("TotalAmount"));
        o.setStatus(rs.getString("Status"));
        // Payment fields – null-safe (column may not exist in old schema)
        try { o.setPaymentMethod(rs.getString("PaymentMethod")); } catch (SQLException ignored) {}
        try { o.setPaymentStatus(rs.getString("PaymentStatus")); } catch (SQLException ignored) {}
        try { o.setVnpTxnRef(rs.getString("VnpTxnRef")); }       catch (SQLException ignored) {}
        o.setNote(rs.getString("Note"));
        o.setShipAddress(rs.getString("ShipAddress"));
        Timestamp ca = rs.getTimestamp("CreatedAt");
        if (ca != null) o.setCreatedAt(ca.toLocalDateTime());
        Timestamp ua = rs.getTimestamp("UpdatedAt");
        if (ua != null) o.setUpdatedAt(ua.toLocalDateTime());
        return o;
    }
}
