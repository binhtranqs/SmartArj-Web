<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <% // Ensure admin user is checked model.User currentUser=(model.User) session.getAttribute("user"); if
        (currentUser==null || !currentUser.isAdmin()) { response.sendRedirect(request.getContextPath() + "/dashboard" );
        return; } %>
        <jsp:include page="/WEB-INF/views/admin/layout_header.jsp" />

        <!-- Page header -->
        <div class="page-header" data-aos="fade-up" data-aos-duration="500">
            <div style="display:flex;justify-content:space-between;align-items:flex-end;">
                <div>
                    <h1>Thống kê chat</h1>
                    <p>Tổng quan về hoạt động nhắn tin của AI và người dùng</p>
                </div>
            </div>
        </div>

        <!-- KPIs -->
        <div class="dashboard-grid" style="margin-bottom:var(--sp-24);">
            <div class="kpi-card glass" data-aos="fade-up" data-aos-delay="0">
                <div class="kpi-header">
                    <h3 class="kpi-title">Tổng số tin nhắn hôm nay</h3>
                    <div class="kpi-icon"><i data-lucide="message-square" width="18" height="18"></i></div>
                </div>
                <div class="kpi-value">1,248</div>
                <div class="kpi-footer">
                    <span class="trend up"><i data-lucide="arrow-up-right" width="12" height="12"></i> +14% hôm
                        nay</span>
                </div>
            </div>

            <div class="kpi-card glass" data-aos="fade-up" data-aos-delay="40">
                <div class="kpi-header">
                    <h3 class="kpi-title">Người dùng hoạt động</h3>
                    <div class="kpi-icon"><i data-lucide="users" width="18" height="18"></i></div>
                </div>
                <div class="kpi-value">342</div>
                <div class="kpi-footer">
                    <span class="trend up"><i data-lucide="arrow-up-right" width="12" height="12"></i> +5% hôm
                        qua</span>
                </div>
            </div>

            <div class="kpi-card glass" data-aos="fade-up" data-aos-delay="80">
                <div class="kpi-header">
                    <h3 class="kpi-title">Tin nhắn AI xử lý</h3>
                    <div class="kpi-icon" style="color:var(--green);"><i data-lucide="bot" width="18" height="18"></i>
                    </div>
                </div>
                <div class="kpi-value">1,120</div>
                <div class="kpi-footer">
                    <span class="trend neutral">Tỉ lệ phản hồi 98%</span>
                </div>
            </div>
        </div>

        <!-- Chart -->
        <div class="panel-box" data-aos="fade-up" data-aos-delay="120">
            <div class="panel-header">
                <div class="panel-title">
                    <i data-lucide="activity" width="20" height="20" style="color:var(--blue);"></i>
                    Lưu lượng tin nhắn (7 ngày qua)
                </div>
            </div>
            <div style="position:relative; height:320px; width:100%; margin-top:var(--sp-16);">
                <canvas id="chatStatsChart"></canvas>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script>
            lucide.createIcons();
            AOS.init({ duration: 500, once: true });

            document.addEventListener('DOMContentLoaded', function () {
                const ctx = document.getElementById('chatStatsChart');
                if (ctx) {
                    new Chart(ctx, {
                        type: 'bar',
                        data: {
                            labels: ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'],
                            datasets: [{
                                label: 'Tin nhắn gửi vào',
                                data: [420, 530, 680, 590, 810, 1024, 1248],
                                backgroundColor: '#38bdf8', /* blue */
                                borderRadius: 4,
                                barPercentage: 0.6
                            },
                            {
                                label: 'AI phản hồi',
                                data: [415, 520, 670, 580, 790, 950, 1120],
                                backgroundColor: '#34d399', /* green */
                                borderRadius: 4,
                                barPercentage: 0.6
                            }]
                        },
                        options: {
                            responsive: true,
                            maintainAspectRatio: false,
                            plugins: {
                                legend: {
                                    position: 'top',
                                    align: 'end',
                                    labels: { color: 'rgba(255,255,255,0.7)', font: { family: 'Inter' } }
                                },
                                tooltip: {
                                    backgroundColor: 'rgba(15, 23, 42, 0.9)',
                                    titleColor: '#fff',
                                    bodyColor: '#e2e8f0',
                                    borderColor: 'rgba(255,255,255,0.1)',
                                    borderWidth: 1,
                                    padding: 12,
                                }
                            },
                            scales: {
                                x: {
                                    grid: { display: false, drawBorder: false },
                                    ticks: { color: 'rgba(255,255,255,0.4)', font: { family: 'Inter', size: 11 } }
                                },
                                y: {
                                    border: { dash: [4, 4] },
                                    grid: { color: 'rgba(255, 255, 255, 0.05)', drawBorder: false },
                                    ticks: { color: 'rgba(255,255,255,0.4)', font: { family: 'Inter', size: 11 } }
                                }
                            },
                            interaction: { intersect: false, mode: 'index' }
                        }
                    });
                }
            });
        </script>

        </div>
        </div>
        </div>
        </body>

        </html>