package config;

public final class VNPayConfig {
    private VNPayConfig() {
    }

    public static final String VNP_TMN_CODE = "MD544N4C";
    public static final String VNP_HASH_SECRET = "68DTUMGFRFXTOAEX5M97IOL46TLYGZ5J";
    public static final String VNP_PAY_URL = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    public static final String VNP_RETURN_URL = "http://localhost:8080/payment/vnpay/return";

}
