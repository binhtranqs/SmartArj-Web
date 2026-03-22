package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBContext {

    // Config from persistence.xml
    private final String SERVER = "localhost";
    private final String PORT = "1433";
    private final String DB_NAME = "SmartAgri_PRJ301";
    private final String USERID = "sa";
    private final String PASSWORD = "YourStrong@123";

    public Connection getConnection() {
        try {
            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            String url = "jdbc:sqlserver://" + SERVER + ":" + PORT + ";databaseName=" + DB_NAME
                    + ";encrypt=true;trustServerCertificate=true"
                    + ";sendStringParametersAsUnicode=true"
                    + ";characterEncoding=UTF-8";
            return DriverManager.getConnection(url, USERID, PASSWORD);
        } catch (ClassNotFoundException | SQLException e) {
            e.printStackTrace();
            return null;
        }
    }
}
