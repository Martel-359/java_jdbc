package sql;
import java.sql.*;

public class ConnectionManager {
    private static Connection conn = null;


    public static Connection getConnection() {
            try {
                conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/qlshopphukien?"+"user=root");

            } catch (SQLException ex) {
                ex.printStackTrace();
                System.out.println("Failed to create the database connection."); 
            }
        return conn;
    }
}