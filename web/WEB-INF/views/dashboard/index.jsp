<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="model.User" %>
<% User currentUser = (User) session.getAttribute("user"); %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
  <jsp:param name="title" value="Dashboard" />
  <jsp:param name="page" value="dashboard" />
</jsp:include>

<div class="page-container">
  <% if (currentUser != null && !currentUser.isVIP()) { %>
    <div class="card mb-4"
      style="padding: 2rem; background: linear-gradient(135deg, #F59E0B 0%, #EF4444 100%); color: white;">
      <div style="display: flex; justify-content: space-between; align-items: center; gap: 2rem;">
        <div style="flex: 1;">
          <h3 style="margin: 0 0 0.5rem 0; font-size: 1.5rem;">⭐ Nâng cấp lên VIP để mở khóa tất cả tính năng!</h3>
          <p style="margin: 0; opacity: 0.9;">
            Chatbot AI, dự báo thời tiết, phân tích nâng cao và nhiều hơn nữa
          </p>
        </div>
        <a href="${pageContext.request.contextPath}/upgrade" class="btn"
          style="background: white; color: #EF4444; padding: 1rem 2rem; font-weight: 700; white-space: nowrap;">
          Xem Gói VIP →
        </a>
      </div>
    </div>
  <% } %>

  <div class="page-header">
    <div>
      <h1 class="page-title">📊 Virtual Station Dashboard</h1>
      <p class="page-subtitle">Theo dõi và phân tích dữ liệu thời tiết theo thời gian thực</p>
    </div>
  </div>

  <div class="card glass-card mb-4">
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; align-items: end;">
      <div>
        <label style="display: block; margin-bottom: 0.5rem; color: var(--text-primary); font-weight: 600;">
          🌍 Zone
        </label>
        <select id="zoneId"
          style="width: 100%; padding: 0.75rem; border: 2px solid var(--border-color); border-radius: var(--radius-md); font-size: 0.9375rem; transition: border 0.2s;">
          <option>Loading zones...</option>
        </select>
      </div>

      <div>
        <label style="display: block; margin-bottom: 0.5rem; color: var(--text-primary); font-weight: 600;">
          📈 Metric
        </label>
        <select id="metric"
          style="width: 100%; padding: 0.75rem; border: 2px solid var(--border-color); border-radius: var(--radius-md); font-size: 0.9375rem;">
          <option value="temperature">🌡️ Temperature (°C)</option>
          <option value="humidity">💧 Humidity (%)</option>
          <option value="rainfall">🌧️ Rainfall (mm)</option>
          <option value="wind">💨 Wind (km/h)</option>
          <option value="radiation">☀️ Radiation (W/m²)</option>
        </select>
      </div>

      <div>
        <label style="display: block; margin-bottom: 0.5rem; color: var(--text-primary); font-weight: 600;">
          🔢 Data Points
        </label>
        <input id="limit" type="number" value="30" min="10" max="500"
          style="width: 100%; padding: 0.75rem; border: 2px solid var(--border-color); border-radius: var(--radius-md); font-size: 0.9375rem;">
      </div>

      <div>
        <button id="btnLoad" class="btn btn-primary" style="width: 100%; padding: 0.75rem 1.5rem;">
          🔄 Load Data
        </button>
      </div>
    </div>

    <div style="margin-top: 1rem;">
      <div id="statusText" style="color: var(--danger); font-size: 0.875rem; font-weight: 500;"></div>
    </div>
  </div>

  <div style="display: grid; grid-template-columns: 1fr 350px; gap: 2rem; margin-bottom: 2rem;">
    <div class="chart-container">
      <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
        <div>
          <h2 style="font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin: 0;">
            📊 Weather Trend
          </h2>
        </div>
        <span id="metaText" class="badge badge-primary" style="font-size: 0.875rem; padding: 0.5rem 1rem;">
          —
        </span>
      </div>
      <div class="chart-wrapper">
        <canvas id="chart"></canvas>
      </div>
    </div>

    <div class="stats-card">
      <h3 style="font-weight: 700; margin-bottom: 0.5rem; color: var(--text-primary);">
        📊 Quick Stats
      </h3>
      <p style="font-size: 0.875rem; color: var(--text-secondary); margin-bottom: 1.5rem;">
        Thống kê dữ liệu hiện tại
      </p>

      <div class="stat-item">
        <span class="stat-label">⬇️ Minimum</span>
        <span id="minVal" class="stat-value" style="color: var(--info);">—</span>
      </div>

      <div class="stat-item">
        <span class="stat-label">⬆️ Maximum</span>
        <span id="maxVal" class="stat-value" style="color: var(--danger);">—</span>
      </div>

      <div class="stat-item">
        <span class="stat-label">📊 Average</span>
        <span id="avgVal" class="stat-value" style="color: var(--success);">—</span>
      </div>
    </div>
  </div>
