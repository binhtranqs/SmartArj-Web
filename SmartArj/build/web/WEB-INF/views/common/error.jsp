<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<c:set var="pageTitle" value="Error" />
<jsp:include page="/WEB-INF/views/common/header.jsp" />

<div class="card card-soft p-4">
  <h4 class="text-danger mb-2"><i class="bi bi-exclamation-triangle"></i> Error</h4>

  <div class="mb-3">
    <div class="text-muted">Message</div>
    <div class="fw-semibold">
      <c:out value="${errorMessage}" />
    </div>
  </div>

  <details class="mb-3">
    <summary class="text-primary">Stacktrace</summary>
    <pre class="mt-2 p-3 bg-light rounded" style="white-space: pre-wrap;">
<c:out value="${errorDetail}" />
    </pre>
  </details>

  <a class="btn btn-outline-secondary" href="javascript:history.back()">
    <i class="bi bi-arrow-left"></i> Back
  </a>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
