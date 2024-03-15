
package app;

import java.sql.Connection;
import java.sql.*;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Scanner;
import sql.ConnectionManager;

public class App {

    public static void main(String[] args) {
    	Scanner sc = new Scanner(System.in);
        Connection conn = ConnectionManager.getConnection();

        int Id = 0;
        int function = 0;

        int state = homePage();
 
        	while(state==2) {
        		CreateAdmin(conn);
        		state = homePage();
        		
        	}

        if (state == 1) {
            while (Id == 0) {
                Id = callLogin(conn);
            }
            while (function != 5) {
                function = funtionPage();
                switch (function) {
                    case 1:
                        ListProduct(conn);
                        break;
                    case 2:
                        createProduct(conn, Id);
                        break;
                    case 3:
                        updateProduct(conn, Id);
                        break;
                    case 4:
                        deleteProduct(conn,Id);
                        break;
                }
            }
        }
        
    }


    private static void ListProduct(Connection conn) {
        try (PreparedStatement statement = conn.prepareStatement("SELECT SanPham.*, Admin.TaiKhoan FROM SanPham INNER JOIN Admin ON SanPham.Creator = Admin.IdAdmin;")) {
            ResultSet resultSet = statement.executeQuery();
            System.out.printf("%-15s%-20s%-10s%-10s%-20s\n", "Id Sản Phẩm", "Tên Phụ Kiện", "Giá Tiền", "Số Lượng", "Tài khoản Tạo Sản Phẩm");
            while (resultSet.next()) {
                // Process each row of the result set
                System.out.printf("%-15s%-20s%-10s%-10s%-20s\n",
                        resultSet.getString("IdSanPham"),
                        resultSet.getString("TenSanPham"),
                        resultSet.getString("Gia"),
                        resultSet.getString("SoLuong"),
                        resultSet.getString("TaiKhoan"));
            }
            System.out.println("---------------------------------------------------------------------");
        } catch (SQLException e) {
            System.err.println("Error listing products: " + e.getMessage());
        }
    }

    private static void createProduct(Connection conn, int creatorId) {
    	 Scanner scanner = new Scanner(System.in);

         System.out.print("Enter product name: ");
         String tenSanPham = scanner.nextLine();

         System.out.print("Enter quantity: ");
         int soLuong = scanner.nextInt();

         System.out.print("Enter price: ");
         int gia = scanner.nextInt();
        try (CallableStatement statement = conn.prepareCall("{CALL CreateSanPham(?, ?, ?, ?)}")) {
            // Set parameters for the stored procedure
            statement.setString(1, tenSanPham);
            statement.setInt(2, soLuong);
            statement.setInt(3, gia);
            statement.setInt(4, creatorId);

            // Execute the stored procedure
            statement.execute();
            
            System.out.println("Product created successfully.");
        } catch (SQLException e) {
            e.printStackTrace(); // Handle the exception appropriately
        }
    }
    
    private static void updateProduct(Connection conn, int creatorId) {
    	Scanner scanner = new Scanner(System.in);
    	
    	System.out.print("Nhập id sản phẩm: ");
    	int IdSanPham = scanner.nextInt();
    	  scanner.nextLine();

        System.out.print("Nhập tên sản phẩm: ");
        String tenSanPham = scanner.nextLine();

        System.out.print("Nhập số lượng: ");
        int soLuong = scanner.nextInt();

        System.out.print("Nhập giá tiền: ");
        int gia = scanner.nextInt();
        
        try (CallableStatement statement = conn.prepareCall("{CALL UpdateSanpham(?, ?, ?, ?, ?)}")) {
            // Set parameters for the stored procedure
        	statement.setInt(1, IdSanPham);
            statement.setString(2, tenSanPham);
            statement.setInt(3, soLuong);
            statement.setInt(4, gia);
            statement.setInt(5, creatorId);

            // Execute the stored procedure
            statement.execute();
            
            System.out.println("Cập Nhật Sản Phẩm Thành Công");
        } catch (SQLException e) {
            System.err.println("Error updating product: " + e.getMessage());// Handle the exception appropriately
        }
	}
    
    private static void deleteProduct(Connection conn, int creatorId) {
        Scanner scanner = new Scanner(System.in);

        System.out.print("Nhập Id sản phẩm cần xóa: ");
        int idSanPham = scanner.nextInt();

        try (CallableStatement statement = conn.prepareCall("{CALL DeleteProduct(?, ?, ?)}")) {
            // Set parameters for the stored procedure
            statement.setInt(1, idSanPham);
            statement.setInt(2, creatorId);

            // Register the output parameter for the result message
            statement.registerOutParameter(3, Types.VARCHAR);

            // Execute the stored procedure
            statement.execute();

            // Retrieve the result message from the stored procedure
            String resultMessage = statement.getString(3);
            System.out.println(resultMessage);
        } catch (SQLException e) {
            System.err.println("Error deleting product: " + e.getMessage());// Handle the exception appropriately
        }
    }

    private static void CreateAdmin (Connection conn) {
    	Scanner scanner = new Scanner(System.in);
    	System.out.print("Nhập tài khoản mới: ");
    	String taiKhoan =scanner.nextLine();
    	System.out.print("Nhập mật khẩu");
    	String matKhau =scanner.nextLine();
    	try (CallableStatement statement = conn.prepareCall("{call CreateAdmin(?, ?, ?)}")){
    		statement.setString(1, taiKhoan);
    		statement.setString(2, matKhau);
    		
    		statement.registerOutParameter(3, Types.VARCHAR);
    		
    		statement.execute();
    		
    		String result=statement.getString(3);
    		System.out.println(result);
		} catch (Exception e) {
			  e.printStackTrace();
		}
    }
    
    private static int callLogin(Connection conn) {
    	Scanner scanner = new Scanner(System.in);
        System.out.print("Nhập tài khoản: ");
        String taiKhoan = scanner.nextLine();
        System.out.print("Nhập mật khẩu: ");
        String matKhau = scanner.nextLine();
        try (CallableStatement statement = conn.prepareCall("{call call_login(?, ?, ?, ?)}")) {
        		statement.setString(1, taiKhoan);
        		statement.setString(2, matKhau);

        		statement.registerOutParameter(3, Types.INTEGER);         // p_result
        		statement.registerOutParameter(4, Types.VARCHAR);         // p_result_message

        		statement.execute();

                int result = statement.getInt(3);
                String resultMessage = statement.getString(4);

                System.out.println(resultMessage);
                return result;
            } catch (SQLException e) {
                e.printStackTrace();
                return -1;
            }
        }
    
	private static int homePage() {
		Scanner scanner = new Scanner(System.in);
		System.out.println("Chào mừng đến với trang chủ shop phụ kiện");
		System.out.println("1.Đăng Nhập");
		System.out.println("2.Đăng Kí");
		int state;
		while(true) {
			System.out.println("Nhập chức năng cần dùng:");
			state = scanner.nextInt();
			if(state==1 || state==2) {
				return state;
			}
		}
	}
	
	private static int funtionPage() {
		Scanner scanner = new Scanner(System.in);
		System.out.println("Chào mừng đến với trang quản lý shop phụ kiện");
		System.out.println("1.Xem danh sách sản phẩm ");
		System.out.println("2.Thêm sản phẩm");
		System.out.println("3.Sửa sản phẩm");
		System.out.println("4.Xóa sản phẩm");
		int state;
		while(true) {
			System.out.println("Nhập chức năng cần dùng:");
			state = scanner.nextInt();
			if(state >=1 && state <=4) {
				return state;
			}
		}
	}
	
}