<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="java.util.*, java.time.LocalDateTime, java.time.format.DateTimeFormatter" %>
        <%@ include file="layout_header.jsp" %>

            <%
                /* ── Data from AdminEventsServlet ──────────────────── */
                List<Map<String, Object>> events =
                    (List<Map<String, Object>>) request.getAttribute("events");
                if (events == null) events = Collections.emptyList();

                int totalEvents = (request.getAttribute("totalEvents") != null)
                    ? (Integer) request.getAttribute("totalEvents") : 0;
                String selectedType = (String) request.getAttribute("selectedType");
                if (selectedType == null) selectedType = "ALL";

                int cntListing = request.getAttribute("cntListing") != null
                    ? (Integer) request.getAttribute("cntListing") : 0;
                int cntOrder   = request.getAttribute("cntOrder")   != null
                    ? (Integer) request.getAttribute("cntOrder")   : 0;
                int cntPayment = request.getAttribute("cntPayment") != null
                    ? (Integer) request.getAttribute("cntPayment") : 0;
                int cntVip     = request.getAttribute("cntVip")     != null
                    ? (Integer) request.getAttribute("cntVip")     : 0;
                int cntCrawler = request.getAttribute("cntCrawler") != null
                    ? (Integer) request.getAttribute("cntCrawler") : 0;

                DateTimeFormatter timeFmt  = DateTimeFormatter.ofPattern("HH:mm");
                DateTimeFormatter dateFmt  = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm:ss");
            %>

            <style>
                /* ════════════════════════════════════════════════════
                   EVENTS DASHBOARD — PAGE STYLES
                ════════════════════════════════════════════════════ */

                /* ── KPI Cards Grid ─────────────────────────────── */
                .ev-kpi-grid {
                    display: grid;
                    grid-template-columns: repeat(5, 1fr);
                    gap: 16px;
                    margin-bottom: 28px;
                }

                @media (max-width: 1200px) {
                    .ev-kpi-grid { grid-template-columns: repeat(3, 1fr); }
                }
                @media (max-width: 768px) {
                    .ev-kpi-grid { grid-template-columns: repeat(2, 1fr); }
                }

                .ev-kpi {
                    padding: 20px;
                    display: flex;
                    align-items: flex-start;
                    gap: 14px;
                    position: relative;
                    overflow: hidden;
                }

                .ev-kpi::after {
                    content: '';
                    position: absolute;
                    width: 100px;
                    height: 100px;
                    border-radius: 50%;
                    right: -30px;
                    bottom: -30px;
                    opacity: 0.04;
                    pointer-events: none;
                }

                .ev-kpi.kpi-listing::after  { background: var(--green); }
                .ev-kpi.kpi-order::after    { background: var(--blue); }
                .ev-kpi.kpi-payment::after  { background: var(--amber); }
                .ev-kpi.kpi-vip::after      { background: var(--purple); }
                .ev-kpi.kpi-crawler::after  { background: #06b6d4; }

                .ev-kpi-icon {
                    width: 42px;
                    height: 42px;
                    border-radius: 12px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-shrink: 0;
                }

                .kpi-listing  .ev-kpi-icon { background: var(--green-dim); color: var(--green); border: 1px solid rgba(52, 211, 153, 0.18); }
                .kpi-order    .ev-kpi-icon { background: var(--blue-dim);  color: var(--blue);  border: 1px solid rgba(56, 189, 248, 0.18); }
                .kpi-payment  .ev-kpi-icon { background: var(--amber-dim); color: var(--amber); border: 1px solid rgba(245, 158, 11, 0.18); }
                .kpi-vip      .ev-kpi-icon { background: var(--purple-dim);color: var(--purple);border: 1px solid rgba(139, 92, 246, 0.18); }
                .kpi-crawler  .ev-kpi-icon { background: rgba(6, 182, 212, 0.10); color: #06b6d4; border: 1px solid rgba(6, 182, 212, 0.18); }

                .ev-kpi-data { flex: 1; }

                .ev-kpi-label {
                    font-size: 0.68rem;
                    font-weight: 600;
                    color: var(--t2);
                    text-transform: uppercase;
                    letter-spacing: 0.06em;
                    margin-bottom: 4px;
                }

                .ev-kpi-value {
                    font-size: 1.6rem;
                    font-weight: 800;
                    color: var(--t1);
                    letter-spacing: -0.03em;
                    font-variant-numeric: tabular-nums;
                    line-height: 1;
                }

                /* ── Filter Tabs ────────────────────────────────── */
                .ev-filter-bar {
                    display: flex;
                    align-items: center;
                    gap: 8px;
                    margin-bottom: 20px;
                    flex-wrap: wrap;
                }

                .ev-filter-tab {
                    display: inline-flex;
                    align-items: center;
                    gap: 5px;
                    padding: 7px 14px;
                    border-radius: 9px;
                    font-size: 0.78rem;
                    font-weight: 600;
                    color: var(--t2);
                    background: transparent;
                    border: 1px solid var(--bdr);
                    text-decoration: none;
                    transition: all 0.22s var(--ease-out);
                    white-space: nowrap;
                    cursor: pointer;
                }

                .ev-filter-tab:hover {
                    border-color: var(--bdr-hi);
                    color: var(--t1);
                    background: rgba(56, 189, 248, 0.04);
                }

                .ev-filter-tab.active {
                    background: linear-gradient(135deg, rgba(56, 189, 248, 0.12) 0%, rgba(139, 92, 246, 0.08) 100%);
                    color: var(--blue);
                    border-color: rgba(56, 189, 248, 0.28);
                    box-shadow: 0 0 12px rgba(56, 189, 248, 0.08);
                }

                .ev-filter-tab .tab-count {
                    background: rgba(56, 189, 248, 0.08);
                    color: var(--t2);
                    padding: 1px 7px;
                    border-radius: 20px;
                    font-size: 0.68rem;
                    font-weight: 700;
                    font-variant-numeric: tabular-nums;
                }

                .ev-filter-tab.active .tab-count {
                    background: rgba(56, 189, 248, 0.18);
                    color: var(--blue);
                }

                /* ── Event Feed ─────────────────────────────────── */
                .ev-feed-header {
                    display: flex;
                    align-items: center;
                    justify-content: space-between;
                    padding: 16px 20px;
                    border-bottom: 1px solid var(--bdr);
                }

                .ev-feed-title {
                    font-size: 0.88rem;
                    font-weight: 700;
                    color: var(--t1);
                    display: flex;
                    align-items: center;
                    gap: 8px;
                }

                .ev-feed-title .live-dot {
                    width: 7px;
                    height: 7px;
                    border-radius: 50%;
                    background: var(--green);
                    box-shadow: 0 0 8px var(--green);
                    animation: pulse-dot 2s ease infinite;
                }

                .ev-feed-meta {
                    font-size: 0.72rem;
                    color: var(--t3);
                    font-weight: 500;
                }

                /* Event Row */
                .ev-row {
                    display: flex;
                    align-items: center;
                    gap: 14px;
                    padding: 14px 20px;
                    border-bottom: 1px solid rgba(8, 15, 39, 0.85);
                    transition: background 0.15s;
                    position: relative;
                }

                .ev-row:hover {
                    background: rgba(56, 189, 248, 0.02);
                }

                .ev-row:last-child {
                    border-bottom: none;
                }

                /* Event type icon bubble */
                .ev-icon {
                    width: 36px;
                    height: 36px;
                    border-radius: 10px;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    flex-shrink: 0;
                }

                .ev-icon.type-listing  { background: var(--green-dim);  color: var(--green);  border: 1px solid rgba(52, 211, 153, 0.15); }
                .ev-icon.type-order    { background: var(--blue-dim);   color: var(--blue);   border: 1px solid rgba(56, 189, 248, 0.15); }
                .ev-icon.type-payment  { background: var(--amber-dim);  color: var(--amber);  border: 1px solid rgba(245, 158, 11, 0.15); }
                .ev-icon.type-vip      { background: var(--purple-dim); color: var(--purple); border: 1px solid rgba(139, 92, 246, 0.15); }
                .ev-icon.type-crawler  { background: rgba(6, 182, 212, 0.08); color: #06b6d4; border: 1px solid rgba(6, 182, 212, 0.15); }
                .ev-icon.type-default  { background: rgba(99, 179, 237, 0.06); color: var(--t2); border: 1px solid var(--bdr); }

                .ev-body {
                    flex: 1;
                    min-width: 0;
                }

                .ev-desc {
                    font-size: 0.84rem;
                    font-weight: 500;
                    color: var(--t1);
                    line-height: 1.4;
                    word-break: break-word;
                }

                .ev-meta-row {
                    display: flex;
                    align-items: center;
                    gap: 12px;
                    margin-top: 3px;
                }

                .ev-type-badge {
                    font-size: 0.64rem;
                    font-weight: 700;
                    text-transform: uppercase;
                    letter-spacing: 0.05em;
                    padding: 2px 8px;
                    border-radius: 6px;
                }

                .ev-type-badge.type-listing  { background: var(--green-dim);  color: var(--green); }
                .ev-type-badge.type-order    { background: var(--blue-dim);   color: var(--blue); }
                .ev-type-badge.type-payment  { background: var(--amber-dim);  color: var(--amber); }
                .ev-type-badge.type-vip      { background: var(--purple-dim); color: var(--purple); }
                .ev-type-badge.type-crawler  { background: rgba(6, 182, 212, 0.08); color: #06b6d4; }
                .ev-type-badge.type-default  { background: rgba(99, 179, 237, 0.06); color: var(--t2); }

                .ev-meta-txt {
                    font-size: 0.72rem;
                    color: var(--t3);
                    font-weight: 500;
                }

                /* Time column */
                .ev-time {
                    font-size: 0.78rem;
                    font-weight: 600;
                    color: var(--t2);
                    white-space: nowrap;
                    font-variant-numeric: tabular-nums;
                    flex-shrink: 0;
                    text-align: right;
                    min-width: 52px;
                }

                /* ID chip */
                .ev-id {
                    font-size: 0.68rem;
                    font-weight: 600;
                    color: var(--t3);
                    background: rgba(8, 15, 39, 0.6);
                    border: 1px solid var(--bdr);
                    padding: 2px 8px;
                    border-radius: 6px;
                    font-variant-numeric: tabular-nums;
                    flex-shrink: 0;
                }

                /* ── Empty State ────────────────────────────────── */
                .ev-empty {
                    text-align: center;
                    padding: 60px 20px;
                    color: var(--t3);
                }

                .ev-empty-icon {
                    width: 56px;
                    height: 56px;
                    border-radius: 16px;
                    background: rgba(56, 189, 248, 0.06);
                    border: 1px solid var(--bdr);
                    display: inline-flex;
                    align-items: center;
                    justify-content: center;
                    margin-bottom: 14px;
                    color: var(--t3);
                }

                .ev-empty h3 {
                    font-size: 0.92rem;
                    font-weight: 700;
                    color: var(--t2);
                    margin-bottom: 6px;
                }

                .ev-empty p {
                    font-size: 0.8rem;
                    color: var(--t3);
                    max-width: 360px;
                    margin: 0 auto;
                    line-height: 1.5;
                }

                /* ── Refresh button ─────────────────────────────── */
                .ev-refresh {
                    display: inline-flex;
                    align-items: center;
                    gap: 5px;
                    padding: 6px 13px;
                    border-radius: 8px;
                    font-size: 0.76rem;
                    font-weight: 600;
                    color: var(--t2);
                    background: transparent;
                    border: 1px solid var(--bdr);
                    cursor: pointer;
                    transition: all 0.2s var(--ease-std);
                    text-decoration: none;
                }

                .ev-refresh:hover {
                    border-color: var(--bdr-hi);
                    color: var(--blue);
                    background: var(--blue-dim);
                }

                .ev-refresh.spinning i,
                .ev-refresh.spinning svg {
                    animation: spin-refresh 0.8s linear infinite;
                }

                @keyframes spin-refresh {
                    from { transform: rotate(0deg); }
                    to   { transform: rotate(360deg); }
                }

                /* ── Timeline accent line ───────────────────────── */
                .ev-row::before {
                    content: '';
                    position: absolute;
                    left: 38px;
                    top: 0;
                    bottom: 0;
                    width: 1px;
                    background: var(--bdr);
                    opacity: 0.5;
                    z-index: 0;
                }

                .ev-row:first-child::before { top: 50%; }
                .ev-row:last-child::before  { bottom: 50%; }

                .ev-icon { z-index: 1; position: relative; }
            </style>

            <!-- ══════════════════════════════════════════════════════
                 PAGE CONTENT
            ══════════════════════════════════════════════════════ -->

            <!-- Page Header -->
            <div class="page-header" data-aos="fade-up">
                <div style="display:flex; align-items:center; justify-content:space-between; flex-wrap:wrap; gap:12px;">
                    <div>
                        <h1>Marketplace Events</h1>
                        <p>Theo dõi hoạt động của Farmer, Buyer và hệ thống theo thời gian thực</p>
                    </div>
                    <a href="<%= ctx %>/admin/events" class="ev-refresh" id="refreshBtn"
                       onclick="this.classList.add('spinning')">
                        <i data-lucide="refresh-cw" width="13" height="13"></i>
                        Làm mới
                    </a>
                </div>
            </div>

            <!-- KPI Cards -->
            <div class="ev-kpi-grid" data-aos="fade-up" data-aos-delay="40">

                <div class="glass glass-hover ev-kpi kpi-listing accent-green">
                    <div class="ev-kpi-icon">
                        <i data-lucide="package-plus" width="20" height="20"></i>
                    </div>
                    <div class="ev-kpi-data">
                        <div class="ev-kpi-label">Đăng sản phẩm</div>
                        <div class="ev-kpi-value"><%= cntListing %></div>
                    </div>
                </div>

                <div class="glass glass-hover ev-kpi kpi-order accent-blue">
                    <div class="ev-kpi-icon">
                        <i data-lucide="shopping-cart" width="20" height="20"></i>
                    </div>
                    <div class="ev-kpi-data">
                        <div class="ev-kpi-label">Đơn hàng mới</div>
                        <div class="ev-kpi-value"><%= cntOrder %></div>
                    </div>
                </div>

                <div class="glass glass-hover ev-kpi kpi-payment accent-amber">
                    <div class="ev-kpi-icon">
                        <i data-lucide="credit-card" width="20" height="20"></i>
                    </div>
                    <div class="ev-kpi-data">
                        <div class="ev-kpi-label">Thanh toán</div>
                        <div class="ev-kpi-value"><%= cntPayment %></div>
                    </div>
                </div>

                <div class="glass glass-hover ev-kpi kpi-vip accent-purple">
                    <div class="ev-kpi-icon">
                        <i data-lucide="crown" width="20" height="20"></i>
                    </div>
                    <div class="ev-kpi-data">
                        <div class="ev-kpi-label">Nâng cấp VIP</div>
                        <div class="ev-kpi-value"><%= cntVip %></div>
                    </div>
                </div>

                <div class="glass glass-hover ev-kpi kpi-crawler" style="border-top: 2px solid rgba(6, 182, 212, 0.42);">
                    <div class="ev-kpi-icon">
                        <i data-lucide="bot" width="20" height="20"></i>
                    </div>
                    <div class="ev-kpi-data">
                        <div class="ev-kpi-label">Crawler</div>
                        <div class="ev-kpi-value"><%= cntCrawler %></div>
                    </div>
                </div>

            </div>

            <!-- Filter Tabs -->
            <div class="ev-filter-bar" data-aos="fade-up" data-aos-delay="60">
                <a href="<%= ctx %>/admin/events"
                   class="ev-filter-tab <%= "ALL".equals(selectedType) ? "active" : "" %>">
                    <i data-lucide="layers" width="13" height="13"></i>
                    Tất cả
                    <span class="tab-count"><%= totalEvents %></span>
                </a>
                <a href="<%= ctx %>/admin/events?type=LISTING_CREATED"
                   class="ev-filter-tab <%= "LISTING_CREATED".equals(selectedType) ? "active" : "" %>">
                    <i data-lucide="package-plus" width="13" height="13"></i>
                    Listings
                    <span class="tab-count"><%= cntListing %></span>
                </a>
                <a href="<%= ctx %>/admin/events?type=ORDER_CREATED"
                   class="ev-filter-tab <%= "ORDER_CREATED".equals(selectedType) ? "active" : "" %>">
                    <i data-lucide="shopping-cart" width="13" height="13"></i>
                    Orders
                    <span class="tab-count"><%= cntOrder %></span>
                </a>
                <a href="<%= ctx %>/admin/events?type=PAYMENT_SUCCESS"
                   class="ev-filter-tab <%= "PAYMENT_SUCCESS".equals(selectedType) ? "active" : "" %>">
                    <i data-lucide="credit-card" width="13" height="13"></i>
                    Payments
                    <span class="tab-count"><%= cntPayment %></span>
                </a>
                <a href="<%= ctx %>/admin/events?type=VIP_UPGRADE"
                   class="ev-filter-tab <%= "VIP_UPGRADE".equals(selectedType) ? "active" : "" %>">
                    <i data-lucide="crown" width="13" height="13"></i>
                    VIP
                    <span class="tab-count"><%= cntVip %></span>
                </a>
                <a href="<%= ctx %>/admin/events?type=CRAWLER_FINISHED"
                   class="ev-filter-tab <%= "CRAWLER_FINISHED".equals(selectedType) ? "active" : "" %>">
                    <i data-lucide="bot" width="13" height="13"></i>
                    Crawler
                    <span class="tab-count"><%= cntCrawler %></span>
                </a>
            </div>

            <!-- Event Feed -->
            <div class="glass" data-aos="fade-up" data-aos-delay="80" style="overflow:hidden;">

                <!-- Feed Header -->
                <div class="ev-feed-header">
                    <div class="ev-feed-title">
                        <span class="live-dot"></span>
                        Hoạt động gần đây
                    </div>
                    <div class="ev-feed-meta">
                        Hiển thị <%= events.size() %> / <%= totalEvents %> sự kiện
                    </div>
                </div>

                <!-- Event Rows -->
                <% if (events.isEmpty()) { %>
                    <div class="ev-empty">
                        <div class="ev-empty-icon">
                            <i data-lucide="inbox" width="24" height="24"></i>
                        </div>
                        <h3>Chưa có sự kiện nào</h3>
                        <p>Các hoạt động của Farmer, Buyer và hệ thống sẽ tự động xuất hiện tại đây khi có thao tác mới.</p>
                    </div>
                <% } else {
                    for (Map<String, Object> ev : events) {
                        String evType = (String) ev.get("eventType");
                        String desc   = (String) ev.get("description");
                        Integer evId  = (Integer) ev.get("eventId");
                        Object tsObj  = ev.get("createdAt");

                        /* format time */
                        String timeStr  = "--:--";
                        String fullDate = "";
                        if (tsObj instanceof LocalDateTime) {
                            LocalDateTime ldt = (LocalDateTime) tsObj;
                            timeStr  = ldt.format(timeFmt);
                            fullDate = ldt.format(dateFmt);
                        }

                        /* icon + css class based on event type */
                        String iconName  = "activity";
                        String typeCls   = "type-default";
                        String typeLabel = evType != null ? evType : "UNKNOWN";
                        if ("LISTING_CREATED".equals(evType))  { iconName = "package-plus";   typeCls = "type-listing"; typeLabel = "Listing"; }
                        if ("ORDER_CREATED".equals(evType))    { iconName = "shopping-cart";   typeCls = "type-order";   typeLabel = "Order"; }
                        if ("PAYMENT_SUCCESS".equals(evType))  { iconName = "credit-card";    typeCls = "type-payment"; typeLabel = "Payment"; }
                        if ("VIP_UPGRADE".equals(evType))      { iconName = "crown";           typeCls = "type-vip";     typeLabel = "VIP"; }
                        if ("CRAWLER_FINISHED".equals(evType)) { iconName = "bot";             typeCls = "type-crawler"; typeLabel = "Crawler"; }
                %>
                    <div class="ev-row">
                        <div class="ev-icon <%= typeCls %>">
                            <i data-lucide="<%= iconName %>" width="17" height="17"></i>
                        </div>
                        <div class="ev-body">
                            <div class="ev-desc"><%= desc != null ? desc : "" %></div>
                            <div class="ev-meta-row">
                                <span class="ev-type-badge <%= typeCls %>"><%= typeLabel %></span>
                                <span class="ev-meta-txt" title="<%= fullDate %>"><%= fullDate %></span>
                            </div>
                        </div>
                        <div class="ev-time" title="<%= fullDate %>">[<%= timeStr %>]</div>
                        <div class="ev-id">#<%= evId != null ? evId : "?" %></div>
                    </div>
                <%  }
                } %>

            </div>

            <!-- ═══════════════════════════════════════════════
                 SCRIPTS
            ═══════════════════════════════════════════════ -->
            <script>
                lucide.createIcons();
                AOS.init({ duration: 550, once: true, easing: 'ease-out-cubic', offset: 20 });

                function toggleSidebar() {
                    document.getElementById('sidebar').classList.toggle('collapsed');
                    document.getElementById('main').classList.toggle('expanded');
                }

                /* ── KPI counter animation ──────────────────── */
                document.querySelectorAll('.ev-kpi-value').forEach(el => {
                    const target = parseInt(el.textContent, 10);
                    if (isNaN(target) || target === 0) return;
                    el.textContent = '0';
                    const duration = 1200;
                    const start = performance.now();
                    function tick(now) {
                        const elapsed = now - start;
                        const progress = Math.min(elapsed / duration, 1);
                        const eased = 1 - Math.pow(1 - progress, 3);
                        el.textContent = Math.round(target * eased).toLocaleString('vi-VN');
                        if (progress < 1) requestAnimationFrame(tick);
                    }
                    requestAnimationFrame(tick);
                });

                /* ── Auto-refresh every 60s ─────────────────── */
                let refreshTimer = 60;
                const metaEl = document.querySelector('.ev-feed-meta');
                setInterval(() => {
                    refreshTimer--;
                    if (refreshTimer <= 0) {
                        window.location.reload();
                    }
                    if (metaEl && refreshTimer <= 15) {
                        metaEl.textContent = 'Tự động làm mới sau ' + refreshTimer + 's...';
                    }
                }, 1000);
            </script>
            </div><!-- page-body -->
            </div><!-- main -->
            </div><!-- app -->
            </body>

            </html>