</div>

<% if (currentUser != null && currentUser.isVIP()) { %>
  <div class="card mb-4" id="forecastSection">
    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
      <h3 class="card-title">🔮 Dự Báo Thời Tiết (Next 7 Days)</h3>
      <span class="badge badge-success">VIP Feature</span>
    </div>

    <div id="forecastLoading" style="text-align: center; padding: 2rem;">
      Loading forecast data...
    </div>

    <div id="forecastContainer" style="display: none;">
      <div class="chart-wrapper" style="height: 300px; margin-bottom: 2rem;">
        <canvas id="forecastChart"></canvas>
      </div>

      <div id="forecastGrid" class="grid"
        style="grid-template-columns: repeat(auto-fit, minmax(120px, 1fr)); gap: 1rem;">
      </div>
    </div>
  </div>
<% } %>

<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

<script>
const ctxPath = "<%=request.getContextPath()%>";

let chart;
let forecastChart;

const elZone = document.getElementById("zoneId");
const elMetric = document.getElementById("metric");
const elLimit = document.getElementById("limit");
const elStatus = document.getElementById("statusText");
const elMeta = document.getElementById("metaText");

const elMin = document.getElementById("minVal");
const elMax = document.getElementById("maxVal");
const elAvg = document.getElementById("avgVal");

async function fetchJson(url) {
  const res = await fetch(url, { credentials: "include" });
  if (!res.ok) throw new Error("HTTP " + res.status);
  return await res.json();
}

function metricLabel(metric) {
  const map = {
    temperature: "Temperature (°C)",
    humidity: "Humidity (%)",
    rainfall: "Rainfall (mm)",
    wind: "Wind (km/h)",
    radiation: "Radiation (W/m²)"
  };
  return map[metric] || metric;
}

function updateStats(values) {
  if (!values || values.length === 0) {
    elMin.textContent = elMax.textContent = elAvg.textContent = "—";
    return;
  }
  const min = Math.min(...values);
  const max = Math.max(...values);
  const avg = values.reduce((a, b) => a + b, 0) / values.length;

  elMin.textContent = min.toFixed(2);
  elMax.textContent = max.toFixed(2);
  elAvg.textContent = avg.toFixed(2);
}

