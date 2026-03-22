<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="java.util.Arrays" %>
        <%@ page import="java.util.List" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Dashboard - SmartArj</title>
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/assets/app.css?v=<%= System.currentTimeMillis() %>">
            </head>

            <body
                style="margin: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background: #F3F4F6;">

                <% // Mock Data - Dữ liệu giả để test giao diện // Sau này sẽ được thay thế bằng dữ liệu thật từ Backend
                    List<Integer> historyData = Arrays.asList(25, 26, 27, 28, 29, 30, 31);
                    List<Integer> forecastData = Arrays.asList(31, 32, 33, 34, 35, 36, 37);

                        // Chuyển đổi sang JSON để JavaScript có thể sử dụng
                        String historyDataJson = historyData.toString();
                        String forecastDataJson = forecastData.toString();
                        %>

                        <!-- Navbar -->
                        <nav class="navbar">
                            <div
                                style="display: flex; justify-content: space-between; align-items: center; max-width: 1400px; margin: 0 auto; width: 100%;">
                                <a href="#" class="navbar-brand">📊 SmartArj</a>

                                <ul class="navbar-nav">
                                    <li><a href="#" class="nav-link">Dashboard</a></li>
                                    <li><a href="#" class="nav-link">Dữ liệu</a></li>
                                    <li><a href="#" class="nav-link">Báo cáo</a></li>

                                    <!-- Notification Bell -->
                                    <li class="notification-wrapper">
                                        <button id="notificationBell" class="notification-bell">
                                            🔔
                                            <span class="notification-badge">3</span>
                                        </button>

                                        <!-- Notification Dropdown -->
                                        <div id="notificationDropdown" class="notification-dropdown">
                                            <div class="notification-header">Thông báo</div>
                                            <div class="notification-item">
                                                <div class="notification-title">Cảnh báo nhiệt độ cao</div>
                                                <div class="notification-text">Nhiệt độ vượt ngưỡng 35°C</div>
                                                <div class="notification-time">5 phút trước</div>
                                            </div>
                                            <div class="notification-item">
                                                <div class="notification-title">Dự báo thời tiết</div>
                                                <div class="notification-text">Có mưa trong 2 giờ tới</div>
                                                <div class="notification-time">15 phút trước</div>
                                            </div>
                                            <div class="notification-item">
                                                <div class="notification-title">Cập nhật dữ liệu</div>
                                                <div class="notification-text">Dữ liệu mới đã được đồng bộ</div>
                                                <div class="notification-time">1 giờ trước</div>
                                            </div>
                                        </div>
                                    </li>
                                </ul>
                            </div>
                        </nav>

                        <!-- Main Content -->
                        <div style="max-width: 1400px; margin: 0 auto; padding: 0 2rem;">

                            <!-- Page Header -->
                            <div style="margin: 2rem 0;">
                                <h1 style="color: #1F2937; font-size: 2rem; margin: 0 0 0.5rem 0;">Dashboard</h1>
                                <p style="color: #6B7280; margin: 0;">Theo dõi dữ liệu và dự báo thời gian thực</p>
                            </div>

                            <!-- Chart Container -->
                            <div class="chart-container">
                                <div class="chart-wrapper">
                                    <canvas id="lineChart"></canvas>
                                </div>
                            </div>

                            <!-- Stats Cards -->
                            <div
                                style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 1.5rem; margin: 2rem 0;">
                                <div class="card-soft" style="padding: 1.5rem;">
                                    <div style="color: #6B7280; font-size: 0.875rem; margin-bottom: 0.5rem;">Nhiệt độ
                                        trung bình</div>
                                    <div style="color: #1F2937; font-size: 2rem; font-weight: 700;">28.5°C</div>
                                    <div style="color: #10B981; font-size: 0.875rem; margin-top: 0.5rem;">↑ 2.3% so với
                                        hôm qua</div>
                                </div>

                                <div class="card-soft" style="padding: 1.5rem;">
                                    <div style="color: #6B7280; font-size: 0.875rem; margin-bottom: 0.5rem;">Độ ẩm</div>
                                    <div style="color: #1F2937; font-size: 2rem; font-weight: 700;">65%</div>
                                    <div style="color: #EF4444; font-size: 0.875rem; margin-top: 0.5rem;">↓ 1.2% so với
                                        hôm qua</div>
                                </div>

                                <div class="card-soft" style="padding: 1.5rem;">
                                    <div style="color: #6B7280; font-size: 0.875rem; margin-bottom: 0.5rem;">Tốc độ gió
                                    </div>
                                    <div style="color: #1F2937; font-size: 2rem; font-weight: 700;">12 km/h</div>
                                    <div style="color: #10B981; font-size: 0.875rem; margin-top: 0.5rem;">↑ 0.8% so với
                                        hôm qua</div>
                                </div>

                                <div class="card-soft" style="padding: 1.5rem;">
                                    <div style="color: #6B7280; font-size: 0.875rem; margin-bottom: 0.5rem;">Chỉ số UV
                                    </div>
                                    <div style="color: #1F2937; font-size: 2rem; font-weight: 700;">7</div>
                                    <div style="color: #F59E0B; font-size: 0.875rem; margin-top: 0.5rem;">Cao - Cần bảo
                                        vệ</div>
                                </div>
                            </div>

                        </div>

                        <!-- Chatbot Toggle Button -->
                        <button id="chatToggle" class="chat-toggle">💬</button>

                        <!-- Chatbot Window -->
                        <div id="chatWindow" class="chat-window">
                            <div class="chat-header">
                                <div class="chat-title">Trợ lý SmartArj</div>
                                <button id="chatClose" class="chat-close">×</button>
                            </div>
                            <div id="chatMessages" class="chat-messages">
                                <div class="chat-message bot">
                                    Xin chào! Tôi là trợ lý ảo của SmartArj. Tôi có thể giúp gì cho bạn?
                                </div>
                            </div>
                            <div class="chat-input-wrapper">
                                <input type="text" id="chatInput" class="chat-input" placeholder="Nhập tin nhắn...">
                                <button id="chatSend" class="chat-send">➤</button>
                            </div>
                        </div>

                        <!-- Scripts -->
                        <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
                        <script>
                            // Inject dữ liệu từ JSP vào JavaScript
                            window.historyData = <%= historyDataJson %>;
                            window.forecastData = <%= forecastDataJson %>;
                        </script>
                        <script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>

            </body>

            </html>