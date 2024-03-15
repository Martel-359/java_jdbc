-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th10 29, 2023 lúc 03:59 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `qlshopphukien`
--

DELIMITER $$
--
-- Thủ tục
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `call_login` (IN `p_username` VARCHAR(30), IN `p_password` VARCHAR(50), OUT `p_result` INT, OUT `p_result_message` VARCHAR(255))   BEGIN
    -- Call the login function
    SET p_result = login(p_username, p_password);

    -- Check the result and set the message accordingly
    IF p_result = 0 THEN
        SET p_result_message = 'Tài khoản hoặc mật khẩu không chính xác';
    ELSE
        SET p_result_message = 'Đăng nhập thành công';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateAdmin` (IN `p_TaiKhoan` CHAR(30), IN `p_MatKhau` VARCHAR(50), OUT `p_ResultMessage` VARCHAR(255))   BEGIN
    DECLARE v_TaiKhoan CHAR;

    SELECT TaiKhoan into v_TaiKhoan
    FROM Admin
    WHERE TaiKhoan= p_TaiKhoan;

    IF v_TaiKhoan IS NOT NULL THEN
        SET p_ResultMessage='Tài Khoản Đã Tồn Tại';
    ELSE
        INSERT INTO Admin(TaiKhoan,MatKhau) VALUES (p_TaiKhoan,p_MatKhau);
        SET p_ResultMessage='Tạo Tài Khoản Thành Công';
    END IF;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CreateSanPham` (IN `p_TenSanPham` CHAR(50), IN `p_SoLuong` INT, IN `p_Gia` INT, IN `p_Creator` INT)   BEGIN
    INSERT INTO SanPham (TenSanPham, SoLuong, Gia, Creator)
    VALUES (p_TenSanPham, p_SoLuong, p_Gia, p_Creator);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `DeleteProduct` (IN `p_IdSanPham` INT, IN `p_AdminId` INT, OUT `p_ResultMessage` VARCHAR(255))   BEGIN
    DECLARE v_CreatorId INT;

    -- Get the Creator (Admin) of the product
    SELECT Creator INTO v_CreatorId
    FROM SanPham
    WHERE IdSanPham = p_IdSanPham;

    -- Check if the product exists
    IF v_CreatorId IS NOT NULL THEN
        -- Check if the Admin has the right to delete the product
        IF v_CreatorId = p_AdminId THEN
            -- Delete the product
            DELETE FROM SanPham WHERE IdSanPham = p_IdSanPham;
            SET p_ResultMessage = 'Xóa sản phẩm thành công';
        ELSE
            SET p_ResultMessage = 'Không có quyền xóa sản phẩm';
        END IF;
    ELSE
        SET p_ResultMessage = 'Sản phẩm không tồn tại';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateSanPham` (IN `p_IdSanPham` INT, IN `p_TenSanPham` CHAR(50), IN `p_SoLuong` INT, IN `p_Gia` INT, IN `p_Creator` INT)   BEGIN
    UPDATE SanPham
    SET
        TenSanPham = p_TenSanPham,
        SoLuong = p_SoLuong,
        Gia = p_Gia,
        Creator = p_Creator
    WHERE IdSanPham = p_IdSanPham;
END$$

--
-- Các hàm
--
CREATE DEFINER=`root`@`localhost` FUNCTION `login` (`p_username` VARCHAR(30), `p_password` VARCHAR(50)) RETURNS INT(11)  BEGIN
    DECLARE v_result INT;

    SELECT IdAdmin INTO v_result
    FROM Admin
    WHERE TaiKhoan = p_username AND MatKhau = p_password;

    IF v_result IS NULL THEN
        RETURN 0;
    END IF;

    RETURN v_result; 
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `admin`
--

CREATE TABLE `admin` (
  `IdAdmin` int(11) NOT NULL,
  `TaiKhoan` char(30) NOT NULL,
  `MatKhau` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Đang đổ dữ liệu cho bảng `admin`
--

INSERT INTO `admin` (`IdAdmin`, `TaiKhoan`, `MatKhau`) VALUES
(1, 'admin1', '123456'),
(2, 'admin2', '123456'),
(3, 'admin3', '123456');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sanpham`
--

CREATE TABLE `sanpham` (
  `IdSanPham` int(11) NOT NULL,
  `TenSanPham` char(50) DEFAULT NULL,
  `SoLuong` int(11) DEFAULT NULL,
  `Gia` int(11) DEFAULT NULL,
  `Creator` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Đang đổ dữ liệu cho bảng `sanpham`
--

INSERT INTO `sanpham` (`IdSanPham`, `TenSanPham`, `SoLuong`, `Gia`, `Creator`) VALUES
(24, 'Móc Khóa', 130, 10000, 2),
(25, 'Vòng Tay', 20, 200000, 2),
(26, 'Bao Tay', 54, 80000, 2),
(27, 'Vớ', 75, 20000, 3),
(28, 'Cáp Sạn Điện Thoại', 75, 50000, 3),
(29, 'update', 11, 2000, 1),
(30, 'Viết Chì', 56, 3000, 2),
(37, 'test', 12, 20000, 1);

--
-- Bẫy `sanpham`
--
DELIMITER $$
CREATE TRIGGER `BeforeUpdateSanPham` BEFORE UPDATE ON `sanpham` FOR EACH ROW BEGIN
    DECLARE creator_id_expected INT;
    SELECT Creator INTO creator_id_expected FROM SanPham WHERE IdSanPham = NEW.IdSanPham;
    IF NEW.Creator <> creator_id_expected THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Không thể cập nhật sản phẩm. Do bạn không phải người thêm sản phẩm';
    END IF;
END
$$
DELIMITER ;

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `admin`
--
ALTER TABLE `admin`
  ADD PRIMARY KEY (`IdAdmin`,`TaiKhoan`);

--
-- Chỉ mục cho bảng `sanpham`
--
ALTER TABLE `sanpham`
  ADD PRIMARY KEY (`IdSanPham`),
  ADD KEY `Creator` (`Creator`);

--
-- AUTO_INCREMENT cho các bảng đã đổ
--

--
-- AUTO_INCREMENT cho bảng `admin`
--
ALTER TABLE `admin`
  MODIFY `IdAdmin` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT cho bảng `sanpham`
--
ALTER TABLE `sanpham`
  MODIFY `IdSanPham` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=38;

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `sanpham`
--
ALTER TABLE `sanpham`
  ADD CONSTRAINT `sanpham_ibfk_1` FOREIGN KEY (`Creator`) REFERENCES `admin` (`IdAdmin`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
