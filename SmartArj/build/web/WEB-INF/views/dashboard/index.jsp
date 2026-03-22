<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<% User currentUser = (User) session.getAttribute("user"); %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
  <jsp:param name="title" value="Dashboard" />
  <jsp:param name="page"  value="dashboard" />
</jsp:include>

<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/dashboard.css">

<style>
  /* Mở rộng trang dashboard để căn đều 2 lề với navbar */
  .main-content-wrapper {
    max-width: none !important;
    padding: 0 2rem 5rem 2rem !important;
  }
  .page-container {
    max-width: none !important;
    padding: 0 !important;
  }
</style>

<div class="page-container">

  <!-- VIP Upgrade Banner -->
  <% if (currentUser != null && !currentUser.isVIP()) { %>
    <div class="card mb-4"
      style="padding:2rem;background:linear-gradient(135deg,#F59E0B 0%,#EF4444 100%);color:white;">
      <div style="display:flex;justify-content:space-between;align-items:center;gap:2rem;">
        <div>
          <h3 style="margin:0 0 .5rem;font-size:1.5rem;">⭐ Nâng cấp lên VIP để mở khóa tất cả tính năng!</h3>
          <p style="margin:0;opacity:.9;">Chatbot AI, dự báo thời tiết, phân tích nâng cao và nhiều hơn nữa</p>
        </div>
        <a href="${pageContext.request.contextPath}/upgrade" class="btn"
          style="background:white;color:#EF4444;padding:1rem 2rem;font-weight:700;white-space:nowrap;">
          Xem Gói VIP →
        </a>
      </div>
    </div>
  <% } %>

  <!-- Marketplace Banner -->
  <div class="card mb-4" style="padding:1.25rem 1.75rem;
       background:linear-gradient(135deg,#1B5E20 0%,#2E7D32 55%,#43A047 100%);
       color:white;border-radius:16px;border:none;">
    <div style="display:flex;justify-content:space-between;align-items:center;gap:1.5rem;flex-wrap:wrap;">
      <div style="display:flex;align-items:center;gap:14px;">
        <div style="font-size:2.2rem;line-height:1;">🛒</div>
        <div>
          <div style="font-weight:800;font-size:1.15rem;margin-bottom:2px;">Chợ Nông Sản SmartAgri</div>
          <div style="opacity:.85;font-size:.875rem;">Mua bán nông sản · Giá thị trường · Kết nối nông dân – người mua</div>
        </div>
      </div>
      <div style="display:flex;gap:10px;flex-wrap:wrap;">
        <a href="${pageContext.request.contextPath}/marketplace"
          style="background:white;color:#1B5E20;padding:.6rem 1.4rem;border-radius:10px;font-weight:700;text-decoration:none;font-size:.9rem;white-space:nowrap;display:inline-flex;align-items:center;gap:6px;">
          🛍️ Vào Marketplace →
        </a>
        <% if (currentUser != null && currentUser.isVIP()) { %>
          <a href="${pageContext.request.contextPath}/farmer/dashboard"
            style="background:rgba(255,255,255,.18);color:white;padding:.6rem 1.4rem;border-radius:10px;font-weight:700;text-decoration:none;font-size:.9rem;white-space:nowrap;display:inline-flex;align-items:center;gap:6px;border:1.5px solid rgba(255,255,255,.4);">
            👨‍🌾 Farmer Dashboard
          </a>
        <% } %>
      </div>
    </div>
  </div>

  <!-- Page Header -->
  <div class="hero-header"
    style="background-image:url('https://images.unsplash.com/photo-1625244724120-1fd1d34d00f6?q=80&w=2070&auto=format&fit=crop');">
    <div class="hero-content">
      <h1 class="page-title">
        <i data-lucide="radio-tower" width="32" height="32"></i> Virtual Station Dashboard
      </h1>
      <p class="page-subtitle">Theo dõi thời tiết theo thời gian thực · Cập nhật lúc: <strong>${lastUpdated}</strong></p>
    </div>
    <% if (currentUser != null && currentUser.isVIP()) { %>
      <div class="hero-actions"
        style="text-align:right;background:rgba(255,255,255,.1);backdrop-filter:blur(10px);padding:12px 20px;border-radius:12px;border:1px solid rgba(255,255,255,.2);">
        <div style="font-size:.75rem;color:rgba(255,255,255,.8);">⭐ VIP – còn
          <strong style="color:#fbbf24"><%= currentUser.getDaysRemaining() %> ngày</strong></div>
        <div style="font-size:.8rem;color:rgba(255,255,255,.8);">Hết hạn:
          <%= currentUser.getVipExpiryDate() != null ? currentUser.getVipExpiryDate().toString().substring(0,10) : "–" %></div>
      </div>
    </div>
    <% } %>
  </div>
  </div>

  <!-- Quick Stats (partial) -->
  <jsp:include page="/WEB-INF/views/dashboard/quick-stats.jsp" />

  <!-- Filter Row -->
  <div class="wt-filter-row">
    <div class="wt-filter-group">
      <label class="wt-filter-label">🌍 Zone</label>
      <select id="zoneId" class="wt-select"><option>Đang tải...</option></select>
    </div>
    <div class="wt-filter-group">
      <label class="wt-filter-label">📈 Metric</label>
      <select id="metric" class="wt-select">
        <option value="temperature">🌡️ Nhiệt độ (°C)</option>
        <option value="humidity">💧 Độ ẩm (%)</option>
        <option value="rainfall">🌧️ Lượng mưa (mm)</option>
        <option value="wind">💨 Gió (km/h)</option>
        <option value="radiation">☀️ Bức xạ (W/m²)</option>
      </select>
    </div>
    <div class="wt-filter-group wt-filter-group-sm">
      <label class="wt-filter-label">🔢 Điểm dữ liệu</label>
      <input id="limit" type="number" value="30" min="10" max="500" class="wt-input">
    </div>
    <div>
      <label class="wt-filter-label">&nbsp;</label>
      <button id="btnLoad" class="wt-btn-load">
        <i data-lucide="refresh-cw" width="15" height="15"></i> Tải dữ liệu
      </button>
    </div>
  </div>
  <div id="statusText"
    style="font-size:.8rem;font-weight:600;color:var(--danger);margin:-0.75rem 0 1.1rem .25rem;min-height:1rem;"></div>

  <!-- Weather Trend + Stats panel (partial) -->
  <jsp:include page="/WEB-INF/views/dashboard/weather-trend.jsp" />

  <!-- VIP Forecast Section -->
  <% if (currentUser != null && (currentUser.isVIP() || currentUser.isAdmin())) { %>
    <div class="card mb-4" id="forecastSection">
      <div style="display:flex;justify-content:space-between;align-items:center;margin-bottom:1.5rem;">
        <h3 class="card-title">🔮 Dự Báo Thời Tiết (Next 7 Days)</h3>
        <span class="badge badge-success">VIP Feature</span>
      </div>
      <div id="forecastLoading" style="text-align:center;padding:2rem;">Loading forecast data...</div>
      <div id="forecastContainer" style="display:none;">
        <div class="chart-wrapper" style="height:300px;margin-bottom:2rem;">
          <canvas id="forecastChart"></canvas>
        </div>
        <div id="forecastGrid" class="grid"
          style="grid-template-columns:repeat(auto-fit,minmax(120px,1fr));gap:1rem;"></div>
      </div>
    </div>
  <% } %>

</div><!-- /.page-container -->

<!-- Scripts: Chart.js → config → forecast renderer → chart logic -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
<script>const ctxPath = "<%=request.getContextPath()%>";</script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard-chart-config.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard-forecast-renderer.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/dashboard-chart.js"></script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
