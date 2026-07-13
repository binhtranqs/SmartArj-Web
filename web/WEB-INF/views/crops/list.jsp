<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <jsp:include page="/WEB-INF/views/common/header.jsp">
            <jsp:param name="title" value="Crops" />
            <jsp:param name="page" value="crops" />
        </jsp:include>

        <div class="page-container">
            <!-- Page Header -->
            <div class="page-header">
                <div>
                    <h1 class="page-title">
                        🌾 Crops
                    </h1>
                    <p class="page-subtitle">Quản lý các loại cây trồng trong hệ thống</p>
                </div>
                <a class="btn btn-primary btn-lg" href="${pageContext.request.contextPath}/crops?action=new">
                    + New Crop
                </a>
            </div>

            <!-- Crops Grid -->
            <c:choose>
                <c:when test="${empty crops}">
                    <!-- Empty State -->
                    <div class="card" style="padding: 4rem 2rem; text-align: center;">
                        <div style="font-size: 4rem; margin-bottom: 1rem;">🌾</div>
                        <h3 style="color: var(--text-primary); margin-bottom: 0.5rem;">Chưa có cây trồng nào</h3>
                        <p style="color: var(--text-secondary); margin-bottom: 2rem;">
                            Thêm cây trồng đầu tiên để bắt đầu quản lý
                        </p>
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/crops?action=new">
                            + Thêm Cây Trồng Mới
                        </a>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="grid grid-3">
                        <c:forEach var="c" items="${crops}">
                            <div class="item-card card-hover-lift">
                                <!-- Icon -->
                                <span class="item-card-icon">🌾</span>

                                <!-- Title -->
                                <h3 class="item-card-title">
                                    <c:out value="${c.cropName}" />
                                </h3>

                                <!-- Subtitle -->
                                <p class="item-card-subtitle">
                                    <span class="badge badge-success">
                                        📍
                                        <c:out value="${c.zone.zoneName}" />
                                    </span>
                                </p>

                                <!-- Info -->
                                <div class="item-card-info">
                                    <div class="item-card-info-row">
                                        <span class="item-card-label">Crop ID</span>
                                        <span class="badge badge-primary">#${c.cropId}</span>
                                    </div>
                                    <div class="item-card-info-row">
                                        <span class="item-card-label">Min Temperature</span>
                                        <span class="item-card-value" style="color: var(--info);">
                                            ${c.minTemp}°C
                                        </span>
                                    </div>
                                    <div class="item-card-info-row">
                                        <span class="item-card-label">Max Temperature</span>
                                        <span class="item-card-value" style="color: var(--danger);">
                                            ${c.maxTemp}°C
                                        </span>
                                    </div>
                                    <div class="item-card-info-row">
                                        <span class="item-card-label">Temperature Range</span>
                                        <c:choose>
                                            <c:when test="${c.maxTemp - c.minTemp <= 10}">
                                                <span class="badge badge-success">Narrow</span>
                                            </c:when>
                                            <c:when test="${c.maxTemp - c.minTemp <= 20}">
                                                <span class="badge badge-warning">Medium</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge badge-danger">Wide</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <!-- Actions -->
                                <div class="item-card-actions">
                                    <a class="btn btn-outline btn-sm" style="flex: 1;"
                                        href="${pageContext.request.contextPath}/crops?action=edit&id=${c.cropId}">
                                        ✏️ Edit
                                    </a>
                                    <a class="btn btn-danger btn-sm" style="flex: 1;"
                                        onclick="return confirm('Xóa cây trồng ${c.cropName}?');"
                                        href="${pageContext.request.contextPath}/crops?action=delete&id=${c.cropId}">
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