package util;

/**
 * Utility class để hash và kiểm tra mật khẩu
 * Sử dụng thuật toán đơn giản cho development
 * 
 * LƯU Ý: Trong production nên dùng BCrypt hoặc Argon2
 */
public class PasswordUtil {

    /**
     * Hash mật khẩu bằng SHA-256 (đơn giản cho development)
     * 
     * @param plainPassword mật khẩu gốc
     * @return mật khẩu đã hash
     */
    public static String hashPassword(String plainPassword) {
        try {
            java.security.MessageDigest md = java.security.MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(plainPassword.getBytes("UTF-8"));

            // Chuyển byte array thành hex string
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1)
                    hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (Exception e) {
            throw new RuntimeException("Lỗi khi hash mật khẩu", e);
        }
    }

    /**
     * Kiểm tra mật khẩu có khớp không
     * 
     * @param plainPassword  mật khẩu người dùng nhập
     * @param hashedPassword mật khẩu đã hash trong database
     * @return true nếu khớp
     */
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        String hashed = hashPassword(plainPassword);
        return hashed.equals(hashedPassword);
    }

    /**
     * Kiểm tra độ mạnh của mật khẩu
     * 
     * @param password mật khẩu cần kiểm tra
     * @return true nếu mật khẩu đủ mạnh
     */
    public static boolean isStrongPassword(String password) {
        if (password == null || password.length() < 6) {
            return false;
        }
        // Có thể thêm các rule khác: chữ hoa, số, ký tự đặc biệt...
        return true;
    }

    /**
     * Tạo mật khẩu ngẫu nhiên
     * 
     * @param length độ dài mật khẩu
     * @return mật khẩu ngẫu nhiên
     */
    public static String generateRandomPassword(int length) {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
        StringBuilder password = new StringBuilder();
        java.util.Random random = new java.util.Random();

        for (int i = 0; i < length; i++) {
            password.append(chars.charAt(random.nextInt(chars.length())));
        }

        return password.toString();
    }
}
