package util;

import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtil {

    // Kiểm tra độ mạnh mật khẩu
    public static boolean isStrongPassword(String password) {
        return password != null && password.length() >= 6;
    }

    // Hash mật khẩu
    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(12));
    }

    // Kiểm tra mật khẩu
    public static boolean checkPassword(String plainPassword, String hashedPassword) {
        if (hashedPassword == null) return false;
        return BCrypt.checkpw(plainPassword, hashedPassword);
    }
}