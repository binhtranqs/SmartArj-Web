<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<jsp:include page="/WEB-INF/views/common/header.jsp" />

<c:set var="z" value="${zone}" />

<div class="container page">
  <div class="page-head">
    <div>
      <h1>
        <c:choose>
          <c:when test="${editing}">Edit Zone</c:when>
          <c:otherwise>New Zone</c:otherwise>
        </c:choose>
      </h1>
      <div class="muted">Nhập thông tin vùng trồng</div>
    </div>
    <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/zones">Back</a>
  </div>

  <div class="cardx">
    <form method="post" action="${pageContext.request.contextPath}/zones" class="row g-3">
      <c:if test="${editing}">
        <input type="hidden" name="zoneId" value="${z.zoneId}" />
      </c:if>

      <div class="col-md-4">
        <label class="form-label">City ID <span class="text-danger">*</span></label>
        <input type="number" class="form-control" name="cityId"
               value="${z.cityId}" required />
        <div class="form-text">VD: 1</div>
      </div>

      <div class="col-md-8">
        <label class="form-label">Zone Name</label>
        <input type="text" class="form-control" name="zoneName"
               value="${z.zoneName}" placeholder="Vườn Lan Cẩm Lệ..." />
      </div>

      <div class="col-md-6">
        <label class="form-label">Latitude</label>
        <input type="number" step="0.000001" class="form-control" name="latitude"
               value="${z.latitude}" placeholder="16.05" />
      </div>

      <div class="col-md-6">
        <label class="form-label">Longitude</label>
        <input type="number" step="0.000001" class="form-control" name="longitude"
               value="${z.longitude}" placeholder="108.20" />
      </div>

      <div class="col-12">
        <label class="form-label">Description</label>
        <textarea class="form-control" name="description" rows="3"
                  placeholder="Mô tả...">${z.description}</textarea>
      </div>

      <div class="col-12 d-flex gap-2">
        <button class="btn btn-primary" type="submit">Save</button>
        <a class="btn btn-outline-secondary" href="${pageContext.request.contextPath}/zones">Cancel</a>
      </div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
