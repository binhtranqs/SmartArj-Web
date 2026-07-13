# SmartArj - Smart Agriculture Web System

SmartArj is a Java web application for managing agricultural zones, monitoring weather data, and supporting crop decisions with forecast-based alerts. The project is built as a Servlet/JSP application and includes authentication, dashboard visualizations, zone/crop management, VIP feature gating, and VNPay sandbox payment integration.

## Highlights

- User authentication with register, login, logout, and session-based access control.
- Zone management for farm areas with city, latitude, longitude, and owner information.
- Crop management with temperature and humidity thresholds per zone.
- Weather dashboard with chart-based metrics for temperature, humidity, rainfall, wind, and radiation.
- Weather APIs for current data, historical logs, alert checks, and zone dashboard data.
- VIP-only 7-day temperature forecasting through an external AI service.
- Forecast persistence into SQL Server using JPA/Hibernate.
- VNPay sandbox checkout flow for VIP upgrade packages.

## Tech Stack

- Java Servlet/JSP
- Jakarta Servlet API
- JPA/Hibernate
- Microsoft SQL Server
- Apache Tomcat
- Apache Ant / NetBeans project structure
- Gson
- BCrypt
- Chart.js on the frontend
- Open-Meteo API for weather history fallback
- VNPay sandbox payment gateway

## Project Structure

```text
SmartArj-Web/
├── src/java/
│   ├── config/          # Payment configuration
│   ├── controller/      # Servlet controllers and API endpoints
│   ├── dao/             # Database access layer
│   ├── dto/             # View/API data transfer objects
│   ├── exception/       # Application exceptions
│   ├── filter/          # Authentication filter
│   ├── model/           # JPA entities
│   ├── scheduler/       # Alert scheduler
│   ├── service/         # Business logic
│   └── util/            # Shared helpers
├── web/
│   ├── WEB-INF/views/   # JSP pages
│   ├── assets/          # CSS and JavaScript
│   └── index.html       # Entry redirect
├── nbproject/           # NetBeans/Ant project files
├── FORECASTS_TABLE.sql  # Forecast table migration
└── build.xml            # Ant build file
```

## Main Features

### Authentication and Authorization

Users can create accounts, log in, and access protected pages through `AuthFilter`. Password handling uses BCrypt, and VIP status is checked from the user's account type and expiry date.

### Agricultural Zone Management

The application lets users create, update, and delete growing zones. Each zone stores city ID, owner ID, coordinates, name, and description.

### Crop Threshold Management

Users can attach crop information to zones and define acceptable temperature and humidity ranges. These thresholds are used by forecast and alert logic.

### Weather Dashboard

The dashboard displays selectable weather metrics, quick statistics, and chart data for each zone. API endpoints provide zone lists, current weather, historical weather logs, and alerts.

### Forecasting

VIP users can request a 7-day temperature forecast. The Java web app gathers historical weather data from SQL Server, fills missing history from Open-Meteo archive data when needed, sends the payload to an AI service at `http://localhost:8000/predict`, and stores returned forecasts in SQL Server.

### Payment

The VIP upgrade flow creates a transaction, redirects users to VNPay sandbox, validates the return signature, and updates the user's VIP status after successful payment.

## Requirements

- JDK 8 or later
- Apache Tomcat with Jakarta-compatible dependencies
- Apache Ant or NetBeans
- Microsoft SQL Server
- Required JAR dependencies configured in `nbproject/project.properties`
- Optional AI forecast service running at `localhost:8000`

## Database Setup

1. Create a SQL Server database named `SmartAgri_PRJ301`.
2. Create the required base tables: `Users`, `Zones`, `Crops`, `WeatherLogs`, and `Transactions`.
3. Run `FORECASTS_TABLE.sql` to add the `Forecasts` table.
4. Set your SQL Server connection through environment variables, JVM system properties, or local-only configuration.

## Configuration Notes

Before running the app outside a local demo environment, review these files:

- `src/java/META-INF/persistence.xml` for default SQL Server connection settings.
- `src/java/config/VNPayConfig.java` for VNPay sandbox configuration keys.
- `src/java/controller/ForecastServlet.java` for the AI service URL.
- `nbproject/project.properties` for local JAR dependency paths.
- `.env.example` for local environment variable examples.

For a public portfolio repository, keep real credentials outside the repository. The application can read database and VNPay values from environment variables or JVM system properties:

```text
SMARTARJ_DB_URL
SMARTARJ_DB_USER
SMARTARJ_DB_PASSWORD
SMARTARJ_VNP_TMN_CODE
SMARTARJ_VNP_HASH_SECRET
SMARTARJ_VNP_PAY_URL
SMARTARJ_VNP_RETURN_URL
```

## Running Locally

1. Open the project in NetBeans.
2. Make sure Tomcat is configured in NetBeans.
3. Add the required JAR dependencies or update paths in `nbproject/project.properties`.
4. Set SQL Server and VNPay configuration through environment variables, JVM system properties, or local config files.
5. Run the web project on Tomcat.
6. Open the application at:

```text
http://localhost:8080/SmartArj/
```

If you want to test forecasting, start the AI service separately on:

```text
http://localhost:8000/predict
```

## Key Routes

| Route | Purpose |
| --- | --- |
| `/login` | User login |
| `/register` | User registration |
| `/dashboard` | Weather dashboard |
| `/zones` | Zone CRUD |
| `/crops` | Crop CRUD |
| `/upgrade` | VIP package page |
| `/vip/checkout` | VNPay checkout |
| `/api/zones` | Zone API |
| `/api/weather` | Historical weather API |
| `/api/current-weather` | Current weather API |
| `/api/forecast` | VIP forecast API |
| `/api/alerts` | Alert API |

## What This Project Demonstrates

- Full-stack Java web development with Servlet/JSP and MVC-style layering.
- Authentication, authorization, and user-specific resource ownership.
- JPA/Hibernate entity mapping and DAO-based data access.
- Integration with third-party APIs and external services.
- Payment flow implementation with transaction tracking.
- Dashboard-oriented UI and JSON API design.
- Practical agriculture-domain modeling with zones, crops, weather logs, and forecasts.

## Portfolio Summary

SmartArj is a smart agriculture management system that helps users monitor growing zones, analyze weather metrics, manage crop thresholds, receive alerts, and access AI-powered forecasts through a VIP subscription flow.
