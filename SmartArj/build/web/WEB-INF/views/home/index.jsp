<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
    User currentUser = (User) request.getAttribute("currentUser");
    boolean isLoggedIn = (currentUser != null);
    String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartArj — Từ đất mẹ đến mùa vàng</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:ital,wght@0,400;0,500;0,600;0,700;0,800;1,700&display=swap" rel="stylesheet">
    <script src="https://unpkg.com/lucide@latest"></script>
    <link rel="stylesheet" href="<%= ctxPath %>/assets/home-landing.css?v=<%= System.currentTimeMillis() %>">
</head>
<body>

<!-- ===== NAVBAR ===== -->
<nav class="home-nav" id="homeNav">
    <a href="<%= ctxPath %>/home" class="nav-brand">
        <div class="brand-icon">
            <i data-lucide="leaf" width="20" height="20" color="white"></i>
        </div>
        SmartArj
    </a>
    <div class="nav-actions">
        <% if (isLoggedIn) { %>
            <span style="font-size:.85rem;color:rgba(255,255,255,.55);font-weight:500;">
                Xin chào, <strong style="color:#74C69D;"><%= currentUser.getUsername() %></strong>
            </span>
            <a href="<%= ctxPath %>/dashboard" class="nav-btn nav-btn-dashboard">
                <i data-lucide="layout-dashboard" width="16" height="16"></i> Dashboard
            </a>
        <% } else { %>
            <a href="<%= ctxPath %>/login"    class="nav-btn nav-btn-ghost">Đăng nhập</a>
            <a href="<%= ctxPath %>/register" class="nav-btn nav-btn-primary">
                <i data-lucide="user-plus" width="16" height="16"></i> Đăng ký miễn phí
            </a>
        <% } %>
    </div>
</nav>

<!-- ===== HERO ===== -->
<section class="hero">
    <div class="hero-bg" id="heroBg"
         style="background-image:url('<%= ctxPath %>/assets/backgrounds/tay-bac-farm.jpg')"></div>
    <div class="hero-overlay"></div>
    <div class="particles" id="particles"></div>

    <div class="hero-content">
        <div class="hero-badge"><span class="dot"></span> Nền tảng nông nghiệp thông minh</div>

        <h1 class="hero-title">Smart<span class="highlight">Arj</span></h1>

        <p class="hero-slogan">
            <span class="slogan-quote">❝</span>
            Từ <span class="slogan-underline slogan-word">đất mẹ</span>
            đến
            <span class="slogan-underline slogan-word-alt">mùa vàng</span>
            <span class="slogan-quote">❞</span>
        </p>

        <p class="hero-desc">
            Ứng dụng công nghệ AI và IoT để theo dõi thời tiết, dự báo mùa vụ,
            quản lý cây trồng và kết nối nông dân — giúp mỗi mảnh đất đều sinh lợi.
        </p>

        <div class="hero-cta">
            <% if (isLoggedIn) { %>
                <a href="<%= ctxPath %>/dashboard" class="cta-btn cta-primary">
                    <i data-lucide="layout-dashboard" width="20" height="20"></i> Vào Dashboard
                </a>
                <a href="<%= ctxPath %>/zones" class="cta-btn cta-secondary">
                    <i data-lucide="map" width="20" height="20"></i> Quản lý Zone
                </a>
            <% } else { %>
                <a href="<%= ctxPath %>/register" class="cta-btn cta-primary">
                    <i data-lucide="sprout" width="20" height="20"></i> Bắt đầu miễn phí
                </a>
                <a href="<%= ctxPath %>/login" class="cta-btn cta-secondary">
                    <i data-lucide="log-in" width="20" height="20"></i> Đăng nhập
                </a>
            <% } %>
        </div>
    </div>

    <div class="hero-stats">
        <div class="hero-stat"><div class="hero-stat-num">10+</div><div class="hero-stat-label">Thành phố</div></div>
        <div class="hero-stat"><div class="hero-stat-num">7 ngày</div><div class="hero-stat-label">Dự báo AI</div></div>
        <div class="hero-stat"><div class="hero-stat-num">AI</div><div class="hero-stat-label">Phân tích thông minh</div></div>
        <div class="hero-stat"><div class="hero-stat-num">24/7</div><div class="hero-stat-label">Theo dõi liên tục</div></div>
    </div>

    <div class="scroll-hint">
        <i data-lucide="chevrons-down" width="20" height="20"></i>
        <span>Khám phá thêm</span>
    </div>
</section>

