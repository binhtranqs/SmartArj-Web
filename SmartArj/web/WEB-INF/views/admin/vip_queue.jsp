<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="java.util.List, model.VipRequest, model.User" %>
        <%@ include file="layout_header.jsp" %>

            <div class="page-header" data-aos="fade-up">
                <h1>VIP Queue</h1>
                <p>Xet duyet yeu cau nang cap tai khoan VIP</p>
            </div>

            <div class="glass" data-aos="fade-up" data-aos-delay="40" style="overflow:hidden;">
                <% List<VipRequest> pending = (List<VipRequest>) request.getAttribute("pendingRequests");
                        if (pending == null || pending.isEmpty()) {
                        %>
                        <div style="text-align:center;padding:72px 24px;">
                            <div
                                style="width:64px;height:64px;border-radius:18px;background:rgba(52,211,153,0.08);border:1px solid rgba(52,211,153,0.2);display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">
                                <i data-lucide="check-circle" width="28" height="28" style="color:#34d399;"></i>
                            </div>
                            <p style="font-size:1rem;font-weight:600;color:var(--text-1);margin-bottom:6px;">Khong co
                                yeu cau nao</p>
                            <p style="font-size:0.82rem;color:var(--text-3);">Tat ca yeu cau VIP da duoc xu ly.</p>
                        </div>
                        <% } else { %>
                            <table class="data-table">
                                <thead>
                                    <tr>
                                        <th class="data-th">Nguoi dung</th>
                                        <th class="data-th">Goi VIP</th>
                                        <th class="data-th">Phi (VND)</th>
                                        <th class="data-th">Ngay yeu cau</th>
                                        <th class="data-th">Hanh dong</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <% for (VipRequest vr : pending) { User u=vr.getUser(); String uname=(u !=null &&
                                        u.getUsername() !=null) ? u.getUsername() : "User #" + vr.getUserId(); String
                                        ini=uname.substring(0,1).toUpperCase(); String tier=vr.getVipTier() !=null ?
                                        vr.getVipTier() : "--" ; Object feeObj=vr.getFee(); String fee=feeObj !=null ?
                                        String.format("%,.0f", Double.parseDouble(feeObj.toString())) : "--" ; String
                                        createdDate; try { createdDate=vr.getCreatedAt().toString().substring(0,10); }
                                        catch(Exception e){ createdDate="--" ; } int months=vr.getDurationMonths()> 0 ?
                                        vr.getDurationMonths() : 1;
                                        %>
                                        <tr class="data-tr">
                                            <td class="data-td">
                                                <div style="display:flex;align-items:center;gap:10px;">
                                                    <div
                                                        style="width:36px;height:36px;border-radius:10px;background:linear-gradient(135deg,rgba(251,191,36,0.15),rgba(245,158,11,0.1));border:1px solid rgba(251,191,36,0.2);display:flex;align-items:center;justify-content:center;font-size:0.82rem;font-weight:700;color:#fbbf24;flex-shrink:0;">
                                                        <%= ini %>
                                                    </div>
                                                    <div>
                                                        <div style="font-weight:600;color:var(--text-1);">
                                                            <%= uname %>
                                                        </div>
                                                        <div style="font-size:0.72rem;color:var(--text-3);">ID #<%=
                                                                vr.getUserId() %>
                                                        </div>
                                                    </div>
                                                </div>
                                            </td>
                                            <td class="data-td">
                                                <span class="badge"
                                                    style="background:rgba(251,191,36,0.1);color:#fbbf24;border:1px solid rgba(251,191,36,0.2);">
                                                    &#11088; <%= tier %> &middot; <%= months %> thang
                                                </span>
                                            </td>
                                            <td class="data-td" style="font-weight:600;color:#34d399;">
                                                <%= fee %>
                                            </td>
                                            <td class="data-td" style="color:var(--text-3);font-size:0.78rem;">
                                                <%= createdDate %>
                                            </td>
                                            <td class="data-td">
                                                <div style="display:flex;gap:8px;">
                                                    <form method="post"
                                                        action="<%= request.getContextPath() %>/admin/vip"
                                                        style="display:inline;">
                                                        <input type="hidden" name="action" value="approve">
                                                        <input type="hidden" name="requestId"
                                                            value="<%= vr.getRequestId() %>">
                                                        <button type="submit" class="btn btn-success btn-sm">
                                                            <i data-lucide="check" width="12" height="12"></i>Duyet
                                                        </button>
                                                    </form>
                                                    <form method="post"
                                                        action="<%= request.getContextPath() %>/admin/vip"
                                                        style="display:inline;">
                                                        <input type="hidden" name="action" value="reject">
                                                        <input type="hidden" name="requestId"
                                                            value="<%= vr.getRequestId() %>">
                                                        <button type="submit" class="btn btn-danger btn-sm"
                                                            onclick="return confirm('Tu choi yeu cau nay?')">
                                                            <i data-lucide="x" width="12" height="12"></i>Tu choi
                                                        </button>
                                                    </form>
                                                </div>
                                            </td>
                                        </tr>
                                        <% } %>
                                </tbody>
                            </table>
                            <% } %>
            </div>

            <script>
                lucide.createIcons();
                AOS.init({ duration: 550, once: true, easing: 'ease-out-cubic', offset: 20 });
                function toggleSidebar() { document.getElementById('sidebar').classList.toggle('collapsed'); document.getElementById('main').classList.toggle('expanded'); }
            </script>
            </div>
            </div>
            </div>
            </body>

            </html>