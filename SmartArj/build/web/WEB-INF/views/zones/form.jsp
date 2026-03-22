<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp">
  <jsp:param name="title" value="${editing ? 'Sửa Zone' : 'Tạo Zone Mới'}" />
  <jsp:param name="page" value="zones" />
</jsp:include>

<c:set var="z" value="${zone}" />

<div class="page-container">

  <%-- Page Header --%>
  <div class="page-header">
    <div>
      <h1 class="page-title">
        <c:choose>
          <c:when test="${editing}">✏️ Sửa Zone</c:when>
          <c:otherwise>🌱 Tạo Zone Mới</c:otherwise>
        </c:choose>
      </h1>
      <p class="page-subtitle">
        <c:choose>
          <c:when test="${editing}">Cập nhật thông tin vùng trồng trọt</c:when>
          <c:otherwise>Chọn thành phố để bắt đầu theo dõi thời tiết &amp; cây trồng</c:otherwise>
        </c:choose>
      </p>
    </div>
    <a href="${pageContext.request.contextPath}/zones" class="btn btn-outline">
      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"
           fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M19 12H5M12 19l-7-7 7-7"/>
      </svg>
      Quay lại
    </a>
  </div>

  <%-- Form Card --%>
  <div style="max-width: 600px; margin: 0 auto;">
    <div class="zone-form-card">

      <%-- Icon header --%>
      <div class="zone-form-icon-header">
        <div class="zone-form-icon">🗺️</div>
        <div>
          <div style="font-weight: 700; font-size: 1.1rem; color: var(--text-primary);">
            <c:choose>
              <c:when test="${editing}">Cập nhật vùng trồng</c:when>
              <c:otherwise>Thêm vùng trồng mới</c:otherwise>
            </c:choose>
          </div>
          <div style="font-size: 0.85rem; color: var(--text-secondary); margin-top: 2px;">
            Hệ thống sẽ tự động lấy dữ liệu thời tiết theo thành phố
          </div>
        </div>
      </div>

      <%-- Error --%>
      <c:if test="${not empty error}">
        <div class="zone-form-alert zone-form-alert-error">
          <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24"
               fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/>
            <line x1="12" y1="16" x2="12.01" y2="16"/>
          </svg>
          <span>${error}</span>
        </div>
      </c:if>

      <%-- Form --%>
      <form method="post" action="${pageContext.request.contextPath}/zones">
        <c:if test="${editing}">
          <input type="hidden" name="zoneId" value="${z.zoneId}" />
        </c:if>

        <%-- Zone Name --%>
        <div class="zone-form-group">
          <label class="zone-form-label">
            Tên Zone <span style="color: var(--danger);">*</span>
          </label>
          <input
            type="text"
            name="zoneName"
            class="zone-form-input"
            placeholder="Ví dụ: Vườn rau Đà Lạt, Ruộng lúa Cần Thơ..."
            value="<c:out value='${z.zoneName}'/>"
            required
            maxlength="100"
          />
          <div class="zone-form-hint">Đặt tên dễ nhớ cho vùng trồng của bạn</div>
        </div>

        <%-- City Select --%>
        <div class="zone-form-group">
          <label class="zone-form-label">
            Thành phố <span style="color: var(--danger);">*</span>
          </label>
          <div class="zone-form-select-wrapper">
            <svg class="zone-form-select-icon" xmlns="http://www.w3.org/2000/svg" width="18" height="18"
                 viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                 stroke-linecap="round" stroke-linejoin="round">
              <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"/>
              <circle cx="12" cy="10" r="3"/>
            </svg>
            <select name="cityId" class="zone-form-select" required>
              <option value="">-- Chọn thành phố --</option>
              <c:forEach var="city" items="${cities}">
                <option value="${city.cityId}"
                  <c:if test="${z.cityId == city.cityId}">selected</c:if>>
                  ${city.cityName}<c:if test="${not empty city.region}"> (${city.region})</c:if>
                </option>
              </c:forEach>
            </select>
          </div>
          <div class="zone-form-hint">Chọn thành phố gần vùng trồng nhất để lấy dữ liệu thời tiết chính xác</div>
        </div>

        <%-- Info box --%>
        <div class="zone-form-info-box">
          <div style="display: flex; align-items: flex-start; gap: 0.75rem;">
            <span style="font-size: 1.25rem; flex-shrink: 0; margin-top: 2px;">🌤️</span>
            <div>
              <div style="font-weight: 600; font-size: 0.9rem; color: var(--primary); margin-bottom: 4px;">
                Dữ liệu tự động cập nhật
              </div>
              <div style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.5;">
                Sau khi tạo zone, hệ thống sẽ tự động thu thập nhiệt độ, độ ẩm, tốc độ gió và lượng mưa
                theo thời gian thực từ thành phố đã chọn.
              </div>
            </div>
          </div>
        </div>

        <%-- Actions --%>
        <div class="zone-form-actions">
          <a href="${pageContext.request.contextPath}/zones" class="btn btn-outline" style="flex: 1; justify-content: center;">
            Hủy
          </a>
          <button type="submit" class="btn btn-primary" style="flex: 2; justify-content: center;">
            <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24"
                 fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <c:choose>
                <c:when test="${editing}">
                  <path d="M19 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h11l5 5v11a2 2 0 0 1-2 2z"/>
                  <polyline points="17 21 17 13 7 13 7 21"/>
                  <polyline points="7 3 7 8 15 8"/>
                </c:when>
                <c:otherwise>
                  <line x1="12" y1="5" x2="12" y2="19"/>
                  <line x1="5" y1="12" x2="19" y2="12"/>
                </c:otherwise>
              </c:choose>
            </svg>
            <c:choose>
              <c:when test="${editing}">Lưu thay đổi</c:when>
              <c:otherwise>Tạo Zone</c:otherwise>
            </c:choose>
          </button>
        </div>

      </form>
    </div>
  </div>
