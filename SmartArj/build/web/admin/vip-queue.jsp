<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <% // Ensure admin user is checked model.User currentUser=(model.User) session.getAttribute("user"); if
        (currentUser==null || !currentUser.isAdmin()) { response.sendRedirect(request.getContextPath() + "/dashboard" );
        return; } %>
        <jsp:include page="/WEB-INF/views/admin/layout_header.jsp" />

        <!-- Page header -->
        <div class="page-header" data-aos="fade-up" data-aos-duration="500">
            <div style="display:flex;justify-content:space-between;align-items:flex-end;">
                <div>
                    <h1>Hàng chờ nâng cấp VIP</h1>
                    <p>Danh sách người dùng yêu cầu nâng cấp lên tài khoản Premium</p>
                </div>
            </div>
        </div>

        <div class="panel-box" data-aos="fade-up" data-aos-delay="50">
            <div class="panel-header">
                <div class="panel-title">
                    <i data-lucide="star" width="20" height="20" style="color:var(--amber);"></i>
                    Yêu cầu đang chờ (Mẫu thử nghiệm)
                </div>
            </div>

            <div class="glass" style="overflow:hidden; border-radius: var(--r-xl); margin-top: var(--sp-16);">
                <table style="width:100%; text-align:left; border-collapse:collapse;">
                    <thead>
                        <tr
                            style="border-bottom:1px solid rgba(255,255,255,0.05); font-size:0.875rem; color:rgba(255,255,255,0.5);">
                            <th style="padding:var(--sp-12) var(--sp-16);">User ID</th>
                            <th style="padding:var(--sp-12) var(--sp-16);">Username</th>
                            <th style="padding:var(--sp-12) var(--sp-16);">Email</th>
                            <th style="padding:var(--sp-12) var(--sp-16);">Request Date</th>
                            <th style="padding:var(--sp-12) var(--sp-16); text-align:right;">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <!-- Dummy Data row 1 -->
                        <tr style="border-bottom:1px solid rgba(255,255,255,0.02); transition:var(--transition-base);">
                            <td style="padding:var(--sp-16); font-family:monospace; color:var(--blue);">#1042</td>
                            <td style="padding:var(--sp-16); font-weight:500;">nguyenvana</td>
                            <td style="padding:var(--sp-16); color:rgba(255,255,255,0.7);">nguyenvana@gmail.com</td>
                            <td style="padding:var(--sp-16); color:rgba(255,255,255,0.5);">2024-03-05 09:15</td>
                            <td style="padding:var(--sp-16); text-align:right;">
                                <div style="display:flex; justify-content:flex-end; gap:var(--sp-8);">
                                    <button class="btn btn-sm"
                                        style="background:var(--green); border-color:var(--green); color:#fff;">Phê
                                        duyệt</button>
                                    <button class="btn btn-sm"
                                        style="background:rgba(239, 68, 68, 0.1); border-color:rgba(239,68,68,0.2); color:var(--red);">Từ
                                        chối</button>
                                </div>
                            </td>
                        </tr>
                        <!-- Dummy Data row 2 -->
                        <tr style="border-bottom:none; transition:var(--transition-base);">
                            <td style="padding:var(--sp-16); font-family:monospace; color:var(--blue);">#1045</td>
                            <td style="padding:var(--sp-16); font-weight:500;">lethib</td>
                            <td style="padding:var(--sp-16); color:rgba(255,255,255,0.7);">lethib@yahoo.com</td>
                            <td style="padding:var(--sp-16); color:rgba(255,255,255,0.5);">2024-03-05 11:30</td>
                            <td style="padding:var(--sp-16); text-align:right;">
                                <div style="display:flex; justify-content:flex-end; gap:var(--sp-8);">
                                    <button class="btn btn-sm"
                                        style="background:var(--green); border-color:var(--green); color:#fff;">Phê
                                        duyệt</button>
                                    <button class="btn btn-sm"
                                        style="background:rgba(239, 68, 68, 0.1); border-color:rgba(239,68,68,0.2); color:var(--red);">Từ
                                        chối</button>
                                </div>
                            </td>
                        </tr>
                    </tbody>
                </table>
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