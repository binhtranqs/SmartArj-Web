import java.sql.*;

public class CheckDB {
    public static void main(String[] args) {
        String url = "jdbc:sqlserver://localhost:1433;databaseName=SmartAgri_PRJ301;encrypt=true;trustServerCertificate=true";
        String user = "sa";
        String pass = "123";

        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            try (Connection conn = DriverManager.getConnection(url, user, pass)) {

                System.out.println("--- WeatherLogs ---");
                try (Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT * FROM WeatherLogs ORDER BY RecordedAt DESC LIMIT 5")) {
                    while (rs.next()) {
                        System.out.println("ZoneID: " + rs.getInt("ZoneID") +
                                ", Date: " + rs.getTimestamp("RecordedAt") +
                                ", Temp: " + rs.getDouble("Temperature") +
                                ", Hum: " + rs.getDouble("Humidity") +
                                ", Rain: " + rs.getDouble("Rainfall") +
                                ", Wind: " + rs.getDouble("Wind"));
                    }
                }

                System.out.println("--- Zones ---");
                try (Statement stmt = conn.createStatement();
                        ResultSet rs = stmt.executeQuery("SELECT * FROM Zones")) {
                    while (rs.next()) {
                        System.out.println("ZoneID: " + rs.getInt("ZoneID") + " Name: " + rs.getString("ZoneName"));
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
