<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <% // Ensure admin user is checked model.User currentUser=(model.User) session.getAttribute("user"); if
        (currentUser==null || !currentUser.isAdmin()) { response.sendRedirect(request.getContextPath() + "/dashboard" );
        return; } %>
        <jsp:include page="/WEB-INF/views/admin/layout_header.jsp" />

        <!-- Page header -->
        <div class="page-header" data-aos="fade-up" data-aos-duration="500">
            <div style="display:flex;justify-content:space-between;align-items:flex-end;">
                <div>
                    <h1>Phân tích AI</h1>
                    <p>Các cảnh báo và đề xuất thông minh từ hệ thống</p>
                </div>
            </div>
        </div>

        <div class="dashboard-grid">
            <!-- AI Alerts List -->
            <div class="panel-box" style="grid-column: span 12;" data-aos="fade-up" data-aos-delay="50">
                <div class="panel-header" style="margin-bottom: var(--sp-24);">
                    <div class="panel-title">
                        <i data-lucide="sparkles" width="20" height="20" style="color:var(--amber);"></i>
                        Thông tin chuyên sâu (Insights)
                    </div>
                </div>

                <div style="display:flex; flex-direction:column; gap:var(--sp-12);">

                    <!-- Alert 1 -->
                    <div class="ai-item glass"
                        style="padding:var(--sp-16); border-radius:var(--r-lg); display:flex; align-items:center; gap:var(--sp-16); transition:var(--transition-base);">
                        <div
                            style="width:40px;height:40px;border-radius:var(--r-md);display:flex;align-items:center;justify-content:center;background:rgba(239, 68, 68, 0.1);color:var(--red);">
                            <i data-lucide="thermometer" width="20" height="20"></i>
                        </div>
                        <div style="flex:1;">
                            <div style="font-weight:600; font-size:0.95rem; margin-bottom:2px;">Cảnh báo nhiệt độ cao
                                tại HCM</div>
                            <div style="font-size:0.85rem; color:rgba(255,255,255,0.6);">Nhiệt độ đo được vượt ngưỡng
                                35°C. Đề nghị tăng cường tưới tiêu trong tuần này.</div>
                        </div>
                        <div
                            style="font-size:0.75rem; color:var(--red); font-weight:600; background:rgba(239,68,68,0.15); padding:4px 8px; border-radius:12px;">
                            Nguy hiểm</div>
                    </div>

                    <!-- Alert 2 -->
                    <div class="ai-item glass"
                        style="padding:var(--sp-16); border-radius:var(--r-lg); display:flex; align-items:center; gap:var(--sp-16); transition:var(--transition-base);">
                        <div
                            style="width:40px;height:40px;border-radius:var(--r-md);display:flex;align-items:center;justify-content:center;background:rgba(245, 158, 11, 0.1);color:var(--amber);">
                            <i data-lucide="droplets" width="20" height="20"></i>
                        </div>
                        <div style="flex:1;">
                            <div style="font-weight:600; font-size:0.95rem; margin-bottom:2px;">Độ ẩm thấp tại Zone B
                            </div>
                            <div style="font-size:0.85rem; color:rgba(255,255,255,0.6);">Độ ẩm đất hiện tại đang ở mức
                                40%. Cần giám sát chặt chẽ cây trồng.</div>
                        </div>
                        <div
                            style="font-size:0.75rem; color:var(--amber); font-weight:600; background:rgba(245,158,11,0.15); padding:4px 8px; border-radius:12px;">
                            Cảnh báo</div>
                    </div>

                    <!-- Alert 3 -->
                    <div class="ai-item glass"
                        style="padding:var(--sp-16); border-radius:var(--r-lg); display:flex; align-items:center; gap:var(--sp-16); transition:var(--transition-base);">
                        <div
                            style="width:40px;height:40px;border-radius:var(--r-md);display:flex;align-items:center;justify-content:center;background:rgba(52, 211, 153, 0.1);color:var(--green);">
                            <i data-lucide="leaf" width="20" height="20"></i>
                        </div>
                        <div style="flex:1;">
                            <div style="font-weight:600; font-size:0.95rem; margin-bottom:2px;">Điều kiện trồng cây tối
                                ưu tại Zone C</div>
                            <div style="font-size:0.85rem; color:rgba(255,255,255,0.6);">Chỉ số thời tiết và đất đai rất
                                lý tưởng cho vụ mùa hiện tại. Không cần hành động.</div>
                        </div>
                        <div
                            style="font-size:0.75rem; color:var(--green); font-weight:600; background:rgba(52,211,153,0.15); padding:4px 8px; border-radius:12px;">
                            Tối ưu</div>
                    </div>

                </div>
            </div>
        </div>

        <script>
            lucide.createIcons();
            AOS.init({ duration: 500, once: true });
        </script>

        </div>
        </div>
        </div>
        </body>

        </html>