?<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!-- Quick Stats: 4 real-time sensor cards -->
<div class="qs-grid">

  <div class="qs-card">
    <div class="qs-live"><span class="qs-dot"></span>LIVE</div>
    <div class="qs-card-inner">
      <div class="qs-icon" style="background:rgba(245,158,11,.12);color:#F59E0B;">
        <i data-lucide="thermometer" width="22" height="22"></i>
      </div>
      <div>
        <div class="qs-val" style="color:#F59E0B;">
          <fmt:formatNumber value="${currentTemp}" maxFractionDigits="1"/><span class="qs-unit">°C</span>
        </div>
        <div class="qs-lbl">Nhiệt độ</div>
      </div>
    </div>
    <div class="qs-bar-wrap">
      <div class="qs-bar-fill" style="width:68%;background:linear-gradient(90deg,#F59E0B,#EF4444)"></div>
    </div>
  </div>

  <div class="qs-card">
    <div class="qs-live"><span class="qs-dot"></span>LIVE</div>
    <div class="qs-card-inner">
      <div class="qs-icon" style="background:rgba(59,130,246,.12);color:#3B82F6;">
        <i data-lucide="droplets" width="22" height="22"></i>
      </div>
      <div>
        <div class="qs-val" style="color:#3B82F6;">
          <fmt:formatNumber value="${currentHumid}" maxFractionDigits="1"/><span class="qs-unit">%</span>
        </div>
        <div class="qs-lbl">Độ ẩm</div>
      </div>
    </div>
    <div class="qs-bar-wrap">
      <div class="qs-bar-fill" style="width:74%;background:linear-gradient(90deg,#3B82F6,#06B6D4)"></div>
    </div>
  </div>

  <div class="qs-card">
    <div class="qs-live"><span class="qs-dot"></span>LIVE</div>
    <div class="qs-card-inner">
      <div class="qs-icon" style="background:rgba(14,165,233,.12);color:#0EA5E9;">
        <i data-lucide="cloud-rain" width="22" height="22"></i>
      </div>
      <div>
        <div class="qs-val" style="color:#0EA5E9;">
          <fmt:formatNumber value="${currentRain}" maxFractionDigits="1"/><span class="qs-unit">mm</span>
        </div>
        <div class="qs-lbl">Lượng mưa</div>
      </div>
    </div>
    <div class="qs-bar-wrap">
      <div class="qs-bar-fill" style="width:32%;background:linear-gradient(90deg,#0EA5E9,#6366F1)"></div>
    </div>
  </div>

  <div class="qs-card">
    <div class="qs-live"><span class="qs-dot"></span>LIVE</div>
    <div class="qs-card-inner">
      <div class="qs-icon" style="background:rgba(139,92,246,.12);color:#8B5CF6;">
        <i data-lucide="wind" width="22" height="22"></i>
      </div>
      <div>
        <div class="qs-val" style="color:#8B5CF6;">
          <fmt:formatNumber value="${currentWind}" maxFractionDigits="1"/><span class="qs-unit">km/h</span>
        </div>
        <div class="qs-lbl">Tốc độ gió</div>
      </div>
    </div>
    <div class="qs-bar-wrap">
      <div class="qs-bar-fill" style="width:45%;background:linear-gradient(90deg,#8B5CF6,#EC4899)"></div>
    </div>
  </div>

</div>