<!-- ===== FEATURES ===== -->
<section class="features-section">
    <div class="section-inner">
        <div class="features-header">
            <span class="section-label">Tính năng nổi bật</span>
            <h2 class="section-title">Công nghệ phục vụ nông nghiệp</h2>
            <p class="section-desc" style="margin:0 auto;">
                SmartArj tích hợp AI, dữ liệu thời tiết thực và mạng lưới nông dân
                để mang đến giải pháp canh tác hiệu quả.
            </p>
        </div>
        <div class="features-grid">
            <div class="feature-card">
                <div class="feature-icon" style="background:rgba(64,145,108,.2)">🌦️</div>
                <div class="feature-title">Theo dõi thời tiết thực</div>
                <div class="feature-desc">Nhiệt độ, độ ẩm, lượng mưa, gió và bức xạ theo thời gian thực tại từng khu vực canh tác.</div>
            </div>
            <div class="feature-card">
                <div class="feature-icon" style="background:rgba(233,196,106,.15)">🤖</div>
                <div class="feature-title">Dự báo AI 7 ngày</div>
                <div class="feature-desc">Mô hình học sâu CaReTS dự báo thời tiết 7 ngày tới, giúp lên kế hoạch mùa vụ tốt hơn.</div>
            </div>
            <div class="feature-card">
                <div class="feature-icon" style="background:rgba(116,198,157,.15)">🌱</div>
                <div class="feature-title">Quản lý cây trồng</div>
                <div class="feature-desc">Theo dõi từng loại cây theo vùng, nhận gợi ý phù hợp dựa trên điều kiện khí hậu và đất.</div>
            </div>
            <div class="feature-card">
                <div class="feature-icon" style="background:rgba(244,162,97,.15)">🔔</div>
                <div class="feature-title">Cảnh báo thông minh</div>
                <div class="feature-desc">Nhận thông báo ngay khi nhiệt độ, độ ẩm hoặc lượng mưa vượt ngưỡng an toàn.</div>
            </div>
            <div class="feature-card">
                <div class="feature-icon" style="background:rgba(74,144,164,.15)">🛒</div>
                <div class="feature-title">Marketplace nông sản</div>
                <div class="feature-desc">Kết nối trực tiếp nông dân với người mua, theo dõi giá thị trường và quản lý đơn hàng.</div>
            </div>
            <div class="feature-card">
                <div class="feature-icon" style="background:rgba(45,106,79,.2)">💬</div>
                <div class="feature-title">Tư vấn AI Chatbot</div>
                <div class="feature-desc">Đặt câu hỏi về canh tác, sâu bệnh hay thị trường — AI tư vấn dựa trên dữ liệu thực tế.</div>
            </div>
        </div>
    </div>
</section>

<!-- ===== HOW IT WORKS ===== -->
<section class="steps-section">
    <div class="section-inner">
        <div style="text-align:center;">
            <span class="section-label">Quy trình</span>
            <h2 class="section-title">Bắt đầu chỉ trong 3 bước</h2>
        </div>
        <div class="steps-grid">
            <div class="step-item">
                <div class="step-num">1</div>
                <div class="step-title">Tạo tài khoản</div>
                <div class="step-desc">Đăng ký miễn phí, thiết lập hồ sơ và thêm vùng canh tác của bạn.</div>
            </div>
            <div class="step-item">
                <div class="step-num">2</div>
                <div class="step-title">Kết nối Zone & cây trồng</div>
                <div class="step-desc">Thêm Zone canh tác, chọn loại cây và cấu hình theo địa phương.</div>
            </div>
            <div class="step-item">
                <div class="step-num">3</div>
                <div class="step-title">Nhận dữ liệu & quyết định</div>
                <div class="step-desc">Theo dõi thời tiết, dự báo AI và cảnh báo để canh tác hiệu quả hơn.</div>
            </div>
            <div class="step-item">
                <div class="step-num">🌾</div>
                <div class="step-title">Mùa vàng bội thu</div>
                <div class="step-desc">Ứng dụng dữ liệu thông minh, tối ưu chi phí và tăng năng suất mùa vụ.</div>
            </div>
        </div>
    </div>
</section>

<!-- ===== CTA BANNER ===== -->
<section class="cta-section">
    <div class="cta-banner">
        <h2 class="cta-banner-title">
            <% if (isLoggedIn) { %>
                Chào mừng trở lại, <%= currentUser.getUsername() %>! 👋
            <% } else { %>
                Sẵn sàng cho mùa vàng bội thu?
            <% } %>
        </h2>
        <p class="cta-banner-sub">
            <% if (isLoggedIn) { %>
                Tiếp tục theo dõi dữ liệu và dự báo thời tiết cho mùa vụ của bạn.
            <% } else { %>
                Tham gia cùng hàng nghìn nông dân đang dùng SmartArj để canh tác thông minh hơn.
            <% } %>
        </p>
        <div class="cta-banner-actions">
            <% if (isLoggedIn) { %>
                <a href="<%= ctxPath %>/dashboard" class="cta-banner-btn cta-banner-btn-white">
                    <i data-lucide="layout-dashboard" width="18" height="18"></i> Vào Dashboard
                </a>
                <a href="<%= ctxPath %>/zones" class="cta-banner-btn cta-banner-btn-outline">
                    <i data-lucide="map-pin" width="18" height="18"></i> Xem Zone của tôi
                </a>
            <% } else { %>
                <a href="<%= ctxPath %>/register" class="cta-banner-btn cta-banner-btn-white">
                    <i data-lucide="user-plus" width="18" height="18"></i> Đăng ký miễn phí ngay
                </a>
                <a href="<%= ctxPath %>/login" class="cta-banner-btn cta-banner-btn-outline">
                    Đã có tài khoản? Đăng nhập
                </a>
            <% } %>
        </div>
    </div>
</section>

<!-- ===== FOOTER ===== -->
<footer class="home-footer">
    <div class="footer-brand">🌿 SmartArj</div>
    <div class="footer-slogan">❝ Từ đất mẹ đến mùa vàng ❞</div>
    <div class="footer-links">
        <a href="<%= ctxPath %>/home">Trang chủ</a>
        <a href="<%= ctxPath %>/dashboard">Dashboard</a>
        <a href="<%= ctxPath %>/marketplace">Marketplace</a>
        <a href="<%= ctxPath %>/login">Đăng nhập</a>
        <a href="<%= ctxPath %>/register">Đăng ký</a>
    </div>
    <div class="footer-copy">© 2025 SmartArj. Nền tảng nông nghiệp thông minh Việt Nam.</div>
</footer>

<script src="<%= ctxPath %>/assets/js/home-landing.js"></script>
</body>
</html>
