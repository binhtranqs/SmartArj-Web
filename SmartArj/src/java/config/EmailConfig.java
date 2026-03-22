package config;

/**
 * SMTP configuration for sending emails.
 *
 * Credentials are read from System Environment Variables to avoid
 * hardcoding passwords in source code.
 *
 * Environment variables to set:
 *   SMTP_USERNAME  → your Gmail address, e.g. yourapp@gmail.com
 *   SMTP_PASSWORD  → Gmail App Password (not your real password!)
 *                    To generate: Google Account → Security → 2FA → App Passwords
 *
 * If the variables are not set, the service will fall back to empty strings
 * and email sending will silently fail (error is logged).
 */
public final class EmailConfig {

    /** Gmail SMTP host */
    public static final String SMTP_HOST = "smtp.gmail.com";

    /** Gmail SMTP port (TLS) */
    public static final int SMTP_PORT = 587;

    /** Whether to use STARTTLS */
    public static final boolean SMTP_TLS = true;

    /**
     * Sender email address — read from environment variable SMTP_USERNAME.
     * Example: "smartarj.app@gmail.com"
     */
    public static final String SMTP_USERNAME = getEnv("SMTP_USERNAME", "thienhao110105@gmail.com");

    /**
     * Gmail App Password — read from environment variable SMTP_PASSWORD.
     * NEVER commit the real password to source control.
     */
    public static final String SMTP_PASSWORD = getEnv("SMTP_PASSWORD", "ndhm zuhg ojmc ygal");

    /** Display name shown in the email FROM field */
    public static final String SENDER_NAME = "SmartArj Marketplace";

    private EmailConfig() {}

    private static String getEnv(String key, String defaultValue) {
        String val = System.getenv(key);
        return (val != null && !val.isEmpty()) ? val : defaultValue;
    }
}