// ==========================
// FORECAST (VIP) - FIX NaN + Day 1..7 + Temp hiển thị chắc chắn
// ==========================
async function loadForecast(zoneId) {
  const elLoading = document.getElementById("forecastLoading");
  const elContainer = document.getElementById("forecastContainer");
  const elGrid = document.getElementById("forecastGrid");
  const canvas = document.getElementById("forecastChart");

  if (!elLoading || !elContainer || !elGrid || !canvas) return;

  try {
    elLoading.style.display = "block";
    elContainer.style.display = "none";
    elLoading.textContent = "Loading forecast data...";

    const res = await fetch(ctxPath + "/api/forecast?zoneId=" + encodeURIComponent(zoneId), {
      credentials: "include"
    });
    const json = await res.json();

    if (!res.ok || !json || json.status !== "success") {
      elLoading.textContent = "Không tải được dự báo.";
      return;
    }

    const rows = Array.isArray(json.data) ? json.data : [];

    // ✅ Normalize cực an toàn: ưu tiên temperature, fallback value
    const normalized = rows.map(r => {
      const raw = (r.temperature !== undefined && r.temperature !== null) ? r.temperature : r.value;
      const num = parseFloat(raw);
      return {
        date: r.date,
        temp: Number.isFinite(num) ? num : null
      };
    }).filter(x => x.date && x.temp !== null);

    if (normalized.length === 0) {
      elLoading.textContent = "Không có dữ liệu dự báo.";
      return;
    }

    // ✅ Render grid: Day 1..Day 7 + temp
    elGrid.innerHTML = "";
    normalized.slice(0, 7).forEach((x, idx) => {
      const item = document.createElement("div");

      // inline style chống CSS đè
      item.style.background = "#ffffff";
      item.style.borderRadius = "16px";
      item.style.padding = "16px";
      item.style.textAlign = "center";
      item.style.boxShadow = "0 10px 25px rgba(0,0,0,0.08)";
      item.style.display = "flex";
      item.style.flexDirection = "column";
      item.style.alignItems = "center";
      item.style.justifyContent = "center";
      item.style.minHeight = "110px";

      item.innerHTML = `
  <div style="font-size:13px;font-weight:900;color:#0f172a;">Day \${idx + 1}</div>
  <div style="font-size:12px;font-weight:700;color:#64748b;margin-top:6px;">\${x.date}</div>
  <div style="font-size:24px;font-weight:900;color:#0f172a;margin-top:10px;">
    \${x.temp.toFixed(2)} <span style="font-size:14px;font-weight:800;color:#334155;">°C</span>
  </div>
`;
      elGrid.appendChild(item);
    });

    // ✅ Render chart
    if (forecastChart) forecastChart.destroy();
    forecastChart = new Chart(canvas, {
      type: "line",
      data: {
        labels: normalized.slice(0, 7).map(x => x.date),
        datasets: [{
          label: "Forecast Temperature (°C)",
          data: normalized.slice(0, 7).map(x => x.temp),
          tension: 0.35,
          fill: true
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false
      }
    });

    elLoading.style.display = "none";
    elContainer.style.display = "block";
  } catch (e) {
    elLoading.textContent = "Lỗi khi tải dự báo.";
  }
}

// ==========================
// ZONES
// ==========================
async function loadZones() {
  elStatus.textContent = "⏳ Loading zones...";
  const resp = await fetchJson(ctxPath + "/api/zones");

  const zones = Array.isArray(resp) ? resp : (resp.data || []);
  elZone.innerHTML = "";

  zones.forEach(z => {
    const opt = document.createElement("option");
    opt.value = z.zoneId;
    opt.textContent = z.zoneName + " (" + z.cityName + ")";
    elZone.appendChild(opt);
  });

  elStatus.textContent = "";
}

// ==========================
// WEATHER CHART
// ==========================
async function loadChart() {
  const zoneId = elZone.value;
  const metric = elMetric.value;
  const limit = elLimit.value;

  if (!zoneId) return;

  elStatus.textContent = "⏳ Loading data...";
  const data = await fetchJson(
    ctxPath + "/api/weather?zoneId=" + encodeURIComponent(zoneId)
      + "&metric=" + encodeURIComponent(metric)
      + "&limit=" + encodeURIComponent(limit)
  );

  if (!data.labels || data.labels.length === 0) {
    elStatus.textContent = "⚠️ No weather logs.";
    if (chart) chart.destroy();
    updateStats([]);
    return;
  }

  // ✅ Đảo thứ tự: hôm nay -> lùi về quá khứ
  const labels = [...data.labels].reverse();                 // YYYY-MM-DD
  const vals = [...data.values].map(Number).reverse();

  elStatus.textContent = "";
  elMeta.textContent = metricLabel(metric) + " • " + labels.length + " points";
  updateStats(vals);

  if (chart) chart.destroy();

  chart = new Chart(document.getElementById("chart"), {
    type: "line",
    data: {
      labels: labels,
      datasets: [{
        label: metricLabel(metric),
        data: vals,
        borderColor: '#667eea',
        backgroundColor: 'rgba(102,126,234,0.1)',
        fill: true,
        tension: 0.4
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        x: {
          ticks: {
            autoSkip: true,
            maxTicksLimit: 10,   // 8-12 tùy thích
            maxRotation: 0,
            minRotation: 0,
            // ✅ Giữ nguyên full YYYY-MM-DD
            callback: function(value) {
              return this.getLabelForValue(value);
            }
          }
        },
        y: {
          ticks: {
            callback: function(val) { return val; }
          }
        }
      }
    }
  });
}

// ==========================
// EVENTS
// ==========================
document.getElementById("btnLoad").addEventListener("click", () => {
  loadChart();
  loadForecast(elZone.value);
});

elZone.addEventListener("change", () => {
  loadChart();
  loadForecast(elZone.value);
});

elMetric.addEventListener("change", loadChart);

// ==========================
// INIT
// ==========================
(async function () {
  try {
    await loadZones();
    await loadChart();
    loadForecast(elZone.value);
  } catch (e) {
    elStatus.textContent = "❌ Error: " + e.message;
  }
})();
</script>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />