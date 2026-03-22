<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

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
            <div class="empty-state">
                <div style="font-size: 5rem; margin-bottom: 1rem;">🌾</div>
                <h3 style="color: var(--text-primary); margin-bottom: 0.5rem; font-size: 1.5rem; font-weight: 700;">Chưa
                    có zone nào</h3>
                <p style="color: var(--text-secondary); margin-bottom: 2rem; max-width: 400px; line-height: 1.5;">
                    Bạn chưa định cấu hình bất kỳ vùng trồng trọt nào. Hãy tạo zone đầu tiên để bắt đầu theo dõi thời tiết
                    và đất đai.
                </p>
                <a class="btn btn-primary btn-lg" href="${pageContext.request.contextPath}/zones?action=new">
                    <i data-lucide="plus" width="18" height="18"></i> Tạo Zone Mới
                </a>
            </div>
        </c:when>
        <c:otherwise>
            <div class="grid grid-3" 
                 style="
                 grid-template-columns: repeat(auto-fill, minmax(300px, 360px));
                 justify-content: center;
                 gap: 70px;
                 ">
                <c:forEach var="dto" items="${zones}">
                    <%-- Map cityName → local image --%>
                    <c:set var="cityLower" value="${fn:toLowerCase(dto.cityName)}" />
                    <c:choose>
                        <c:when test="${fn:contains(cityLower, 'nội') or fn:contains(cityLower, 'hanoi')}">
                            <c:set var="cityImg" value="hanoi.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'nẵng') or fn:contains(cityLower, 'danang')}">
                            <c:set var="cityImg" value="danang.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'lạt') or fn:contains(cityLower, 'dalat')}">
                            <c:set var="cityImg" value="dalat.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'thơ') or fn:contains(cityLower, 'cantho')}">
                            <c:set var="cityImg" value="cantho.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'phòng') or fn:contains(cityLower, 'haiphong')}">
                            <c:set var="cityImg" value="haiphong.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'minh') or fn:contains(cityLower, 'hcm')}">
                            <c:set var="cityImg" value="hcm.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'huế') or fn:contains(cityLower, 'hue')}">
                            <c:set var="cityImg" value="hue.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'trang') or fn:contains(cityLower, 'nhatrang')}">
                            <c:set var="cityImg" value="nhatrang.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'pa') or fn:contains(cityLower, 'sapa')}">
                            <c:set var="cityImg" value="sapa.png" />
                        </c:when>
                        <c:when test="${fn:contains(cityLower, 'lắk') or fn:contains(cityLower, 'daklak')}">
                            <c:set var="cityImg" value="daklak.png" />
                        </c:when>
                        <c:otherwise>
                            <c:set var="cityImg" value="" />
                        </c:otherwise>
                    </c:choose>

                    <div class="item-card card-hover-lift" style="position: relative; overflow: hidden; padding: 0;">

                        <%-- Card Cover: dùng div background thay img để tránh broken image --%>
                        <c:choose>
                            <c:when test="${not empty cityImg}">
                                <div class="card-cover" style="background-image: url('${pageContext.request.contextPath}/assets/cities/${cityImg}'); background-size: cover; background-position: center; height: 148px;"></div>
                            </c:when>
                            <c:otherwise>
                                <%-- Gradient fallback khi không có ảnh city --%>
                                <div class="card-cover" style="background: linear-gradient(135deg, #2D6A4F 0%, #52B788 60%, #74C69D 100%); height: 148px; display: flex; align-items: center; justify-content: center; font-size: 3rem;">🌾</div>
                            </c:otherwise>
                        </c:choose>

                        <!-- Status Badge -->
                        <div
                            style="position: absolute; top: 0; right: 0; padding: 0.5rem 1rem;
                            background: ${dto.status == 'Danger' ? 'var(--danger)' : (dto.status == 'Warning' ? 'var(--warning)' : 'var(--success)')};
                            color: white; border-bottom-left-radius: var(--radius-xl); font-weight: bold; font-size: 0.8rem; border-top-right-radius: var(--radius-xl); z-index: 2; box-shadow: -2px 2px 10px rgba(0,0,0,0.1);">
                            ${dto.status}
                        </div>

                        <div class="item-card-body">
                            <!-- Header -->
                            <div style="display: flex; gap: 1rem; align-items: start; margin-bottom: 1rem;">
                                <div class="item-card-icon"
                                     style="font-size: 2.5rem; background: var(--bg-surface); width: 60px; height: 60px; display: flex; align-items: center; justify-content: center; border-radius: 50%; box-shadow: var(--shadow-md); margin-top: -45px; z-index: 2; border: 2px solid white; position: relative;">
                                    ${dto.currentRain > 0 ? '🌧️' : (dto.currentTemp > 30 ? '☀️' : '⛅')}
                                </div>
                                <div style="flex: 1; padding-top: 0.5rem;">
                                    <h3 class="item-card-title" style="margin-bottom: 0.25rem;">
                                        <c:out value="${dto.zone.zoneName}" />
                                    </h3>
                                    <p class="item-card-subtitle"
                                       style="margin-bottom: 0; display: flex; align-items: center; gap: 4px;">
                                        <i data-lucide="map-pin" width="14" height="14"></i> ${dto.cityName} <span
                                            style="opacity: 0.5; margin: 0 4px;">•</span> <i data-lucide="sprout" width="14"
                                            height="14"></i> ${dto.cropName != null ? dto.cropName : 'Chưa trồng'}
                                    </p>
                                </div>
                            </div>

                            <!-- Weather Snapshot -->
                            <div
                                style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin-bottom: 1rem;
                                background: rgba(255, 255, 255, 0.92); padding: 0.75rem; border-radius: var(--radius-md); border: 1px solid var(--border-subtle); backdrop-filter: blur(4px);">
                                <div style="font-size: 0.9rem;">🌡 <b>
                                        <fmt:formatNumber value="${dto.currentTemp}" maxFractionDigits="1" />°C
                                    </b></div>
                                <div style="font-size: 0.9rem;">💧 <b>
                                        <fmt:formatNumber value="${dto.currentHumidity}" maxFractionDigits="1" />%
                                    </b></div>
                                <div style="font-size: 0.9rem;">💨 <b>
                                        <fmt:formatNumber value="${dto.currentWind}" maxFractionDigits="1" /> km/h
                                    </b></div>
                                <div style="font-size: 0.9rem;">🌧 <b>
                                        <fmt:formatNumber value="${dto.currentRain}" maxFractionDigits="1" /> mm
                                    </b></div>
                            </div>

                            <!-- Sparkline (Placeholder for real chart implementation) -->
                            <c:if test="${not empty dto.sparklineData}">
                                <div
                                    style="height: 40px; display: flex; align-items: flex-end; gap: 2px; margin-bottom: 1rem; opacity: 0.7;">
                                    <c:forEach var="val" items="${dto.sparklineData}">
                                        <div
                                            style="flex: 1; background: #2D6A4F; height: ${val * 2}%; max-height: 100%; border-radius: 2px;">
                                        </div>
                                    </c:forEach>
                                </div>
                            </c:if>

                            <!-- Footer Info -->
                            <div
                                style="display: flex; justify-content: space-between; align-items: center; font-size: 0.85rem; color: #6B7280; border-top: 1px solid #E5E7EB; padding-top: 0.75rem;">
                                <span style="display: flex; align-items: center; gap: 4px;"><i data-lucide="clock" width="12"
                                                                                               height="12"></i> Updated: ${dto.lastUpdated}</span>
                                <span style="display: flex; align-items: center; gap: 4px;"><i data-lucide="bell" width="12"
                                                                                               height="12"></i> Alerts: <b
                                                                                               style="color: ${dto.alertCount > 0 ? 'var(--danger)' : 'var(--text-muted)'}">${dto.alertCount}</b></span>
                            </div>

                            <!-- Actions -->
                            <div class="item-card-actions" style="margin-top: 1rem; display: flex; gap: 0.75rem;">
                                <a class="btn btn-outline btn-sm" style="flex: 1; justify-content: center;"
                                   href="${pageContext.request.contextPath}/zones?action=edit&id=${dto.zone.zoneId}">
                                    <i data-lucide="edit-3" width="14" height="14"></i> Sửa
                                </a>
                                <a class="btn btn-danger btn-sm" style="flex: 1; justify-content: center;"
                                   onclick="return confirm('Xóa zone ${dto.zone.zoneName}?');"
                                   href="${pageContext.request.contextPath}/zones?action=delete&id=${dto.zone.zoneId}">
                                    <i data-lucide="trash-2" width="14" height="14"></i> Xóa
                                </a>
                            </div>
                        </div> <!-- End .item-card-body -->
                    </div>
                </c:forEach>
            </div>
        </c:otherwise>
    </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />