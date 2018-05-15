package softuni.demo04052018.task1;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.HashMap;
import java.util.Map;

import com.mysql.jdbc.PreparedStatement;

public class Main {

	public static void main(String[] args) throws SQLException {
		
//		try {
		createConnection();
		
	}
	
	public static void createConnection() throws SQLException {
		String URL = "jdbc:mysql://localhost:3306/softuni_db_test?createDatabaseIfNotExist=true";
		String USER = "root";
		String PASSWORD = "corero123";
		
		Connection conn = null;
		PreparedStatement preStmt = null;
		Statement stmt = null;
		ResultSet rs = null;
		
		String createTableSql = "CREATE TABLE IF NOT EXISTS admins( " +
				"id INT AUTO_INCREMENT PRIMARY KEY," +
				"user VARCHAR(20)," +
				"password VARCHAR(20)" +
				")";
		
		String insertData = "INSERT INTO admins(user, password)" +
				"VALUES('Pesho','12345'),('ivan', '3421')";
		
		String selectSql = "SELECT * FROM admins";
		
		
		try {
			conn = DriverManager.getConnection(URL, USER, PASSWORD);
			if(conn!=null) {
				System.out.println("Connection is open");
			}
			preStmt.executeUpdate(createTableSql);
//			preStmt = new PreparedStatement(createTableSql, "pesho");
			 stmt = conn.createStatement();
			 stmt.executeUpdate(createTableSql);
			 stmt.executeUpdate(insertData);
			 
			 rs = stmt.executeQuery(selectSql);
			 if(rs != null) {
				 rs.beforeFirst();
				 while (rs.next()) {
					System.out.printf("User: %s, password:%s. %n", 
							rs.getString("user"), rs.getString("password"));
				}
			 }
		} catch (SQLException e) {
//StringBuilder builder = new StringBuilder();
			e.getMessage();
		} finally {
			if(rs != null) {
				rs.close();
				rs = null;
			}
			if(stmt != null) {
				stmt.close();
				stmt = null;
			}
			if(conn != null || !conn.isClosed()) {
				conn.close();
				conn = null;
				System.out.println("Connection is closed");
			}
		}
	}
	
	public void testStatement() throws SQLException {

		PreparedStatement pr = null;
		ResultSet rs = pr.executeQuery("Select");
		ResultSetMetaData rsm = rs.getMetaData();
		int cCount = rsm.getColumnCount();
		while (rs.next()) {
			Map<String, Object> resultMap = new HashMap<>();
			for (int i = 1; i <= cCount; i++) {
				String columnName = rsm.getColumnLabel(i);
				Object value = rs.getObject(i);
				resultMap.put(columnName, value);			
			}
			
			System.out.println(resultMap);
		}
		
	}
}
