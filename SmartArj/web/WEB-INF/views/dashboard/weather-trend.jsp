<%@ page contentType="text/html; charset=UTF-8" %>
<!-- Weather Trend chart + Quick Stats panel -->
<div class="wt-layout">

  <!-- Chart Card -->
  <div class="wt-chart-card">
    <div class="wt-chart-header">
      <div>
        <h2 class="wt-title">
          <i data-lucide="line-chart" width="18" height="18"></i> Weather Trend
        </h2>
        <span id="metaText" class="wt-meta-tag">—</span>
      </div>
      <div class="wt-chips">
        <button class="wt-chip active" data-metric="temperature">🌡️ Nhiệt độ</button>
        <button class="wt-chip" data-metric="humidity">💧 Độ ẩm</button>
        <button class="wt-chip" data-metric="rainfall">🌧️ Mưa</button>
        <button class="wt-chip" data-metric="wind">💨 Gió</button>
        <button class="wt-chip" data-metric="radiation">☀️ Bức xạ</button>
      </div>
    </div>
    <div class="wt-canvas-wrap">
      <canvas id="chart"></canvas>
    </div>
  </div>

  <!-- Stats Panel -->
  <div class="wt-stats-panel">
    <div class="wt-stats-hd">Quick Stats</div>
    <div class="wt-stats-sub">Thống kê từ dữ liệu hiện tại</div>

    <div class="wt-stat-block" style="background:rgba(59,130,246,.07);">
      <div class="wt-stat-icon" style="background:rgba(59,130,246,.15);color:#3B82F6;">
        <i data-lucide="arrow-down-to-line" width="18" height="18"></i>
      </div>
      <div>
        <div class="wt-stat-lbl" style="color:#3B82F6;">Minimum</div>
        <div class="wt-stat-val" id="minVal" style="color:#3B82F6;">—</div>
      </div>
    </div>

    <div class="wt-stat-block" style="background:rgba(239,68,68,.07);">
      <div class="wt-stat-icon" style="background:rgba(239,68,68,.15);color:#EF4444;">
        <i data-lucide="arrow-up-to-line" width="18" height="18"></i>
      </div>
      <div>
        <div class="wt-stat-lbl" style="color:#EF4444;">Maximum</div>
        <div class="wt-stat-val" id="maxVal" style="color:#EF4444;">—</div>
      </div>
    </div>

    <div class="wt-stat-block" style="background:rgba(45,106,79,.07);">
      <div class="wt-stat-icon" style="background:rgba(45,106,79,.15);color:var(--primary);">
        <i data-lucide="activity" width="18" height="18"></i>
      </div>
      <div>
        <div class="wt-stat-lbl" style="color:var(--primary);">Trung bình</div>
        <div class="wt-stat-val" id="avgVal" style="color:var(--primary);">—</div>
      </div>
    </div>

    <!-- Range Bar -->
    <div class="wt-range-section">
      <div class="wt-range-lbl">Phạm vi giá trị</div>
      <div class="wt-range-track">
        <div class="wt-range-fill" id="rangeBarFill"></div>
        <div class="wt-range-avg-dot" id="rangeAvgDot"></div>
      </div>
      <div class="wt-range-endpoints">
        <span id="rangeLbMin">—</span>
        <span style="color:var(--primary);font-weight:700;">▲ avg</span>
        <span id="rangeLbMax">—</span>
      </div>
    </div>
  </div>

</div>