</div>

<style>
  /* ── Zone Form Card – solid bg chống mờ từ background image ── */
  .zone-form-card {
    background: #ffffff;
    border-radius: 20px;
    padding: 2rem;
    box-shadow:
      0 4px 6px rgba(27, 67, 50, 0.06),
      0 20px 40px rgba(27, 67, 50, 0.12),
      0 0 0 1px rgba(45, 106, 79, 0.08);
    border: 1.5px solid rgba(45, 106, 79, 0.10);
  }

  .zone-form-icon-header {
    display: flex;
    align-items: center;
    gap: 1rem;
    padding-bottom: 1.5rem;
    margin-bottom: 1.75rem;
    border-bottom: 1.5px dashed rgba(45, 106, 79, 0.15);
  }

  .zone-form-icon {
    width: 52px;
    height: 52px;
    background: linear-gradient(135deg, rgba(45,106,79,0.1) 0%, rgba(82,183,136,0.15) 100%);
    border: 1.5px solid rgba(45, 106, 79, 0.18);
    border-radius: 14px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 1.6rem;
    flex-shrink: 0;
  }

  .zone-form-group {
    margin-bottom: 1.5rem;
  }

  .zone-form-label {
    display: block;
    font-weight: 700;
    font-size: 0.9rem;
    color: var(--text-primary);
    margin-bottom: 0.5rem;
    letter-spacing: 0.01em;
  }

  .zone-form-input {
    width: 100%;
    padding: 0.8rem 1rem;
    border: 1.5px solid rgba(45, 106, 79, 0.20);
    border-radius: 12px;
    background: #fafff9;
    color: var(--text-primary);
    font-size: 0.95rem;
    font-family: inherit;
    transition: all 0.2s;
    outline: none;
  }

  .zone-form-input:focus {
    border-color: var(--primary);
    background: #ffffff;
    box-shadow: 0 0 0 3px rgba(45, 106, 79, 0.12);
  }

  .zone-form-input::placeholder { color: var(--text-muted); }

  /* Select wrapper với icon map-pin */
  .zone-form-select-wrapper {
    position: relative;
  }

  .zone-form-select-icon {
    position: absolute;
    left: 0.9rem;
    top: 50%;
    transform: translateY(-50%);
    color: var(--primary);
    pointer-events: none;
    z-index: 1;
  }

  .zone-form-select {
    width: 100%;
    padding: 0.8rem 1rem 0.8rem 2.75rem;
    border: 1.5px solid rgba(45, 106, 79, 0.20);
    border-radius: 12px;
    background: #fafff9;
    color: var(--text-primary);
    font-size: 0.95rem;
    font-family: inherit;
    transition: all 0.2s;
    outline: none;
    appearance: none;
    -webkit-appearance: none;
    cursor: pointer;
    /* Custom dropdown arrow */
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='16' height='16' viewBox='0 0 24 24' fill='none' stroke='%232D6A4F' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
    background-repeat: no-repeat;
    background-position: right 1rem center;
  }

  .zone-form-select:focus {
    border-color: var(--primary);
    background-color: #ffffff;
    box-shadow: 0 0 0 3px rgba(45, 106, 79, 0.12);
  }

  .zone-form-hint {
    font-size: 0.8rem;
    color: var(--text-muted);
    margin-top: 0.4rem;
    padding-left: 0.25rem;
  }

  /* Info box */
  .zone-form-info-box {
    background: linear-gradient(135deg, rgba(45,106,79,0.06) 0%, rgba(82,183,136,0.08) 100%);
    border: 1.5px solid rgba(45, 106, 79, 0.15);
    border-radius: 12px;
    padding: 1rem 1.1rem;
    margin-bottom: 1.75rem;
  }

  /* Error alert */
  .zone-form-alert {
    display: flex;
    align-items: center;
    gap: 0.6rem;
    padding: 0.875rem 1rem;
    border-radius: 10px;
    margin-bottom: 1.5rem;
    font-size: 0.9rem;
    font-weight: 500;
  }

  .zone-form-alert-error {
    background: var(--danger-bg);
    color: var(--danger);
    border: 1px solid rgba(193, 68, 14, 0.20);
    border-left: 3px solid var(--danger);
  }

  /* Actions row */
  .zone-form-actions {
    display: flex;
    gap: 0.75rem;
    margin-top: 0.5rem;
  }
</style>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
