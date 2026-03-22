/**
 * dashboard-chart.js
 * Core chart logic: zone loader, chart renderer, stats panel, metric chips.
 * Depends on: dashboard-chart-config.js, dashboard-forecast-renderer.js, Chart.js, ctxPath (global)
 */

// ─── DOM helpers ──────────────────────────────────────────────────────────────
const elZone   = () => document.getElementById('zoneId');
const elMetric = () => document.getElementById('metric');
const elLimit  = () => document.getElementById('limit');
const elStatus = () => document.getElementById('statusText');
const elMeta   = () => document.getElementById('metaText');
const elMin    = () => document.getElementById('minVal');
const elMax    = () => document.getElementById('maxVal');
const elAvg    = () => document.getElementById('avgVal');

let activeChart;

// ─── Fetch helper ─────────────────────────────────────────────────────────────
async function fetchJson(url) {
  const res = await fetch(url);
  if (!res.ok) throw new Error('HTTP ' + res.status);
  return res.json();
}

// ─── Animated count-up ────────────────────────────────────────────────────────
function countUp(el, target) {
  if (!el) return;
  const from = parseFloat(el.textContent) || 0;
  const t0   = performance.now();
  (function tick(now) {
    const p = Math.min((now - t0) / 580, 1);
    el.textContent = (from + (target - from) * (1 - Math.pow(1 - p, 3))).toFixed(1);
    if (p < 1) requestAnimationFrame(tick);
  })(t0);
}

// ─── Stats panel + range bar ──────────────────────────────────────────────────
function updateStats(values) {
  const rFill = document.getElementById('rangeBarFill');
  const rDot  = document.getElementById('rangeAvgDot');
  const rMin  = document.getElementById('rangeLbMin');
  const rMax  = document.getElementById('rangeLbMax');

  if (!values?.length) {
    [elMin(), elMax(), elAvg()].forEach(el => { if (el) el.textContent = '—'; });
    if (rFill) rFill.style.width = '0%';
    if (rDot)  rDot.style.left   = '50%';
    if (rMin)  rMin.textContent   = '—';
    if (rMax)  rMax.textContent   = '—';
    return;
  }

  const nums  = values.map(Number);
  const min   = Math.min(...nums);
  const max   = Math.max(...nums);
  const avg   = nums.reduce((a, b) => a + b, 0) / nums.length;
  const range = max - min;

  countUp(elMin(), min);
  countUp(elMax(), max);
  countUp(elAvg(), avg);

  if (rFill) rFill.style.width = '100%';
  if (rDot)  rDot.style.left   = range > 0 ? ((avg - min) / range * 100).toFixed(1) + '%' : '50%';
  if (rMin)  rMin.textContent  = min.toFixed(1);
  if (rMax)  rMax.textContent  = max.toFixed(1);
}

// ─── Metric chips sync ────────────────────────────────────────────────────────
function syncChips(metric) {
  document.querySelectorAll('.wt-chip').forEach(c => {
    c.classList.toggle('active', c.dataset.metric === metric);
  });
}

// ─── Zone loader ──────────────────────────────────────────────────────────────
async function loadZones() {
  elStatus().textContent = '⏳ Đang tải zones...';
  const zones = await fetchJson(ctxPath + '/api/zones');
  const sel   = elZone();
  sel.innerHTML = '';
  zones.forEach(z => {
    const opt       = document.createElement('option');
    opt.value       = z.zoneId;
    opt.textContent = z.zoneName + ' (' + z.cityName + ')';
    sel.appendChild(opt);
  });
  elStatus().textContent = zones.length === 0
    ? '⚠️ Chưa có zone nào. Vui lòng tạo zone trước.' : '';
}

// ─── Chart loader ─────────────────────────────────────────────────────────────
async function loadChart() {
  const zoneId = elZone().value;
  const metric = elMetric().value;
  const limit  = elLimit().value;

  if (!zoneId) { elStatus().textContent = '⚠️ Vui lòng chọn zone.'; return; }

  elStatus().textContent = '⏳ Đang tải dữ liệu...';
  const data = await fetchJson(
    ctxPath + '/api/weather?zoneId=' + zoneId + '&metric=' + metric + '&limit=' + limit
  );

  if (!data.labels?.length) {
    elStatus().textContent = '⚠️ Không có dữ liệu cho zone này.';
    if (activeChart) activeChart.destroy();
    updateStats([]);
    return;
  }

  const vals  = data.values.map(Number);
  const label = METRIC_LABELS[metric] || metric;
  const cfg   = METRIC_CONFIG[metric] || { color: '#2D6A4F', bg: 'rgba(45,106,79,.12)', point: '#2D6A4F' };

  elStatus().textContent = '';
  elMeta().textContent   = label + ' · ' + vals.length + ' điểm';
  syncChips(metric);
  updateStats(vals);

  if (activeChart) activeChart.destroy();
  activeChart = new Chart(document.getElementById('chart'), {
    type: 'line',
    data: {
      labels: data.labels,
      datasets: [{
        label: label, data: vals,
        borderColor: cfg.color, backgroundColor: cfg.bg,
        pointBackgroundColor: cfg.point, pointBorderColor: '#fff',
        pointBorderWidth: 2, pointRadius: 3, pointHoverRadius: 6,
        tension: 0.4, borderWidth: 2.5, fill: true
      }]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      animation: { duration: 500, easing: 'easeOutQuart' },
      plugins: {
        legend: { display: true, position: 'top',
          labels: { font: { size: 12, weight: '700' }, padding: 14, usePointStyle: true } },
        tooltip: { backgroundColor: 'rgba(15,30,20,.88)', padding: 12,
          titleFont: { size: 13, weight: '700' }, bodyFont: { size: 12 },
          borderColor: cfg.color, borderWidth: 1, cornerRadius: 10 }
      },
      scales: {
        x: { ticks: { maxTicksLimit: 8, font: { size: 11 }, color: '#8BA898' }, grid: { display: false } },
        y: { grid: { color: 'rgba(45,106,79,.06)' }, ticks: { font: { size: 11 }, color: '#8BA898' } }
      }
    }
  });

  _loadForecast(zoneId);
}

// ─── Init ─────────────────────────────────────────────────────────────────────
document.addEventListener('DOMContentLoaded', async function () {
  document.getElementById('btnLoad').addEventListener('click', loadChart);
  elZone().addEventListener('change', loadChart);
  elMetric().addEventListener('change', function () { syncChips(this.value); });

  document.querySelectorAll('.wt-chip').forEach(chip => {
    chip.addEventListener('click', function () {
      const m = this.dataset.metric;
      if (!m) return;
      elMetric().value = m;
      syncChips(m);
      loadChart();
    });
  });

  try {
    await loadZones();
    await loadChart();
  } catch (e) {
    elStatus().textContent = '❌ Lỗi: ' + e.message;
  }
});
