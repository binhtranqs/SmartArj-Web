<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ include file="layout_header.jsp" %>

        <div class="page-header" data-aos="fade-up">
            <h1>Gói đăng ký</h1>
            <p>Quản lý các gói dịch vụ và người dùng đăng ký</p>
        </div>

        <div class="panel-box" data-aos="fade-up" data-aos-delay="40">
            <div style="text-align:center;padding:60px 20px;color:var(--t3);">
                <i data-lucide="credit-card" width="48" height="48"
                    style="color:var(--blue);opacity:0.6;margin-bottom:16px;"></i>
                <h3 style="font-size:1.2rem;color:var(--t1);margin-bottom:8px;">Tính năng đang phát triển</h3>
                <p>Giao diện Quản lý Gói đăng ký sẽ sớm được cập nhật.</p>
            </div>
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