<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
        <%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>
                    <c:choose>
                        <c:when test="${action == 'create'}">Đăng sản phẩm mới</c:when>
                        <c:otherwise>Chỉnh sửa sản phẩm</c:otherwise>
                    </c:choose>
                    | SmartAgri Farmer
                </title>
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
                        --border: #C8E6C9;
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
                        font-family: 'Nunito', sans-serif;
                        font-weight: 900;
                        font-size: 1.8rem;
                        margin: 0 0 6px;
                    }

                    .page-header p {
                        margin: 0;
                        opacity: .8;
                        font-size: 14px;
                    }

                    .form-container {
                        max-width: 800px;
                        margin: 32px auto;
                        padding: 0 24px;
                    }

                    .form-card {
                        background: white;
                        border-radius: 20px;
                        box-shadow: 0 4px 30px rgba(46, 125, 50, 0.12);
                        overflow: hidden;
                    }

                    .form-section {
                        padding: 28px;
                        border-bottom: 1px solid #F1F8E9;
                    }

                    .form-section:last-child {
                        border-bottom: none;
                    }

                    .form-section-title {
                        font-weight: 700;
                        font-size: 14px;
                        color: var(--primary);
                        margin: 0 0 20px;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .form-label {
                        font-weight: 600;
                        font-size: 13px;
                        color: #444;
                    }

                    .form-control,
                    .form-select {
                        border: 2px solid #E0E0E0;
                        border-radius: 12px;
                        padding: 10px 14px;
                        font-size: 14px;
                        transition: all .2s;
                    }

                    .form-control:focus,
                    .form-select:focus {
                        border-color: var(--primary);
                        box-shadow: 0 0 0 4px rgba(46, 125, 50, 0.1);
                    }

                    textarea.form-control {
                        resize: vertical;
                        min-height: 100px;
                    }

                    .price-hint {
                        background: #FFF8E1;
                        border: 1px solid #FFE082;
                        border-radius: 10px;
                        padding: 12px 14px;
                        margin-top: 10px;
                        font-size: 12px;
                        color: #6D4C41;
                    }

                    .price-hint strong {
                        color: var(--primary);
                    }

                    .btn-submit {
                        background: var(--primary);
                        color: white;
                        border: none;
                        border-radius: 14px;
                        padding: 14px 32px;
                        font-size: 16px;
                        font-weight: 700;
                        cursor: pointer;
                        transition: all .2s;
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    .btn-submit:hover {
                        background: var(--primary-dark);
                        transform: translateY(-2px);
                        box-shadow: 0 4px 15px rgba(46, 125, 50, 0.3);
                        color: white;
                    }

                    .btn-back {
                        background: transparent;
                        color: var(--primary);
                        border: 2px solid var(--border);
                        border-radius: 14px;
                        padding: 12px 24px;
                        font-size: 14px;
                        font-weight: 600;
                        text-decoration: none;
                        transition: all .2s;
                    }

                    .btn-back:hover {
                        background: var(--bg-light);
                        color: var(--primary-dark);
                    }

                    .unit-addon {
                        border: 2px solid #E0E0E0;
                        border-left: none;
                        border-radius: 0 12px 12px 0;
                        background: var(--bg-light);
                        color: var(--primary);
                        font-weight: 600;
                        padding: 0 14px;
                    }

                    .input-group .form-control {
                        border-radius: 12px 0 0 12px !important;
                        border-right: none;
                    }

                    .status-options {
                        display: flex;
                        gap: 12px;
                        flex-wrap: wrap;
                    }

                    .status-radio {
                        display: none;
                    }

                    .status-label {
                        padding: 8px 16px;
                        border: 2px solid #E0E0E0;
                        border-radius: 20px;
                        font-size: 13px;
                        font-weight: 600;
                        cursor: pointer;
                        transition: all .2s;
                    }

                    .status-radio:checked+.status-label {
                        border-color: var(--primary);
                        background: #E8F5E9;
                        color: var(--primary);
                    }

                    .image-preview {
                        width: 100%;
                        height: 200px;
                        background: var(--bg-light);
                        border-radius: 12px;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: 48px;
                        border: 2px dashed var(--border);
                        margin-top: 10px;
                        overflow: hidden;
                        transition: all .2s;
                    }

                    .image-preview img {
                        width: 100%;
                        height: 100%;
                        object-fit: cover;
                    }

                    .alert-error {
                        background: #FFEBEE;
                        border: 1px solid #FFCDD2;
                        color: #C62828;
                        padding: 12px 16px;
                        border-radius: 12px;
                        margin: 0 28px 20px;
                        font-size: 13px;
                    }
                </style>
            </head>

            <body>

                <!-- Page Header -->
                <div class="page-header">
                    <div style="max-width:800px;margin:0 auto;">
                        <a href="${pageContext.request.contextPath}/farmer/dashboard"
                            style="color:rgba(255,255,255,0.8);text-decoration:none;font-size:13px;display:inline-flex;align-items:center;gap:6px;margin-bottom:12px;">
                            <i class="bi bi-arrow-left"></i> Quay lại Dashboard
                        </a>
                        <h1>
                            <c:choose>
                                <c:when test="${action == 'create'}">🌿 Đăng sản phẩm mới</c:when>
                                <c:otherwise>✏️ Chỉnh sửa sản phẩm</c:otherwise>
                            </c:choose>
                        </h1>
                        <p>Thông tin sẽ hiển thị trên Marketplace cho người mua</p>
                    </div>
                </div>

                <div class="form-container">
                    <!-- Error -->
                    <c:if test="${error != null}">
                        <div class="alert-error"><i class="bi bi-exclamation-circle"></i> ${error}</div>
                    </c:if>

                    <form method="post"
                        action="${pageContext.request.contextPath}/farmer/listing/${action == 'create' ? 'create' : 'update'}"
                        id="listing-form">

                        <c:if test="${action == 'update'}">
                            <input type="hidden" name="listingId" value="${listing.listingId}">
                        </c:if>

                        <div class="form-card">

                            <!-- Section 1: Basic Info -->
                            <div class="form-section">
                                <div class="form-section-title"><i class="bi bi-info-circle"></i> Thông tin sản phẩm
                                </div>
                                <div class="row g-3">
                                    <div class="col-12">
                                        <label class="form-label">Tên sản phẩm *</label>
                                        <input type="text" class="form-control" name="productName" required
                                            placeholder="VD: Cà phê nhân xô Robusta"
                                            value="${listing.productName != null ? listing.productName : ''}"
                                            oninput="updatePriceHint()">
                                    </div>
                                    <div class="col-12">
                                        <label class="form-label">Mô tả sản phẩm</label>
                                        <textarea class="form-control" name="description"
                                            placeholder="Mô tả chất lượng, xuất xứ, cách bảo quản...">${listing.description != null ? listing.description : ''}</textarea>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Vùng trồng</label>
                                        <select class="form-select" name="regionId">
                                            <option value="">-- Chọn vùng --</option>
                                            <c:forEach var="region" items="${regions}">
                                                <option value="${region.regionId}" ${listing.regionId==region.regionId
                                                    ? 'selected' : '' }>
                                                    ${region.regionName}
                                                </option>
                                            </c:forEach>
                                        </select>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Đơn vị tính</label>
                                        <select class="form-select" name="unit">
                                            <option value="kg" ${listing.unit=='kg' ? 'selected' : '' }>kg</option>
                                            <option value="tấn" ${listing.unit=='tấn' ? 'selected' : '' }>tấn</option>
                                            <option value="tạ" ${listing.unit=='tạ' ? 'selected' : '' }>tạ</option>
                                            <option value="bao" ${listing.unit=='bao' ? 'selected' : '' }>bao</option>
                                            <option value="thùng" ${listing.unit=='thùng' ? 'selected' : '' }>thùng
                                            </option>
                                            <option value="trái" ${listing.unit=='trái' ? 'selected' : '' }>trái
                                            </option>
                                        </select>
                                    </div>
                                </div>
                            </div>

                            <!-- Section 2: Price & Quantity -->
                            <div class="form-section">
                                <div class="form-section-title"><i class="bi bi-currency-exchange"></i> Giá & Số lượng
                                </div>
                                <div class="row g-3">
                                    <div class="col-md-6">
                                        <label class="form-label">Giá bán (đồng) *</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" name="price" required
                                                placeholder="97000" min="0" step="100"
                                                value="${listing.price != null ? listing.price : ''}" id="price-input"
                                                oninput="updatePriceHint()">
                                            <span class="unit-addon">đ</span>
                                        </div>
                                        <div class="price-hint" id="price-hint" style="display:none;">
                                            💡 Giá thị trường tham chiếu: <strong id="market-ref">Đang tải...</strong>
                                        </div>
                                    </div>
                                    <div class="col-md-6">
                                        <label class="form-label">Số lượng *</label>
                                        <div class="input-group">
                                            <input type="number" class="form-control" name="quantity" required
                                                placeholder="1000" min="0" step="1"
                                                value="${listing.quantity != null ? listing.quantity : ''}">
                                            <span class="unit-addon" id="qty-unit">kg</span>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Section 3: Image -->
                            <div class="form-section">
                                <div class="form-section-title"><i class="bi bi-image"></i> Hình ảnh</div>
                                <div class="row g-3">
                                    <div class="col-md-8">
                                        <label class="form-label">URL hình ảnh</label>
                                        <input type="url" class="form-control" name="imageUrl" id="image-url"
                                            placeholder="https://example.com/image.jpg"
                                            value="${listing.imageUrl != null ? listing.imageUrl : ''}"
                                            oninput="previewImage()">
                                        <small class="text-muted">Dán đường dẫn ảnh từ internet (jpg, png, webp)</small>
                                    </div>
                                    <div class="col-md-4">
                                        <div class="image-preview" id="image-preview">
                                            <c:choose>
                                                <c:when test="${listing.imageUrl != null && listing.imageUrl != ''}">
                                                    <img src="${listing.imageUrl}" alt="preview" id="preview-img">
                                                </c:when>
                                                <c:otherwise>
                                                    <span id="preview-emoji">🌿</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Section 4: Status -->
                            <div class="form-section">
                                <div class="form-section-title"><i class="bi bi-toggle-on"></i> Trạng thái</div>
                                <div class="status-options">
                                    <c:set var="curStatus"
                                        value="${listing.status != null ? listing.status : 'ACTIVE'}" />
                                    <input type="radio" name="status" value="ACTIVE" id="status-active"
                                        class="status-radio" ${curStatus=='ACTIVE' ? 'checked' : '' }>
                                    <label for="status-active" class="status-label">● Đang bán</label>

                                    <input type="radio" name="status" value="SOLD_OUT" id="status-sold"
                                        class="status-radio" ${curStatus=='SOLD_OUT' ? 'checked' : '' }>
                                    <label for="status-sold" class="status-label">⚠ Hết hàng</label>

                                    <input type="radio" name="status" value="HIDDEN" id="status-hidden"
                                        class="status-radio" ${curStatus=='HIDDEN' ? 'checked' : '' }>
                                    <label for="status-hidden" class="status-label">🔒 Ẩn</label>
                                </div>
                            </div>

                            <!-- Footer Actions -->
                            <div
                                style="padding:22px 28px;display:flex;gap:14px;background:#FAFAFA;justify-content:flex-end;">
                                <a href="${pageContext.request.contextPath}/farmer/listing" class="btn-back">Hủy</a>
                                <button type="submit" class="btn-submit">
                                    <i class="bi bi-check-circle"></i>
                                    <c:choose>
                                        <c:when test="${action == 'create'}">Đăng sản phẩm</c:when>
                                        <c:otherwise>Cập nhật</c:otherwise>
                                    </c:choose>
                                </button>
                            </div>
                        </div>
                    </form>
                </div>

                <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
                <script>
                    // Sync unit display with selected unit
                    document.querySelector('select[name=unit]')?.addEventListener('change', function () {
                        document.getElementById('qty-unit').textContent = this.value;
                    });

                    // Image preview
                    function previewImage() {
                        const url = document.getElementById('image-url').value;
                        const preview = document.getElementById('image-preview');
                        if (url) {
                            preview.innerHTML = '<img src="' + url + '" alt="preview" style="width:100%;height:100%;object-fit:cover;" onerror="this.parentElement.innerHTML=\'<span>❌ URL không hợp lệ</span>\'">';
                        } else {
                            preview.innerHTML = '<span id="preview-emoji">🌿</span>';
                        }
                    }

                    // Fetch market price reference
                    let priceHintTimer = null;
                    function updatePriceHint() {
                        const productName = document.querySelector('input[name=productName]').value.trim();
                        const hint = document.getElementById('price-hint');
                        const ref = document.getElementById('market-ref');

                        // Ẩn khi chưa gõ tên
                        if (productName.length === 0) {
                            hint.style.display = 'none';
                            return;
                        }

                        // Hiện box ngay với trạng thái loading
                        hint.style.display = 'block';
                        ref.textContent = 'Đang tải...';

                        // Debounce 500ms tránh spam API
                        clearTimeout(priceHintTimer);
                        priceHintTimer = setTimeout(() => {
                            const encodedName = encodeURIComponent(productName);
                            fetch('${pageContext.request.contextPath}/api/market-prices?q=' + encodedName)
                                .then(r => r.json())
                                .then(data => {
                                    if (data.length > 0) {
                                        const prices = data.map(p => p.label + ': ' + p.formattedPrice).join(' | ');
                                        ref.innerHTML = '<strong style="color:#2E7D32">' + prices + '</strong>';
                                    } else {
                                        ref.textContent = 'Chưa có dữ liệu tham chiếu cho sản phẩm này';
                                    }
                                })
                                .catch(() => {
                                    ref.textContent = 'Không thể tải dữ liệu thị trường';
                                });
                        }, 500);
                    }
                </script>
            </body>

            </html>