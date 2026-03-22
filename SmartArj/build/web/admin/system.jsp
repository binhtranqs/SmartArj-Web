<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <% // Ensure admin user is checked model.User currentUser=(model.User) session.getAttribute("user"); if
        (currentUser==null || !currentUser.isAdmin()) { response.sendRedirect(request.getContextPath() + "/dashboard" );
        return; } %>
        <jsp:include page="/WEB-INF/views/admin/layout_header.jsp" />

        <!-- Page header -->
        <div class="page-header" data-aos="fade-up" data-aos-duration="500">
            <div style="display:flex;justify-content:space-between;align-items:flex-end;">
                <div>
                    <h1>Cài đặt hệ thống</h1>
                    <p>Tùy chỉnh hệ thống và máy chủ ứng dụng</p>
                </div>
            </div>
        </div>

        <div class="panel-box" data-aos="fade-up" data-aos-delay="50">
            <div style="text-align:center; padding:var(--sp-32); color:rgba(255,255,255,0.4); font-size:0.9rem;">
                <i data-lucide="settings" width="32" height="32" style="margin-bottom:var(--sp-12);opacity:0.5;"></i>
                <p>Tính năng đang trong quá trình phát triển.</p>
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