<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="java.util.List, java.util.Map" %>
        <%@ include file="layout_header.jsp" %>

            <style>
                .stats-grid {
                    display: grid;
                    grid-template-columns: repeat(4, 1fr);
                    gap: 16px;
                    margin-bottom: 26px;
                }

                .stat-card {
                    padding: 20px;
                    text-align: center;
                }

                .stat-val {
                    font-size: 2.2rem;
                    font-weight: 800;
                    letter-spacing: -0.04em;
                    line-height: 1;
                    margin-bottom: 6px;
                    font-variant-numeric: tabular-nums;
                }

                .stat-lbl {
                    font-size: 0.68rem;
                    font-weight: 700;
                    color: var(--text-3);
                    text-transform: uppercase;
                    letter-spacing: 0.09em;
                }

                .intent-bar-wrap {
                    margin-bottom: 12px;
                }

                .intent-name {
                    display: flex;
                    justify-content: space-between;
                    font-size: 0.8rem;
                    margin-bottom: 6px;
                    color: var(--text-1);
                    font-weight: 500;
                }

                .intent-name span {
                    color: var(--text-3);
                    font-weight: 400;
                    font-size: 0.75rem;
                }

                .intent-track {
                    height: 6px;
                    background: rgba(10, 17, 40, 0.8);
                    border-radius: 3px;
                    overflow: hidden;
                }

                .intent-fill {
                    height: 100%;
                    border-radius: 3px;
                    transition: width 0.8s ease;
                }
            </style>

            <div class="page-header" data-aos="fade-up">
                <h1>Chat Statistics</h1>
                <p>Phan tich luong chat AI va nguon du lieu</p>
            </div>

            <!-- Stat Cards -->
            <div class="stats-grid">
                <div class="glass glass-hover stat-card" data-aos="fade-up" data-aos-delay="0">
                    <div class="stat-val" style="color:var(--blue);">${totalMessages}</div>
                    <div class="stat-lbl">Tong tin nhan</div>
                </div>
                <div class="glass glass-hover stat-card" data-aos="fade-up" data-aos-delay="50">
                    <div class="stat-val" style="color:#34d399;">${dbHits}</div>
                    <div class="stat-lbl">Tra loi tu DB</div>
                </div>
                <div class="glass glass-hover stat-card" data-aos="fade-up" data-aos-delay="100">
                    <div class="stat-val" style="color:#c084fc;">${aiHits}</div>
                    <div class="stat-lbl">Tra loi tu AI</div>
                </div>
                <div class="glass glass-hover stat-card" data-aos="fade-up" data-aos-delay="150">
                    <div class="stat-val" style="color:#f59e0b;">${uniqueUsers}</div>
                    <div class="stat-lbl">Users chat</div>
                </div>
            </div>

            <div style="display:grid;grid-template-columns:1fr 1fr;gap:20px;">

                <!-- Top Intents -->
                <div class="glass" data-aos="fade-up" data-aos-delay="60" style="padding:22px;">
                    <div class="sec-title"
                        style="font-size:0.68rem;font-weight:700;color:var(--text-3);text-transform:uppercase;letter-spacing:0.09em;display:flex;align-items:center;gap:6px;margin-bottom:18px;padding-bottom:12px;border-bottom:1px solid var(--border);">
                        <i data-lucide="bar-chart-2" width="14" height="14" style="color:var(--blue);"></i>
                        Top Intents
                    </div>
                    <% List<Object[]> intents = (List<Object[]>) request.getAttribute("topIntents");
                            long maxCount = 1;
                            if (intents != null && !intents.isEmpty()) {
                            try { maxCount = Math.max(1, ((Number) intents.get(0)[1]).longValue()); } catch(Exception
                            ignored){}
                            String[] barColors =
                            {"#38bdf8","#8b5cf6","#34d399","#f59e0b","#ef4444","#c084fc","#60a5fa","#a78bfa","#6ee7b7","#fcd34d"};
                            int idx = 0;
                            for (Object[] row : intents) {
                            String intent = (String) row[0];
                            long count = row[1] != null ? ((Number) row[1]).longValue() : 0;
                            int pct = (int) (count * 100 / maxCount);
                            String color = barColors[idx % barColors.length]; idx++;
                            %>
                            <div class="intent-bar-wrap">
                                <div class="intent-name">
                                    <%= intent %> <span>
                                            <%= count %>
                                        </span>
                                </div>
                                <div class="intent-track">
                                    <div class="intent-fill" style="width:<%= pct %>%;background:<%= color %>;"></div>
                                </div>
                            </div>
                            <% } } else { %>
                                <p style="color:var(--text-3);font-size:0.82rem;text-align:center;padding:20px;">Chua co
                                    du lieu intent.</p>
                                <% } %>
                </div>

                <!-- Recent Messages -->
                <div class="glass" data-aos="fade-up" data-aos-delay="100" style="overflow:hidden;">
                    <div
                        style="padding:16px 18px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px;">
                        <i data-lucide="message-square" width="14" height="14" style="color:var(--text-3);"></i>
                        <span
                            style="font-size:0.68rem;font-weight:700;color:var(--text-3);text-transform:uppercase;letter-spacing:0.09em;">Tin
                            nhan gan day</span>
                    </div>
                    <table class="data-table">
                        <thead>
                            <tr>
                                <th class="data-th">User</th>
                                <th class="data-th">Cau hoi</th>
                                <th class="data-th">Nguon</th>
                                <th class="data-th">Thoi gian</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% List<Object[]> recent = (List<Object[]>) request.getAttribute("recentChats");
                               if (recent != null) {
                                   for (Object[] row : recent) {
                                       String uname = row[0] != null ? String.valueOf(row[0]) : "?";
                                       String message = row[1] != null ? String.valueOf(row[1]) : "";
                                       String source = row[2] != null ? String.valueOf(row[2]).toUpperCase() : "?";
                                       String logTime;
                                       try {
                                           logTime = row[3] != null ? row[3].toString().substring(0, 16).replace("T", " ") : "--";
                                       } catch (Exception e) {
                                           logTime = "--";
                                       }
                                       if (message.length() > 50) message = message.substring(0, 50) + "...";
                                       
                                       String badgeColor = "DB".equals(source) ? "#34d399" : "#c084fc";
                                       String badgeBg = "DB".equals(source) ? "rgba(52, 211, 153, 0.15)" : "rgba(192, 132, 252, 0.15)";
                            %>
                            <tr class="data-tr">
                                <td class="data-td" style="font-weight:600;font-size:0.82rem;">
                                    <%= uname %>
                                </td>
                                <td class="data-td" style="color:var(--text-2);font-size:0.78rem;max-width:180px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;" title="<%= message %>">
                                    <%= message %>
                                </td>
                                <td class="data-td">
                                    <span style="background: <%= badgeBg %>; color: <%= badgeColor %>; padding: 4px 10px; border-radius: 12px; font-size: 0.65rem; font-weight: 800; text-transform: uppercase;">
                                        <%= source %>
                                    </span>
                                </td>
                                <td class="data-td" style="color:var(--text-3);font-size:0.72rem;white-space:nowrap;">
                                    <%= logTime %>
                                </td>
                            </tr>
                            <%     } 
                               } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <script>
                lucide.createIcons();
                AOS.init({ duration: 550, once: true, easing: 'ease-out-cubic', offset: 20 });
                function toggleSidebar() { document.getElementById('sidebar').classList.toggle('collapsed'); document.getElementById('main').classList.toggle('expanded'); }

                /* Animate stat counters */
                window.addEventListener('load', function () {
                    setTimeout(function () {
                        document.querySelectorAll('.stat-val').forEach(function (el) {
                            var text = el.textContent.trim();
                            var num = parseInt(text, 10);
                            if (!isNaN(num) && num > 0) {
                                var start = 0, dur = 900, sT = null;
                                function step(ts) {
                                    if (!sT) sT = ts;
                                    var p = Math.min((ts - sT) / dur, 1);
                                    var ease = 1 - Math.pow(1 - p, 3);
                                    el.textContent = Math.floor(ease * num);
                                    if (p < 1) requestAnimationFrame(step); else el.textContent = num;
                                }
                                requestAnimationFrame(step);
                            }
                        });
                        /* Animate intent bars */
                        document.querySelectorAll('.intent-fill').forEach(function (bar) {
                            var target = bar.style.width;
                            bar.style.width = '0';
                            setTimeout(function () { bar.style.width = target; }, 200);
                        });
                    }, 400);
                });
            </script>
            </div>
            </div>
            </div>
            </body>

            </html>