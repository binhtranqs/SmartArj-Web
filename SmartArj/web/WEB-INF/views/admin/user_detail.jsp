<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="java.util.List, model.User, model.AdminAuditLog, model.Zone, model.ZoneCrop, model.CropCatalog" %>
        <%@ include file="layout_header.jsp" %>

            <style>
                .profile-hero {
                    display: flex;
                    align-items: center;
                    gap: 20px;
                    flex-wrap: wrap;
                }

                .profile-big-avatar {
                    width: 72px;
                    height: 72px;
                    border-radius: 20px;
                    background: linear-gradient(135deg, var(--blue), var(--purple));
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 2rem;
                    font-weight: 900;
                    color: #fff;
                    box-shadow: 0 0 28px rgba(56, 189, 248, 0.33);
                    flex-shrink: 0;
                }

                .profile-info-grid {
                    display: grid;
                    grid-template-columns: repeat(3, 1fr);
                    gap: 12px;
                    margin-top: 20px;
                }

                .info-cell {
                    background: rgba(2, 8, 23, 0.6);
                    border: 1px solid var(--border);
                    border-radius: 11px;
                    padding: 14px 16px;
                }

                .info-cell-label {
                    font-size: 0.65rem;
                    color: var(--text-3);
                    text-transform: uppercase;
                    letter-spacing: 0.08em;
                    font-weight: 700;
                    margin-bottom: 5px;
                }

                .info-cell-value {
                    font-size: 0.9rem;
                    font-weight: 600;
                    color: var(--text-1);
                }

                .zone-grid {
                    display: grid;
                    grid-template-columns: repeat(auto-fill, minmax(220px, 1fr));
                    gap: 12px;
                    padding: 18px;
                }

                .zone-card {
                    background: rgba(2, 8, 23, 0.6);
                    border: 1px solid var(--border);
                    border-radius: 12px;
                    padding: 14px;
                    transition: all 0.25s;
                }

                .zone-card:hover {
                    border-color: rgba(56, 189, 248, 0.3);
                    background: rgba(10, 17, 40, 0.8);
                    transform: translateY(-2px);
                }
            </style>

            <a href="<%= request.getContextPath() %>/admin/users" class="btn btn-ghost btn-sm"
                style="margin-bottom:20px;display:inline-flex;" data-aos="fade-right">
                <i data-lucide="arrow-left" width="13" height="13"></i>Quay lai
            </a>

            <% User target=(User) request.getAttribute("targetUser"); if (target==null) { %>
                <div class="glass" style="padding:20px;border-top:2px solid rgba(239,68,68,0.4);">
                    <p style="color:#ef4444;">Khong tim thay user.</p>
                </div>
                <% } else { boolean lk=!Boolean.TRUE.equals(target.getIsActive()); String role=target.getRole() !=null ?
                    target.getRole() : "USER" ; String acct=target.getAccountType() !=null ? target.getAccountType()
                    : "FREE" ; String roleCls="ADMIN" .equals(role) ? "badge badge-admin" : "badge badge-user" ; String
                    acctCls="VIP" .equals(acct) ? "badge badge-vip" : "badge badge-free" ; String stCls=lk
                    ? "badge badge-locked" : "badge badge-active" ; String lockBtnCls=lk ? "btn btn-success btn-sm"
                    : "btn btn-danger btn-sm" ; String cAt, ll, ve; try { cAt=target.getCreatedAt() !=null ?
                    target.getCreatedAt().toString().substring(0,10) : "--" ; } catch(Exception e){ cAt="--" ; } try {
                    ll=target.getLastLogin() !=null ?
                    target.getLastLogin().toString().substring(0,16).replace("T"," ") : " Chua dang nhap"; }
                    catch(Exception e){ ll="--" ; } try { ve=target.getVipExpiryDate() !=null ?
                    target.getVipExpiryDate().toString().substring(0,10) : "--" ; } catch(Exception e){ ve="--" ; }
                    String ini=(target.getUsername()!=null && target.getUsername().length()>0) ?
                    target.getUsername().substring(0,1).toUpperCase() : "U";
                    String dispNm = target.getFullName() != null ? target.getFullName() : target.getUsername();
                    %>

                    <!-- Profile Card -->
                    <div class="glass" data-aos="fade-up" style="padding:28px;margin-bottom:20px;">
                        <div class="profile-hero">
                            <div class="profile-big-avatar">
                                <%= ini %>
                            </div>
                            <div style="flex:1;">
                                <div
                                    style="font-size:1.4rem;font-weight:800;color:var(--text-1);letter-spacing:-0.03em;">
                                    <%= dispNm %>
                                </div>
                                <div style="font-size:0.85rem;color:var(--text-3);margin-top:3px;">
                                    @<%= target.getUsername() %> &middot; <%=
                                            target.getEmail()!=null?target.getEmail():"--" %>
                                </div>
                                <div style="display:flex;gap:8px;margin-top:12px;flex-wrap:wrap;">
                                    <span class="<%= roleCls %>">
                                        <%= role %>
                                    </span>
                                    <span class="<%= acctCls %>">
                                        <%= "VIP" .equals(acct)?"&#11088; ":"" %><%= acct %></span>
        <span class=" <%=stCls %>">
                                            <span
                                                style="width:5px;height:5px;border-radius:50%;background:currentColor;display:inline-block;"></span>
                                            <%= lk ? "Bi khoa" : "Hoat dong" %>
                                    </span>
                                </div>
                            </div>
                            <div style="display:flex;gap:8px;flex-shrink:0;flex-wrap:wrap;">
                                <% if (!lk) { %>
                                    <form method="post" action="<%= request.getContextPath() %>/admin/users">
                                        <input type="hidden" name="action" value="lock">
                                        <input type="hidden" name="userId" value="<%= target.getUserId() %>">
                                        <input type="hidden" name="reason" value="Admin khoa tu profile">
                                        <button type="submit" class="btn btn-danger btn-sm"
                                            onclick="return confirm('Khoa?')">
                                            <i data-lucide="lock" width="12" height="12"></i>Khoa
                                        </button>
                                    </form>
                                    <% } else { %>
                                        <form method="post" action="<%= request.getContextPath() %>/admin/users">
                                            <input type="hidden" name="action" value="unlock">
                                            <input type="hidden" name="userId" value="<%= target.getUserId() %>">
                                            <button type="submit" class="btn btn-success btn-sm">
                                                <i data-lucide="unlock" width="12" height="12"></i>Mo khoa
                                            </button>
                                        </form>
                                        <% } %>
                            </div>
                        </div>

                        <div class="profile-info-grid">
                            <div class="info-cell">
                                <div class="info-cell-label">Ngay tao</div>
                                <div class="info-cell-value">
                                    <%= cAt %>
                                </div>
                            </div>
                            <div class="info-cell">
                                <div class="info-cell-label">Dang nhap cuoi</div>
                                <div class="info-cell-value">
                                    <%= ll %>
                                </div>
                            </div>
                            <div class="info-cell" style="<%= " VIP".equals(acct) ? "border-color:rgba(251,191,36,0.2);"
                                : "" %>">
                                <div class="info-cell-label">VIP het han</div>
                                <div class="info-cell-value" style="<%= " VIP".equals(acct) ? "color:#fbbf24;" : "" %>">
                                    <%= ve %>
                                </div>
                            </div>
                            <% try { if (lk && target.getLockReason() !=null) { %>
                                <div class="info-cell"
                                    style="grid-column:1/-1;border-color:rgba(239,68,68,0.18);background:rgba(239,68,68,0.04);">
                                    <div class="info-cell-label" style="color:#ef4444;">Ly do khoa</div>
                                    <div class="info-cell-value" style="color:#fca5a5;">
                                        <%= target.getLockReason() %>
                                    </div>
                                </div>
                                <% } } catch(Exception ignored) {} %>
                        </div>
                    </div>

                    <!-- Zones -->
                    <% List<Zone> zones = (List<Zone>) request.getAttribute("userZones");
                            int zc = zones != null ? zones.size() : 0;
                            %>
                            <div class="glass" data-aos="fade-up" data-aos-delay="50"
                                style="overflow:hidden;margin-bottom:20px;">
                                <div
                                    style="padding:14px 18px;border-bottom:1px solid var(--border);display:flex;align-items:center;justify-content:space-between;">
                                    <div
                                        style="display:flex;align-items:center;gap:8px;font-size:0.68rem;font-weight:700;color:var(--blue);text-transform:uppercase;letter-spacing:0.09em;">
                                        <i data-lucide="map-pin" width="14" height="14"></i>Zones (<%= zc %>)
                                    </div>
                                </div>
                                <% if (zc==0) { %>
                                    <div style="text-align:center;padding:36px;color:var(--text-3);">
                                        <i data-lucide="home" width="28" height="28"
                                            style="opacity:0.2;margin:0 auto 10px;display:block;"></i>
                                        <p style="font-size:0.82rem;">Chua co zone nao.</p>
                                    </div>
                                    <% } else { %>
                                        <div class="zone-grid">
                                            <% for (Zone z : zones) { String zn=z.getZoneName() !=null ? z.getZoneName()
                                                : "Zone #" + z.getZoneId(); String descShort=z.getDescription() !=null
                                                && z.getDescription().length()> 70 ?
                                                z.getDescription().substring(0,70)+"..." : (z.getDescription() != null ?
                                                z.getDescription() : "");
                                                %>
                                                <div class="zone-card">
                                                    <div
                                                        style="display:flex;align-items:center;gap:8px;margin-bottom:8px;">
                                                        <div
                                                            style="width:28px;height:28px;border-radius:8px;background:rgba(56,189,248,0.1);border:1px solid rgba(56,189,248,0.2);display:flex;align-items:center;justify-content:center;">
                                                            <i data-lucide="map-pin" width="13" height="13"
                                                                style="color:var(--blue);"></i>
                                                        </div>
                                                        <div>
                                                            <div
                                                                style="font-size:0.85rem;font-weight:600;color:var(--text-1);">
                                                                <%= zn %>
                                                            </div>
                                                            <div style="font-size:0.68rem;color:var(--text-3);">City #
                                                                <%= z.getCityId() %>
                                                            </div>
                                                        </div>
                                                    </div>
                                                    <% if (!descShort.isEmpty()) { %>
                                                        <div
                                                            style="font-size:0.75rem;color:var(--text-3);line-height:1.5;margin-bottom:8px;">
                                                            <%= descShort %>
                                                        </div>
                                                        <% } %>
                                                            <% if (z.getLatitude() !=null) { %><span
                                                                    style="font-size:0.68rem;color:var(--text-3);background:rgba(2,8,23,0.7);padding:2px 7px;border-radius:5px;">
                                                                    <%= String.format("%.4f",z.getLatitude()) %>, <%=
                                                                            String.format("%.4f",z.getLongitude()) %>
                                                                </span>
                                                                <% } %>
                                                </div>
                                                <% } %>
                                        </div>
                                        <% } %>
                            </div>

                            <!-- Crops -->
                            <% List<ZoneCrop> crops = (List<ZoneCrop>) request.getAttribute("userCrops");
                                    int cc = crops != null ? crops.size() : 0;
                                    %>
                                    <div class="glass" data-aos="fade-up" data-aos-delay="80"
                                        style="overflow:hidden;margin-bottom:20px;">
                                        <div
                                            style="padding:14px 18px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px;font-size:0.68rem;font-weight:700;color:#34d399;text-transform:uppercase;letter-spacing:0.09em;">
                                            <i data-lucide="leaf" width="14" height="14"></i>Cay trong (<%= cc %>)
                                        </div>
                                        <% if (cc==0) { %>
                                            <div style="text-align:center;padding:36px;color:var(--text-3);">
                                                <i data-lucide="sprout" width="28" height="28"
                                                    style="opacity:0.2;margin:0 auto 10px;display:block;"></i>
                                                <p style="font-size:0.82rem;">Chua co cay trong nao.</p>
                                            </div>
                                            <% } else { %>
                                                <table class="data-table">
                                                    <thead>
                                                        <tr>
                                                            <th class="data-th">Ten cay</th>
                                                            <th class="data-th">Zone</th>
                                                            <th class="data-th">Nhiet do (C)</th>
                                                            <th class="data-th">Do am (%)</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <% for (ZoneCrop zc : crops) { String zname="--" ; for (Zone z :
                                                            zones) { if (z.getZoneId().equals(zc.getZoneId())) {
                                                            zname=z.getZoneName() !=null ? z.getZoneName() : "Zone #" +
                                                            z.getZoneId(); break; } } CropCatalog c=zc.getCropCatalog();
                                                            String minT=c.getMinTemp() !=null ?
                                                            String.format("%.1f",c.getMinTemp()) : "--" ; String
                                                            maxT=c.getMaxTemp() !=null ?
                                                            String.format("%.1f",c.getMaxTemp()) : "--" ; String
                                                            minH=c.getMinHumid()!=null ?
                                                            String.format("%.1f",c.getMinHumid()) : "--" ; String
                                                            maxH=c.getMaxHumid()!=null ?
                                                            String.format("%.1f",c.getMaxHumid()) : "--" ; %>
                                                            <tr class="data-tr">
                                                                <td class="data-td">
                                                                    <div
                                                                        style="display:flex;align-items:center;gap:8px;">
                                                                        <div
                                                                            style="width:28px;height:28px;border-radius:8px;background:rgba(52,211,153,0.1);border:1px solid rgba(52,211,153,0.2);display:flex;align-items:center;justify-content:center;font-size:0.82rem;">
                                                                            &#127807;</div>
                                                                        <span style="font-weight:600;">
                                                                            <%= c.getCropName() %>
                                                                        </span>
                                                                    </div>
                                                                </td>
                                                                <td class="data-td"
                                                                    style="color:var(--blue);font-weight:500;">
                                                                    <%= zname %>
                                                                </td>
                                                                <td class="data-td">
                                                                    <span
                                                                        style="color:#ef4444;font-weight:600;font-size:0.82rem;">
                                                                        <%= minT %>&#176;
                                                                    </span>
                                                                    <span
                                                                        style="color:var(--text-3);margin:0 4px;">&#8211;</span>
                                                                    <span
                                                                        style="color:#f59e0b;font-weight:600;font-size:0.82rem;">
                                                                        <%= maxT %>&#176;
                                                                    </span>
                                                                </td>
                                                                <td class="data-td">
                                                                    <span
                                                                        style="color:var(--blue);font-weight:600;font-size:0.82rem;">
                                                                        <%= minH %>%
                                                                    </span>
                                                                    <span
                                                                        style="color:var(--text-3);margin:0 4px;">&#8211;</span>
                                                                    <span
                                                                        style="color:var(--purple);font-weight:600;font-size:0.82rem;">
                                                                        <%= maxH %>%
                                                                    </span>
                                                                </td>
                                                            </tr>
                                                            <% } %>
                                                    </tbody>
                                                </table>
                                                <% } %>
                                    </div>

                                    <!-- Audit Log -->
                                    <% List<AdminAuditLog> logs = (List<AdminAuditLog>)
                                            request.getAttribute("auditLogs");
                                            if (logs != null && !logs.isEmpty()) {
                                            %>
                                            <div class="glass" data-aos="fade-up" data-aos-delay="120"
                                                style="overflow:hidden;">
                                                <div
                                                    style="padding:14px 18px;border-bottom:1px solid var(--border);display:flex;align-items:center;gap:8px;font-size:0.68rem;font-weight:700;color:var(--text-3);text-transform:uppercase;letter-spacing:0.09em;">
                                                    <i data-lucide="scroll-text" width="14" height="14"></i>Lich su hanh
                                                    dong
                                                </div>
                                                <table class="data-table">
                                                    <thead>
                                                        <tr>
                                                            <th class="data-th">Thoi gian</th>
                                                            <th class="data-th">Hanh dong</th>
                                                            <th class="data-th">Admin</th>
                                                            <th class="data-th">Ghi chu</th>
                                                        </tr>
                                                    </thead>
                                                    <tbody>
                                                        <% for (AdminAuditLog log : logs) { String lt; try {
                                                            lt=log.getCreatedAt().toString().substring(0,16).replace("T"," "); } catch(Exception e){ lt="
                                                            --"; } String act=log.getAction() !=null ? log.getAction()
                                                            : "--" ; String actColor; if (act.contains("LOCK") ||
                                                            act.contains("REJECT")) actColor="#ef4444" ; else if
                                                            (act.contains("APPROVE")|| act.contains("UNLOCK"))
                                                            actColor="#34d399" ; else actColor="#8ba3c7" ; %>
                                                            <tr class="data-tr">
                                                                <td class="data-td"
                                                                    style="color:var(--text-3);font-size:0.78rem;white-space:nowrap;">
                                                                    <%= lt %>
                                                                </td>
                                                                <td class="data-td"
                                                                    style="font-weight:600;color:<%= actColor %>;">
                                                                    <%= act %>
                                                                </td>
                                                                <td class="data-td"
                                                                    style="color:var(--text-3);font-size:0.82rem;">Admin
                                                                    #<%= log.getAdminId() %>
                                                                </td>
                                                                <td class="data-td"
                                                                    style="color:var(--text-2);font-size:0.82rem;">
                                                                    <%= log.getNote()!=null?log.getNote():"--" %>
                                                                </td>
                                                            </tr>
                                                            <% } %>
                                                    </tbody>
                                                </table>
                                            </div>
                                            <% } %>
                                                <% } %>

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