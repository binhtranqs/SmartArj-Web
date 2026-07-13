# SmartArj CV Notes

## One-line CV Description

Built SmartArj, a Java Servlet/JSP smart agriculture web system for managing farm zones, crop thresholds, weather dashboards, AI-assisted forecasts, alerts, authentication, and VNPay sandbox VIP payments.

## Short CV Bullets

- Developed a Java Servlet/JSP smart agriculture platform with authentication, role-based VIP feature access, and MVC-style controller/service/DAO layers.
- Implemented zone and crop management with SQL Server, JPA/Hibernate entities, and user-owned data access.
- Built dashboard APIs and frontend views for weather metrics, quick statistics, alerts, and forecast visualization.
- Integrated Open-Meteo weather history fallback and an external AI prediction service for VIP-only temperature forecasts.
- Implemented VNPay sandbox checkout, payment return validation, transaction tracking, and VIP account upgrade logic.

## Tech Keywords

Java, Servlet, JSP, Jakarta EE, JPA, Hibernate, SQL Server, Tomcat, Ant, NetBeans, Gson, BCrypt, Chart.js, REST-style APIs, VNPay, Open-Meteo, MVC, DAO, Authentication, Payment Integration.

## Interview Talking Points

- Designed the app around clear layers: Servlet controllers, services, DAOs, JPA models, JSP views, and shared utilities.
- Protected application pages and APIs with session-based authentication and ownership checks.
- Used crop thresholds and weather logs to support alert and forecast workflows.
- Handled external integration risks by returning meaningful API errors when the AI service is unavailable.
- Stored payment transactions and updated VIP access only after successful VNPay return validation.

