<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Sản phẩm của tôi | Farmer</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Nunito:wght@700;800;900&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
                <style>
                    :root {
                        --primary: #2E7D32;
                        --primary-dark: #1B5E20;
                        --bg-light: #F1F8E9;
                    }

                    body {
                        font-family: 'Plus Jakarta Sans', sans-serif;
                        background: var(--bg-light);
                    }

                    .top-bar {
                        background: linear-gradient(135deg, var(--primary-dark), var(--primary));
                        padding: 14px 24px;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                    }

                    .top-bar a {
                        color: rgba(255, 255, 255, .85);
                        text-decoration: none;
                        font-size: 13px;
                    }

                    .top-bar h2 {
                        color: white;
                        font-family: 'Nunito', sans-serif;
                        font-weight: 900;
                        margin: 0;
                        font-size: 1.2rem;
                    }

                    .container-main {
                        max-width: 1200px;
                        margin: 28px auto;
                        padding: 0 24px;
                    }

                    .actions-bar {
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        margin-bottom: 20px;
                        flex-wrap: wrap;
                        gap: 12px;
                    }

                    .page-title {
                        font-family: 'Nunito', sans-serif;
                        font-size: 1.5rem;
                        font-weight: 900;
                        color: var(--primary-dark);
                        margin: 0;
                    }

                    .btn-new {
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 12px;
                        padding: 10px 20px;
                        font-weight: 700;
                        font-size: 14px;
                        text-decoration: none;
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        transition: all .2s;
                    }

                    .btn-new:hover {
                        background: var(--primary-dark);
                        color: white;
                    }

                    .listings-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                        gap: 20px;
                    }

                    .listing-card {
                        background: white;
                        border-radius: 16px;
                        box-shadow: 0 4px 16px rgba(46, 125, 50, 0.1);
                        overflow: hidden;
                        transition: all .3s;
                    }

                    .listing-card:hover {
                        transform: translateY(-4px);
                        box-shadow: 0 8px 28px rgba(46, 125, 50, 0.18);
                    }

                    .listing-img {
                        height: 140px;
                        background: var(--bg-light);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 52px;
                    }

                    .listing-body {
                        padding: 16px;
                    }

                    .listing-name {
                        font-weight: 700;
                        font-size: 15px;
                        color: var(--primary-dark);
                        margin: 0 0 6px;
                    }

                    .listing-region {
                        font-size: 12px;
                        color: #9E9E9E;
                        margin: 0 0 10px;
                    }

                    .listing-price {
                        font-family: 'Nunito', sans-serif;
                        font-size: 1.2rem;
                        font-weight: 900;
                        color: var(--primary);
                    }

                    .listing-qty {
                        font-size: 12px;
                        color: #9E9E9E;
                    }

                    .listing-footer {
                        padding: 12px 16px;
                        background: #FAFAFA;
                        display: flex;
                        gap: 8px;
                    }

                    .btn-edit {
                        flex: 1;
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 10px;
                        padding: 8px;
                        font-size: 13px;
                        font-weight: 600;
                        text-decoration: none;
                        text-align: center;
                        transition: all .2s;
                    }

                    .btn-edit:hover {
                        background: var(--primary-dark);
                        color: white;
                    }

                    .btn-del {
                        background: #FFEBEE;
                        color: #C62828;
                        border: none;
                        border-radius: 10px;
                        padding: 8px 12px;
                        font-size: 13px;
                        cursor: pointer;
                        transition: all .2s;
                    }

                    .btn-del:hover {
                        background: #C62828;
                        color: white;
                    }

                    .status-pill {
                        font-size: 10px;
                        font-weight: 700;
                        padding: 3px 8px;
                        border-radius: 20px;
                    }

                    .pill-active {
                        background: #E8F5E9;
                        color: #2E7D32;
                    }

                    .pill-sold {
                        background: #FFF8E1;
                        color: #E65100;
                    }

                    .pill-hidden {
                        background: #EEEEEE;
                        color: #757575;
                    }
                </style>
            </head>

            <body>
                <div class="top-bar">
                    <a href="${pageContext.request.contextPath}/farmer/dashboard"><i class="bi bi-arrow-left"></i>
                        Dashboard</a>
                    <h2>🌿 Sản phẩm của tôi</h2>
                    <a href="${pageContext.request.contextPath}/marketplace">Xem chợ →</a>
                </div>

                <div class="container-main">
                    <!-- Messages -->
                    <c:if test="${param.success == 'created'}">
                        <div class="alert alert-success mb-4">✓ Đã đăng sản phẩm thành công!</div>
                    </c:if>
                    <c:if test="${param.success == 'updated'}">
                        <div class="alert alert-success mb-4">✓ Đã cập nhật sản phẩm!</div>
                    </c:if>
                    <c:if test="${param.success == 'deleted'}">
                        <div class="alert alert-info mb-4">✓ Đã xóa sản phẩm!</div>
                    </c:if>

                    <div class="actions-bar">
                        <h1 class="page-title">Danh sách sản phẩm (${listings.size()})</h1>
                        <a href="${pageContext.request.contextPath}/farmer/listing/new" class="btn-new">
                            <i class="bi bi-plus-lg"></i> Đăng mới
                        </a>
                    </div>

                    <c:choose>
                        <c:when test="${not empty listings}">
                            <div class="listings-grid">
                                <c:forEach var="listing" items="${listings}">
                                    <div class="listing-card">
                                        <div class="listing-img">
                                            <c:choose>
                                                <c:when test="${listing.imageUrl != null && listing.imageUrl != ''}">
                                                    <img src="${listing.imageUrl}" alt="${listing.productName}"
                                                        style="width:100%;height:100%;object-fit:cover;">
                                                </c:when>
                                                <c:otherwise>
                                                    <c:choose>
                                                        <c:when
                                                            test="${listing.productName.toLowerCase().contains('cà phê')}">
                                                            ☕</c:when>
                                                        <c:when
                                                            test="${listing.productName.toLowerCase().contains('tiêu')}">
                                                            🌶️</c:when>
                                                        <c:when
                                                            test="${listing.productName.toLowerCase().contains('sầu riêng')}">
                                                            🍈</c:when>
                                                        <c:otherwise>🌿</c:otherwise>
                                                    </c:choose>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                <div class="listing-body">
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:6px;">
                        <span class="listing-name">${listing.productName}</span>
                        <c:choose>
                            <c:when test="${listing.status == 'ACTIVE'}"><span class="status-pill pill-active">●
                                    Bán</span></c:when>
                            <c:when test="${listing.status == 'SOLD_OUT'}"><span
                                    class="status-pill pill-sold">Hết</span></c:when>
                            <c:otherwise><span class="status-pill pill-hidden">Ẩn</span></c:otherwise>
                        </c:choose>
                    </div>
                    <p class="listing-region"><i class="bi bi-geo-alt"></i> ${listing.regionName != null ?
                        listing.regionName : 'Chưa chọn vùng'}</p>
                    <div class="listing-price">
                        <fmt:formatNumber value="${listing.price}" pattern="#,##0" />đ/${listing.unit}
                    </div>
                    <div class="listing-qty">Còn:
                        <fmt:formatNumber value="${listing.quantity}" pattern="#,##0" /> ${listing.unit}
                    </div>
                </div>
                <div class="listing-footer">
                    <a href="${pageContext.request.contextPath}/farmer/listing/edit?id=${listing.listingId}"
                        class="btn-edit">
                        <i class="bi bi-pencil"></i> Chỉnh sửa
                    </a>
                    <%-- Nút toggle status --%>
                    <c:choose>
                        <c:when test="${listing.status == 'SOLD_OUT' || listing.status == 'HIDDEN'}">
                            <form action="${pageContext.request.contextPath}/farmer/listing/toggle-status" method="post" style="display:inline;">
                                <input type="hidden" name="listingId" value="${listing.listingId}">
                                <input type="hidden" name="status" value="ACTIVE">
                                <button type="submit" class="btn-edit"
                                        style="background:#E8F5E9;color:#2E7D32;border:1.5px solid #A5D6A7;padding:7px 12px;border-radius:10px;font-size:12px;font-weight:700;cursor:pointer;"
                                        title="Mở bán lại sản phẩm này">
                                    <i class="bi bi-play-circle-fill"></i> Mở bán
                                </button>
                            </form>
                        </c:when>
                        <c:when test="${listing.status == 'ACTIVE'}">
                            <form action="${pageContext.request.contextPath}/farmer/listing/toggle-status" method="post" style="display:inline;">
                                <input type="hidden" name="listingId" value="${listing.listingId}">
                                <input type="hidden" name="status" value="SOLD_OUT">
                                <button type="submit" class="btn-edit"
                                        style="background:#FFF8E1;color:#E65100;border:1.5px solid #FFE082;padding:7px 12px;border-radius:10px;font-size:12px;font-weight:700;cursor:pointer;"
                                        title="Tạm dừng bán sản phẩm">
                                    <i class="bi bi-pause-circle-fill"></i> Tạm ẩn
                                </button>
                            </form>
                        </c:when>
                    </c:choose>
                    <form action="${pageContext.request.contextPath}/farmer/listing/delete" method="post"
                        onsubmit="return confirm('Xóa sản phẩm này?')">
                        <input type="hidden" name="listingId" value="${listing.listingId}">
                        <button type="submit" class="btn-del"><i class="bi bi-trash"></i></button>
                    </form>
                </div>

                </div>
                </c:forEach>
                </div>
                </c:when>
                <c:otherwise>
                    <div style="text-align:center;padding:80px 20px;color:#9E9E9E;">
                        <div style="font-size:72px;margin-bottom:20px;">🌾</div>
                        <h3 style="font-family:'Nunito',sans-serif;font-weight:900;color:var(--primary-dark);">Chưa có
                            sản phẩm</h3>
                        <p>Đăng nông sản đầu tiên của bạn!</p>
                        <a href="${pageContext.request.contextPath}/farmer/listing/new"
                            style="background:var(--primary);color:white;padding:12px 28px;border-radius:14px;text-decoration:none;font-weight:700;display:inline-block;">
                            + Đăng ngay
                        </a>
                    </div>
                </c:otherwise>
                </c:choose>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>