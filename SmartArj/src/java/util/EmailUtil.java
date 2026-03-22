package util;

import config.EmailConfig;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;
import jakarta.mail.internet.MimeUtility;

import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Utility class for sending HTML emails via SMTP (Gmail).
 *
 * Uses Jakarta Mail for SMTP connections.
 * Configuration is loaded from EmailConfig.
 *
 * Design: static helper — stateless, thread-safe.
 */
public final class EmailUtil {

    private static final Logger log = Logger.getLogger(EmailUtil.class.getName());

    private EmailUtil() {
    }

    /**
     * Sends an HTML email to the given recipient.
     *
     * @param toEmail  recipient email address
     * @param subject  email subject line
     * @param htmlBody full HTML content of the email body
     * @return true if sent successfully, false if an error occurred
     */
    public static boolean sendHtmlEmail(String toEmail, String subject, String htmlBody) {
        if (toEmail == null || toEmail.isBlank()) {
            log.warning("[EmailUtil] Skipped send: recipient email is null or empty.");
            return false;
        }

        if (subject == null || subject.isBlank()) {
            subject = "Thông báo từ SmartAgri";
        }

        if (htmlBody == null || htmlBody.isBlank()) {
            log.warning("[EmailUtil] Skipped send: email body is null or empty.");
            return false;
        }

        Properties props = buildSmtpProperties();

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(
                        EmailConfig.SMTP_USERNAME,
                        EmailConfig.SMTP_PASSWORD
                );
            }
        });

        try {
            MimeMessage message = new MimeMessage(session);

            message.setFrom(new InternetAddress(
                    EmailConfig.SMTP_USERNAME,
                    EmailConfig.SENDER_NAME,
                    "UTF-8"
            ));

            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail, false));

            // Encode subject safely for Vietnamese characters
            message.setSubject(MimeUtility.encodeText(subject, "UTF-8", "B"));

            message.setContent(htmlBody, "text/html; charset=UTF-8");

            Transport.send(message);

            log.info("[EmailUtil] Email sent successfully to: " + toEmail + " | Subject: " + subject);
            return true;

        } catch (Exception e) {
            log.log(Level.SEVERE, "[EmailUtil] Failed to send email to " + toEmail, e);
            // Do not rethrow: email failure must not break payment/order flow
            return false;
        }
    }

    private static Properties buildSmtpProperties() {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", String.valueOf(EmailConfig.SMTP_TLS));
        props.put("mail.smtp.host", EmailConfig.SMTP_HOST);
        props.put("mail.smtp.port", String.valueOf(EmailConfig.SMTP_PORT));
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");
        props.put("mail.smtp.writetimeout", "5000");
        return props;
    }
}