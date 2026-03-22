package marketplace.dao;

import marketplace.model.Region;
import util.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * DAO cho bảng Regions
 */
public class RegionDAO {

    private Connection getConnection() throws SQLException {
        Connection conn = new DBContext().getConnection();
        if (conn == null)
            throw new SQLException("Cannot get DB connection");
        return conn;
    }

    public List<Region> findAll() {
        List<Region> list = new ArrayList<>();
        String sql = "SELECT RegionID, RegionName, Province FROM Regions ORDER BY RegionName";
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

    public Region findById(int regionId) {
        String sql = "SELECT RegionID, RegionName, Province FROM Regions WHERE RegionID = ?";
        try (Connection conn = getConnection();
                PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, regionId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next())
                    return mapRow(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    private Region mapRow(ResultSet rs) throws SQLException {
        return new Region(
                rs.getInt("RegionID"),
                rs.getString("RegionName"),
                rs.getString("Province"));
    }
}
