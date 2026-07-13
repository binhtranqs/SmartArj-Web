<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.User" %>
<%
  User currentUser = (User) session.getAttribute("user");
%>

<jsp:include page="/WEB-INF/views/common/header.jsp">
  <jsp:param name="title" value="VIP Checkout" />
  <jsp:param name="page" value="upgrade" />
</jsp:include>

<div class="page-container">
  <div class="page-header">
    <div>
      <h1 class="page-title">💳 Thanh Toán VNPay Sandbox</h1>
      <p class="page-subtitle">Chọn gói VIP và chuyển đến cổng VNPay để thanh toán</p>
    </div>
  </div>

  <div class="card" style="max-width: 680px; margin: 0 auto 2rem auto;">
    <h3 style="margin-bottom:1rem;">Thông tin thanh toán</h3>
    <p style="color: var(--text-secondary); margin-bottom:1.5rem;">
      Tài khoản:
      <strong><%= currentUser != null ? currentUser.getUsername() : "" %></strong>
    </p>

    <form method="post" action="${pageContext.request.contextPath}/vip/checkout">
      <label for="days" style="display:block; margin-bottom:0.5rem; font-weight:600;">Gói VIP</label>
      <select id="days" name="days"
              style="width:100%; padding:0.75rem; border:1px solid var(--border-color); border-radius:var(--radius-md); margin-bottom:1rem;">
        <option value="30">VIP 30 ngày - 99,000 VND</option>
        <option value="90">VIP 90 ngày - 249,000 VND</option>
        <option value="365">VIP 365 ngày - 899,000 VND</option>
      </select>

      <button type="submit" class="btn btn-primary" style="width:100%;">Thanh toán với VNPay</button>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp" />
