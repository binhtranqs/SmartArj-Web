<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Gợi ý cây trồng | SmartAgri</title>
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
                        --accent-yellow: #F9A825;
                    }

                    body {
                        font-family: 'Plus Jakarta Sans', sans-serif;
                        background: var(--bg-light);
                    }

                    .hero {
                        background: linear-gradient(135deg, var(--primary-dark) 0%, var(--primary) 60%, #388E3C 100%);
                        padding: 52px 32px;
                        text-align: center;
                        color: white;
                    }

                    .hero h1 {
                        font-family: 'Nunito', sans-serif;
                        font-size: 2.5rem;
                        font-weight: 900;
                        margin: 0 0 12px;
                    }

                    .hero p {
                        font-size: 1.05rem;
                        opacity: .85;
                        margin: 0 0 28px;
                    }

                    .zone-selector {
                        display: flex;
                        gap: 12px;
                        justify-content: center;
                        flex-wrap: wrap;
                        max-width: 600px;
                        margin: 0 auto;
                    }

                    .zone-selector select {
                        flex: 1;
                        padding: 12px 16px;
                        border-radius: 14px;
                        border: none;
                        font-size: 14px;
                        font-weight: 600;
                        background: rgba(255, 255, 255, 0.2);
                        color: white;
                        backdrop-filter: blur(8px);
                        outline: none;
                        cursor: pointer;
                    }

                    .zone-selector select option {
                        color: #1A2E1A;
                        background: white;
                    }

                    .zone-selector select::placeholder {
                        color: rgba(255, 255, 255, 0.7);
                    }

                    .btn-search {
                        background: var(--accent-yellow);
                        color: #1A2E1A;
                        border: none;
                        border-radius: 14px;
                        padding: 12px 28px;
                        font-size: 14px;
                        font-weight: 800;
                        cursor: pointer;
                        transition: all .2s;
                    }

                    .btn-search:hover {
                        background: #FBC02D;
                        transform: translateY(-2px);
                    }

                    .results {
                        max-width: 1000px;
                        margin: 40px auto;
                        padding: 0 24px;
                    }

                    .results-header {
                        text-align: center;
                        margin-bottom: 32px;
                    }

                    .results-header h2 {
                        font-family: 'Nunito', sans-serif;
                        font-size: 1.8rem;
                        font-weight: 900;
                        color: var(--primary-dark);
                    }

                    .results-header .zone-tag {
                        display: inline-block;
                        background: var(--primary);
                        color: white;
                        padding: 4px 16px;
                        border-radius: 20px;
                        font-size: 14px;
                        font-weight: 600;
                        margin-bottom: 8px;
                    }

                    .crop-grid {
                        display: grid;
                        grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                        gap: 20px;
                    }

                    .crop-card {
                        background: white;
                        border-radius: 20px;
                        overflow: hidden;
                        box-shadow: 0 4px 20px rgba(46, 125, 50, 0.1);
                        transition: all .3s;
                        border-top: 4px solid var(--primary);
                    }

                    .crop-card:hover {
                        transform: translateY(-6px);
                        box-shadow: 0 12px 32px rgba(46, 125, 50, 0.2);
                    }

                    .crop-card-header {
                        height: 120px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 60px;
                        position: relative;
                    }

                    .crop-body {
                        padding: 20px;
                    }

                    .crop-name {
                        font-family: 'Nunito', sans-serif;
                        font-size: 1.2rem;
                        font-weight: 900;
                        color: var(--primary-dark);
                        margin: 0 0 8px;
                    }

                    .crop-desc {
                        font-size: 13px;
                        color: #6B7B6B;
                        margin: 0 0 16px;
                        line-height: 1.5;
                    }

                    .crop-cta {
                        display: flex;
                        gap: 8px;
                    }

                    .btn-explore {
                        flex: 1;
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 10px;
                        padding: 9px;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        text-decoration: none;
                        text-align: center;
                        transition: all .2s;
                    }

                    .btn-explore:hover {
                        background: var(--primary-dark);
                        color: white;
                    }

                    .btn-find {
                        background: var(--bg-light);
                        color: var(--primary);
                        border: 2px solid #C8E6C9;
                        border-radius: 10px;
                        padding: 9px 14px;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        text-decoration: none;
                        text-align: center;
                        transition: all .2s;
                    }

                    .btn-find:hover {
                        background: var(--primary);
                        color: white;
                        border-color: var(--primary);
                    }

                    .back-link {
                        display: flex;
                        align-items: center;
                        gap: 6px;
                        color: rgba(255, 255, 255, 0.8);
                        text-decoration: none;
                        font-size: 13px;
                        margin-bottom: 16px;
                        justify-content: flex-start;
                        max-width: 1000px;
                        margin-left: auto;
                        margin-right: auto;
                    }
                </style>
            </head>

            <body>

                <div class="hero">
                    <div style="max-width:700px;margin:0 auto;">
                        <a href="${pageContext.request.contextPath}/marketplace"
                            style="color:rgba(255,255,255,0.75);text-decoration:none;font-size:13px;display:inline-flex;align-items:center;gap:6px;margin-bottom:20px;">
                            <i class="bi bi-arrow-left"></i> Về Marketplace
                        </a>
                        <div style="font-size:64px;margin-bottom:12px;">🌱</div>
                        <h1>Gợi ý Cây Trồng Thông Minh</h1>
                        <p>Tìm cây trồng phù hợp nhất với vùng địa lý và điều kiện khí hậu của bạn</p>

                        <form action="${pageContext.request.contextPath}/crop-recommend" method="get">
                            <div class="zone-selector">
                                <select name="region" id="region-select">
                                    <option value="">-- Chọn vùng địa lý --</option>
                                    <c:forEach var="region" items="${regions}">
                                        <option value="${region.regionName}" ${selectedZone==region.regionName
                                            ? 'selected' : '' }>
                                            ${region.regionName}
                                        </option>
                                    </c:forEach>
                                </select>
                                <button type="submit" class="btn-search">
                                    <i class="bi bi-search"></i> Gợi ý ngay
                                </button>
                            </div>
                        </form>
                    </div>
                </div>

                <div class="results">
                    <div class="results-header">
                        <c:choose>
                            <c:when test="${selectedZone != null && selectedZone != ''}">
                                <div class="zone-tag">📍 ${selectedZone}</div>
                                <h2>Cây trồng phù hợp</h2>
                                <p style="color:#6B7B6B;">Dựa trên điều kiện khí hậu, thổ nhưỡng và kinh nghiệm canh tác
                                </p>
                            </c:when>
                            <c:otherwise>
                                <h2>Cây trồng phổ biến Việt Nam</h2>
                                <p style="color:#6B7B6B;">Chọn vùng địa lý để nhận gợi ý cụ thể hơn</p>
                            </c:otherwise>
                        </c:choose>
                    </div>

                    <div class="crop-grid">
                        <c:forEach var="crop" items="${recommendations}">
                            <div class="crop-card">
                                <div class="crop-card-header" style="background:${crop.color}22;">
                                    <span>${crop.emoji}</span>
                                </div>
                                <div class="crop-body">
                                    <h3 class="crop-name">${crop.name}</h3>
                                    <p class="crop-desc">${crop.description}</p>
                                    <div class="crop-cta">
                                        <a href="${pageContext.request.contextPath}/marketplace?keyword=${crop.name}"
                                            class="btn-explore">
                                            <i class="bi bi-shop"></i> Tìm trên chợ
                                        </a>
                                        <a href="#" class="btn-find" title="Tìm hiểu thêm">
                                            <i class="bi bi-info-circle"></i>
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </div>

                    <!-- CTA Section -->
                    <div
                        style="margin-top:48px;background:linear-gradient(135deg,var(--primary-dark),var(--primary));border-radius:20px;padding:40px;text-align:center;color:white;">
                        <div style="font-size:48px;margin-bottom:12px;">🛒</div>
                        <h3 style="font-family:'Nunito',sans-serif;font-weight:900;margin:0 0 8px;">Tìm nông sản theo
                            vùng</h3>
                        <p style="opacity:.85;margin:0 0 20px;">Mua trực tiếp từ nông dân địa phương</p>
                        <a href="${pageContext.request.contextPath}/marketplace${selectedZone != null ? '?keyword='.concat(selectedZone) : ''}"
                            style="background:var(--accent-yellow);color:#1A2E1A;padding:12px 32px;border-radius:50px;text-decoration:none;font-weight:800;display:inline-block;">
                            Vào Marketplace →
                        </a>
                    </div>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
            </body>

            </html>