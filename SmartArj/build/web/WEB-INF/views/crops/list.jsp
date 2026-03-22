<%@ page contentType="text/html;charset=UTF-8" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>

        <jsp:include page="/WEB-INF/views/common/header.jsp">
            <jsp:param name="title" value="Cây trồng" />
            <jsp:param name="page" value="crops" />
        </jsp:include>

        <style>
            /* Modern Crop Selection Styling */
            :root {
                --primary: #22c55e;
                --primary-hover: #16a34a;
                --surface: #ffffff;
                --surface-hover: #f8fafc;
                --text: #1e293b;
                --text-muted: #64748b;
                --border: #e2e8f0;
                --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
                --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
                --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
            }

            .page-header {
                display: flex;
                justify-content: space-between;
                align-items: flex-end;
                margin-bottom: 2rem;
                padding-bottom: 1rem;
                border-bottom: 1px solid var(--border);
            }

            .page-title {
                font-size: 2.25rem;
                font-weight: 800;
                color: var(--text);
                margin-bottom: 0.5rem;
                letter-spacing: -0.025em;
            }

            .page-subtitle {
                color: var(--text-muted);
                font-size: 1.125rem;
            }

            .controls-bar {
                display: flex;
                gap: 1.5rem;
                margin-bottom: 2rem;
                flex-wrap: wrap;
                align-items: center;
                background: rgba(255, 255, 255, 0.92);
                padding: 1.5rem;
                border-radius: 16px;
                box-shadow: var(--shadow-sm);
                border: 1px solid var(--border);
                backdrop-filter: blur(10px);
            }

            .input-group {
                display: flex;
                flex-direction: column;
                gap: 0.5rem;
                flex: 1;
                min-width: 250px;
            }

            .input-group label {
                font-size: 0.875rem;
                font-weight: 600;
                color: var(--text-muted);
                text-transform: uppercase;
                letter-spacing: 0.05em;
            }

            .form-select,
            .form-input {
                width: 100%;
                padding: 0.875rem 1rem;
                border: 1px solid var(--border);
                border-radius: 12px;
                font-size: 1rem;
                color: var(--text);
                background-color: #f8fafc;
                transition: all 0.2s;
                outline: none;
            }

            .form-select:hover,
            .form-input:hover {
                background-color: #f1f5f9;
            }

            .form-select:focus,
            .form-input:focus {
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(34, 197, 94, 0.2);
                background-color: #fff;
            }

            .filter-tabs {
                display: flex;
                gap: 0.5rem;
                margin-bottom: 2rem;
                overflow-x: auto;
                padding-bottom: 0.5rem;
                -webkit-overflow-scrolling: touch;
                scrollbar-width: none;
            }

            .filter-tabs::-webkit-scrollbar {
                display: none;
            }

            .filter-tab {
                padding: 0.75rem 1.5rem;
                border-radius: 9999px;
                background: #f1f5f9;
                color: var(--text-muted);
                font-weight: 600;
                font-size: 0.95rem;
                cursor: pointer;
                border: none;
                white-space: nowrap;
                transition: all 0.2s;
            }

            .filter-tab:hover {
                background: #e2e8f0;
                color: var(--text);
            }

            .filter-tab.active {
                background: var(--primary);
                color: white;
                box-shadow: 0 4px 6px -1px rgba(34, 197, 94, 0.4);
            }

            .section-title {
                font-size: 1.5rem;
                font-weight: 700;
                color: var(--text);
                margin-bottom: 1.5rem;
                display: flex;
                align-items: center;
                gap: 0.75rem;
            }

            .crop-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
                gap: 1.5rem;
                margin-bottom: 3rem;
            }

            .crop-card {
                background: rgba(255, 255, 255, 0.92);
                border-radius: 20px;
                overflow: hidden;
                box-shadow: var(--shadow-md);
                border: 1px solid var(--border);
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                position: relative;
                display: flex;
                flex-direction: column;
            }

            .crop-card:hover {
                transform: translateY(-4px);
                box-shadow: var(--shadow-lg);
            }

            .crop-img-wrap {
                height: 180px;
                width: 100%;
                overflow: hidden;
                position: relative;
            }

            .crop-img {
                width: 100%;
                height: 100%;
                object-fit: cover;
                transition: transform 0.5s ease;
            }

            .crop-card:hover .crop-img {
                transform: scale(1.05);
            }

            .crop-category-badge {
                position: absolute;
                top: 1rem;
                left: 1rem;
                background: rgba(255, 255, 255, 0.9);
                backdrop-filter: blur(4px);
                color: var(--text);
                padding: 0.25rem 0.75rem;
                border-radius: 9999px;
                font-size: 0.75rem;
                font-weight: 700;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            }

            .crop-body {
                padding: 1.5rem;
                flex: 1;
                display: flex;
                flex-direction: column;
            }

            .crop-name {
                font-size: 1.25rem;
                font-weight: 700;
                color: var(--text);
                margin-bottom: 1rem;
            }

            .crop-stats {
                display: flex;
                flex-direction: column;
                gap: 0.75rem;
                margin-bottom: 1.5rem;
            }

            .stat-row {
                display: flex;
                align-items: center;
                gap: 0.5rem;
                font-size: 0.9rem;
                color: var(--text-muted);
            }

            .stat-icon {
                display: flex;
                align-items: center;
                justify-content: center;
                width: 24px;
                height: 24px;
                background: #f1f5f9;
                border-radius: 6px;
                color: var(--primary);
            }

            .btn-select {
                width: 100%;
                padding: 0.875rem;
                background: var(--primary);
                color: white;
                border: none;
                border-radius: 12px;
                font-weight: 600;
                font-size: 1rem;
                cursor: pointer;
                transition: all 0.2s;
                margin-top: auto;
            }

            .btn-select:hover {
                background: var(--primary-hover);
                transform: scale(1.02);
            }

            .btn-select:active {
                transform: scale(0.98);
            }

            .btn-remove {
                background: #ef4444;
            }

            .btn-remove:hover {
                background: #dc2626;
            }

            .zone-crops-section {
                background: #f8fafc;
                border-radius: 20px;
                padding: 2rem;
                margin-bottom: 3rem;
                border: 1px dashed var(--border);
            }

            .custom-crop-section {
                text-align: center;
                padding: 4rem 2rem;
                background: linear-gradient(135deg, #f0fdf4 0%, #dcfce7 100%);
                border-radius: 24px;
                margin-top: 2rem;
            }

            .custom-crop-title {
                font-size: 1.5rem;
                font-weight: 700;
                color: #166534;
                margin-bottom: 1rem;
            }

            .btn-custom {
                background: #166534;
                color: white;
                padding: 0.875rem 2rem;
                border-radius: 9999px;
                font-weight: 600;
                border: none;
                cursor: pointer;
                transition: all 0.2s;
                font-size: 1.1rem;
                box-shadow: 0 4px 6px -1px rgba(22, 101, 52, 0.4);
            }

            .btn-custom:hover {
                background: #14532d;
                transform: translateY(-2px);
                box-shadow: 0 10px 15px -3px rgba(22, 101, 52, 0.4);
            }

            /* Modal Styling */
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(15, 23, 42, 0.6);
                backdrop-filter: blur(4px);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 1000;
                opacity: 0;
                pointer-events: none;
                transition: opacity 0.3s;
            }

            .modal-overlay.active {
                opacity: 1;
                pointer-events: auto;
            }

            .modal-content {
                background: white;
                width: 100%;
                max-width: 600px;
                border-radius: 24px;
                padding: 2rem;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
                transform: translateY(20px) scale(0.95);
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
                max-height: 90vh;
                overflow-y: auto;
            }

            .modal-overlay.active .modal-content {
                transform: translateY(0) scale(1);
            }

            .modal-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 1.5rem;
            }

            .modal-close {
                background: none;
                border: none;
                font-size: 1.5rem;
                color: var(--text-muted);
                cursor: pointer;
                padding: 0.5rem;
            }

            .form-grid {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 1rem;
            }

            .form-full {
                grid-column: span 2;
            }
        </style>

        <div class="page-container">
            <div class="page-header">
                <div>
                    <h1 class="page-title">🌾 Cây trồng</h1>

                </div>
            </div>

            <div class="controls-bar">
                <div class="input-group">
                    <label for="zoneSelect">Chọn Vùng Trồng</label>
                    <select id="zoneSelect" class="form-select">
                        <option value="">-- Chọn vùng của bạn --</option>
                        <c:forEach var="z" items="${userZones}">
                            <option value="${z.zoneId}">
                                <c:out value="${z.zoneName}" />
                            </option>
                        </c:forEach>
                    </select>
                </div>

                <div class="input-group">
                    <label for="searchInput">Tìm Kiếm</label>
                    <input type="text" id="searchInput" class="form-input" placeholder="Tìm cây trồng... (VD: Cà chua)">
                </div>
            </div>

            <!-- Assigned Crops Section (Hidden if no zone selected) -->
            <div id="zoneCropsSection" class="zone-crops-section" style="display: none;">
                <h2 class="section-title">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"
                        stroke-linecap="round" stroke-linejoin="round" style="color: var(--primary)">
                        <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path>
                        <polyline points="22 4 12 14.01 9 11.01"></polyline>
                    </svg>
                    Cây trồng trong vùng này
                </h2>
                <div id="zoneCropsGrid" class="crop-grid">
                    <!-- Populated via JS -->
                </div>
            </div>

            <h2 class="section-title">Danh Mục Gợi Ý</h2>
            <div class="filter-tabs" id="categoryTabs">
                <button class="filter-tab active" data-cat="all">Tất cả</button>
                <button class="filter-tab" data-cat="Lương thực">Lương thực</button>
                <button class="filter-tab" data-cat="Rau củ">Rau củ</button>
                <button class="filter-tab" data-cat="Trái cây">Trái cây</button>
                <button class="filter-tab" data-cat="Công nghiệp">Công nghiệp</button>
                <button class="filter-tab" data-cat="Khác">Khác</button>
            </div>

            <div id="catalogGrid" class="crop-grid">
                <!-- Populated via JS -->
            </div>

            <div class="custom-crop-section">
                <h3 class="custom-crop-title">Không thấy cây trồng phù hợp?</h3>
                <p style="color: #15803d; margin-bottom: 2rem;">Thêm cây trồng chuyên biệt của bạn vào hệ thống để bắt
                    đầu theo dõi.</p>
                <button class="btn-custom" onclick="openModal()">+ Tạo cây trồng mới</button>
            </div>
        </div>

        <!-- Custom Crop Modal -->
        <div class="modal-overlay" id="customCropModal">
            <div class="modal-content">
                <div class="modal-header">
                    <h2 class="section-title" style="margin:0;">Tạo Cây Trồng Mới</h2>
                    <button class="modal-close" onclick="closeModal()">&times;</button>
                </div>
                <form id="customCropForm" onsubmit="submitCustomCrop(event)">
                    <div class="form-grid">
                        <div class="input-group form-full">
                            <label>Tên cây trồng</label>
                            <input type="text" id="cName" class="form-input" required>
                        </div>
                        <div class="input-group form-full">
                            <label>Danh mục</label>
                            <select id="cCat" class="form-select" required>
                                <option value="Lương thực">Lương thực</option>
                                <option value="Rau củ">Rau củ</option>
                                <option value="Trái cây">Trái cây</option>
                                <option value="Công nghiệp">Công nghiệp</option>
                                <option value="Khác">Khác</option>
                            </select>
                        </div>
                        <div class="input-group">
                            <label>Nhiệt độ tối thiểu (°C)</label>
                            <input type="number" id="cMinT" step="0.1" class="form-input">
                        </div>
                        <div class="input-group">
                            <label>Nhiệt độ tối đa (°C)</label>
                            <input type="number" id="cMaxT" step="0.1" class="form-input">
                        </div>
                        <div class="input-group">
                            <label>Độ ẩm tối thiểu (%)</label>
                            <input type="number" id="cMinH" step="0.1" class="form-input">
                        </div>
                        <div class="input-group">
                            <label>Độ ẩm tối đa (%)</label>
                            <input type="number" id="cMaxH" step="0.1" class="form-input">
                        </div>
                        <div class="input-group form-full">
                            <label>Mô tả thêm</label>
                            <input type="text" id="cDesc" class="form-input">
                        </div>
                        <div class="input-group form-full" style="margin-top: 1rem;">
                            <button type="submit" class="btn-select">Lưu Cây Trồng</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <script>
            let catalog = [];
            let assignedCrops = [];
            let currentCategory = 'all';

            document.addEventListener("DOMContentLoaded", () => {
                fetchCatalog();

                // Bind Category Filters
                document.querySelectorAll('.filter-tab').forEach(tab => {
                    tab.addEventListener('click', (e) => {
                        document.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
                        e.target.classList.add('active');
                        currentCategory = e.target.getAttribute('data-cat');
                        renderCatalog();
                    });
                });

                // Bind Search
                document.getElementById('searchInput').addEventListener('input', renderCatalog);

                // Bind Zone dropdown
                document.getElementById('zoneSelect').addEventListener('change', (e) => {
                    const zId = e.target.value;
                    if (zId) {
                        fetchZoneCrops(zId);
                        document.getElementById('zoneCropsSection').style.display = 'block';
                    } else {
                        assignedCrops = [];
                        document.getElementById('zoneCropsSection').style.display = 'none';
                        renderZoneCrops();
                    }
                });
            });

            async function fetchCatalog() {
                try {
                    const res = await fetch('${pageContext.request.contextPath}/api/crops');
                    catalog = await res.json();
                    renderCatalog();
                } catch (e) { console.error('Error fetching catalog', e); }
            }

            async function fetchZoneCrops(zoneId) {
                try {
                    const res = await fetch('${pageContext.request.contextPath}/api/zones/' + zoneId + '/crops');
                    assignedCrops = await res.json();
                    renderZoneCrops();
                } catch (e) {
                    console.error('Error fetching zone crops', e);
                }
            }

            function createCropCardHTML(crop, isAssigned) {
                const tempInfo = (crop.minTemp != null && crop.maxTemp != null) ? crop.minTemp + ' - ' + crop.maxTemp + '°C' : 'N/A';
                const humInfo = (crop.minHumid != null && crop.maxHumid != null) ? crop.minHumid + ' - ' + crop.maxHumid + '%' : 'N/A';

                const categoryFallbacks = {
                    'Lương thực': 'assets/crops/fallback-luong-thuc.jpg',
                    'Rau củ': 'assets/crops/fallback-rau-cu.jpg',
                    'Trái cây': 'assets/crops/fallback-trai-cay.jpg',
                    'Công nghiệp': 'assets/crops/fallback-cong-nghiep.jpg',
                    'Khác': 'assets/crops/fallback-khac.jpg'
                };
                const defaultFallback = 'assets/crops/placeholder.jpg';
                const fallbackPath = categoryFallbacks[crop.category] || defaultFallback;

                const img = crop.imageUrl && crop.imageUrl.trim() !== '' ? '${pageContext.request.contextPath}/' + crop.imageUrl : '${pageContext.request.contextPath}/' + fallbackPath;
                const fallbackUrl = '${pageContext.request.contextPath}/' + fallbackPath;

                // Construct the button based on assignment
                let btnStr = '';
                if (isAssigned) {
                    btnStr = '<button class="btn-select btn-remove" onclick="removeCrop(' + crop.zoneCropId + ')">Gỡ bỏ</button>';
                } else {
                    btnStr = '<button class="btn-select" onclick="assignCrop(' + crop.cropCatalogId + ')">Chọn</button>';
                }

                return '<div class="crop-card">' +
                    '<div class="crop-category-badge">' + crop.category + '</div>' +
                    '<div class="crop-img-wrap"><img src="' + img + '" class="crop-img" alt="Crop" onerror="this.src=\'' + fallbackUrl + '\'"></div>' +
                    '<div class="crop-body">' +
                    '<div class="crop-name">' + crop.cropName + '</div>' +
                    '<div class="crop-stats">' +
                    '<div class="stat-row">' +
                    '<div class="stat-icon">🌡</div>' +
                    '<span>Nhiệt độ: <b>' + tempInfo + '</b></span>' +
                    '</div>' +
                    '<div class="stat-row">' +
                    '<div class="stat-icon">💧</div>' +
                    '<span>Độ ẩm: <b>' + humInfo + '</b></span>' +
                    '</div>' +
                    '</div>' +
                    btnStr +
                    '</div>' +
                    '</div>';
            }

            function renderCatalog() {
                const grid = document.getElementById('catalogGrid');
                const search = document.getElementById('searchInput').value.toLowerCase();

                const filtered = catalog.filter(c => {
                    const matchName = c.cropName.toLowerCase().includes(search);
                    const matchCat = currentCategory === 'all' || c.category === currentCategory;
                    return matchName && matchCat;
                });

                if (filtered.length === 0) {
                    grid.innerHTML = '<div style="grid-column: 1/-1; text-align: center; color: var(--text-muted); padding: 3rem;">Không tìm thấy kết quả nào.</div>';
                    return;
                }

                grid.innerHTML = filtered.map(c => createCropCardHTML(c, false)).join('');
            }

            function renderZoneCrops() {
                const grid = document.getElementById('zoneCropsGrid');

                if (assignedCrops.length === 0) {
                    grid.innerHTML = '<div style="grid-column: 1/-1; color: var(--text-muted);">Vùng này chưa có cây trồng. Hãy chọn từ danh mục bên dưới!</div>';
                    return;
                }

                // assignedCrops are ZoneCrop objects, containing cropCatalog field
                const html = assignedCrops.map(zc => {
                    const cropDat = Object.assign({}, zc.cropCatalog); // copy
                    cropDat.zoneCropId = zc.zoneCropId; // attach mapping ID
                    return createCropCardHTML(cropDat, true);
                }).join('');

                grid.innerHTML = html;
            }

            async function assignCrop(cropCatalogId) {
                const zId = document.getElementById('zoneSelect').value;
                if (!zId) {
                    alert('Vui lòng chọn vùng trồng trước khi chọn cây!');
                    document.getElementById('zoneSelect').focus();
                    return;
                }

                // Check if already assigned
                const exists = assignedCrops.find(zc => zc.cropCatalog.cropCatalogId === cropCatalogId);
                if (exists) {
                    alert('Cây trồng này đã có trong vùng!');
                    return;
                }

                try {
                    const res = await fetch('${pageContext.request.contextPath}/api/zones/' + zId + '/crops', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify({ cropCatalogId: cropCatalogId })
                    });

                    if (res.ok) {
                        // Refresh zone crops
                        fetchZoneCrops(zId);
                    } else {
                        alert('Không thể thêm cây trồng (có thể đã tồn tại).');
                    }
                } catch (e) {
                    console.error(e);
                    alert('Lỗi kết nối!');
                }
            }

            async function removeCrop(zoneCropId) {
                const zId = document.getElementById('zoneSelect').value;
                if (!confirm('Bạn có chắc muốn gỡ bỏ cây trồng này khỏi vùng?')) return;

                try {
                    const res = await fetch('${pageContext.request.contextPath}/api/zones/' + zId + '/crops/' + zoneCropId, {
                        method: 'DELETE'
                    });

                    if (res.ok) {
                        fetchZoneCrops(zId);
                    } else {
                        alert('Lỗi khi xóa!');
                    }
                } catch (e) {
                    console.error(e);
                }
            }

            // Modal logic
            function openModal() { document.getElementById('customCropModal').classList.add('active'); }
            function closeModal() { document.getElementById('customCropModal').classList.remove('active'); document.getElementById('customCropForm').reset(); }

            async function submitCustomCrop(e) {
                e.preventDefault();

                const payload = {
                    cropName: document.getElementById('cName').value,
                    category: document.getElementById('cCat').value,
                    minTemp: document.getElementById('cMinT').value ? parseFloat(document.getElementById('cMinT').value) : null,
                    maxTemp: document.getElementById('cMaxT').value ? parseFloat(document.getElementById('cMaxT').value) : null,
                    minHumid: document.getElementById('cMinH').value ? parseFloat(document.getElementById('cMinH').value) : null,
                    maxHumid: document.getElementById('cMaxH').value ? parseFloat(document.getElementById('cMaxH').value) : null,
                    description: document.getElementById('cDesc').value
                };

                try {
                    const res = await fetch('${pageContext.request.contextPath}/api/crops', {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(payload)
                    });

                    if (res.ok) {
                        alert('Tạo cây trồng thành công!');
                        closeModal();
                        fetchCatalog(); // Refresh list
                    } else {
                        alert('Lỗi tạo cây trồng!');
                    }
                } catch (err) {
                    console.error(err);
                }
            }
        </script>

        <jsp:include page="/WEB-INF/views/common/footer.jsp" />