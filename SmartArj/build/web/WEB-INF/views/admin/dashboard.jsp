<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="java.util.List, java.util.Map, model.AdminAuditLog" %>
        <%@ include file="layout_header.jsp" %>

            <style>
                /* ── KPI GRID ─────────────────────────────── */
                .kpi-grid {
                    display: grid;
                    grid-template-columns: repeat(4, 1fr);
                    gap: var(--sp-24);
                    margin-bottom: var(--sp-32);
                }

                .kpi-card {
                    padding: var(--sp-24);
                    background: rgba(15, 23, 42, 0.4);
                    /* Darker glass */
                    border: 1px solid rgba(255, 255, 255, 0.05);
                    /* very subtle border */
                    border-radius: var(--r-xl);
                    position: relative;
                    overflow: hidden;
                    cursor: default;
                    transition: var(--transition-base);
                    box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
                }

                .kpi-card:hover {
                    background: rgba(15, 23, 42, 0.7);
                    transform: translateY(-4px);
                    box-shadow: var(--shadow-lg);
                    border-color: rgba(255, 255, 255, 0.1);
                }

                .kpi-icon {
                    width: 48px;
                    height: 48px;
                    border-radius: var(--r-lg);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    margin-bottom: var(--sp-16);
                }

                .kpi-label {
                    font-size: 0.875rem;
                    font-weight: 500;
                    color: rgba(255, 255, 255, 0.6);
                    margin-bottom: var(--sp-8);
                }

                .kpi-val {
                    font-size: 2.25rem;
                    font-weight: 700;
                    color: #fff;
                    line-height: 1.1;
                    letter-spacing: -0.02em;
                    font-variant-numeric: tabular-nums;
                }

                .kpi-sub {
                    font-size: 0.8125rem;
                    margin-top: var(--sp-16);
                    display: flex;
                    align-items: center;
                    gap: var(--sp-4);
                    font-weight: 500;
                    padding-top: var(--sp-12);
                    border-top: 1px solid rgba(255, 255, 255, 0.05);
                }

                .trend-up {
                    color: var(--green);
                }

                .trend-down {
                    color: var(--red);
                }

                .trend-neutral {
                    color: var(--amber);
                }

                /* ── MAIN DASHBOARD LAYOUT ─────────────────── */
                .dashboard-grid {
                    display: grid;
                    grid-template-columns: 2fr 1fr;
                    gap: var(--sp-24);
                    margin-bottom: var(--sp-32);
                }

                .panel-box {
                    background: rgba(15, 23, 42, 0.4);
                    border: 1px solid rgba(255, 255, 255, 0.05);
                    border-radius: var(--r-xl);
                    padding: var(--sp-24);
                    box-shadow: var(--shadow-md);
                }

                .panel-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: center;
                    margin-bottom: var(--sp-24);
                }

                .panel-title {
                    font-size: 1.125rem;
                    font-weight: 600;
                    color: #fff;
                    display: flex;
                    align-items: center;
                    gap: var(--sp-8);
                }

                /* ── IOS WEATHER WIDGET ─────────────────── */
                .wx-forecast-card {
                    height: 100%;
                    display: flex;
                    flex-direction: column;
                    gap: 0;
                }

                .wx-city-selector {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    margin-bottom: var(--sp-16);
                }

                .wx-city-selector select {
                    background: #1e293b;
                    border: 1px solid rgba(255, 255, 255, 0.12);
                    color: #e2e8f0;
                    border-radius: 8px;
                    padding: 6px 12px;
                    font-size: 0.875rem;
                    cursor: pointer;
                    flex: 1;
                    max-height: 36px;
                    overflow: hidden;
                }

                .wx-city-selector select option {
                    background: #1e293b;
                    color: #e2e8f0;
                    padding: 6px 10px;
                }

                .wx-city-selector select:focus {
                    outline: none;
                    border-color: rgba(56, 189, 248, 0.5);
                    box-shadow: 0 0 0 2px rgba(56, 189, 248, 0.1);
                }

                .wx-hero {
                    display: flex;
                    align-items: center;
                    gap: var(--sp-16);
                    padding: var(--sp-16);
                    background: linear-gradient(135deg, rgba(56, 189, 248, 0.12) 0%, rgba(99, 102, 241, 0.10) 100%);
                    border: 1px solid rgba(56, 189, 248, 0.18);
                    border-radius: var(--r-xl);
                    margin-bottom: var(--sp-16);
                }

                .wx-hero-icon {
                    font-size: 3.5rem;
                    line-height: 1;
                }

                .wx-hero-temp {
                    font-size: 3rem;
                    font-weight: 700;
                    color: #fff;
                    letter-spacing: -0.04em;
                    line-height: 1;
                }

                .wx-hero-label {
                    font-size: 0.75rem;
                    color: rgba(255, 255, 255, 0.5);
                    margin-top: 4px;
                }

                .wx-stats-row {
                    display: flex;
                    gap: var(--sp-8);
                    margin-bottom: var(--sp-16);
                }

                .wx-stat-pill {
                    flex: 1;
                    background: rgba(255, 255, 255, 0.04);
                    border: 1px solid rgba(255, 255, 255, 0.07);
                    border-radius: var(--r-lg);
                    padding: 10px 8px;
                    text-align: center;
                }

                .wx-stat-pill .lbl {
                    font-size: 0.65rem;
                    color: rgba(255, 255, 255, 0.45);
                    margin-bottom: 4px;
                    text-transform: uppercase;
                    letter-spacing: .04em;
                }

                .wx-stat-pill .val {
                    font-size: 0.9rem;
                    font-weight: 600;
                    color: #e2e8f0;
                }

                .wx-forecast-title {
                    font-size: 0.7rem;
                    text-transform: uppercase;
                    letter-spacing: .08em;
                    color: rgba(255, 255, 255, 0.4);
                    margin-bottom: var(--sp-8);
                    font-weight: 600;
                }

                .wx-forecast-rows {
                    flex: 1;
                    display: flex;
                    flex-direction: column;
                    gap: 4px;
                }

                .wx-row {
                    display: flex;
                    align-items: center;
                    padding: 8px 12px;
                    border-radius: var(--r-md);
                    background: rgba(255, 255, 255, 0.025);
                    transition: background 0.2s;
                }

                .wx-row:hover {
                    background: rgba(255, 255, 255, 0.055);
                }

                .wx-row-day {
                    font-size: 0.8rem;
                    color: rgba(255, 255, 255, 0.65);
                    width: 50px;
                }

                .wx-row-icon {
                    font-size: 1.1rem;
                    flex: 1;
                    text-align: center;
                }

                .wx-row-temp {
                    font-size: 0.85rem;
                    font-weight: 600;
                    color: #e2e8f0;
                    min-width: 54px;
                    text-align: right;
                }

                .wx-skeleton {
                    animation: wxPulse 1.4s ease-in-out infinite;
                }

                @keyframes wxPulse {

                    0%,
                    100% {
                        opacity: .35
                    }

                    50% {
                        opacity: .7
                    }
                }

                /* ── WEATHER OVERLAY GRID ─────────────────── */
                .city-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                    gap: var(--sp-16);
                }

                .city-tile {
                    border-radius: var(--r-lg);
                    overflow: hidden;
                    position: relative;
                    aspect-ratio: 16/9;
                    cursor: pointer;
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    transition: var(--transition-base);
                    box-shadow: var(--shadow-sm);
                }

                .city-tile:hover {
                    transform: scale(1.02);
                    box-shadow: var(--shadow-lg);
                    border-color: rgba(56, 189, 248, 0.4);
                }

                .city-img {
                    width: 100%;
                    height: 100%;
                    object-fit: cover;
                    position: absolute;
                    inset: 0;
                    z-index: 0;
                }

                .city-overlay {
                    position: absolute;
                    inset: 0;
                    background: linear-gradient(to top, rgba(15, 23, 42, 0.95) 0%, rgba(15, 23, 42, 0.4) 50%, rgba(15, 23, 42, 0.1) 100%);
                    z-index: 1;
                    padding: var(--sp-16);
                    display: flex;
                    flex-direction: column;
                    justify-content: flex-end;
                }

                .city-tbadge {
                    position: absolute;
                    top: var(--sp-12);
                    right: var(--sp-12);
                    background: rgba(15, 23, 42, 0.8);
                    backdrop-filter: blur(8px);
                    border: 1px solid rgba(255, 255, 255, 0.1);
                    color: #fff;
                    font-size: 0.875rem;
                    font-weight: 600;
                    padding: var(--sp-4) var(--sp-12);
                    border-radius: 99px;
                    z-index: 2;
                }

                .city-info {
                    position: relative;
                    z-index: 2;
                }

                .city-name {
                    font-size: 1.125rem;
                    font-weight: 600;
                    color: #fff;
                    margin-bottom: 2px;
                }

                .city-desc {
                    font-size: 0.75rem;
                    color: rgba(255, 255, 255, 0.6);
                    display: flex;
                    align-items: center;
                    gap: var(--sp-4);
                }

                /* ── AI INSIGHTS PANEL ────────────────────── */
                .insight-card {
                    display: flex;
                    align-items: flex-start;
                    gap: var(--sp-12);
                    padding: var(--sp-16);
                    background: rgba(255, 255, 255, 0.02);
                    border: 1px solid rgba(255, 255, 255, 0.05);
                    border-radius: var(--r-lg);
                    margin-bottom: var(--sp-12);
                    transition: var(--transition-base);
                }

                .insight-card:hover {
                    background: rgba(255, 255, 255, 0.04);
                    transform: translateX(4px);
                }

                .insight-icon {
                    flex-shrink: 0;
                    width: 36px;
                    height: 36px;
                    border-radius: 50%;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }

                .insight-content h4 {
                    font-size: 0.875rem;
                    font-weight: 600;
                    color: #fff;
                    margin-bottom: 2px;
                }

                .insight-content p {
                    font-size: 0.75rem;
                    color: rgba(255, 255, 255, 0.6);
                    line-height: 1.4;
                }

                /* ── ACTIVITY TIMELINE ────────────────────── */
                .timeline {
                    position: relative;
                    padding-left: var(--sp-24);
                }

                .timeline::before {
                    content: '';
                    position: absolute;
                    left: 7px;
                    top: 0;
                    bottom: 0;
                    width: 2px;
                    background: rgba(255, 255, 255, 0.05);
                }

                .timeline-item {
                    position: relative;
                    padding-bottom: var(--sp-24);
                }

                .timeline-item:last-child {
                    padding-bottom: 0;
                }

                .timeline-dot {
                    position: absolute;
                    left: -24px;
                    top: 2px;
                    width: 16px;
                    height: 16px;
                    border-radius: 50%;
                    background: var(--bg-surface);
                    border: 2px solid var(--blue);
                    box-shadow: 0 0 0 4px var(--bg-base);
                }

                .timeline-content {
                    background: rgba(255, 255, 255, 0.02);
                    border: 1px solid rgba(255, 255, 255, 0.05);
                    border-radius: var(--r-lg);
                    padding: var(--sp-12) var(--sp-16);
                    transition: var(--transition-base);
                }

                .timeline-content:hover {
                    background: rgba(255, 255, 255, 0.04);
                }

                .timeline-header {
                    display: flex;
                    justify-content: space-between;
                    align-items: flex-start;
                    margin-bottom: var(--sp-4);
                }

                .timeline-title {
                    font-size: 0.875rem;
                    font-weight: 600;
                    color: #e2e8f0;
                }

                .timeline-time {
                    font-size: 0.75rem;
                    color: rgba(255, 255, 255, 0.4);
                }

                .timeline-desc {
                    font-size: 0.8125rem;
                    color: rgba(255, 255, 255, 0.6);
                }

                @media(max-width:1024px) {
                    .kpi-grid {
                        grid-template-columns: repeat(2, 1fr);
                    }

                    .dashboard-grid {
                        grid-template-columns: 1fr;
                    }
                }

                @media(max-width:640px) {
                    .kpi-grid {
                        grid-template-columns: 1fr;
                    }
                }
            </style>

            <!-- Page header -->
            <div class="page-header" data-aos="fade-up" data-aos-duration="500">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;flex-wrap:wrap;gap:12px;">
                    <div>
                        <h1>Admin Dashboard</h1>
                        <p>Tổng quan hệ thống &middot; <%= new java.text.SimpleDateFormat("EEEE, dd/MM/yyyy", new
                                java.util.Locale("vi","VN")).format(new java.util.Date()) %>
                        </p>
                    </div>
                    <div style="display:flex;gap:8px;flex-wrap:wrap;">
                        <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-ghost">
                            <i data-lucide="users" width="13" height="13"></i>Người dùng
                        </a>
                        <a href="<%= request.getContextPath() %>/admin/vip" class="btn btn-ghost"
                            style="color:#fbbf24;border-color:rgba(251,191,36,.18);background:rgba(251,191,36,.06);">
                            <i data-lucide="star" width="13" height="13"></i>Hàng chờ VIP
                        </a>
                    </div>
                </div>
            </div>

            <!-- ── KPI Cards ─────────────────────────── -->
            <div class="kpi-grid">

                <div class="kpi-card" data-aos="fade-up" data-aos-delay="0" data-aos-duration="520">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                        <div>
                            <div class="kpi-label">TỔNG SỐ NGƯỜI DÙNG</div>
                            <div class="kpi-val tabnum" id="cnt-users" data-target="${totalUsers}">0</div>
                        </div>
                        <div class="kpi-icon"
                            style="background: rgba(56, 189, 248, 0.1); border: 1px solid rgba(56, 189, 248, 0.2);">
                            <i data-lucide="users" width="22" height="22" style="color:var(--blue);"></i>
                        </div>
                    </div>
                    <div class="kpi-sub">
                        <span class="trend-up" style="display:flex; align-items:center; gap:4px; font-weight:600;">
                            <i data-lucide="trending-up" width="14" height="14"></i> +12 hôm nay
                        </span>
                        <span style="color:rgba(255,255,255,0.4); margin-left:auto;">${activeUsers} hoạt động</span>
                    </div>
                </div>

                <div class="kpi-card" data-aos="fade-up" data-aos-delay="55" data-aos-duration="520">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                        <div>
                            <div class="kpi-label">TÀI KHOẢN VIP</div>
                            <div class="kpi-val tabnum" id="cnt-vip" data-target="${vipUsers}">0</div>
                        </div>
                        <div class="kpi-icon"
                            style="background: rgba(245, 158, 11, 0.1); border: 1px solid rgba(245, 158, 11, 0.2);">
                            <i data-lucide="star" width="22" height="22" style="color:#f59e0b;"></i>
                        </div>
                    </div>
                    <div class="kpi-sub">
                        <span class="trend-up" style="display:flex; align-items:center; gap:4px; font-weight:600;">
                            <i data-lucide="trending-up" width="14" height="14"></i> +3 tuần này
                        </span>
                        <span style="color:rgba(255,255,255,0.4); margin-left:auto;">Gói cao cấp</span>
                    </div>
                </div>

                <div class="kpi-card" data-aos="fade-up" data-aos-delay="110" data-aos-duration="520">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                        <div>
                            <div class="kpi-label">YÊU CẦU VIP CHỜ DUYỆT</div>
                            <div class="kpi-val tabnum" id="cnt-pending" data-target="${pendingVip}">0</div>
                        </div>
                        <div class="kpi-icon"
                            style="background: rgba(245, 158, 11, 0.1); border: 1px solid rgba(245, 158, 11, 0.2);">
                            <i data-lucide="clock" width="22" height="22" style="color:#f59e0b;"></i>
                        </div>
                    </div>
                    <div class="kpi-sub">
                        <span class="trend-neutral" style="display:flex; align-items:center; gap:4px; font-weight:600;">
                            <i data-lucide="minus" width="14" height="14"></i> Không đổi
                        </span>
                        <span style="color:rgba(255,255,255,0.4); margin-left:auto;">Cần xử lý</span>
                    </div>
                </div>

                <div class="kpi-card" data-aos="fade-up" data-aos-delay="165" data-aos-duration="520">
                    <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                        <div>
                            <div class="kpi-label">TÀI KHOẢN KHÓA</div>
                            <div class="kpi-val tabnum" id="cnt-locked" data-target="${totalUsers - activeUsers}">0
                            </div>
                        </div>
                        <div class="kpi-icon"
                            style="background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.2);">
                            <i data-lucide="lock" width="22" height="22" style="color:var(--red);"></i>
                        </div>
                    </div>
                    <div class="kpi-sub">
                        <span class="trend-down" style="display:flex; align-items:center; gap:4px; font-weight:600;">
                            <i data-lucide="trending-down" width="14" height="14"></i> -1 hôm nay
                        </span>
                        <span style="color:rgba(255,255,255,0.4); margin-left:auto;">Hệ thống an toàn</span>
                    </div>
                </div>
            </div>

            <!-- ── Analytics & Insights ────────────────────── -->
            <div class="dashboard-grid" data-aos="fade-up" data-aos-delay="80" data-aos-duration="540">
                <!-- Weather Forecast Widget (iOS-style) -->
                <div class="panel-box" style="display:flex;flex-direction:column;">
                    <div class="panel-header" style="margin-bottom:var(--sp-16);">
                        <div class="panel-title">
                            <i data-lucide="cloud-sun" width="20" height="20" style="color:#38bdf8;"></i>
                            Dự Báo Thời Tiết
                        </div>
                        <span id="wxLastUpd" style="font-size:0.7rem;color:rgba(255,255,255,0.35);">--</span>
                    </div>
                    <div class="wx-forecast-card">
                        <!-- City selector -->
                        <div class="wx-city-selector">
                            <i data-lucide="map-pin" width="14" height="14" style="color:#38bdf8;flex-shrink:0;"></i>
                            <select id="wxZoneSelect" onchange="loadAdminWeather()">
                                <option value="">Đang tải...</option>
                            </select>
                        </div>
                        <!-- Current conditions hero -->
                        <div class="wx-hero">
                            <div id="wxHeroIcon" class="wx-hero-icon wx-skeleton">🌤️</div>
                            <div style="flex:1;">
                                <div id="wxHeroTemp" class="wx-hero-temp wx-skeleton">--°C</div>
                                <div id="wxHeroCondition"
                                    style="font-size:0.8rem;color:rgba(255,255,255,0.6);margin-top:2px;">--</div>
                                <div id="wxCityLabel" class="wx-hero-label">Chọn khu vực</div>
                            </div>
                        </div>
                        <!-- Stats pills -->
                        <div class="wx-stats-row">
                            <div class="wx-stat-pill">
                                <div class="lbl">💧 Độ ẩm</div>
                                <div class="val" id="wxPillHumid">--%</div>
                            </div>
                            <div class="wx-stat-pill">
                                <div class="lbl">🌧️ Mưa</div>
                                <div class="val" id="wxPillRain">-- mm</div>
                            </div>
                            <div class="wx-stat-pill">
                                <div class="lbl">💨 Gió</div>
                                <div class="val" id="wxPillWind">-- km/h</div>
                            </div>
                        </div>
                        <!-- 7-day forecast rows -->
                        <div class="wx-forecast-title">📅 Dự báo 7 ngày</div>
                        <div class="wx-forecast-rows" id="wxForecastRows">
                            <!-- filled by JS -->
                            <div style="text-align:center;padding:20px;color:rgba(255,255,255,0.3);font-size:0.8rem;"
                                class="wx-skeleton">Đang tải dữ liệu...</div>
                        </div>
                    </div>
                </div>

                <!-- AI Insights Panel -->
                <div class="panel-box">
                    <div class="panel-header">
                        <div class="panel-title">
                            <i data-lucide="sparkles" width="20" height="20" style="color:var(--purple);"></i>
                            Phân tích AI
                        </div>
                    </div>
                    <div>
                        <!-- Static Mock Data for AI Insights as requested -->
                        <div class="insight-card">
                            <div class="insight-icon" style="background:rgba(239, 68, 68, 0.1); color:var(--red);">
                                <i data-lucide="thermometer-sun" width="16" height="16"></i>
                            </div>
                            <div class="insight-content">
                                <h4>Cảnh báo nhiệt độ cao tại HCM</h4>
                                <p>Nhiệt độ đo được vượt ngưỡng 35°C. Đề nghị giám sát tưới tiêu.</p>
                            </div>
                        </div>

                        <div class="insight-card">
                            <div class="insight-icon" style="background:rgba(245, 158, 11, 0.1); color:var(--amber);">
                                <i data-lucide="droplets" width="16" height="16"></i>
                            </div>
                            <div class="insight-content">
                                <h4>Cảnh báo độ ẩm thấp</h4>
                                <p>Độ ẩm đất hiện tại ở Zone B đang ở mức thấp (32%).</p>
                            </div>
                        </div>

                        <div class="insight-card">
                            <div class="insight-icon" style="background:rgba(56, 189, 248, 0.1); color:var(--blue);">
                                <i data-lucide="leaf" width="16" height="16"></i>
                            </div>
                            <div class="insight-content">
                                <h4>Điều kiện trồng cây tối ưu</h4>
                                <p>Chỉ số thời tiết và đất đai tại Zone C rất lý tưởng.</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- ── Weather ─────────────────────────────── -->
            <div data-aos="fade-up" data-aos-delay="100" data-aos-duration="540" style="margin-bottom:var(--sp-32);">
                <div class="panel-box">
                    <div class="panel-header" style="margin-bottom: var(--sp-16);">
                        <div class="panel-title">
                            <i data-lucide="cloud-rain" width="20" height="20" style="color:var(--blue);"></i>
                            Đề xuất thời tiết & Nông nghiệp
                        </div>
                    </div>
                    <div class="city-grid" id="cityGrid">
                        <% List<Map<String,Object>> zoneData = (List<Map<String,Object>>)
                                request.getAttribute("zoneData");
                                // City normalized name-based image map
                                String _cp2 = request.getContextPath();
                                java.util.Map<String,String> NORM_IMG = new java.util.HashMap<>();
                                NORM_IMG.put("danang",  _cp2 + "/assets/cities/");
                                NORM_IMG.put("hanoi",  _cp2 + "/assets/cities/hanoi.png");
                                NORM_IMG.put("hochiminh",  _cp2 + "/assets/cities/hcm.png");
                                NORM_IMG.put("hcm",  _cp2 + "/assets/cities/hcm.png");
                                NORM_IMG.put("cantho",  _cp2 + "/assets/cities/cantho.png");
                                NORM_IMG.put("dalat",  _cp2 + "/assets/cities/dalat.png");
                                NORM_IMG.put("daklak",  _cp2 + "/assets/cities/daklak.png");
                                NORM_IMG.put("haiphong",  _cp2 + "/assets/cities/haiphong.png");
                                NORM_IMG.put("hue",  _cp2 + "/assets/cities/hue.png");
                                NORM_IMG.put("nhatrang",  _cp2 + "/assets/cities/nhatrang.png");
                                NORM_IMG.put("sapa", _cp2 + "/assets/cities/sapa.png");
                                String FBIMG = "https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=360&q=65";
                                if (zoneData != null && !zoneData.isEmpty()) {
                                    java.util.Set<String> seenNames = new java.util.HashSet<>();
                                    int ii = 0;
                                    for (Map<String,Object> z : zoneData) {
                                        Object cidObj = z.get("cityId");
                                        int cid = cidObj != null ? ((Number)cidObj).intValue() : -(ii+1);
                                        
                                        String dispName = z.get("cityName") != null ? String.valueOf(z.get("cityName")) : "";
                                        String normName = dispName.toLowerCase()
                                            .replaceAll("[àáạảãâầấậẩẫăằắặẳẵ]", "a")
                                            .replaceAll("[èéẹẻẽêềếệểễ]", "e")
                                            .replaceAll("[ìíịỉĩ]", "i")
                                            .replaceAll("[òóọỏõôồốộổỗơờớợởỡ]", "o")
                                            .replaceAll("[ùúụủũưừứựửữ]", "u")
                                            .replaceAll("[ỳýỵỷỹ]", "y")
                                            .replaceAll("đ", "d")
                                            .replaceAll("\\s+", "");
                                            
                                        if (!seenNames.add(normName)) continue;
                                        
                                        String img2     = NORM_IMG.containsKey(normName) ? NORM_IMG.get(normName) : FBIMG;
                                        String tempStr  = z.get("temp")     != null ? String.valueOf(z.get("temp"))     : "--";
                                        String zoneName = z.get("zoneName") != null ? String.valueOf(z.get("zoneName")) : "";
                                        Object zid      = z.get("zoneId");
                                        String sHumid   = z.get("humid")    != null ? String.valueOf(z.get("humid"))    : "0";
                                        String sRain    = z.get("rain")     != null ? String.valueOf(z.get("rain"))     : "0";
                                        String sWind    = z.get("wind")     != null ? String.valueOf(z.get("wind"))     : "0";
                                        String sUpd     = z.get("updatedAt") != null ? String.valueOf(z.get("updatedAt")) : "--";
                                        String safeDn   = dispName.replace("'", " ");
                                        String safeUpd  = sUpd.replace("'", " ");
                                        ii++;
                                        %>
                                        <div class="city-tile" data-aos="zoom-in" data-aos-delay="<%= (ii-1)*35 %>" data-aos-duration="420"
                                            onclick="showCity('<%= zid %>',this,'<%= safeDn %>','<%= tempStr %>','<%= sHumid %>','<%= sRain %>','<%= sWind %>','<%= safeUpd %>')">
                                            <img class="city-img" src="<%= img2 %>" alt="<%= dispName %>" loading="lazy"
                                                 onerror="this.onerror=null;this.src='https://images.unsplash.com/photo-1501785888041-af3ef285b470?w=360&q=65'">
                                            <div class="city-overlay">
                                                <div class="city-tbadge"><%= tempStr %>&#176;C</div>
                                                <div class="city-info">
                                                    <div class="city-name"><%= dispName %></div>
                                                    <div class="city-desc"><i data-lucide="map-pin" width="12" height="12"></i> <%= zoneName %></div>
                                                </div>
                                            </div>
                                        </div>
                                        <% } } else { %>
                                            <div style="grid-column:1/-1;text-align:center;padding:44px 16px;">
                                                <i data-lucide="cloud-off" width="28" height="28" style="color:var(--t3);margin:0 auto 10px;display:block;opacity:.4;"></i>
                                                <p style="font-size:.82rem;color:var(--t3);">Chua co du lieu.</p>
                                            </div>
                                        <% } %>

                    </div>
                </div>

                <!-- Detail panel -->
                <div class="glass wx-panel">
                    <div class="sec-title">
                        <i data-lucide="thermometer" width="13" height="13" style="color:var(--blue);"></i>
                        Chi tiết
                    </div>
                    <div id="wxEmpty" class="wx-empty">
                        <div class="wx-empty-icon">&#127758;</div>
                        <p style="font-size:.8rem;color:var(--t3);line-height:1.7;">Chọn một thành phố<br>để xem thời
                            tiết</p>
                        tiet</p>
                    </div>
                    <div id="wxDetail" style="display:none;">
                        <div id="wxIcon" style="font-size:2.6rem;margin-bottom:6px;"></div>
                        <div id="wxCity" class="wx-city-nm"></div>
                        <div id="wxUpd" class="wx-upd"></div>
                        <div id="wxTemp" class="wx-temp-big"></div>
                        <div class="wx-stats">
                            <div class="wx-stat">
                                <div class="wx-stat-lbl">&#128167; Độ ẩm</div>
                                <div class="wx-stat-val" id="wxHumid">--%</div>
                            </div>
                            <div class="wx-stat">
                                <div class="wx-stat-lbl">&#127783; Mưa</div>
                                <div class="wx-stat-val" id="wxRain">-- mm</div>
                            </div>
                            <div class="wx-stat">
                                <div class="wx-stat-lbl">&#128168; Gió</div>
                                <div class="wx-stat-val" id="wxWind">-- km/h</div>
                            </div>
                            <div class="wx-stat">
                                <div class="wx-stat-lbl">&#127774; Cảm giác</div>
                                <div class="wx-stat-val" id="wxFeel" style="color:var(--green);">--</div>
                            </div>
                        </div>
                        <a id="wxLink" href="#" class="btn btn-ghost"
                            style="display:flex;justify-content:center;margin-top:14px;width:100%;">
                            <i data-lucide="bar-chart-2" width="13" height="13"></i>Xem dự báo đầy đủ
                        </a>
                    </div>
                </div>
            </div>

            <!-- ── Activity Timeline ─────────────────────────── -->
            <div class="panel-box" data-aos="fade-up" data-aos-delay="60" data-aos-duration="500">
                <div class="panel-header">
                    <div class="panel-title">
                        <i data-lucide="activity" width="20" height="20" style="color:var(--green);"></i>
                        Hoạt động gần đây
                    </div>
                    <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-ghost btn-sm"
                        style="font-size:.7rem;">Xem tất cả</a>
                </div>
                <div class="timeline">
                    <% List<AdminAuditLog> logs = (List<AdminAuditLog>) request.getAttribute("recentLogs");
                            if (logs != null && !logs.isEmpty()) {
                            for (AdminAuditLog log : logs) {
                            String lt;
                            try { lt = log.getCreatedAt().toString().substring(0,16).replace("T"," "); } catch(Exception
                            e){ lt="--"; }
                            String act = log.getAction() != null ? log.getAction() : "--";
                            String iconColor = "var(--blue)";
                            if (act.contains("LOCK") || act.contains("REJECT")) {
                            iconColor = "var(--red)";
                            } else if (act.contains("APPROVE")||act.contains("UNLOCK")) {
                            iconColor = "var(--green)";
                            }
                            %>
                            <div class="timeline-item">
                                <div class="timeline-dot" style="border-color: <%= iconColor %>;"></div>
                                <div class="timeline-content">
                                    <div class="timeline-header">
                                        <div class="timeline-title">
                                            <%= act %>
                                        </div>
                                        <div class="timeline-time">
                                            <%= lt %> (Admin #<%= log.getAdminId() %>)
                                        </div>
                                    </div>
                                    <div class="timeline-desc">
                                        <%= log.getNote() !=null ? log.getNote() : "" %>
                                    </div>
                                </div>
                            </div>
                            <% } } else { %>
                                <div
                                    style="text-align:center;padding:32px;color:rgba(255,255,255,0.4);font-size:.875rem;">
                                    No recent activity found.</div>
                                <% } %>
                </div>
            </div>

            <script>
                /* ── Init libs ────────────────────────── */
                lucide.createIcons();
                AOS.init({ duration: 520, once: true, easing: 'cubic-bezier(0.22, 1, 0.36, 1)', offset: 16 });

                /* ── Sidebar toggle ───────────────────── */
                function toggleSidebar() {
                    document.getElementById('sidebar').classList.toggle('collapsed');
                    document.getElementById('main').classList.toggle('expanded');
                }

                /* ── Animated counter ──────────────────── */
                function animCount(el, target, dur) {
                    if (!el || isNaN(target) || target <= 0) return;
                    var s = null;
                    requestAnimationFrame(function tick(ts) {
                        if (!s) s = ts;
                        var p = Math.min((ts - s) / dur, 1);
                        var e = 1 - Math.pow(1 - p, 4);          /* easeOutQuart */
                        el.textContent = Math.round(e * target);
                        if (p < 1) requestAnimationFrame(tick);
                        else el.textContent = target;
                    });
                }

                /* ── GSAP hover lift for KPI cards ─────── */
                document.querySelectorAll('.kpi-card').forEach(function (c) {
                    c.addEventListener('mouseenter', function () { gsap.to(c, { y: -7, duration: .28, ease: 'power2.out' }); });
                    c.addEventListener('mouseleave', function () { gsap.to(c, { y: 0, duration: .28, ease: 'power2.out' }); });
                });

                /* ── Run counters on load ──────────────── */
                window.addEventListener('load', function () {
                    setTimeout(function () {
                        ['cnt-users', 'cnt-vip', 'cnt-pending', 'cnt-locked'].forEach(function (id) {
                            var el = document.getElementById(id);
                            if (el) { animCount(el, parseInt(el.dataset.target || '0', 10), 1100); }
                        });
                    }, 350);
                });

                /* ── City weather panel ─────────────────── */
                var ctxP = '<%= request.getContextPath() %>';
                function showCity(zoneId, tile, city, temp, humid, rain, wind, upd) {
                    document.querySelectorAll('.city-tile').forEach(function (t) { t.classList.remove('active'); });
                    if (tile) tile.classList.add('active');
                    document.getElementById('wxEmpty').style.display = 'none';
                    var d = document.getElementById('wxDetail');
                    d.style.display = 'block';
                    gsap.fromTo(d, { opacity: 0, y: 10 }, { opacity: 1, y: 0, duration: .42, ease: 'power3.out' });
                    var t = parseFloat(temp);
                    var icons = ['&#9925;', '&#127773;', '&#9728;&#65039;', '&#10052;', '&#127807;'];
                    var icon = isNaN(t) ? '&#127758;' : t >= 36 ? icons[2] : t >= 28 ? icons[1] : t >= 18 ? icons[0] : icons[3];
                    document.getElementById('wxIcon').innerHTML = icon;
                    document.getElementById('wxCity').textContent = city;
                    document.getElementById('wxUpd').textContent = 'Cập nhật: ' + upd;
                    document.getElementById('wxTemp').innerHTML = temp + '<span style="font-size:2rem;">&#176;C</span>';
                    document.getElementById('wxHumid').textContent = humid + '%';
                    document.getElementById('wxRain').textContent = rain + ' mm';
                    document.getElementById('wxWind').textContent = wind + ' km/h';
                    var feel = document.getElementById('wxFeel');
                    if (!isNaN(t)) {
                        if (t >= 34) { feel.textContent = 'Rất nóng'; feel.style.color = '#ef4444'; }
                        else if (t >= 28) { feel.textContent = 'Nóng'; feel.style.color = '#f59e0b'; }
                        else if (t >= 22) { feel.textContent = 'Ấm'; feel.style.color = '#fbbf24'; }
                        else if (t >= 15) { feel.textContent = 'Mát'; feel.style.color = '#38bdf8'; }
                        else { feel.textContent = 'Lạnh'; feel.style.color = '#8b5cf6'; }
                    }
                    document.getElementById('wxLink').href = ctxP + '/dashboard?zone=' + zoneId;
                }

                /* ── Admin Weather Forecast Widget ────────── */
                var _wxZones = [];

                function wxCondition(temp, rain) {
                    if (rain > 5) return { icon: '🌧️', label: 'Mưa rào' };
                    if (rain > 0) return { icon: '🌦️', label: 'Mưa nhẹ' };
                    if (temp > 35) return { icon: '🔥', label: 'Nắng gắt' };
                    if (temp > 30) return { icon: '☀️', label: 'Nắng nóng' };
                    if (temp > 25) return { icon: '🌤️', label: 'Nắng đẹp' };
                    if (temp > 20) return { icon: '⛅', label: 'Mát mẻ' };
                    return { icon: '🌫️', label: 'Lạnh' };
                }

                function wxDayName(offset) {
                    var days = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
                    var d = new Date(); d.setDate(d.getDate() + offset);
                    return offset === 0 ? 'Hôm nay' : (offset === 1 ? 'Ngày mai' : days[d.getDay()]);
                }

                function loadAdminWeather() {
                    var sel = document.getElementById('wxZoneSelect');
                    var zoneId = sel ? sel.value : '';
                    if (!zoneId) return;

                    var ctxP = '<%= request.getContextPath() %>';
                    var heroIcon = document.getElementById('wxHeroIcon');
                    var heroTemp = document.getElementById('wxHeroTemp');
                    var heroCond = document.getElementById('wxHeroCondition');
                    var cityLbl = document.getElementById('wxCityLabel');
                    var pillH = document.getElementById('wxPillHumid');
                    var pillR = document.getElementById('wxPillRain');
                    var pillW = document.getElementById('wxPillWind');
                    var rowsEl = document.getElementById('wxForecastRows');
                    var updEl = document.getElementById('wxLastUpd');

                    // Show skeleton
                    [heroIcon, heroTemp].forEach(function (e) { if (e) e.classList.add('wx-skeleton'); });
                    if (rowsEl) rowsEl.innerHTML = '<div style="text-align:center;padding:20px;color:rgba(255,255,255,0.3);font-size:0.8rem;" class="wx-skeleton">Đang tải...</div>';

                    // Find selected zone city label
                    var selOpt = sel.options[sel.selectedIndex];
                    if (cityLbl) cityLbl.textContent = selOpt ? selOpt.text : '';

                    // Fetch latest weather data (limit=30 records for 7-day spread)
                    fetch(ctxP + '/api/weather?zoneId=' + zoneId + '&metric=temperature&limit=30')
                        .then(function (r) { return r.json(); })
                        .then(function (data) {
                            if (!data.labels || data.labels.length === 0) {
                                if (rowsEl) rowsEl.innerHTML = '<div style="text-align:center;padding:24px;color:rgba(255,255,255,0.3);font-size:0.8rem;">⚠️ Chưa có dữ liệu thời tiết</div>';
                                return;
                            }

                            // Latest record (last in array = most recent)
                            var temps = data.values.map(Number);
                            var latestT = temps[temps.length - 1];
                            var updStr = data.labels[data.labels.length - 1];

                            // Fetch humidity & rain for same zone (most recent)
                            Promise.all([
                                fetch(ctxP + '/api/weather?zoneId=' + zoneId + '&metric=humidity&limit=1').then(function (r) { return r.json(); }),
                                fetch(ctxP + '/api/weather?zoneId=' + zoneId + '&metric=rainfall&limit=1').then(function (r) { return r.json(); }),
                                fetch(ctxP + '/api/weather?zoneId=' + zoneId + '&metric=wind&limit=1').then(function (r) { return r.json(); })
                            ]).then(function (results) {
                                var humid = results[0].values && results[0].values.length ? Number(results[0].values[results[0].values.length - 1]) : 0;
                                var rain = results[1].values && results[1].values.length ? Number(results[1].values[results[1].values.length - 1]) : 0;
                                var wind = results[2].values && results[2].values.length ? Number(results[2].values[results[2].values.length - 1]) : 0;

                                var cond = wxCondition(latestT, rain);

                                // Update hero
                                if (heroIcon) { heroIcon.textContent = cond.icon; heroIcon.classList.remove('wx-skeleton'); }
                                if (heroTemp) { heroTemp.innerHTML = latestT.toFixed(1) + '<span style="font-size:1.6rem;">°C</span>'; heroTemp.classList.remove('wx-skeleton'); }
                                if (heroCond) heroCond.textContent = cond.label;
                                if (pillH) pillH.textContent = humid.toFixed(0) + '%';
                                if (pillR) pillR.textContent = rain.toFixed(1) + ' mm';
                                if (pillW) pillW.textContent = wind.toFixed(1) + ' km/h';
                                if (updEl) updEl.textContent = 'Cập nhật: ' + updStr;

                                // Build 7-day simulated forecast using historical data as base
                                // Roll through the last 7 records (or extrapolate)
                                var forecastData = [];
                                var last7 = temps.slice(-7);
                                for (var i = 0; i < 7; i++) {
                                    var base = last7[i % last7.length];
                                    // Slight variation ±1.5°C to simulate forecast uncertainty
                                    var variance = (Math.sin(i * 1.7 + latestT) * 1.5);
                                    var fc = base + variance;
                                    var fcRain = (Math.sin(i * 2.3) > 0.3) ? (Math.random() * 4) : 0;
                                    forecastData.push({ offset: i, temp: fc, rain: fcRain });
                                }

                                if (rowsEl) {
                                    rowsEl.innerHTML = '';
                                    forecastData.forEach(function (fd) {
                                        var fc = wxCondition(fd.temp, fd.rain);
                                        var row = document.createElement('div');
                                        row.className = 'wx-row';
                                        row.innerHTML =
                                            '<div class="wx-row-day">' + wxDayName(fd.offset) + '</div>' +
                                            '<div class="wx-row-icon">' + fc.icon + '</div>' +
                                            '<div class="wx-row-temp">' + fd.temp.toFixed(1) + '°C</div>';
                                        rowsEl.appendChild(row);
                                    });
                                }
                            }).catch(function (e) {
                                console.error('Weather stats fetch error', e);
                            });
                        })
                        .catch(function (e) {
                            if (rowsEl) rowsEl.innerHTML = '<div style="text-align:center;padding:24px;color:rgba(239,68,68,0.7);font-size:0.8rem;">❌ Lỗi tải dữ liệu</div>';
                        });
                }

                /* Load zones into weather widget selector, then auto-load first zone */
                document.addEventListener('DOMContentLoaded', function () {
                    var ctxP = '<%= request.getContextPath() %>';
                    fetch(ctxP + '/api/zones')
                        .then(function (r) { return r.json(); })
                        .then(function (zones) {
                            var sel = document.getElementById('wxZoneSelect');
                            if (!sel) return;
                            sel.innerHTML = '';
                            // Deduplicate: show only config names, use first zoneId for each city
                            var seenCities = {};
                            zones.forEach(function (z) {
                                var city = z.cityName || z.zoneName;
                                if (!city) return;
                                var normCity = city.toLowerCase()
                                    .normalize("NFD").replace(/[\u0300-\u036f]/g, "")
                                    .replace(/đ/g, "d").replace(/\s+/g, "");
                                    
                                if (seenCities[normCity]) return; // skip duplicate cities
                                seenCities[normCity] = true;
                                var opt = document.createElement('option');
                                opt.value = z.zoneId;
                                opt.textContent = city;
                                sel.appendChild(opt);
                            });
                            if (zones.length > 0) loadAdminWeather();
                        })
                        .catch(function (e) { console.error('Zone load error', e); });
                });
            </script>

            </div>
            </div>
            </div>
            </body>

            </html>