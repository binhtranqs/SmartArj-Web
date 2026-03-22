/**
 * dashboard-forecast-renderer.js
 * Handles VIP forecast: API fetch, day-grid cards, dual-axis chart.
 * Depends on: ctxPath (global), Chart.js
 */

function _loadForecast(zoneId) {
  const fLoading   = document.getElementById('forecastLoading');
  const fContainer = document.getElementById('forecastContainer');
  const fGrid      = document.getElementById('forecastGrid');
  if (!fLoading || !fContainer || !fGrid) return;

  fLoading.style.display   = 'block';
  fContainer.style.display = 'none';

  fetch(ctxPath + '/api/forecast?zoneId=' + zoneId)
    .then(r => r.json())
    .then(json => {
      fLoading.style.display = 'none';
      if (json.status !== 'success' || !json.data?.length) {
        fLoading.style.display = 'block';
        fLoading.innerHTML = '<div style="color:var(--danger);font-weight:600;">⚠️ '
          + (json.error || json.message || 'Không có dữ liệu dự báo.') + '</div>';
        return;
      }
      _renderForecastGrid(fGrid, json.data);
      _renderForecastChart(json.data);
      fContainer.style.display = 'block';
    })
    .catch(err => {
      fLoading.style.display = 'block';
      fLoading.textContent   = '❌ Lỗi tải dự báo: ' + err.message;
    });
}

function _renderForecastGrid(grid, days) {
  grid.innerHTML = '';
  days.forEach(day => {
    const card = document.createElement('div');
    card.style.cssText = 'background:var(--bg-secondary);border-radius:12px;padding:1rem;text-align:center;';
    card.innerHTML =
      `<div style="font-size:1.8rem">${day.icon || '🌤️'}</div>
       <div style="font-size:.75rem;color:var(--text-secondary);margin:.25rem 0">${day.date}</div>
       <div style="font-weight:700;font-size:1rem">${day.temperature.toFixed(1)}°C</div>
       <div style="font-size:.75rem;color:var(--text-secondary)">${day.condition || ''}</div>
       <div style="font-size:.75rem;margin-top:.25rem">
         💧 ${day.humidity.toFixed(1)}% &nbsp; 🌧️ ${Math.max(0, day.rainfall).toFixed(1)}mm
       </div>`;
    grid.appendChild(card);
  });
}

function _renderForecastChart(days) {
  const canvas = document.getElementById('forecastChart');
  if (!canvas) return;
  if (window._forecastChart) window._forecastChart.destroy();
  window._forecastChart = new Chart(canvas, {
    type: 'line',
    data: {
      labels: days.map(d => d.date),
      datasets: [
        { label: 'Nhiệt độ (°C)', data: days.map(d => d.temperature),
          borderColor: '#EF4444', backgroundColor: 'rgba(239,68,68,.1)',
          tension: 0.4, fill: true, borderWidth: 2 },
        { label: 'Độ ẩm (%)', data: days.map(d => d.humidity),
          borderColor: '#3B82F6', backgroundColor: 'rgba(59,130,246,.1)',
          tension: 0.4, fill: true, borderWidth: 2 }
      ]
    },
    options: {
      responsive: true, maintainAspectRatio: false,
      plugins: { legend: { position: 'top' } },
      scales: {
        x: { grid: { display: false } },
        y: { grid: { color: 'rgba(0,0,0,.05)' } }
      }
    }
  });
}
