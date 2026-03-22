<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Farmer Dashboard | SmartAgri</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Nunito:wght@700;800;900&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
                <style>
                    :root {
                        --primary: #2E7D32;
                        --primary-light: #43A047;
                        --primary-dark: #1B5E20;
                        --accent: #81C784;
                        --accent-yellow: #F9A825;
                        --bg-light: #F1F8E9;
                        --sidebar-bg: #1B5E20;
                    }

                    body {
                        font-family: 'Plus Jakarta Sans', sans-serif;
                        background: var(--bg-light);
                        margin: 0;
                    }

                    /* Sidebar */
                    .farmer-sidebar {
                        width: 240px;
                        background: var(--sidebar-bg);
                        min-height: 100vh;
                        position: fixed;
                        left: 0;
                        top: 0;
                        z-index: 100;
                        padding: 0;
                    }

                    .sidebar-logo {
                        padding: 24px 20px;
                        border-bottom: 1px solid rgba(255, 255, 255, 0.1);
                    }

                    .sidebar-logo .brand {
                        color: white;
                        font-family: 'Nunito', sans-serif;
                        font-weight: 900;
                        font-size: 18px;
                    }

                    .sidebar-logo .sub {
                        color: rgba(255, 255, 255, 0.6);
                        font-size: 11px;
                        letter-spacing: 1px;
                    }

                    .sidebar-badge {
                        background: var(--accent-yellow);
                        color: #1A2E1A;
                        font-size: 9px;
                        font-weight: 800;
                        padding: 2px 6px;
                        border-radius: 10px;
                        margin-left: 6px;
                    }

                    .sidebar-nav {
                        padding: 16px 0;
                    }

                    .sidebar-nav .nav-section {
                        padding: 4px 20px;
                        color: rgba(255, 255, 255, 0.4);
                        font-size: 10px;
                        font-weight: 700;
                        letter-spacing: 1px;
                        margin: 12px 0 4px;
                    }

                    .sidebar-nav a {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                        padding: 10px 20px;
                        color: rgba(255, 255, 255, 0.8);
                        text-decoration: none;
                        font-size: 14px;
                        transition: all .2s;
                        border-left: 3px solid transparent;
                    }

                    .sidebar-nav a:hover,
                    .sidebar-nav a.active {
                        background: rgba(255, 255, 255, 0.1);
                        color: white;
                        border-left-color: var(--accent-yellow);
                    }

                    .sidebar-nav a .bi {
                        font-size: 16px;
                    }

                    /* Main content */
                    .main-content {
                        margin-left: 240px;
                        padding: 28px;
                        min-height: 100vh;
                    }

                    /* Header bar */
                    .page-header {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 28px;
                    }

                    .page-title {
                        font-family: 'Nunito', sans-serif;
                        font-size: 1.8rem;
                        font-weight: 900;
                        color: var(--primary-dark);
                        margin: 0;
                    }

                    .page-title span {
                        color: var(--primary-light);
                    }

                    /* Stat cards */
                    .stats-row {
                        display: grid;
                        grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
                        gap: 20px;
                        margin-bottom: 28px;
                    }

                    .stat-card {
                        background: white;
                        border-radius: 16px;
                        padding: 22px;
                        box-shadow: 0 4px 20px rgba(46, 125, 50, 0.1);
                        display: flex;
                        align-items: center;
                        gap: 16px;
                        transition: transform .2s;
                    }

                    .stat-card:hover {
                        transform: translateY(-3px);
                    }

                    .stat-icon {
                        width: 52px;
                        height: 52px;
                        border-radius: 14px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 24px;
                    }

                    .stat-icon.green {
                        background: #E8F5E9;
                    }

                    .stat-icon.blue {
                        background: #E3F2FD;
                    }

                    .stat-icon.yellow {
                        background: #FFF8E1;
                    }

                    .stat-icon.purple {
                        background: #F3E5F5;
                    }

                    .stat-val {
                        font-family: 'Nunito', sans-serif;
                        font-size: 1.8rem;
                        font-weight: 900;
                        color: var(--primary-dark);
                        line-height: 1;
                    }

                    .stat-label {
                        font-size: 12px;
                        color: #6B7B6B;
                        margin-top: 2px;
                    }

                    /* Table */
                    .content-card {
                        background: white;
                        border-radius: 16px;
                        box-shadow: 0 4px 20px rgba(46, 125, 50, 0.08);
                        margin-bottom: 24px;
                        overflow: hidden;
                    }

                    .card-header-custom {
                        padding: 18px 22px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        border-bottom: 2px solid #F1F8E9;
                    }

                    .card-title {
                        font-weight: 700;
                        font-size: 16px;
                        color: var(--primary-dark);
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        margin: 0;
                    }

                    .table {
                        margin: 0;
                        font-size: 14px;
                    }

                    .table th {
                        background: #F1F8E9;
                        color: var(--primary-dark);
                        font-weight: 600;
                        font-size: 12px;
                        letter-spacing: 0.5px;
                        border-bottom: 2px solid #C8E6C9;
                        padding: 12px 16px;
                    }

                    .table td {
                        padding: 12px 16px;
                        vertical-align: middle;
                        border-color: #F1F8E9;
                    }

                    .table tbody tr:hover {
                        background: #F9FBF9;
                    }

                    .badge-active {
                        background: #E8F5E9;
                        color: #2E7D32;
                        border-radius: 20px;
                        padding: 4px 10px;
                        font-size: 11px;
                        font-weight: 700;
                    }

                    .badge-sold {
                        background: #FFF8E1;
                        color: #F57F17;
                        border-radius: 20px;
                        padding: 4px 10px;
                        font-size: 11px;
                        font-weight: 700;
                    }

                    .badge-pending {
                        background: #FFF8E1;
                        color: #E65100;
                    }

                    .badge-completed {
                        background: #E8F5E9;
                        color: #1B5E20;
                    }

                    .badge-shipped {
                        background: #E3F2FD;
                        color: #0D47A1;
                    }

                    .badge-cancelled {
                        background: #FFEBEE;
                        color: #B71C1C;
                    }

                    .btn-sm-green {
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 8px;
                        padding: 5px 12px;
                        font-size: 12px;
                        font-weight: 600;
                        text-decoration: none;
                        display: inline-flex;
                        align-items: center;
                        gap: 4px;
                    }

                    .btn-sm-green:hover {
                        background: var(--primary-dark);
                        color: white;
                    }

                    .btn-sm-red {
                        background: #FFEBEE;
                        color: #B71C1C;
                        border: none;
                        border-radius: 8px;
                        padding: 5px 12px;
                        font-size: 12px;
                        font-weight: 600;
                        transition: all .2s;
                    }

                    .btn-sm-red:hover {
                        background: #B71C1C;
                        color: white;
                    }

                    /* Market price table */
                    .market-price-row {
                        display: flex;
                        justify-content: space-between;
                        padding: 8px 0;
                        border-bottom: 1px solid #F1F8E9;
                        font-size: 13px;
                    }

                    .market-price-row:last-child {
                        border-bottom: none;
                    }

                    .mp-name {
                        color: #2E7D32;
                        font-weight: 600;
                    }

                    .mp-price {
                        color: #F57F17;
                        font-weight: 700;
                    }

                    /* Stars */
                    .stars {
                        color: #F9A825;
                        font-size: 16px;
                    }

                    /* Responsive */
                    @media (max-width: 768px) {
                        .farmer-sidebar {
                            display: none;
                        }

                        .main-content {
                            margin-left: 0;
                            padding: 16px;
                        }
                    }
                </style>
            </head>

            <body>

                <!-- Sidebar -->
                <div class="farmer-sidebar">
                    <div class="sidebar-logo">
                        <div class="brand">🌾 SmartAgri</div>
                        <div class="sub">FARMER DASHBOARD</div>
                        <div style="margin-top:10px;color:rgba(255,255,255,0.8);font-size:13px;">
                            👨‍🌾 ${sessionScope.user.fullName}
                            <span class="sidebar-badge">VIP</span>
                        </div>
                    </div>
                    <nav class="sidebar-nav">
                        <div class="nav-section">TỔNG QUAN</div>
                        <a href="${pageContext.request.contextPath}/farmer/dashboard" class="active">
                            <i class="bi bi-speedometer2"></i> Dashboard
                        </a>

                        <div class="nav-section">NÔNG SẢN</div>
                        <a href="${pageContext.request.contextPath}/farmer/listing">
                            <i class="bi bi-list-ul"></i> Danh sách sản phẩm
                        </a>
                        <a href="${pageContext.request.contextPath}/farmer/listing/new">
                            <i class="bi bi-plus-circle"></i> Đăng sản phẩm mới
                        </a>

                        <div class="nav-section">BÁN HÀNG</div>
                        <a href="${pageContext.request.contextPath}/farmer/orders">
                            <i class="bi bi-bag-check"></i> Đơn hàng nhận được
                        </a>

                        <div class="nav-section">KHÁC</div>
                        <a href="${pageContext.request.contextPath}/marketplace">
                            <i class="bi bi-shop"></i> Ra chợ
                        </a>
                        <a href="${pageContext.request.contextPath}/logout">
                            <i class="bi bi-box-arrow-right"></i> Đăng xuất
                        </a>
                    </nav>
                </div>

                <!-- Main Content -->
                <div class="main-content">
                    <div class="page-header">
                        <h1 class="page-title">Xin chào, <span>${sessionScope.user.fullName}!</span> 👋</h1>
                        <div style="display:flex;gap:10px;">
                            <a href="${pageContext.request.contextPath}/farmer/listing/new" class="btn btn-sm"
                                style="background:var(--primary);color:white;border-radius:10px;font-weight:600;">
                                <i class="bi bi-plus-lg"></i> Đăng sản phẩm mới
                            </a>
                            <a href="${pageContext.request.contextPath}/marketplace"
                                class="btn btn-sm btn-outline-secondary" style="border-radius:10px;">
                                <i class="bi bi-shop"></i> Xem Marketplace
                            </a>
                        </div>
                    </div>

                    <!-- Stat Cards -->
                    <div class="stats-row">
                        <div class="stat-card">
                            <div class="stat-icon green">🌿</div>
                            <div>
                                <div class="stat-val">${stats.activeListings}</div>
                                <div class="stat-label">Sản phẩm đang bán</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon blue">📦</div>
                            <div>
                                <div class="stat-val">${stats.totalOrders}</div>
                                <div class="stat-label">Tổng đơn hàng</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon yellow">⏳</div>
                            <div>
                                <div class="stat-val">${stats.pendingOrders}</div>
                                <div class="stat-label">Chờ xác nhận</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon green">💰</div>
                            <div>
                                <div class="stat-val">
                                    <fmt:formatNumber value="${stats.totalRevenue}" pattern="#,##0"
                                        maxFractionDigits="0" />đ
                                </div>
                                <div class="stat-label">Doanh thu hoàn thành</div>
                            </div>
                        </div>
                        <div class="stat-card">
                            <div class="stat-icon yellow">⭐</div>
                            <div>
                                <fmt:formatNumber var="rating" value="${stats.avgRating}" pattern="0.0"
                                    maxFractionDigits="1" />
                                <div class="stat-val">${rating}</div>
                                <div class="stat-label">Đánh giá trung bình</div>
                            </div>
                        </div>
                    </div>

                    <div class="row g-4">
                        <!-- Recent Orders -->
                        <div class="col-lg-7">
                            <div class="content-card">
                                <div class="card-header-custom">
                                    <h3 class="card-title"><i class="bi bi-bag-check" style="color:var(--primary);"></i>
                                        Đơn hàng gần đây</h3>
                                    <a href="${pageContext.request.contextPath}/farmer/orders" class="btn-sm-green">Xem
                                        tất cả</a>
                                </div>
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>Mã ĐH</th>
                                            <th>Người mua</th>
                                            <th>Tổng tiền</th>
                                            <th>Trạng thái</th>
                                            <th>Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty recentOrders}">
                                                <c:forEach var="order" items="${recentOrders}">
                                                    <tr>
                                                        <td><strong>#${order.orderId}</strong></td>
                                                        <td>${order.buyerName}</td>
                                                        <td style="color:var(--primary);font-weight:700;">
                                                            <fmt:formatNumber value="${order.totalAmount}"
                                                                pattern="#,##0" />đ
                                                        </td>
                                                        <td>
                                                            <span class="badge-${order.statusBadgeClass}"
                                                                style="padding:4px 10px;border-radius:20px;font-size:11px;font-weight:700;">
                                                                ${order.statusLabel}
                                                            </span>
                                                        </td>
                                                        <td>
                                                            <c:if test="${order.status == 'PENDING'}">
                                                                <form
                                                                    action="${pageContext.request.contextPath}/farmer/orders/confirm"
                                                                    method="post" style="display:inline;">
                                                                    <input type="hidden" name="orderId"
                                                                        value="${order.orderId}">
                                                                    <button type="submit" class="btn-sm-green"
                                                                        style="font-size:11px;">✓ Xác nhận</button>
                                                                </form>
                                                            </c:if>
                                                        </td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="5" class="text-center text-muted py-4">Chưa có đơn hàng
                                                        nào</td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>

                        <!-- Market Prices -->
                        <div class="col-lg-5">
                            <div class="content-card">
                                <div class="card-header-custom">
                                    <h3 class="card-title"><i class="bi bi-bar-chart" style="color:#F9A825;"></i> Giá
                                        thị trường hôm nay</h3>
                                </div>
                                <div style="padding:16px 22px;">
                                    <c:forEach var="mp" items="${marketPrices}">
                                        <div class="market-price-row">
                                            <span>
                                                <span class="mp-name">${mp.productName}</span>
                                                <c:if test="${mp.regionName != null}">
                                                    <br><small
                                                        style="color:#9E9E9E;font-size:11px;">${mp.regionName}</small>
                                                </c:if>
                                            </span>
                                            <span class="mp-price">
                                                <fmt:formatNumber value="${mp.price}" pattern="#,##0" />đ/${mp.unit}
                                            </span>
                                        </div>
                                    </c:forEach>
                                    <c:if test="${empty marketPrices}">
                                        <p class="text-muted text-center py-3">Chưa có dữ liệu giá</p>
                                    </c:if>
                                    <div style="margin-top:12px;text-align:right;">
                                        <a href="${pageContext.request.contextPath}/admin/crawler"
                                            style="font-size:12px;color:var(--primary);">
                                            Cập nhật giá →
                                        </a>
                                    </div>
                                </div>
                            </div>

                            <!-- Reviews -->
                            <c:if test="${not empty reviews}">
                                <div class="content-card">
                                    <div class="card-header-custom">
                                        <h3 class="card-title"><i class="bi bi-star" style="color:#F9A825;"></i> Đánh
                                            giá gần đây</h3>
                                    </div>
                                    <div style="padding:16px 22px;">
                                        <c:forEach var="review" items="${reviews}" varStatus="st">
                                            <c:if test="${st.index < 3}">
                                                <div style="padding:10px 0;border-bottom:1px solid #F1F8E9;">
                                                    <div
                                                        style="display:flex;justify-content:space-between;align-items:center;margin-bottom:4px;">
                                                        <span
                                                            style="font-weight:600;font-size:13px;">${review.buyerName}</span>
                                                        <span class="stars">${review.starHtml}</span>
                                                    </div>
                                                    <p style="font-size:12px;color:#6B7B6B;margin:0;">${review.comment}
                                                    </p>
                                                </div>
                                            </c:if>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>
                        </div>
                    </div>

                    <!-- My Listings Table -->
                    <div class="content-card">
                        <div class="card-header-custom">
                            <h3 class="card-title"><i class="bi bi-box-seam" style="color:var(--primary);"></i> Sản phẩm
                                của tôi</h3>
                            <a href="${pageContext.request.contextPath}/farmer/listing/new" class="btn-sm-green">
                                <i class="bi bi-plus"></i> Thêm mới
                            </a>
                        </div>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>Sản phẩm</th>
                                    <th>Vùng</th>
                                    <th>Giá</th>
                                    <th>Số lượng</th>
                                    <th>Trạng thái</th>
                                    <th>Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${not empty listings}">
                                        <c:forEach var="listing" items="${listings}" varStatus="st">
                                            <c:if test="${st.index < 10}">
                                                <tr>
                                                    <td>
                                                        <strong>${listing.productName}</strong>
                                                        <c:if test="${listing.description != null}">
                                                            <br><small class="text-muted">${listing.description.length()
                                                                > 50 ? listing.description.substring(0,50).concat('...')
                                                                : listing.description}</small>
                                                        </c:if>
                                                    </td>
                                                    <td>${listing.regionName != null ? listing.regionName : '-'}</td>
                                                    <td style="color:var(--primary);font-weight:700;">
                                                        <fmt:formatNumber value="${listing.price}" pattern="#,##0" />
                                                        đ/${listing.unit}
                                                    </td>
                                                    <td>
                                                        <fmt:formatNumber value="${listing.quantity}" pattern="#,##0" />
                                                        ${listing.unit}
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${listing.status == 'ACTIVE'}"><span
                                                                    class="badge-active">● Đang bán</span></c:when>
                                                            <c:when test="${listing.status == 'SOLD_OUT'}"><span
                                                                    class="badge-sold">● Hết hàng</span></c:when>
                                                            <c:otherwise><span class="badge-sold">Ẩn</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td>
                                                        <div style="display:flex;gap:6px;">
                                                            <a href="${pageContext.request.contextPath}/farmer/listing/edit?id=${listing.listingId}"
                                                                class="btn-sm-green">
                                                                <i class="bi bi-pencil"></i>
                                                            </a>
                                                            <form
                                                                action="${pageContext.request.contextPath}/farmer/listing/delete"
                                                                method="post" style="display:inline;"
                                                                onsubmit="return confirm('Xóa sản phẩm này?')">
                                                                <input type="hidden" name="listingId"
                                                                    value="${listing.listingId}">
                                                                <button type="submit" class="btn-sm-red">
                                                                    <i class="bi bi-trash"></i>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            </c:if>
                                        </c:forEach>
                                    </c:when>
                                    <c:otherwise>
                                        <tr>
                                            <td colspan="6" class="text-center py-4">
                                                <div style="color:#9E9E9E;">
                                                    <div style="font-size:48px;margin-bottom:12px;">🌾</div>
                                                    <p>Bạn chưa có sản phẩm nào</p>
                                                    <a href="${pageContext.request.contextPath}/farmer/listing/new"
                                                        class="btn-sm-green" style="display:inline-flex;">
                                                        <i class="bi bi-plus-circle"></i> Đăng sản phẩm đầu tiên
                                                    </a>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>