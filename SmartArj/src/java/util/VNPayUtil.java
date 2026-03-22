package util;

import config.VNPayConfig;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Map;
import java.util.TreeMap;

public final class VNPayUtil {
    private VNPayUtil() {
    }

    // Build query string from params in alphabetical order.
    // IMPORTANT: key is raw, value is URL-encoded.
    public static String buildQueryString(Map<String, String> params) {
        TreeMap<String, String> sorted = new TreeMap<>(params);
        StringBuilder sb = new StringBuilder();

        for (Map.Entry<String, String> entry : sorted.entrySet()) {
            String key = entry.getKey();
            String value = entry.getValue();

            if (key == null || value == null || value.isEmpty())
                continue;

            if (sb.length() > 0)
                sb.append("&");

            sb.append(key);
            sb.append("=");
            sb.append(urlEncode(value));
        }
        return sb.toString();
    }

    public static String hmacSHA512(String secret, String data) {
        try {
            Mac hmac512 = Mac.getInstance("HmacSHA512");
            SecretKeySpec secretKey = new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA512");
            hmac512.init(secretKey);
            byte[] bytes = hmac512.doFinal(data.getBytes(StandardCharsets.UTF_8));
            return toHex(bytes);
        } catch (Exception e) {
            throw new RuntimeException("Cannot generate HMAC SHA512", e);
        }
    }

    // Safe default verify: removes vnp_SecureHash / vnp_SecureHashType
    // automatically
    public static boolean verifySignature(Map<String, String> params, String receivedHash, String secret) {
        if (receivedHash == null || receivedHash.isEmpty() || params == null)
            return false;

        TreeMap<String, String> copied = new TreeMap<>(params);
        copied.remove("vnp_SecureHash");
        copied.remove("vnp_SecureHashType");

        String data = buildQueryString(copied);
        String calculated = hmacSHA512(secret, data);
        return calculated.equalsIgnoreCase(receivedHash);
    }

    public static boolean verifySignature(Map<String, String> params, String receivedHash) {
        return verifySignature(params, receivedHash, VNPayConfig.VNP_HASH_SECRET);
    }

    private static String urlEncode(String value) {
        try {
            return URLEncoder.encode(value, StandardCharsets.UTF_8.toString());
        } catch (Exception e) {
            throw new RuntimeException("Cannot URL encode value", e);
        }
    }

    private static String toHex(byte[] bytes) {
        StringBuilder sb = new StringBuilder(bytes.length * 2);
        for (byte b : bytes) {
            String hex = Integer.toHexString(b & 0xff);
            if (hex.length() == 1)
                sb.append('0');
            sb.append(hex);
        }
        return sb.toString();
    }
}
