# Security Notes

This repository is prepared for portfolio/demo use. Do not commit production credentials, payment secrets, database passwords, or private API keys.

## Local Configuration

SmartArj supports environment variables or JVM system properties for local runtime configuration:

- `SMARTARJ_DB_URL`
- `SMARTARJ_DB_USER`
- `SMARTARJ_DB_PASSWORD`
- `SMARTARJ_VNP_TMN_CODE`
- `SMARTARJ_VNP_HASH_SECRET`
- `SMARTARJ_VNP_PAY_URL`
- `SMARTARJ_VNP_RETURN_URL`

See `.env.example` for sample values.

## Before Public Deployment

- Replace sandbox payment credentials with environment-managed production credentials.
- Disable stacktrace details in user-facing error pages.
- Review database privileges and use a limited SQL Server account instead of `sa`.
- Enforce HTTPS and secure session cookie settings.
- Move AI service URL and external API settings into environment-managed configuration.

