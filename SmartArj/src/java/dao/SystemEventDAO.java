package dao;

import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

/**
 * Pure-JDBC DAO for the SystemEvents table.
 *
 * Follows the same pattern as ListingDAO / MarketPriceDAO — uses DBContext
 * directly (no JPA), so it works even if Hibernate is unavailable.
 *
 * Schema (SystemEvents):
 *   EventId     INT IDENTITY PK
 *   EventType   NVARCHAR(50)   NOT NULL
 *   UserId      INT            NULL
 *   EntityId    INT            NULL
 *   Description NVARCHAR(500)  NOT NULL
 *   CreatedAt   DATETIME       DEFAULT GETDATE()
 */
public class SystemEventDAO {

    private static final Logger log = Logger.getLogger(SystemEventDAO.class.getName());

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null) throw new SQLException("Cannot get DB connection");
        return conn;
    }

    // ──────────────────────────────────────────────────────────────
    // WRITE
    // ──────────────────────────────────────────────────────────────

    /**
     * Persist one system event row. Silently ignores errors to avoid
     * disrupting the main business flow.
     *
     * @param eventType   e.g. "LISTING_CREATED"
     * @param userId      nullable actor ID
     * @param entityId    nullable entity ID (ListingID / OrderID)
     * @param description human-readable summary
     */
    public void insertEvent(String eventType, Integer userId,
                            Integer entityId, String description) {
        String sql = "INSERT INTO SystemEvents (EventType, UserId, EntityId, Description) "
                   + "VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eventType);
            if (userId != null) ps.setInt(2, userId);
            else                ps.setNull(2, Types.INTEGER);
            if (entityId != null) ps.setInt(3, entityId);
            else                  ps.setNull(3, Types.INTEGER);
            // Truncate description to 500 chars to match column length
            String desc = description != null ? description : "";
            if (desc.length() > 500) desc = desc.substring(0, 500);
            ps.setString(4, desc);
            ps.executeUpdate();
        } catch (SQLException e) {
            log.warning("[SystemEventDAO] insertEvent failed: " + e.getMessage());
        }
    }

    // ──────────────────────────────────────────────────────────────
    // READ
    // ──────────────────────────────────────────────────────────────

    /**
     * Returns the N most recent events, newest first.
     *
     * @param limit max rows to return
     * @return list of maps with keys: eventId, eventType, userId, entityId,
     *         description, createdAt
     */
    public List<Map<String, Object>> getRecentEvents(int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        int safeLimit = (limit > 0 && limit <= 500) ? limit : 100;
        String sql = "SELECT TOP " + safeLimit + " "
                   + "EventId, EventType, UserId, EntityId, Description, CreatedAt "
                   + "FROM SystemEvents ORDER BY CreatedAt DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                result.add(mapRow(rs));
            }
        } catch (SQLException e) {
            log.warning("[SystemEventDAO] getRecentEvents failed: " + e.getMessage());
        }
        return result;
    }

    /**
     * Returns recent events filtered by type.
     *
     * @param eventType exact event type string (e.g. "ORDER_CREATED")
     * @param limit     max rows
     */
    public List<Map<String, Object>> getEventsByType(String eventType, int limit) {
        List<Map<String, Object>> result = new ArrayList<>();
        int safeLimit = (limit > 0 && limit <= 500) ? limit : 100;
        String sql = "SELECT TOP " + safeLimit + " "
                   + "EventId, EventType, UserId, EntityId, Description, CreatedAt "
                   + "FROM SystemEvents WHERE EventType = ? ORDER BY CreatedAt DESC";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, eventType);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) result.add(mapRow(rs));
            }
        } catch (SQLException e) {
            log.warning("[SystemEventDAO] getEventsByType failed: " + e.getMessage());
        }
        return result;
    }

    /**
     * Returns a count breakdown: eventType → count.
     * Used to render the KPI cards on the events dashboard.
     */
    public Map<String, Integer> countByType() {
        Map<String, Integer> counts = new LinkedHashMap<>();
        String sql = "SELECT EventType, COUNT(*) AS Cnt FROM SystemEvents GROUP BY EventType";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                counts.put(rs.getString("EventType"), rs.getInt("Cnt"));
            }
        } catch (SQLException e) {
            log.warning("[SystemEventDAO] countByType failed: " + e.getMessage());
        }
        return counts;
    }

    /**
     * Total number of events in the table.
     */
    public int countTotal() {
        String sql = "SELECT COUNT(*) FROM SystemEvents";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        } catch (SQLException e) {
            log.warning("[SystemEventDAO] countTotal failed: " + e.getMessage());
        }
        return 0;
    }

    // ──────────────────────────────────────────────────────────────
    // PRIVATE HELPERS
    // ──────────────────────────────────────────────────────────────

    private Map<String, Object> mapRow(ResultSet rs) throws SQLException {
        Map<String, Object> row = new LinkedHashMap<>();
        row.put("eventId",     rs.getInt("EventId"));
        row.put("eventType",   rs.getString("EventType"));
        int uid = rs.getInt("UserId");
        row.put("userId",      rs.wasNull() ? null : uid);
        int eid = rs.getInt("EntityId");
        row.put("entityId",    rs.wasNull() ? null : eid);
        row.put("description", rs.getString("Description"));
        Timestamp ts = rs.getTimestamp("CreatedAt");
        row.put("createdAt",   ts != null ? ts.toLocalDateTime() : null);
        return row;
    }
}
