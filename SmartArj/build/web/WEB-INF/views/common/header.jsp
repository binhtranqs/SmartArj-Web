<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="model.User" %>
        <% User currentUser=(User) session.getAttribute("user"); String currentPage=request.getParameter("page"); if
            (currentPage==null) currentPage="" ; boolean _isVip=false; boolean _isAdmin=false; long _daysLeft=0; try {
            _isVip=(currentUser !=null) && currentUser.isVIP(); } catch (Throwable ignored) {} try {
            _isAdmin=(currentUser !=null) && currentUser.isAdmin(); } catch (Throwable ignored) {} try {
            _daysLeft=(currentUser !=null) ? currentUser.getDaysRemaining() : 0; } catch (Throwable ignored) {} String
            navDash="dashboard" .equals(currentPage) ? "active" : "" ; String navZones="zones" .equals(currentPage)
            ? "active" : "" ; String navCrops="crops" .equals(currentPage) ? "active" : "" ; %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>${param.title} - SmartArj</title>
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet"
                    href="${pageContext.request.contextPath}/assets/app.css?v=<%= System.currentTimeMillis() %>">
                <!-- Lucide Icons -->
                <script src="https://unpkg.com/lucide@latest"></script>

                <style>
                    body {
                        background-image: url('${pageContext.request.contextPath}/assets/backgrounds/tay-bac-farm.jpg');
                        background-size: cover;
                        background-position: center;
                        background-repeat: no-repeat;
                        background-attachment: fixed;
                    }

                    /* Enhance readability and premium look with extra blurring where appropriate */
                    .page-container,
                    .navbar,
                    .item-card-body,
                    .glass-card,
                    .card {
                        backdrop-filter: blur(10px);
                        -webkit-backdrop-filter: blur(10px);
                    }
                </style>
            </head>

            <body>

                <nav class="navbar glass">
                    <div class="navbar-container">
                        <a href="${pageContext.request.contextPath}/home" class="navbar-brand">
                            <i data-lucide="leaf" width="24" height="24"></i>
                            SmartArj
                        </a>

                        <ul class="navbar-nav">
                            <li><a href="${pageContext.request.contextPath}/home"
                                    class='nav-link'><i data-lucide="house" width="18" height="18"></i> Trang chủ</a></li>
                            <li><a href="${pageContext.request.contextPath}/dashboard"
                                    class='nav-link <%= navDash %>'><i data-lucide="layout-dashboard" width="18"
                                        height="18"></i> Dashboard</a></li>
                            <li><a href="${pageContext.request.contextPath}/zones" class='nav-link <%= navZones %>'><i
                                        data-lucide="map" width="18" height="18"></i> Zones</a></li>
                            <li><a href="${pageContext.request.contextPath}/crops" class='nav-link <%= navCrops %>'><i
                                        data-lucide="sprout" width="18" height="18"></i> Crops</a></li>
                            <li><a href="${pageContext.request.contextPath}/marketplace" class='nav-link'
                                    style="display:flex;align-items:center;gap:6px;">
                                    <i data-lucide="shopping-basket" width="18" height="18"></i>
                                    Marketplace
                                </a></li>

                            <% if (currentUser !=null) { %>

                                <% if (_isVip) { %>
                                    <li id="weatherWidget"
                                        style="display:none; margin-right:15px; align-items:center; background:var(--bg-element); border:1px solid var(--border-light); padding:0.4rem 0.8rem; border-radius:20px; box-shadow:var(--shadow-sm); color:var(--text-secondary); font-size:0.85rem; gap:10px;">
                                        <div style="display:flex; align-items:center; gap:6px;">
                                            <span id="weatherIcon"
                                                style="color:var(--secondary); display:flex; align-items:center;"><i
                                                    data-lucide="cloud-sun" width="18" height="18"></i></span>
                                            <div style="display:flex; flex-direction:column; line-height:1.1;">
                                                <span id="weatherTemp"
                                                    style="font-weight:700; color:var(--text-primary); font-size:0.9rem;">--°C</span>
                                                <span id="weatherCity"
                                                    style="font-size:0.7rem; color:var(--text-muted); font-weight:500;">--</span>
                                            </div>
                                        </div>
                                        <div
                                            style="border-left:1px solid var(--border-subtle); padding-left:10px; display:flex; flex-direction:column; line-height:1.1;">
                                            <span id="currentTime"
                                                style="font-weight:600; color:var(--text-primary); font-size:0.85rem;">--:--</span>
                                            <span
                                                style="font-size:0.7rem; color:var(--text-muted); font-weight:500;">Hôm
                                                nay</span>
                                        </div>
                                    </li>
                                    <% } %>

                                        <% if (!_isVip) { %>
                                            <li>
                                                <a href="${pageContext.request.contextPath}/upgrade" class="btn btn-sm"
                                                    style="background:linear-gradient(135deg,#F59E0B 0%,#EF4444 100%); color:white; border:none; box-shadow:0 4px 12px rgba(245, 158, 11, 0.3);">
                                                    <i data-lucide="crown" width="16" height="16"></i> Nâng Cấp VIP
                                                </a>
                                            </li>
                                            <% } %>

                                                <!-- Notification Bell -->
                                                <li class="notification-wrapper">
                                                    <button id="notificationBell" class="notification-bell"
                                                        type="button" title="Thông báo">
                                                        <i data-lucide="bell" width="20" height="20"></i>
                                                        <span class="notification-badge" style="display:none;">
                                                            0
                                                        </span>
                                                    </button>

                                                    <div id="notificationDropdown" class="notification-dropdown">
                                                        <div class="notification-header">
                                                            <i data-lucide="bell-ring" width="16" height="16"
                                                                style="margin-right:6px; color:var(--primary); vertical-align:text-bottom;"></i>
                                                            Thông báo mới
                                                        </div>
                                                        <div class="notification-list">
                                                            <div class="notification-item"
                                                                style="text-align:center; color:var(--text-muted); padding:3rem 1rem;">
                                                                <i data-lucide="loader-2" class="lucide-spin" width="32"
                                                                    height="32"
                                                                    style="margin-bottom:1rem; color:var(--primary); opacity:0.5;"></i>
                                                                <div style="font-weight:500;">Đang tải thông báo...
                                                                </div>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </li>

                                                <li class="notification-wrapper">
                                                    <button id="userMenuButton" class="notification-bell" type="button"
                                                        style="padding:0.4rem 0.8rem 0.4rem 0.6rem; border-radius:20px; font-size:0.9rem; font-weight:600; color:var(--text-primary); gap:6px;">
                                                        <div
                                                            style="width:28px; height:28px; border-radius:50%; background:var(--primary-gradient); display:flex; align-items:center; justify-content:center; color:white; font-size:0.8rem;">
                                                            <% if (_isAdmin) { %><i data-lucide="shield" width="14"
                                                                    height="14"></i>
                                                                <% } else if (_isVip) { %><i data-lucide="crown"
                                                                        width="14" height="14"></i>
                                                                    <% } else { %><i data-lucide="user" width="14"
                                                                            height="14"></i>
                                                                        <% } %>
                                                        </div>
                                                        <span>
                                                            <%= currentUser.getUsername() %>
                                                        </span>
                                                        <i data-lucide="chevron-down" width="14" height="14"
                                                            style="color:var(--text-muted); margin-left:2px;"></i>
                                                    </button>

                                                    <div id="userMenuDropdown" class="notification-dropdown"
                                                        style="width:260px;">
                                                        <div class="notification-header"
                                                            style="display:flex; flex-direction:column; gap:4px; padding:1.25rem;">
                                                            <div style="font-size:1.1rem; color:var(--text-primary);">
                                                                <%= (currentUser.getFullName() !=null &&
                                                                    !currentUser.getFullName().isEmpty()) ?
                                                                    currentUser.getFullName() :
                                                                    currentUser.getUsername() %>
                                                            </div>
                                                            <div
                                                                style="font-size:0.8rem; color:var(--text-muted); font-weight:500;">
                                                                <%= currentUser.getEmail() %>
                                                            </div>
                                                        </div>

                                                        <div class="notification-item"
                                                            style="background:var(--info-bg); border-left:4px solid var(--primary); padding:1rem 1.25rem; cursor:default;">
                                                            <div class="notification-title"
                                                                style="display:flex; align-items:center; gap:6px; color:var(--primary);">
                                                                <% if (_isAdmin) { %><i data-lucide="shield" width="16"
                                                                        height="16"></i> Admin<% } else if (_isVip) { %>
                                                                        <i data-lucide="crown" width="16"
                                                                            height="16"></i> Tài khoản VIP<% } else { %>
                                                                            <i data-lucide="user" width="16"
                                                                                height="16"></i> Tài khoản FREE<% } %>
                                                            </div>
                                                            <% if (_isVip && _daysLeft> 0) { %>
                                                                <div class="notification-text"
                                                                    style="color:var(--text-primary); font-weight:600; margin-top:4px;">
                                                                    Còn <%= _daysLeft %> ngày
                                                                </div>
                                                                <% } %>
                                                        </div>

                                                        <% if (!_isVip) { %>
                                                            <a href="${pageContext.request.contextPath}/upgrade"
                                                                style="display:flex; align-items:center; gap:8px; padding:1rem 1.25rem; text-decoration:none; color:var(--warning); font-weight:500; border-bottom:1px solid var(--border-subtle); transition:var(--transition-fast);">
                                                                <i data-lucide="crown" width="16" height="16"></i> Nâng
                                                                cấp VIP
                                                            </a>
                                                            <% } %>

                                                                <% if (_isAdmin) { %>
                                                                    <a href="${pageContext.request.contextPath}/admin"
                                                                        style="display:flex; align-items:center; gap:8px; padding:1rem 1.25rem; text-decoration:none; color:var(--primary); font-weight:600; border-bottom:1px solid var(--border-subtle); transition:var(--transition-fast);">
                                                                        <i data-lucide="settings" width="16"
                                                                            height="16"></i> Admin Panel
                                                                    </a>
                                                                    <% } %>

                                                                        <a href="${pageContext.request.contextPath}/logout"
                                                                            style="display:flex; align-items:center; gap:8px; padding:1rem 1.25rem; text-decoration:none; color:var(--danger); font-weight:500; transition:var(--transition-fast);">
                                                                            <i data-lucide="log-out" width="16"
                                                                                height="16"></i> Đăng xuất
                                                                        </a>
                                                    </div>
                                                </li>

                                                <% } else { %>
                                                    <li>
                                                        <a href="${pageContext.request.contextPath}/login"
                                                            class="nav-link"><i data-lucide="log-in" width="18"
                                                                height="18"></i> Đăng Nhập</a>
                                                    </li>
                                                    <% } %>
                        </ul>
                    </div>
                </nav>

                <div class="main-content-wrapper">

                    <script>
                        (function () {
                            const ctxPath = '<%= request.getContextPath() %>';
                            const isLoggedIn = <%= (currentUser != null) ? "true" : "false" %>;

                            function escapeHtml(s) {
                                return String(s == null ? "" : s)
                                    .replace(/&/g, "&amp;")
                                    .replace(/</g, "&lt;")
                                    .replace(/>/g, "&gt;")
                                    .replace(/"/g, "&quot;")
                                    .replace(/'/g, "&#039;");
                            }

                            function getAlertIcon(msg) {
                                if (msg.includes('CROP_MAX')) return '<i data-lucide="alert-triangle" width="20" height="20" style="color:var(--danger)"></i>';
                                if (msg.includes('CROP_MIN')) return '<i data-lucide="snowflake" width="20" height="20" style="color:var(--info)"></i>';
                                if (msg.includes('HEAT')) return '<i data-lucide="flame" width="20" height="20" style="color:var(--warning)"></i>';
                                if (msg.includes('RAIN')) return '<i data-lucide="cloud-rain" width="20" height="20" style="color:var(--secondary)"></i>';
                                return '<i data-lucide="bell" width="20" height="20" style="color:var(--primary)"></i>';
                            }

                            function normalizeIsRead(v) {
                                if (v === true) return true;
                                if (v === false) return false;
                                if (typeof v === "number") return v !== 0;
                                if (typeof v === "string") {
                                    var s = v.trim().toLowerCase();
                                    return (s === "true" || s === "1" || s === "yes");
                                }
                                return Boolean(v);
                            }

                            async function loadAlerts() {
                                if (!isLoggedIn) return;
                                const listEl = document.querySelector("#notificationDropdown .notification-list");
                                const badgeEl = document.querySelector("#notificationBell .notification-badge");
                                if (!listEl) return;

                                try {
                                    const res = await fetch(ctxPath + "/api/alerts");
                                    if (!res.ok) throw new Error("HTTP " + res.status);
                                    const json = await res.json();

                                    if (json.status !== "success") throw new Error("API Error");
                                    const alerts = Array.isArray(json.data) ? json.data : [];

                                    // Update Badge
                                    const unread = alerts.filter(a => !normalizeIsRead(a.isRead)).length;
                                    if (badgeEl) {
                                        badgeEl.textContent = unread;
                                        badgeEl.style.display = unread > 0 ? "inline-flex" : "none";
                                    }

                                    if (alerts.length === 0) {
                                        listEl.innerHTML = '<div class="notification-item" style="text-align:center; color:var(--text-muted); padding:3rem 1rem;">' +
                                            '<i data-lucide="inbox" width="32" height="32" style="margin-bottom:1rem; color:var(--text-muted); opacity:0.5;"></i>' +
                                            '<div style="font-weight:500;">Không có thông báo mới</div></div>';
                                        lucide.createIcons();
                                        return;
                                    }

                                    let html = "";
                                    alerts.forEach(a => {
                                        const isRead = normalizeIsRead(a.isRead);
                                        const icon = getAlertIcon(a.message || "");
                                        // Strip "DEDUP=...; " prefix
                                        let displayMsg = a.message || "";
                                        if (displayMsg.includes("; ")) {
                                            displayMsg = displayMsg.substring(displayMsg.indexOf("; ") + 2);
                                        }
                                        // Further strip tags like [CROP_MAX]
                                        displayMsg = displayMsg.replace(/\[CROP_MAX\]|\[CROP_MIN\]|\[HEAT\]|\[RAIN\]|\[CROP_MAX_FORECAST\]|\[CROP_MIN_FORECAST\]|\[HEAT_FORECAST\]/g, '').trim();

                                        const opacity = isRead ? "opacity: 0.6;" : "";
                                        const newBadge = isRead ? "" : '<span style="margin-left:auto; font-size:10px; font-weight:800; color:#ef4444; background:rgba(239,68,68,0.1); padding:2px 6px; border-radius:10px;">MỚI</span>';

                                        html += '<div class="notification-item" style="' + opacity + '">' +
                                            '<div style="display:flex; gap:12px; align-items:flex-start;">' +
                                            '<div style="font-size:1.25rem;">' + icon + '</div>' +
                                            '<div style="flex:1;">' +
                                            '<div style="display:flex; align-items:center;">' +
                                            '<span style="font-weight:600; font-size:0.9rem; color:var(--text-primary);">Cảnh báo</span>' +
                                            newBadge +
                                            '</div>' +
                                            '<div style="font-size:0.875rem; color:var(--text-secondary); margin-top:4px; line-height:1.5;">' + escapeHtml(displayMsg) + '</div>' +
                                            '<div style="font-size:0.75rem; font-weight:500; color:var(--text-muted); margin-top:6px;">' + (a.alertTime ? a.alertTime.substring(0, 16).replace('T', ' ') : '') + '</div>' +
                                            '</div></div></div>';
                                    });
                                    listEl.innerHTML = html;
                                    lucide.createIcons();

                                } catch (e) {
                                    console.error("loadAlerts error:", e);
                                    listEl.innerHTML = '<div class="notification-item" style="text-align:center; color:var(--danger); padding:2rem;">Lỗi tải thông báo</div>';
                                }
                            }

                            // Event Delegation for clicks
                            document.addEventListener("click", function (e) {
                                const bellElement = e.target.closest("#notificationBell");
                                const userBtnElement = e.target.closest("#userMenuButton");
                                const notifDropdownEl = document.getElementById("notificationDropdown");
                                const userDropdownEl = document.getElementById("userMenuDropdown");

                                if (bellElement) {
                                    e.stopPropagation();
                                    const opening = !notifDropdownEl.classList.contains("show");
                                    if (userDropdownEl) userDropdownEl.classList.remove("show");
                                    notifDropdownEl.classList.toggle("show");
                                    if (opening) loadAlerts();
                                } else if (userBtnElement) {
                                    e.stopPropagation();
                                    if (notifDropdownEl) notifDropdownEl.classList.remove("show");
                                    userDropdownEl.classList.toggle("show");
                                } else {
                                    if (notifDropdownEl) notifDropdownEl.classList.remove("show");
                                    if (userDropdownEl) userDropdownEl.classList.remove("show");
                                }
                            });

                            if (isLoggedIn) {
                                loadAlerts();
                                setInterval(loadAlerts, 30000);
                            }

                            <% if (currentUser != null && _isVip) { %>
                                fetch(ctxPath + '/api/current-weather')
                                    .then(r => r.json())
                                    .then(data => {
                                        if (!data || data.temperature == null) return;
                                        const widget = document.getElementById('weatherWidget');
                                        if (widget) widget.style.display = 'flex';
                                        const tempElement = document.getElementById('weatherTemp');
                                        const cityElement = document.getElementById('weatherCity');
                                        const timeElement = document.getElementById('currentTime');
                                        const iconElement = document.getElementById('weatherIcon');
                                        if (tempElement) tempElement.innerText = Number(data.temperature).toFixed(1) + '°C';
                                        if (cityElement) cityElement.innerText = data.city || '--';
                                        if (timeElement && data.currentTime) timeElement.innerText = String(data.currentTime).split(' ')[0];

                                        let iconHTML = '<i data-lucide="cloud-sun" width="18" height="18"></i>';
                                        const condStr = data.condition || '';
                                        if (condStr.includes('Mưa')) iconHTML = '<i data-lucide="cloud-rain" width="18" height="18" style="color:var(--secondary)"></i>';
                                        else if (condStr.includes('Nắng')) iconHTML = '<i data-lucide="sun" width="18" height="18" style="color:var(--warning)"></i>';
                                        if (iconElement) {
                                            iconElement.innerHTML = iconHTML;
                                            lucide.createIcons();
                                        }
                                    })
                                    .catch(err => console.error('Weather error:', err));
                            <% } %>

                                // Initialize Lucide icons on page load
                                lucide.createIcons();
                        })();
                    </script>