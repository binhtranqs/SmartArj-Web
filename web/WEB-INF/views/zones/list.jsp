<%@ page contentType="text/html; charset=UTF-8" %>
  <%@ taglib prefix="c" uri="jakarta.tags.core" %>

    <jsp:include page="/WEB-INF/views/common/header.jsp">
      <jsp:param name="title" value="Zones" />
      <jsp:param name="page" value="zones" />
    </jsp:include>

    <div class="page-container">
      <!-- Page Header -->
      <div class="page-header">
        <div>
          <h1 class="page-title">
            🌍 Zones
          </h1>
          <p class="page-subtitle">Quản lý các vùng trồng trọt của bạn</p>
        </div>
        <a class="btn btn-primary btn-lg" href="${pageContext.request.contextPath}/zones?action=new">
          + New Zone
        </a>
      </div>

      <!-- Zones Grid -->
      <c:choose>
        <c:when test="${empty zones}">
          <!-- Empty State -->
          <div class="card" style="padding: 4rem 2rem; text-align: center;">
            <div style="font-size: 4rem; margin-bottom: 1rem;">🌍</div>
            <h3 style="color: var(--text-primary); margin-bottom: 0.5rem;">Chưa có zone nào</h3>
            <p style="color: var(--text-secondary); margin-bottom: 2rem;">
              Tạo zone đầu tiên để bắt đầu quản lý vùng trồng
            </p>
            <a class="btn btn-primary" href="${pageContext.request.contextPath}/zones?action=new">
              + Tạo Zone Mới
            </a>
          </div>
        </c:when>
        <c:otherwise>
          <div class="grid grid-3">
            <c:forEach var="dto" items="${zones}">
              <div class="item-card card-hover-lift" style="position: relative; overflow: hidden;">
                <!-- Status Badge -->
                <div
                  style="position: absolute; top: 0; right: 0; padding: 0.5rem 1rem; 
                            background: ${dto.status == 'Danger' ? '#EF4444' : (dto.status == 'Warning' ? '#F59E0B' : '#10B981')}; 
                            color: white; border-bottom-left-radius: var(--radius-xl); font-weight: bold; font-size: 0.8rem;">
                  ${dto.status}
                </div>

                <!-- Header -->
                <div style="display: flex; gap: 1rem; align-items: start; margin-bottom: 1rem;">
                  <span class="item-card-icon" style="font-size: 2.5rem;">
                    ${dto.currentRain > 0 ? '🌧️' : (dto.currentTemp > 30 ? '☀️' : '⛅')}
                  </span>
                  <div>
                    <h3 class="item-card-title" style="margin-bottom: 0.25rem;">
                      <c:out value="${dto.zone.zoneName}" />
                    </h3>
                    <p class="item-card-subtitle" style="margin-bottom: 0;">
                      📍 ${dto.cityName} • 🌱 ${dto.cropName != null ? dto.cropName : 'Chưa trồng'}
                    </p>
                  </div>
                </div>

                <!-- Weather Snapshot -->
                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin-bottom: 1rem; 
                            background: #F3F4F6; padding: 0.75rem; border-radius: var(--radius-md);">
                  <div style="font-size: 0.9rem;">🌡 <b>${dto.currentTemp}°C</b></div>
                  <div style="font-size: 0.9rem;">💧 <b>${dto.currentHumidity}%</b></div>
                  <div style="font-size: 0.9rem;">💨 <b>${dto.currentWind} km/h</b></div>
                  <div style="font-size: 0.9rem;">🌧 <b>${dto.currentRain} mm</b></div>
                </div>

                <!-- Sparkline (Placeholder for real chart implementation) -->
                <c:if test="${not empty dto.sparklineData}">
                  <div
                    style="height: 40px; display: flex; align-items: flex-end; gap: 2px; margin-bottom: 1rem; opacity: 0.7;">
                    <c:forEach var="val" items="${dto.sparklineData}">
                      <div
                        style="flex: 1; background: #667eea; height: ${val * 2}%; max-height: 100%; border-radius: 2px;">
                      </div>
                    </c:forEach>
                  </div>
                </c:if>

                <!-- Footer Info -->
                <div
                  style="display: flex; justify-content: space-between; align-items: center; font-size: 0.85rem; color: #6B7280; border-top: 1px solid #E5E7EB; padding-top: 0.75rem;">
                  <span>⏱ Updated: ${dto.lastUpdated}</span>
                  <span>🔔 Alerts: <b
                      style="color: ${dto.alertCount > 0 ? '#EF4444' : '#6B7280'}">${dto.alertCount}</b></span>
                </div>

                <!-- Actions -->
                <div class="item-card-actions" style="margin-top: 1rem;">
                  <a class="btn btn-outline btn-sm" style="flex: 1;"
                    href="${pageContext.request.contextPath}/zones?action=edit&id=${dto.zone.zoneId}">
                    ✏️ Edit
                  </a>
                  <a class="btn btn-danger btn-sm" style="flex: 1;"
                    onclick="return confirm('Xóa zone ${dto.zone.zoneName}?');"
                    href="${pageContext.request.contextPath}/zones?action=delete&id=${dto.zone.zoneId}">
                    🗑️ Delete
                  </a>
                </div>
              </div>
            </c:forEach>
          </div>
        </c:otherwise>
      </c:choose>
    </div>

    <jsp:include page="/WEB-INF/views/common/footer.jsp" />