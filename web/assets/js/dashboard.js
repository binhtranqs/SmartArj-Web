// ==========================
// ALERTS UI (Option 1)
// - Filter already done in backend (/api/alerts)
// - Click alert -> go dashboard?zoneId=...
// - Badge clears when open dropdown OR click any alert
// ==========================

const ALERT_REFRESH_MS = 60000; // 60s
const LS_LAST_SEEN_ALERT_ID = "lastSeenAlertId";

// cache newest alert id from last load
let newestAlertIdCache = 0;

function getLastSeenAlertId() {
  const v = localStorage.getItem(LS_LAST_SEEN_ALERT_ID);
  const n = parseInt(v || "0", 10);
  return isNaN(n) ? 0 : n;
}

function setLastSeenAlertId(id) {
  localStorage.setItem(LS_LAST_SEEN_ALERT_ID, String(id || 0));
}

function setBadgeCount(count) {
  const bell = document.getElementById("notificationBell");
  if (!bell) return;
  const badge = bell.querySelector(".notification-badge");
  if (!badge) return;

  if (!count || count <= 0) {
    badge.style.display = "none";
    badge.textContent = "";
  } else {
    badge.style.display = "flex";
    badge.textContent = String(count);
  }
}

function openDropdown() {
  const dd = document.getElementById("notificationDropdown");
  if (!dd) return;
  dd.classList.add("show");
}

function closeDropdown() {
  const dd = document.getElementById("notificationDropdown");
  if (!dd) return;
  dd.classList.remove("show");
}

function isDropdownOpen() {
  const dd = document.getElementById("notificationDropdown");
  return dd && dd.classList.contains("show");
}

async function loadAlerts() {
  const listEl = document.getElementById("notificationList");
  if (!listEl) return;

  try {
    const res = await fetch("/api/alerts", { credentials: "include" });
    const json = await res.json();

    if (!res.ok || !json || json.status !== "success") {
      return;
    }

    const alerts = Array.isArray(json.data) ? json.data : [];
    listEl.innerHTML = "";

    if (alerts.length === 0) {
      newestAlertIdCache = 0;
      listEl.innerHTML = `<div class="notification-empty">Không có cảnh báo</div>`;
      setBadgeCount(0);
      return;
    }

    // newest id to compute unread
    const newestId = alerts.reduce((mx, a) => Math.max(mx, a.alertId || 0), 0);
    newestAlertIdCache = newestId;

    const lastSeen = getLastSeenAlertId();
    const unreadCount = alerts.filter(a => (a.alertId || 0) > lastSeen).length;

    // render badge
    setBadgeCount(unreadCount);

    // render list
    alerts.forEach(a => {
      const level = (a.level || "INFO").toUpperCase();
      const zoneId = a.zoneId || 0;
      const alertId = a.alertId || 0;

      const item = document.createElement("div");
      item.className = "notification-item";
      item.style.cursor = "pointer";

      // mark unread visually (optional)
      if (alertId > lastSeen) item.classList.add("unread");
      item.dataset.alertId = String(alertId);

      item.innerHTML = `
        <div class="notification-title">${level} - Zone #${zoneId}</div>
        <div class="notification-message">${a.message || ""}</div>
        <div class="notification-time">${a.createdAt || ""}</div>
      `;

      // click -> go dashboard?zoneId=...
      item.addEventListener("click", (e) => {
        e.preventDefault();
        e.stopPropagation();

        // mark all as seen up to newest (at the moment list was rendered)
        setLastSeenAlertId(newestId);
        setBadgeCount(0);
        closeDropdown();

        window.location.href = `/dashboard?zoneId=${encodeURIComponent(zoneId)}&fromAlert=1`;
      });

      listEl.appendChild(item);
    });

  } catch (err) {
    // ignore
  }
}

// ==========================
// INIT
// ==========================
document.addEventListener("DOMContentLoaded", () => {
  // 1) load now
  loadAlerts();

  // 2) refresh every 60s
  setInterval(loadAlerts, ALERT_REFRESH_MS);

  // 3) bell toggle + mark read when open dropdown
  const bell = document.getElementById("notificationBell");
  const dd = document.getElementById("notificationDropdown");

  if (bell && dd) {
    bell.addEventListener("click", async (e) => {
      e.preventDefault();
      e.stopPropagation();

      if (isDropdownOpen()) {
        closeDropdown();
        return;
      }

      // open dropdown
      openDropdown();

      // ensure list is loaded so newestAlertIdCache is correct
      await loadAlerts();

      // mark read up to newest currently loaded
      if (newestAlertIdCache > 0) {
        setLastSeenAlertId(newestAlertIdCache);
      }
      setBadgeCount(0);
    });

    // click outside closes dropdown
    document.addEventListener("click", () => {
      if (isDropdownOpen()) closeDropdown();
    });

    // prevent click inside dropdown bubbling to document
    dd.addEventListener("click", (e) => e.stopPropagation());
  }
});