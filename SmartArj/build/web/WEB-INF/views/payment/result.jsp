<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="model.Transaction" %>
        <% Boolean paymentSuccess=(Boolean) request.getAttribute("paymentSuccess"); Boolean signatureValid=(Boolean)
            request.getAttribute("signatureValid"); String paymentMessage=(String)
            request.getAttribute("paymentMessage"); String responseCode=(String) request.getAttribute("responseCode");
            Transaction tx=(Transaction) request.getAttribute("transaction"); if (paymentSuccess==null)
            paymentSuccess=false; if (signatureValid==null) signatureValid=false; %>

            <jsp:include page="/WEB-INF/views/common/header.jsp">
                <jsp:param name="title" value="Payment Result" />
                <jsp:param name="page" value="upgrade" />
            </jsp:include>

            <div class="page-container">
                <div class="card" style="max-width: 760px; margin: 2rem auto;">
                    <h2 style="margin-bottom:1rem;">
                        <%= paymentSuccess ? "✅ Thanh toán thành công" : "❌ Thanh toán thất bại" %>
                    </h2>

                    <p style="margin-bottom:1rem; color: var(--text-secondary);">
                        <%= paymentMessage !=null ? paymentMessage : "" %>
                    </p>

                    <div style="display:grid; gap:0.75rem;">
                        <div><strong>Chữ ký hợp lệ:</strong>
                            <%= signatureValid %>
                        </div>
                        <div><strong>Mã phản hồi VNPay:</strong>
                            <%= responseCode !=null ? responseCode : "-" %>
                        </div>
                        <div><strong>Mã tham chiếu:</strong>
                            <%= (tx !=null && tx.getProviderTxnRef() !=null) ? tx.getProviderTxnRef() : "-" %>
                        </div>
                        <div><strong>Trạng thái giao dịch:</strong>
                            <%= (tx !=null && tx.getStatus() !=null) ? tx.getStatus() : "-" %>
                        </div>
                        <div><strong>Thời hạn VIP (ngày):</strong>
                            <%= (tx !=null && tx.getVipDuration() !=null) ? tx.getVipDuration() : "-" %>
                        </div>
                    </div>

                    <div style="display:flex; gap:0.75rem; margin-top:1.5rem; flex-wrap:wrap;">
                        <a class="btn btn-primary" href="${pageContext.request.contextPath}/dashboard">Về Dashboard</a>
                        <a class="btn btn-outline" href="${pageContext.request.contextPath}/vip/checkout">Thanh toán
                            lại</a>
                    </div>
                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/footer.jsp" />