<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ include file="layout_header.jsp" %>
    
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

        <style>
            .kpi-grid {
                display: grid;
                grid-template-columns: repeat(3, 1fr);
                gap: var(--sp-24);
                margin-bottom: var(--sp-32);
            }

            .kpi-card {
                padding: var(--sp-24);
                background: rgba(15, 23, 42, 0.4);
                border: 1px solid rgba(255, 255, 255, 0.05);
                border-radius: var(--r-xl);
                position: relative;
                overflow: hidden;
                box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
            }

            .kpi-icon {
                width: 48px;
                height: 48px;
                border-radius: var(--r-lg);
                display: flex;
                align-items: center;
                justify-content: center;
                margin-bottom: var(--sp-16);
            }

            .kpi-label {
                font-size: 0.875rem;
                font-weight: 500;
                color: rgba(255, 255, 255, 0.6);
            }

            .kpi-val {
                font-size: 2.25rem;
                font-weight: 700;
                color: #fff;
                margin-top: var(--sp-8);
                font-variant-numeric: tabular-nums;
            }

            .panel-box {
                background: rgba(15, 23, 42, 0.4);
                border: 1px solid rgba(255, 255, 255, 0.05);
                border-radius: var(--r-xl);
                padding: var(--sp-24);
                box-shadow: var(--shadow-md);
            }

            .panel-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: var(--sp-24);
            }

            .panel-title {
                font-size: 1.125rem;
                font-weight: 600;
                color: #fff;
                display: flex;
                align-items: center;
                gap: var(--sp-8);
            }
        </style>

        <div class="page-header" data-aos="fade-up">
            <h1>Thống kê chat</h1>
            <p>Phân tích dữ liệu và thống kê tin nhắn hệ thống</p>
        </div>

        <div class="kpi-grid" data-aos="fade-up" data-aos-delay="50">
            <!-- Tin nhắn hôm nay -->
            <div class="kpi-card">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                    <div>
                        <div class="kpi-label">TỔNG TIN NHẮN (HÔM NAY)</div>
                        <div class="kpi-val tabnum">${todayMessages != null ? todayMessages : 0}</div>
                    </div>
                    <div class="kpi-icon" style="background: rgba(56, 189, 248, 0.1); border: 1px solid rgba(56, 189, 248, 0.2);">
                        <i data-lucide="message-circle" width="22" height="22" style="color:var(--blue);"></i>
                    </div>
                </div>
            </div>

            <!-- User tương tác hôm nay -->
            <div class="kpi-card">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                    <div>
                        <div class="kpi-label">USER TƯƠNG TÁC (HÔM NAY)</div>
                        <div class="kpi-val tabnum">${todayActiveUsers != null ? todayActiveUsers : 0}</div>
                    </div>
                    <div class="kpi-icon" style="background: rgba(16, 185, 129, 0.1); border: 1px solid rgba(16, 185, 129, 0.2);">
                        <i data-lucide="users" width="22" height="22" style="color:var(--green);"></i>
                    </div>
                </div>
            </div>

            <!-- AI phản hồi hôm nay -->
            <div class="kpi-card">
                <div style="display:flex;justify-content:space-between;align-items:flex-start;">
                    <div>
                        <div class="kpi-label">SỐ LƯỢNG AI PHẢN HỒI (HÔM NAY)</div>
                        <div class="kpi-val tabnum">${todayAiResponses != null ? todayAiResponses : 0}</div>
                    </div>
                    <div class="kpi-icon" style="background: rgba(139, 92, 246, 0.1); border: 1px solid rgba(139, 92, 246, 0.2);">
                        <i data-lucide="bot" width="22" height="22" style="color:var(--purple);"></i>
                    </div>
                </div>
            </div>
        </div>

        <div class="panel-box" data-aos="fade-up" data-aos-delay="100">
            <div class="panel-header">
                <div class="panel-title">
                    <i data-lucide="bar-chart-3" width="20" height="20" style="color:var(--blue);"></i>
                    Biểu đồ tương tác 7 ngày qua
                </div>
            </div>
            
            <div style="position: relative; height:400px; width:100%;">
                <canvas id="chatStatsChart"></canvas>
            </div>
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;margin-bottom:var(--sp-32);">
            <!-- Panel 1: Câu hỏi gần đây -->
            <div class="panel-box" data-aos="fade-up" data-aos-delay="150" style="overflow:hidden;">
                <div class="panel-header" style="margin-bottom:var(--sp-16);border-bottom:1px solid rgba(255,255,255,0.05);padding-bottom:12px;">
                    <div class="panel-title" style="font-size:1rem;color:rgba(255,255,255,0.9);">
                        <i data-lucide="message-square" width="18" height="18" style="color:var(--t3);"></i>
                        Câu hỏi gần đây
                    </div>
                </div>
                
                <div style="overflow-x:auto;">
                    <table style="width:100%;border-collapse:collapse;text-align:left;">
                        <thead>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.05);">
                                <th style="padding:12px 16px;color:var(--t3);font-size:0.75rem;font-weight:600;text-transform:uppercase;">User</th>
                                <th style="padding:12px 16px;color:var(--t3);font-size:0.75rem;font-weight:600;text-transform:uppercase;">Câu hỏi</th>
                                <th style="padding:12px 16px;color:var(--t3);font-size:0.75rem;font-weight:600;text-transform:uppercase;">Nguồn</th>
                                <th style="padding:12px 16px;color:var(--t3);font-size:0.75rem;font-weight:600;text-transform:uppercase;">Thời gian</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                java.util.List<Object[]> recent = (java.util.List<Object[]>) request.getAttribute("recentQuestions");
                                if (recent != null && !recent.isEmpty()) {
                                    for (Object[] row : recent) {
                                        String uname = row[0] != null ? row[0].toString() : "Khách";
                                        String msg = row[1] != null ? row[1].toString() : "";
                                        String truncMsg = msg.length() > 50 ? msg.substring(0, 50) + "..." : msg;
                                        String source = row[2] != null ? row[2].toString() : "DB";
                                        
                                        String timeStr = "--";
                                        if (row[3] != null) {
                                            try {
                                                timeStr = row[3].toString().substring(0, 16).replace("T", " ");
                                            } catch(Exception ignored) {}
                                        }
                                        
                                        String srcStyle = "AI".equals(source) 
                                            ? "background:rgba(139,92,246,0.15);color:#c084fc;padding:2px 8px;border-radius:4px;font-size:0.7rem;font-weight:600;" 
                                            : "background:rgba(52,211,153,0.15);color:#6ee7b7;padding:2px 8px;border-radius:4px;font-size:0.7rem;font-weight:600;";
                            %>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.02);transition:background 0.2s;">
                                <td style="padding:12px 16px;color:#fff;font-size:0.875rem;font-weight:500;"><%= uname %></td>
                                <td style="padding:12px 16px;color:rgba(255,255,255,0.7);font-size:0.85rem;max-width:200px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<%= msg %>">
                                    <%= truncMsg %>
                                </td>
                                <td style="padding:12px 16px;"><span style="<%= srcStyle %>"><%= source %></span></td>
                                <td style="padding:12px 16px;color:var(--t3);font-size:0.75rem;white-space:nowrap;"><%= timeStr %></td>
                            </tr>
                            <% 
                                    }
                                } else { 
                            %>
                            <tr>
                                <td colspan="4" style="padding:40px 16px;text-align:center;color:var(--t3);font-size:0.85rem;">
                                    Chưa có tin nhắn nào gần đây.
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- Panel 2: Top câu hỏi phổ biến -->
            <div class="panel-box" data-aos="fade-up" data-aos-delay="200" style="overflow:hidden;">
                <div class="panel-header" style="margin-bottom:var(--sp-16);border-bottom:1px solid rgba(255,255,255,0.05);padding-bottom:12px;">
                    <div class="panel-title" style="font-size:1rem;color:rgba(255,255,255,0.9);">
                        <i data-lucide="trending-up" width="18" height="18" style="color:var(--t3);"></i>
                        Top câu hỏi phổ biến hôm nay
                    </div>
                </div>
                
                <div style="overflow-x:auto;">
                    <table style="width:100%;border-collapse:collapse;text-align:left;">
                        <thead>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.05);">
                                <th style="padding:12px 16px;color:var(--t3);font-size:0.75rem;font-weight:600;text-transform:uppercase;">Nội dung</th>
                                <th style="padding:12px 16px;color:var(--t3);font-size:0.75rem;font-weight:600;text-transform:uppercase;text-align:right;">Số lượt hỏi</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% 
                                java.util.List<Object[]> topQ = (java.util.List<Object[]>) request.getAttribute("topQuestions");
                                if (topQ != null && !topQ.isEmpty()) {
                                    for (Object[] row : topQ) {
                                        String txt = row[0] != null ? row[0].toString() : "";
                                        String truncTxt = txt.length() > 60 ? txt.substring(0, 60) + "..." : txt;
                                        long cnt = row[1] != null ? ((Number) row[1]).longValue() : 0;
                            %>
                            <tr style="border-bottom:1px solid rgba(255,255,255,0.02);transition:background 0.2s;">
                                <td style="padding:14px 16px;color:rgba(255,255,255,0.85);font-size:0.85rem;max-width:260px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<%= txt %>">
                                    <%= truncTxt %>
                                </td>
                                <td style="padding:14px 16px;color:var(--blue);font-size:0.9rem;font-weight:700;text-align:right;">
                                    <%= cnt %>
                                </td>
                            </tr>
                            <% 
                                    }
                                } else { 
                            %>
                            <tr>
                                <td colspan="2" style="padding:40px 16px;text-align:center;color:var(--t3);font-size:0.85rem;">
                                    Chưa có top thống kê.
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <script>
            lucide.createIcons();
            AOS.init({ duration: 550, once: true, easing: 'ease-out-cubic', offset: 20 });
            function toggleSidebar() { document.getElementById('sidebar').classList.toggle('collapsed'); document.getElementById('main').classList.toggle('expanded'); }

            document.addEventListener("DOMContentLoaded", function () {
                var chartDataStrings = {
                    labels: '${chartLabels}',
                    messages: '${chartMessages}',
                    aiData: '${chartAiData}'
                };
                
                var labels = [];
                var messages = [];
                var aiData = [];
                
                try {
                    if (chartDataStrings.labels && chartDataStrings.labels !== '') labels = JSON.parse(chartDataStrings.labels);
                    if (chartDataStrings.messages && chartDataStrings.messages !== '') messages = JSON.parse(chartDataStrings.messages);
                    if (chartDataStrings.aiData && chartDataStrings.aiData !== '') aiData = JSON.parse(chartDataStrings.aiData);
                } catch(e) {
                    console.error("Failed parsing chart JSON data", e);
                }
                
                var hasData = messages.some(function(v) { return v > 0; }) || aiData.some(function(v) { return v > 0; });
                var ctx = document.getElementById('chatStatsChart');

                if (!hasData) {
                    ctx.outerHTML = '<div style="text-align:center;padding:100px 20px;color:rgba(255,255,255,0.4);border:1px dashed rgba(255,255,255,0.1);border-radius:var(--r-lg);">Không có dữ liệu trò chuyện nào được phát sinh trong 7 ngày qua.</div>';
                    return;
                }

                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [
                            {
                                label: 'Tổng tin nhắn',
                                data: messages,
                                backgroundColor: 'rgba(56, 189, 248, 0.6)',
                                borderColor: 'rgba(56, 189, 248, 1)',
                                borderWidth: 1,
                                borderRadius: 4,
                                order: 2
                            },
                            {
                                label: 'Phản hồi AI',
                                data: aiData,
                                type: 'line',
                                fill: false,
                                borderColor: 'rgba(139, 92, 246, 1)',
                                backgroundColor: 'rgba(139, 92, 246, 1)',
                                tension: 0.3,
                                pointBackgroundColor: '#fff',
                                pointBorderWidth: 2,
                                pointRadius: 4,
                                order: 1
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        interaction: {
                            mode: 'index',
                            intersect: false,
                        },
                        plugins: {
                            legend: {
                                labels: {
                                    color: 'rgba(255, 255, 255, 0.7)'
                                }
                            },
                            tooltip: {
                                backgroundColor: 'rgba(15, 23, 42, 0.9)',
                                titleColor: '#fff',
                                bodyColor: 'rgba(255, 255, 255, 0.8)',
                                padding: 12,
                                cornerRadius: 8
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    color: 'rgba(255, 255, 255, 0.5)',
                                    precision: 0
                                },
                                grid: {
                                    color: 'rgba(255, 255, 255, 0.05)',
                                    drawBorder: false
                                }
                            },
                            x: {
                                ticks: {
                                    color: 'rgba(255, 255, 255, 0.5)'
                                },
                                grid: {
                                    display: false,
                                    drawBorder: false
                                }
                            }
                        }
                    }
                });
            });
        </script>
        </div>
        </div>
        </div>
        </body>

        </html>