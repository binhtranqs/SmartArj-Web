<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
  // Lấy user từ session và page hiện tại truyền qua <jsp:param name="page" ...>
  User currentUser = (User) session.getAttribute("user");
  String currentPage = request.getParameter("page");
  if (currentPage == null) {
    currentPage = "";
  }
%>

    <!DOCTYPE html>
    <html lang="vi">

    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">

      <title>
        ${param.title != null ? param.title : 'SmartArj'} - Smart Agriculture System
      </title>

      <!-- Google Fonts -->
      <link rel="preconnect" href="https://fonts.googleapis.com">
      <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

      <!-- Custom CSS -->
      <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css">
    </head>

    <body>

      <!-- Navbar -->
      <nav class="navbar">
        <div class="navbar-container">

          <a href="${pageContext.request.contextPath}/dashboard" class="navbar-brand">
            📊 SmartArj
          </a>

          <ul class="navbar-nav">

            <li>
              <a href="${pageContext.request.contextPath}/dashboard" class="nav-link <%= "dashboard".equals(currentPage) ? "active" : "" %>">
                Dashboard
              </a>
            </li>

            <li>
              <a href="${pageContext.request.contextPath}/zones" class="nav-link <%= "zones".equals(currentPage) ? "active" : "" %>">
                Zones
              </a>
            </li>

            <li>
              <a href="${pageContext.request.contextPath}/crops" class="nav-link <%= "crops".equals(currentPage) ? "active" : "" %>">
                Crops
              </a>
            </li>

            <% if (currentUser !=null) { %>

              <% if (currentUser.isVIP()) { %>
                <!-- Weather Widget (VIP) -->
                <li id="weatherWidget"
                  style="display:none; margin-right:15px; align-items:center; color:#4B5563; font-size:0.9rem;">

                  <span id="weatherIcon" style="margin-right:5px; font-size:1.2rem;">
                    ⛅
                  </span>

                  <div style="display:flex; flex-direction:column; line-height:1.2;">
                    <span id="weatherTemp" style="font-weight:bold; color:#111827;">
                      --°C
                    </span>
                    <span id="weatherCity" style="font-size:0.75rem; color:#6B7280;">
                      --
                    </span>
                  </div>

                  <div style="margin-left:10px; border-left:1px solid #E5E7EB;
                                padding-left:10px; display:flex;
                                flex-direction:column; line-height:1.2;">
                    <span id="currentTime" style="font-weight:bold; color:#111827;">
                      --:--
                    </span>
                    <span style="font-size:0.75rem; color:#6B7280;">
                      Hôm nay
                    </span>
                  </div>
                </li>
                <% } %>

                  <% if (!currentUser.isVIP()) { %>
                    <li>
                      <a href="${pageContext.request.contextPath}/upgrade" class="nav-link" style="background: linear-gradient(135deg,#F59E0B 0%,#EF4444 100%);
                              color:white; border-radius: var(--radius-md);
                              padding:0.5rem 1rem;">
                        ⭐ Nâng Cấp VIP
                      </a>
                    </li>
                    <% } %>

                      <!-- Weather + Time -->
                      <li class="header-weather-li">
                        <div id="header-weather" class="header-weather">
                          <span class="weather-icon">☀️</span>
                          <div class="header-weather-meta">
                            <span id="weather-temp" class="header-weather-temp">--°C</span>
                            <span id="weather-city" class="header-weather-city">--</span>
                          </div>
                          <div class="header-time-block">
                            <span id="header-current-time" class="header-time-value">--:--</span>
                            <span class="header-time-label">Hôm nay</span>
                          </div>
                        </div>
                      </li>

                      <!-- Notification Bell -->
                      <li class="notification-wrapper">
                        <button id="notificationBell" class="notification-bell" type="button">
                          🔔
                          <span class="notification-badge" style="display:none;">
                            0
                          </span>
                        </button>

                        <div id="notificationDropdown" class="notification-dropdown">

                          <div class="notification-header">
                            Thông báo
                          </div>

                          <div class="notification-list">
                            <div class="notification-item" style="text-align:center;
                                        color:var(--text-secondary);
                                        padding:2rem;">
                              <div style="font-size:2rem; margin-bottom:0.5rem;">
                                ⏳
                              </div>
                              <div>Đang tải thông báo...</div>
                            </div>
                          </div>
                        </div>
                      </li>

                      <!-- User Menu -->
                      <li class="notification-wrapper">
                        <button id="userMenuButton" class="notification-bell" type="button" style="padding:0.5rem 1rem;
                                   border-radius: var(--radius-md);
                                   font-size:0.95rem;">
                          <% if (currentUser.isVIP()) { %>
                            ⭐ <%= currentUser.getUsername() %>
                              <% } else { %>
                                👤 <%= currentUser.getUsername() %>
                                  <% } %>
                        </button>

                        <div id="userMenuDropdown" class="notification-dropdown">

                          <div class="notification-header">
                            <%= (currentUser.getFullName() !=null && !currentUser.getFullName().isEmpty()) ?
                              currentUser.getFullName() : currentUser.getUsername() %>
                          </div>

                          <div class="notification-item" style="background: rgba(102,126,234,0.1);
                                    border-left:4px solid #667eea;">
                            <div class="notification-title">
                              <% if (currentUser.isVIP()) { %>
                                ⭐ Tài khoản VIP
                                <% } else { %>
                                  👤 Tài khoản FREE
                                  <% } %>
                            </div>

                            <% if (currentUser.isVIP()) { %>
                              <div class="notification-text">
                                Còn <%= currentUser.getDaysRemaining() %> ngày
                              </div>
                              <% } %>
                          </div>

                          <% if (!currentUser.isVIP()) { %>
                            <a href="${pageContext.request.contextPath}/upgrade" style="display:block; padding:1rem;
                                  text-decoration:none;
                                  color:var(--text-primary);
                                  border-bottom:1px solid rgba(0,0,0,0.05);">
                              ⭐ Nâng cấp VIP
                            </a>
                            <% } %>

                              <a href="${pageContext.request.contextPath}/logout" style="display:block; padding:1rem;
                                  text-decoration:none;
                                  color: var(--danger);">
                                🚪 Đăng xuất
                              </a>
                        </div>
                      </li>

                      <% } else { %>

                        <li>
                          <a href="${pageContext.request.contextPath}/login" class="nav-link">
                            🔐 Đăng Nhập
                          </a>
                        </li>

                        <% } %>

          </ul>
        </div>
      </nav>

      <!-- Wrapper mở cho footer.jsp đóng -->
      <div style="max-width:1400px; margin:0 auto; padding:0 2rem;">

        <script>
          window.__CTX_PATH__ = window.__CTX_PATH__ || "<%=request.getContextPath()%>";
          window.__LOGGED_IN__ = <%= (currentUser != null) ? "true" : "false" %>;

          // ✅ chống init nhiều lần (header bị include nhiều lần cũng không chết)
          if (!window.__ALERT_BELL_INITED__) {
            window.__ALERT_BELL_INITED__ = true;

            function escapeHtml(s) {
              return String(s == null ? "" : s)
                .replaceAll("&", "&amp;")
                .replaceAll("<", "&lt;")
                .replaceAll(">", "&gt;")
                .replaceAll('"', "&quot;")
                .replaceAll("'", "&#039;");
            }

            function levelToIcon(level) {
              var lv = String(level || "").toUpperCase();
              if (lv.indexOf("DANGER") >= 0 || lv.indexOf("HIGH") >= 0) return "🚨";
              if (lv.indexOf("WARN") >= 0) return "⚠️";
              if (lv.indexOf("SUCCESS") >= 0) return "✅";
              return "🔔";
            }

            function normalizeIsRead(v) {
              if (v === true) return true;
              if (v === false) return false;
              if (typeof v === "number") return v !== 0;
              if (typeof v === "string") {
                var s = v.trim().toLowerCase();
                if (s === "true" || s === "1" || s === "yes") return true;
                if (s === "false" || s === "0" || s === "no" || s === "") return false;
              }
              return Boolean(v);
            }

            function setLoading(listEl) {
              if (!listEl) return;
              listEl.innerHTML =
                '<div class="notification-item" style="text-align:center; color:var(--text-secondary); padding:2rem;">' +
                '<div style="font-size:2rem; margin-bottom:0.5rem;">⏳</div>' +
                '<div>Đang tải thông báo...</div>' +
                '</div>';
            }

            function setError(listEl, text) {
              if (!listEl) return;
              listEl.innerHTML =
                '<div class="notification-item" style="text-align:center; color:var(--danger); padding:2rem;">' +
                '<div style="font-size:2rem; margin-bottom:0.5rem;">❌</div>' +
                '<div>' + escapeHtml(text) + '</div>' +
                '</div>';
            }

            function setEmpty(listEl) {
              if (!listEl) return;
              listEl.innerHTML =
                '<div class="notification-item" style="text-align:center; color:var(--text-secondary); padding:2rem;">' +
                '<div style="font-size:2rem; margin-bottom:0.5rem;">📭</div>' +
                '<div>Không có thông báo</div>' +
                '</div>';
            }

            async function loadAlerts() {
              var badgeEl = document.querySelector("#notificationBell .notification-badge");
              var listEl = document.querySelector("#notificationDropdown .notification-list");
              if (!listEl) return;

              setLoading(listEl);

              try {
                var res = await fetch(window.__CTX_PATH__ + "/api/alerts", { credentials: "include" });
                if (!res.ok) {
                  setError(listEl, "Không tải được thông báo (HTTP " + res.status + ")");
                  return;
                }

                var json = await res.json();
                if (!json || json.status !== "success") {
                  setError(listEl, "Không tải được thông báo");
                  return;
                }

                var alerts = Array.isArray(json.data) ? json.data : [];
                var unread = alerts.filter(function (a) {
                  return a && normalizeIsRead(a.isRead) === false;
                }).length;

                if (badgeEl) {
                  badgeEl.textContent = String(unread);
                  badgeEl.style.display = unread > 0 ? "inline-flex" : "none";
                }

                if (alerts.length === 0) {
                  setEmpty(listEl);
                  return;
                }

                var html = "";
                for (var i = 0; i < alerts.length; i++) {
                  var a = alerts[i] || {};
                  var msg = escapeHtml(a.message || "");
                  var time = escapeHtml(a.alertTime || a.createdAt || "");
                  var levelRaw = a.level || "INFO";
                  var level = escapeHtml(levelRaw);
                  var icon = levelToIcon(levelRaw);

                  var isRead = normalizeIsRead(a.isRead);
                  var opacity = isRead ? "opacity:.7;" : "";
                  var newBadge = isRead
                    ? ""
                    : '<span style="margin-left:auto; font-size:12px; font-weight:800; color:#ef4444;">NEW</span>';

                  html +=
                    '<div class="notification-item" style="' + opacity + '">' +
                    '<div class="notification-title" style="display:flex; align-items:center; gap:.5rem;">' +
                    '<span>' + icon + '</span>' +
                    '<span>' + level + '</span>' +
                    newBadge +
                    '</div>' +
                    '<div class="notification-text" style="margin-top:.25rem;">' + msg + '</div>' +
                    '<div style="margin-top:.5rem; font-size:12px; color:var(--text-secondary);">' + time + '</div>' +
                    '</div>';
                }

                listEl.innerHTML = html;

              } catch (e) {
                console.error("loadAlerts error:", e);
                setError(listEl, "Lỗi khi tải thông báo");
              }
            }

            // expose để test nhanh
            window.loadAlerts = loadAlerts;

            // ✅ Event delegation: click ở đâu cũng bắt được chuông (kể cả DOM render lại)
            document.addEventListener("click", function (e) {
              var bell = e.target && e.target.closest ? e.target.closest("#notificationBell") : null;
              var userBtn = e.target && e.target.closest ? e.target.closest("#userMenuButton") : null;

              var notifDropdown = document.getElementById("notificationDropdown");
              var userDropdown = document.getElementById("userMenuDropdown");

              if (bell) {
                e.stopPropagation();
                if (!notifDropdown) return;

                var opening = !notifDropdown.classList.contains("show");
                notifDropdown.classList.toggle("show");
                if (userDropdown) userDropdown.classList.remove("show");
                if (opening) loadAlerts();
                return;
              }

              if (userBtn) {
                e.stopPropagation();
                if (!userDropdown) return;

                userDropdown.classList.toggle("show");
                if (notifDropdown) notifDropdown.classList.remove("show");
                return;
              }

            });

            // ✅ auto refresh để demo (chỉ khi đã login)
            if (window.__LOGGED_IN__) {
              loadAlerts();
              setInterval(loadAlerts, 10000);
            }
          }
        </script>

        <script>
          document.addEventListener("DOMContentLoaded", function () {
            function updateHeaderClock() {
              var timeEl = document.getElementById("header-current-time");
              if (!timeEl) return;
              var now = new Date();
              var hh = String(now.getHours()).padStart(2, "0");
              var mm = String(now.getMinutes()).padStart(2, "0");
              timeEl.textContent = hh + ":" + mm;
            }

            updateHeaderClock();
            setInterval(updateHeaderClock, 60000);

            fetch("<%=request.getContextPath()%>/api/header-info")
              .then(res => {
                if (!res.ok) throw new Error("Weather fetch failed");
                return res.json();
              })
              .then(data => {
                document.getElementById("weather-temp").textContent =
                  data.tempC.toFixed(1) + "°C";
                document.getElementById("weather-city").textContent =
                  data.city;
              })
              .catch(err => {
                console.error("Weather error:", err);
              });
          });
        </script>
