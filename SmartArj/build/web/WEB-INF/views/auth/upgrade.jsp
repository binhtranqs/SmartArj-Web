<%@ page contentType="text/html; charset=UTF-8" %>
    <%@ page import="model.User" %>
        <% User currentUser=(User) request.getAttribute("user"); if (currentUser==null) { currentUser=(User)
            session.getAttribute("user"); } %>

            <jsp:include page="/WEB-INF/views/common/header.jsp">
                <jsp:param name="title" value="Nâng Cấp VIP" />
                <jsp:param name="page" value="upgrade" />
            </jsp:include>

            <div class="page-container">
                <!-- Page Header -->
                <div class="page-header">
                    <div>
                        <h1 class="page-title">
                            💎 Nâng Cấp VIP
                        </h1>
                        <p class="page-subtitle">Mở khóa tất cả tính năng cao cấp với SmartArj VIP</p>
                    </div>
                </div>

                <% if (request.getAttribute("error") !=null) { %>
                    <div
                        style="background: rgba(239, 68, 68, 0.1); color: var(--danger); padding: 1rem 1.5rem; border-radius: var(--radius-lg); margin-bottom: 2rem; border-left: 4px solid var(--danger);">
                        ⚠️ <%= request.getAttribute("error") %>
                    </div>
                    <% } %>

                        <!-- Current Status -->
                        <% if (currentUser !=null) { %>
                            <div class="card mb-4"
                                style="padding: 2rem; background: linear-gradient(135deg, #2D6A4F 0%, #1B4332 100%); color: white;">
                                <div style="display: flex; justify-content: space-between; align-items: center;">
                                    <div>
                                        <h3 style="margin: 0 0 0.5rem 0; font-size: 1.25rem;">Trạng thái tài khoản</h3>
                                        <p style="margin: 0; opacity: 0.9;">
                                            <%= currentUser.getFullName() !=null ? currentUser.getFullName() :
                                                currentUser.getUsername() %>
                                        </p>
                                    </div>
                                    <div style="text-align: right;">
                                        <% if (currentUser.isVIP()) { %>
                                            <div class="badge"
                                                style="background: rgba(255, 255, 255, 0.3); color: white; font-size: 1rem; padding: 0.5rem 1rem;">
                                                ⭐ VIP
                                            </div>
                                            <p style="margin: 0.5rem 0 0 0; font-size: 0.875rem; opacity: 0.9;">
                                                Còn <%= currentUser.getDaysRemaining() %> ngày
                                            </p>
                                            <% } else { %>
                                                <div class="badge"
                                                    style="background: rgba(255, 255, 255, 0.3); color: white; font-size: 1rem; padding: 0.5rem 1rem;">
                                                    👤 FREE
                                                </div>
                                                <% } %>
                                    </div>
                                </div>
                            </div>
                            <% } %>

                                <!-- Pricing Cards -->
                                <div class="grid grid-3 mb-4">
                                    <!-- 1 Month Package -->
                                    <div class="card card-hover-lift" style="padding: 2rem; text-align: center;">
                                        <div style="font-size: 3rem; margin-bottom: 1rem;">📅</div>
                                        <h3 style="font-size: 1.5rem; margin-bottom: 0.5rem;">VIP 1 Tháng</h3>
                                        <div
                                            style="font-size: 2.5rem; font-weight: 700; color: #2D6A4F; margin: 1rem 0;">
                                            99,000đ
                                        </div>
                                        <p style="color: var(--text-secondary); margin-bottom: 2rem;">
                                            3,300đ/ngày
                                        </p>
                                        <form method="POST" action="${pageContext.request.contextPath}/vip/checkout">
                                            <input type="hidden" name="days" value="30">
                                            <button type="submit" class="btn btn-outline" style="width: 100%;">
                                                💳 Thanh toán VNPay
                                            </button>
                                        </form>
                                    </div>

                                    <!-- 3 Months Package (Popular) -->
                                    <div class="card card-hover-lift"
                                        style="padding: 2rem; text-align: center; border: 3px solid #2D6A4F; position: relative;">
                                        <div
                                            style="position: absolute; top: -15px; left: 50%; transform: translateX(-50%); background: #2D6A4F; color: white; padding: 0.25rem 1rem; border-radius: 999px; font-size: 0.75rem; font-weight: 700;">
                                            PHỔ BIẾN NHẤT
                                        </div>
                                        <div style="font-size: 3rem; margin-bottom: 1rem;">🔥</div>
                                        <h3 style="font-size: 1.5rem; margin-bottom: 0.5rem;">VIP 3 Tháng</h3>
                                        <div
                                            style="font-size: 2.5rem; font-weight: 700; color: #2D6A4F; margin: 1rem 0;">
                                            249,000đ
                                        </div>
                                        <p style="color: var(--text-secondary); margin-bottom: 0.5rem;">
                                            2,767đ/ngày
                                        </p>
                                        <p style="color: var(--success); font-weight: 600; margin-bottom: 2rem;">
                                            ✨ Tiết kiệm 15%
                                        </p>
                                        <form method="POST" action="${pageContext.request.contextPath}/vip/checkout">
                                            <input type="hidden" name="days" value="90">
                                            <button type="submit" class="btn btn-primary" style="width: 100%;">
                                                💳 Thanh toán VNPay
                                            </button>
                                        </form>
                                    </div>

                                    <!-- 1 Year Package -->
                                    <div class="card card-hover-lift" style="padding: 2rem; text-align: center;">
                                        <div style="font-size: 3rem; margin-bottom: 1rem;">👑</div>
                                        <h3 style="font-size: 1.5rem; margin-bottom: 0.5rem;">VIP 1 Năm</h3>
                                        <div
                                            style="font-size: 2.5rem; font-weight: 700; color: #2D6A4F; margin: 1rem 0;">
                                            899,000đ
                                        </div>
                                        <p style="color: var(--text-secondary); margin-bottom: 0.5rem;">
                                            2,463đ/ngày
                                        </p>
                                        <p style="color: var(--success); font-weight: 600; margin-bottom: 2rem;">
                                            ✨ Tiết kiệm 25%
                                        </p>
                                        <form method="POST" action="${pageContext.request.contextPath}/vip/checkout">
                                            <input type="hidden" name="days" value="365">
                                            <button type="submit" class="btn btn-outline" style="width: 100%;">
                                                💳 Thanh toán VNPay
                                            </button>
                                        </form>
                                    </div>
                                </div>

                                <!-- Features Comparison -->
                                <div class="card" style="padding: 2rem;">
                                    <h2 style="text-align: center; margin-bottom: 2rem;">Tính năng VIP</h2>

                                    <div
                                        style="display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 2rem;">
                                        <div style="text-align: center;">
                                            <div style="font-size: 3rem; margin-bottom: 1rem;">💬</div>
                                            <h4 style="margin-bottom: 0.5rem;">Chatbot AI</h4>
                                            <p style="color: var(--text-secondary); font-size: 0.875rem;">
                                                Trợ lý ảo hỗ trợ 24/7
                                            </p>
                                        </div>

                                        <div style="text-align: center;">
                                            <div style="font-size: 3rem; margin-bottom: 1rem;">📈</div>
                                            <h4 style="margin-bottom: 0.5rem;">Dự Báo Thời Tiết</h4>
                                            <p style="color: var(--text-secondary); font-size: 0.875rem;">
                                                Dự đoán thời tiết nhiều ngày
                                            </p>
                                        </div>

                                        <div style="text-align: center;">
                                            <div style="font-size: 3rem; margin-bottom: 1rem;">📊</div>
                                            <h4 style="margin-bottom: 0.5rem;">Phân Tích Nâng Cao</h4>
                                            <p style="color: var(--text-secondary); font-size: 0.875rem;">
                                                Báo cáo chi tiết và insights
                                            </p>
                                        </div>

                                        <div style="text-align: center;">
                                            <div style="font-size: 3rem; margin-bottom: 1rem;">💾</div>
                                            <h4 style="margin-bottom: 0.5rem;">Xuất Dữ Liệu</h4>
                                            <p style="color: var(--text-secondary); font-size: 0.875rem;">
                                                Export CSV, Excel, PDF
                                            </p>
                                        </div>
                                    </div>
                                </div>
            </div>

            <jsp:include page="/WEB-INF/views/common/footer.jsp" />