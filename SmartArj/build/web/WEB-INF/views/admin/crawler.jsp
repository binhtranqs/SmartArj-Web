<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Admin - Crawler Dashboard | SmartAgri</title>
                <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
                <link
                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">
                <link rel="stylesheet"
                    href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
                <style>
                    :root {
                        --primary: #2E7D32;
                        --primary-dark: #1B5E20;
                        --bg-light: #F1F8E9;
                        --accent-yellow: #F9A825;
                    }

                    body {
                        font-family: 'Plus Jakarta Sans', sans-serif;
                        background: var(--bg-light);
                    }

                    .page-header {
                        background: linear-gradient(135deg, var(--primary-dark), var(--primary));
                        padding: 28px 32px;
                        color: white;
                    }

                    .page-header h1 {
                        font-family: 'Plus Jakarta Sans', sans-serif;
                        font-size: 2rem;
                        font-weight: 900;
                        margin: 0 0 6px;
                    }

                    .container-main {
                        max-width: 1200px;
                        margin: 32px auto;
                        padding: 0 24px;
                    }

                    .card-box {
                        background: white;
                        border-radius: 16px;
                        box-shadow: 0 4px 20px rgba(46, 125, 50, 0.1);
                        margin-bottom: 24px;
                        overflow: hidden;
                    }

                    .card-header-green {
                        padding: 16px 22px;
                        border-bottom: 2px solid #F1F8E9;
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
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
                        font-size: 13px;
                    }

                    .table th {
                        background: #F1F8E9;
                        font-size: 11px;
                        font-weight: 700;
                        letter-spacing: 0.5px;
                        color: var(--primary-dark);
                        padding: 10px 16px;
                    }

                    .table td {
                        padding: 10px 16px;
                        vertical-align: middle;
                        border-color: #F1F8E9;
                    }

                    .badge-success-custom {
                        background: #E8F5E9;
                        color: #2E7D32;
                        padding: 3px 10px;
                        border-radius: 20px;
                        font-size: 11px;
                        font-weight: 700;
                    }

                    .badge-fail {
                        background: #FFEBEE;
                        color: #C62828;
                        padding: 3px 10px;
                        border-radius: 20px;
                        font-size: 11px;
                        font-weight: 700;
                    }

                    .btn-run {
                        background: var(--accent-yellow);
                        color: #1A2E1A;
                        border: none;
                        border-radius: 12px;
                        padding: 10px 24px;
                        font-weight: 800;
                        font-size: 14px;
                        cursor: pointer;
                        transition: all .2s;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .btn-run:hover {
                        background: #FBC02D;
                        transform: translateY(-2px);
                    }

                    .source-link {
                        font-size: 12px;
                        color: var(--primary);
                    }
                </style>
            </head>

            <body>

                <div class="page-header">
                    <div style="max-width:1200px;margin:0 auto;">
                        <a href="${pageContext.request.contextPath}/admin"
                            style="color:rgba(255,255,255,0.75);font-size:13px;text-decoration:none;display:inline-flex;align-items:center;gap:6px;margin-bottom:14px;">
                            <i class="bi bi-arrow-left"></i> Admin Panel
                        </a>
                        <h1>🕷️ Market Price Crawler</h1>
                        <p style="opacity:.8;margin:0;">Thu thập giá nông sản tự động từ nongnghiepmoitruong.vn</p>
                    </div>
                </div>

                <div class="container-main">
                    <!-- Alert messages -->
                    <c:if test="${param.success != null}">
                        <div class="alert alert-success d-flex align-items-center gap-2 mb-4">
                            <i class="bi bi-check-circle-fill"></i>
                            Crawl thành công! Đã thu thập ${param.success} sản phẩm.
                        </div>
                    </c:if>
                    <c:if test="${param.error != null}">
                        <div class="alert alert-danger d-flex align-items-center gap-2 mb-4">
                            <i class="bi bi-x-circle-fill"></i>
                            Lỗi: ${param.error}
                        </div>
                    </c:if>

                    <div class="row g-4">
                        <!-- Control Panel -->
                        <div class="col-lg-4">
                            <div class="card-box">
                                <div class="card-header-green">
                                    <h3 class="card-title"><i class="bi bi-spider"></i> Điều khiển</h3>
                                </div>
                                <div style="padding:22px;">
                                    <p style="font-size:13px;color:#6B7B6B;margin-bottom:16px;">
                                        Crawler tự động chạy mỗi 24 giờ. Nhấn nút để chạy thủ công.
                                    </p>
                                    <form action="${pageContext.request.contextPath}/admin/crawler" method="post">
                                        <input type="hidden" name="action" value="crawl">
                                        <button type="submit" class="btn-run">
                                            <i class="bi bi-play-circle"></i> Chạy Crawler ngay
                                        </button>
                                    </form>
                                    <hr style="margin:20px 0;border-color:#F1F8E9;">
                                    <div style="font-size:12px;color:#9E9E9E;">
                                        <p style="margin:0 0 4px;"><strong style="color:#444;">Nguồn dữ liệu:</strong>
                                        </p>
                                        <a href="https://nongnghiepmoitruong.vn/gia-nong-san-hom-nay-tag111220/"
                                            target="_blank" class="source-link">nongnghiepmoitruong.vn →</a>
                                        <p style="margin:8px 0 0;color:#9E9E9E;">Lịch trình: mỗi 24 giờ sau khi deploy
                                        </p>
                                    </div>
                                </div>
                            </div>
                        </div>

                        <!-- Crawler Logs -->
                        <div class="col-lg-8">
                            <div class="card-box">
                                <div class="card-header-green">
                                    <h3 class="card-title"><i class="bi bi-journal-text"></i> Lịch sử Crawler</h3>
                                </div>
                                <table class="table">
                                    <thead>
                                        <tr>
                                            <th>#</th>
                                            <th>Thời gian</th>
                                            <th>Trạng thái</th>
                                            <th>Items</th>
                                            <th>Thời lượng</th>
                                            <th>Ghi chú</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:choose>
                                            <c:when test="${not empty crawlerLogs}">
                                                <c:forEach var="log" items="${crawlerLogs}">
                                                    <tr>
                                                        <td>${log.logId}</td>
                                                        <td>
                                                            <fmt:formatDate value="${log.runAt}"
                                                                pattern="dd/MM/yyyy HH:mm" />
                                                        </td>
                                                        <td>
                                                            <c:choose>
                                                                <c:when test="${log.status == 'SUCCESS'}"><span
                                                                        class="badge-success-custom">✓ Thành công</span>
                                                                </c:when>
                                                                <c:otherwise><span class="badge-fail">✗
                                                                        ${log.status}</span></c:otherwise>
                                                            </c:choose>
                                                        </td>
                                                        <td>${log.itemsCrawled}</td>
                                                        <td>${log.duration}ms</td>
                                                        <td style="font-size:11px;color:#9E9E9E;">${log.errorMsg}</td>
                                                    </tr>
                                                </c:forEach>
                                            </c:when>
                                            <c:otherwise>
                                                <tr>
                                                    <td colspan="6" class="text-center text-muted py-4">Chưa có log nào
                                                        - hãy chạy crawler lần đầu</td>
                                                </tr>
                                            </c:otherwise>
                                        </c:choose>
                                    </tbody>
                                </table>
                            </div>
                        </div>
                    </div>

                    <!-- Latest Market Prices -->
                    <div class="card-box">
                        <div class="card-header-green">
                            <h3 class="card-title"><i class="bi bi-bar-chart"></i> Giá nông sản mới nhất trong DB</h3>
                            <span style="font-size:12px;color:#9E9E9E;">${latestPrices.size()} records</span>
                        </div>
                        <table class="table">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Sản phẩm</th>
                                    <th>Vùng</th>
                                    <th>Giá</th>
                                    <th>Đơn vị</th>
                                    <th>Crawled At</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="mp" items="${latestPrices}">
                                    <tr>
                                        <td>${mp.priceId}</td>
                                        <td><strong>${mp.productName}</strong></td>
                                        <td>${mp.regionName}</td>
                                        <td style="color:var(--primary);font-weight:700;">
                                            <fmt:formatNumber value="${mp.price}" pattern="#,##0" />
                                        </td>
                                        <td>${mp.unit}</td>
                                        <td style="font-size:11px;color:#9E9E9E;">
                                            ${mp.formattedCrawledAt}
                                        </td>
                                    </tr>
                                </c:forEach>
                                <c:if test="${empty latestPrices}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">Chưa có dữ liệu giá thị
                                            trường</td>
                                    </tr>
                                </c:if>
                            </tbody>
                        </table>
                    </div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>