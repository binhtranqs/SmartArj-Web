package config;

public final class VNPayConfig {
    private VNPayConfig() {
    }

    public static final String VNP_TMN_CODE = getConfig("SMARTARJ_VNP_TMN_CODE", "YOUR_VNPAY_TMN_CODE");
    public static final String VNP_HASH_SECRET = getConfig("SMARTARJ_VNP_HASH_SECRET", "YOUR_VNPAY_HASH_SECRET");
    public static final String VNP_PAY_URL = getConfig("SMARTARJ_VNP_PAY_URL", "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html");
    public static final String VNP_RETURN_URL = getConfig("SMARTARJ_VNP_RETURN_URL", "http://localhost:8080/SmartArj/payment/vnpay/return");

    private static String getConfig(String key, String fallback) {
        String value = System.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        return value == null || value.trim().isEmpty() ? fallback : value;
    }
}
