<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="java.util.List, model.User" %>
        <%@ include file="layout_header.jsp" %>

            <style>
                .user-avatar {
                    width: 36px;
                    height: 36px;
                    border-radius: 10px;
                    background: linear-gradient(135deg, rgba(56, 189, 248, 0.2), rgba(99, 102, 241, 0.2));
                    border: 1px solid rgba(56, 189, 248, 0.15);
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 0.82rem;
                    font-weight: 700;
                    color: var(--blue);
                    flex-shrink: 0;
                }

                .filter-bar {
                    display: flex;
                    gap: 10px;
                    margin-bottom: 20px;
                    flex-wrap: wrap;
                    align-items: center;
                }

                .filter-bar .form-input {
                    flex: 1;
                    min-width: 180px;
                }
            </style>

            <div class="page-header" data-aos="fade-up">
                <h1>Quản lý Người dùng</h1>
                <p>Tìm kiếm, lọc, khóa/mở khóa tài khoản</p>
            </div>

            <!-- Filter -->
            <form method="get" data-aos="fade-up" data-aos-delay="40">
                <div class="filter-bar">
                    <div style="position:relative;flex:1;min-width:200px;">
                        <i data-lucide="search" width="14" height="14"
                            style="position:absolute;left:11px;top:50%;transform:translateY(-50%);color:var(--text-3);pointer-events:none;"></i>
                        <input type="text" name="q" value="${query}" placeholder="Tìm username, email..."
                            class="form-input" style="padding-left:34px;width:100%;">
                    </div>
                    <select name="role" class="form-select">
                        <option value="">Tất cả Vai trò</option>
                        <option value="USER" <%="USER" .equals(request.getAttribute("roleFilter")) ? "selected" :"" %>
                            >User</option>
                        <option value="ADMIN" <%="ADMIN" .equals(request.getAttribute("roleFilter")) ? "selected" :"" %>
                            >Admin</option>
                    </select>
                    <select name="status" class="form-select">
                        <option value="">Tất cả trạng thái</option>
                        <option value="active" <%="active" .equals(request.getAttribute("statusFilter")) ? "selected"
                            :"" %>>Hoạt động</option>
                        <option value="locked" <%="locked" .equals(request.getAttribute("statusFilter")) ? "selected"
                            :"" %>>Bị khóa</option>
                    </select>
                    <button type="submit" class="btn btn-primary">
                        <i data-lucide="filter" width="14" height="14"></i>Lọc
                    </button>
                </div>
            </form>

            <!-- Table -->
            <div class="glass" data-aos="fade-up" data-aos-delay="60" style="overflow:hidden;">
                <table class="data-table">
                    <thead>
                        <tr>
                            <th class="data-th">ID</th>
                            <th class="data-th">Người dùng</th>
                            <th class="data-th">Email</th>
                            <th class="data-th">Role</th>
                            <th class="data-th">Tài khoản</th>
                            <th class="data-th">Trạng thái</th>
                            <th class="data-th">Đăng nhập</th>
                            <th class="data-th">Hành động</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% List<User> users = (List<User>) request.getAttribute("users");
                                if (users != null) {
                                for (User u : users) {
                                boolean lk = !Boolean.TRUE.equals(u.getIsActive());
                                String role = u.getRole() != null ? u.getRole() : "USER";
                                String acct = u.getAccountType() != null ? u.getAccountType() : "FREE";
                                String roleCls = "ADMIN".equals(role) ? "badge badge-admin" : "badge badge-user";
                                String acctCls = "VIP".equals(acct) ? "badge badge-vip" : "badge badge-free";
                                String statCls = lk ? "badge badge-locked" : "badge badge-active";
                                String lastLogin;
                                try { lastLogin = u.getLastLogin() != null ?
                                u.getLastLogin().toString().substring(0,16).replace("T"," ") : "Chưa đăng nhập"; }
                                catch(Exception e){ lastLogin="--"; }
                                String ini = (u.getUsername()!=null && u.getUsername().length()>0) ?
                                u.getUsername().substring(0,1).toUpperCase() : "U";
                                %>
                                <tr class="data-tr">
                                    <td class="data-td" style="color:var(--text-3);font-size:0.78rem;font-weight:500;">#
                                        <%= u.getUserId() %>
                                    </td>
                                    <td class="data-td">
                                        <div style="display:flex;align-items:center;gap:10px;">
                                            <div class="user-avatar">
                                                <%= ini %>
                                            </div>
                                            <span style="font-weight:600;color:var(--text-1);">
                                                <%= u.getUsername() %>
                                            </span>
                                        </div>
                                    </td>
                                    <td class="data-td" style="color:var(--text-2);">
                                        <%= u.getEmail()!=null?u.getEmail():"--" %>
                                    </td>
                                    <td class="data-td"><span class="<%= roleCls %>">
                                            <%= role %>
                                        </span></td>
                                    <td class="data-td"><span class="<%= acctCls %>">
                                            <%= "VIP" .equals(acct)?"&#11088; ":"" %><%= acct %></span></td>
        <td class=" data-td">
                                                <span class="<%= statCls %>">
                                                    <span
                                                        style="width:5px;height:5px;border-radius:50%;background:currentColor;display:inline-block;"></span>
                                                    <%= lk ? "Bị khóa" : "Hoạt động" %>
                                                </span>
                                    </td>
                                    <td class="data-td" style="color:var(--text-3);font-size:0.78rem;">
                                        <%= lastLogin %>
                                    </td>
                                    <td class="data-td">
                                        <div style="display:flex;gap:6px;">
                                            <a href="<%= request.getContextPath() %>/admin/users?view=<%= u.getUserId() %>"
                                                class="btn btn-ghost btn-sm">
                                                <i data-lucide="eye" width="12" height="12"></i>Hồ sơ
                                            </a>
                                            <% if (!lk) { %>
                                                <form method="post" action="<%= request.getContextPath() %>/admin/users"
                                                    style="display:inline;">
                                                    <input type="hidden" name="action" value="lock">
                                                    <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                                    <input type="hidden" name="reason" value="Admin khóa thủ công">
                                                    <button type="submit" class="btn btn-danger btn-sm"
                                                        onclick="return confirm('Khóa người dùng này?')">
                                                        <i data-lucide="lock" width="11" height="11"></i>Khóa
                                                    </button>
                                                </form>
                                                <% } else { %>
                                                    <form method="post"
                                                        action="<%= request.getContextPath() %>/admin/users"
                                                        style="display:inline;">
                                                        <input type="hidden" name="action" value="unlock">
                                                        <input type="hidden" name="userId" value="<%= u.getUserId() %>">
                                                        <button type="submit" class="btn btn-success btn-sm">
                                                            <i data-lucide="unlock" width="11" height="11"></i>Mở khóa
                                                        </button>
                                                    </form>
                                                    <% } %>
                                        </div>
                                    </td>
                                </tr>
                                <% } } %>
                    </tbody>
                </table>
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