<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="marketplace.model.Order,marketplace.model.OrderItem,java.util.List,java.text.NumberFormat,java.util.Locale" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    if (orders == null) orders = new java.util.ArrayList<>();
    String ctx = request.getContextPath();
    String successParam = request.getParameter("success");
    String errorParam   = request.getParameter("error");
    int totalCount=0,pendingCount=0,confirmedCount=0,shippedCount=0,completedCount=0,cancelledCount=0;
    for (Order o : orders) {
        totalCount++;
        String st = o.getStatus()!=null?o.getStatus():"";
        if      ("PENDING"  .equals(st)) pendingCount++;
        else if ("CONFIRMED".equals(st)) confirmedCount++;
        else if ("SHIPPED"  .equals(st)) shippedCount++;
        else if ("COMPLETED".equals(st)) completedCount++;
        else if ("CANCELLED".equals(st)) cancelledCount++;
    }
    NumberFormat nf = NumberFormat.getNumberInstance(new Locale("vi","VN"));
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Đơn hàng nhận được | SmartAgri Farmer</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Nunito:wght@700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #2E7D32; --primary-light: #43A047; --primary-dark: #1B5E20;
            --accent: #81C784; --accent-yellow: #F9A825; --bg-light: #F1F8E9; --sidebar-bg: #1B5E20;
        }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-light); margin: 0; }
        .farmer-sidebar { width:240px; background:var(--sidebar-bg); min-height:100vh; position:fixed; left:0; top:0; z-index:100; }
        .sidebar-logo { padding:24px 20px; border-bottom:1px solid rgba(255,255,255,0.1); }
        .sidebar-logo .brand { color:white; font-family:'Nunito',sans-serif; font-weight:900; font-size:18px; }
        .sidebar-logo .sub { color:rgba(255,255,255,0.6); font-size:11px; letter-spacing:1px; }
        .sidebar-badge { background:var(--accent-yellow); color:#1A2E1A; font-size:9px; font-weight:800; padding:2px 6px; border-radius:10px; margin-left:6px; }
        .sidebar-nav { padding:16px 0; }
        .sidebar-nav .nav-section { padding:4px 20px; color:rgba(255,255,255,0.4); font-size:10px; font-weight:700; letter-spacing:1px; margin:12px 0 4px; }
        .sidebar-nav a { display:flex; align-items:center; gap:10px; padding:10px 20px; color:rgba(255,255,255,0.8); text-decoration:none; font-size:14px; transition:all .2s; border-left:3px solid transparent; }
        .sidebar-nav a:hover, .sidebar-nav a.active { background:rgba(255,255,255,0.1); color:white; border-left-color:var(--accent-yellow); }
        .main-content { margin-left:240px; padding:28px; min-height:100vh; }
        .page-header { display:flex; align-items:center; justify-content:space-between; margin-bottom:28px; }
        .page-title { font-family:'Nunito',sans-serif; font-size:1.8rem; font-weight:900; color:var(--primary-dark); margin:0; }
        .page-title span { color:var(--primary-light); }
        .stats-strip { display:grid; grid-template-columns:repeat(auto-fit,minmax(160px,1fr)); gap:16px; margin-bottom:28px; }
        .stat-pill { background:white; border-radius:14px; padding:18px 20px; box-shadow:0 4px 16px rgba(46,125,50,0.09); display:flex; align-items:center; gap:14px; transition:transform .2s; }
        .stat-pill:hover { transform:translateY(-2px); }
        .stat-pill .icon { width:46px; height:46px; border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; }
        .stat-pill .val { font-family:'Nunito',sans-serif; font-size:1.6rem; font-weight:900; color:var(--primary-dark); line-height:1; }
        .stat-pill .lbl { font-size:11px; color:#6B7B6B; margin-top:2px; }
        .alert-success-custom { background:#E8F5E9; border:1px solid #A5D6A7; color:#2E7D32; border-radius:12px; padding:12px 18px; margin-bottom:20px; display:flex; align-items:center; gap:10px; font-weight:600; }
        .alert-error-custom { background:#FFEBEE; border:1px solid #FFCDD2; color:#C62828; border-radius:12px; padding:12px 18px; margin-bottom:20px; display:flex; align-items:center; gap:10px; font-weight:600; }
        .content-card { background:white; border-radius:16px; box-shadow:0 4px 20px rgba(46,125,50,0.08); margin-bottom:24px; overflow:hidden; }
        .card-header-custom { padding:18px 22px; display:flex; align-items:center; justify-content:space-between; border-bottom:2px solid #F1F8E9; }
        .card-title { font-weight:700; font-size:16px; color:var(--primary-dark); display:flex; align-items:center; gap:8px; margin:0; }
        .filter-bar { padding:14px 22px; background:#FAFFF9; border-bottom:1px solid #E8F5E9; display:flex; align-items:center; gap:10px; flex-wrap:wrap; }
        .filter-btn { padding:6px 16px; border-radius:20px; border:1.5px solid #C8E6C9; background:white; color:#4A7A4A; font-size:13px; font-weight:600; cursor:pointer; transition:all .2s; text-decoration:none; }
        .filter-btn:hover, .filter-btn.active { background:var(--primary); color:white; border-color:var(--primary); }
        .table { margin:0; font-size:14px; }
        .table th { background:#F1F8E9; color:var(--primary-dark); font-weight:600; font-size:12px; letter-spacing:0.5px; border-bottom:2px solid #C8E6C9; padding:12px 16px; }
        .table td { padding:12px 16px; vertical-align:middle; border-color:#F1F8E9; }
        .table tbody tr:hover { background:#F9FBF9; }
        .status-badge { padding:4px 12px; border-radius:20px; font-size:11px; font-weight:700; display:inline-block; }
        .badge-pending   { background:#FFF8E1; color:#E65100; }
        .badge-confirmed { background:#E3F2FD; color:#0D47A1; }
        .badge-shipped   { background:#EDE7F6; color:#4527A0; }
        .badge-completed { background:#E8F5E9; color:#1B5E20; }
        .badge-cancelled { background:#FFEBEE; color:#B71C1C; }
        .btn-action { padding:5px 12px; border-radius:8px; border:none; font-size:12px; font-weight:600; cursor:pointer; transition:all .2s; display:inline-flex; align-items:center; gap:4px; text-decoration:none; }
        .btn-confirm  { background:#E8F5E9; color:#2E7D32; } .btn-confirm:hover  { background:#2E7D32; color:white; }
        .btn-ship     { background:#E3F2FD; color:#1565C0; } .btn-ship:hover     { background:#1565C0; color:white; }
        .btn-complete { background:var(--primary); color:white; } .btn-complete:hover { background:var(--primary-dark); }
        .items-row { background:#F9FBF9 !important; } .items-row td { padding:0; }
        .items-panel { padding:12px 20px 16px 48px; border-top:1px dashed #C8E6C9; }
        .items-panel .item-row { display:flex; justify-content:space-between; align-items:center; padding:6px 0; font-size:13px; border-bottom:1px solid #F1F8E9; color:#444; }
        .items-panel .item-row:last-child { border-bottom:none; }
        .items-panel .item-name { font-weight:600; color:var(--primary-dark); }
        .items-panel .item-total { font-weight:700; color:var(--primary); }
        .ship-addr { font-size:12px; color:#6B7B6B; max-width:200px; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; }
        .toggle-icon { cursor:pointer; color:var(--primary); transition:transform .2s; }
        .toggle-icon.open { transform:rotate(90deg); }
        .empty-state { text-align:center; padding:60px 20px; color:#9E9E9E; }
        .empty-state .icon { font-size:60px; margin-bottom:16px; }
        .empty-state h4 { color:#6B7B6B; font-weight:700; margin-bottom:8px; }
        @media (max-width:768px) { .farmer-sidebar { display:none; } .main-content { margin-left:0; padding:16px; } }
    </style>
</head>
<body>
    <!-- SIDEBAR -->
    <div class="farmer-sidebar">
        <div class="sidebar-logo">
            <div class="brand">🌾 SmartAgri</div>
            <div class="sub">FARMER DASHBOARD</div>
            <div style="margin-top:10px;color:rgba(255,255,255,0.8);font-size:13px;">
                👨‍🌾 ${sessionScope.user.fullName}<span class="sidebar-badge">VIP</span>
            </div>
        </div>
        <nav class="sidebar-nav">
            <div class="nav-section">TỔNG QUAN</div>
            <a href="<%=ctx%>/farmer/dashboard"><i class="bi bi-speedometer2"></i> Dashboard</a>
            <div class="nav-section">NÔNG SẢN</div>
            <a href="<%=ctx%>/farmer/listing"><i class="bi bi-list-ul"></i> Danh sách sản phẩm</a>
            <a href="<%=ctx%>/farmer/listing/new"><i class="bi bi-plus-circle"></i> Đăng sản phẩm mới</a>
            <div class="nav-section">BÁN HÀNG</div>
            <a href="<%=ctx%>/farmer/orders" class="active"><i class="bi bi-bag-check"></i> Đơn hàng nhận được</a>
            <div class="nav-section">KHÁC</div>
            <a href="<%=ctx%>/marketplace"><i class="bi bi-shop"></i> Ra chợ</a>
            <a href="<%=ctx%>/logout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a>
        </nav>
    </div>

    <!-- MAIN CONTENT -->
    <div class="main-content">
        <div class="page-header">
            <h1 class="page-title">Đơn hàng <span>nhận được</span> 📦</h1>
            <a href="<%=ctx%>/farmer/dashboard" class="btn btn-sm btn-outline-secondary" style="border-radius:10px;">
                <i class="bi bi-arrow-left"></i> Về Dashboard
            </a>
        </div>

        <%if(successParam!=null&&!successParam.isEmpty()){%>
        <div class="alert-success-custom"><i class="bi bi-check-circle-fill"></i>
            <%if("confirmed".equals(successParam)){%>Đã xác nhận đơn hàng thành công!
            <%}else if("shipped".equals(successParam)){%>Đã cập nhật trạng thái giao hàng!
            <%}else if("completed".equals(successParam)){%>Đã hoàn thành đơn hàng!
            <%}else{%>Cập nhật thành công!<%}%>
        </div>
        <%}%>
        <%if(errorParam!=null&&!errorParam.isEmpty()){%>
        <div class="alert-error-custom"><i class="bi bi-exclamation-triangle-fill"></i>
            <%if("update_failed".equals(errorParam)){%>Không thể cập nhật trạng thái đơn hàng
            <%}else{%>Đã xảy ra lỗi: <%=errorParam%><%}%>
        </div>
        <%}%>

        <!-- Stats -->
        <div class="stats-strip">
            <div class="stat-pill"><div class="icon" style="background:#E8F5E9;">📦</div><div><div class="val"><%=totalCount%></div><div class="lbl">Tổng đơn hàng</div></div></div>
            <div class="stat-pill"><div class="icon" style="background:#FFF8E1;">⏳</div><div><div class="val"><%=pendingCount%></div><div class="lbl">Chờ xác nhận</div></div></div>
            <div class="stat-pill"><div class="icon" style="background:#E3F2FD;">✅</div><div><div class="val"><%=confirmedCount%></div><div class="lbl">Đã xác nhận</div></div></div>
            <div class="stat-pill"><div class="icon" style="background:#EDE7F6;">🚚</div><div><div class="val"><%=shippedCount%></div><div class="lbl">Giao hàng</div></div></div>
            <div class="stat-pill"><div class="icon" style="background:#E8F5E9;">🏆</div><div><div class="val"><%=completedCount%></div><div class="lbl">Hoàn thành</div></div></div>
            <div class="stat-pill"><div class="icon" style="background:#FFEBEE;">❌</div><div><div class="val"><%=cancelledCount%></div><div class="lbl">Đã hủy</div></div></div>
        </div>

        <!-- Orders -->
        <div class="content-card" id="ordersCard">
            <div class="card-header-custom">
                <h3 class="card-title"><i class="bi bi-bag-check" style="color:var(--primary);"></i> Danh sách đơn hàng</h3>
                <span style="font-size:13px;color:#6B7B6B;"><%=totalCount%> đơn</span>
            </div>
            <div class="filter-bar" id="filterBar">
                <a href="#" class="filter-btn active" id="tabAll" data-filter="all">Tất cả <span style="background:rgba(0,0,0,0.08);border-radius:10px;padding:1px 7px;margin-left:4px;"><%=totalCount%></span></a>
                <a href="#" class="filter-btn" id="tabPending"   data-filter="PENDING">Chờ xác nhận<%if(pendingCount>0){%><span style="background:#E65100;color:white;border-radius:10px;padding:1px 7px;margin-left:4px;"><%=pendingCount%></span><%}%></a>
                <a href="#" class="filter-btn" id="tabConfirmed" data-filter="CONFIRMED">Đã xác nhận</a>
                <a href="#" class="filter-btn" id="tabShipped"   data-filter="SHIPPED">Đang giao</a>
                <a href="#" class="filter-btn" id="tabCompleted" data-filter="COMPLETED">Hoàn thành</a>
                <a href="#" class="filter-btn" id="tabCancelled" data-filter="CANCELLED">Đã hủy</a>
            </div>

            <%if(!orders.isEmpty()){%>
            <table class="table" id="ordersTable">
                <thead><tr>
                    <th style="width:36px;"></th><th>Mã ĐH</th><th>Người mua</th>
                    <th>Địa chỉ giao</th><th>Tổng tiền</th><th>Trạng thái</th>
                    <th>Ngày đặt</th><th>Thao tác</th>
                </tr></thead>
                <tbody>
                <%for(Order order:orders){
                    String status  = order.getStatus()!=null?order.getStatus():"";
                    String badgeCls= "badge-"+status.toLowerCase();
                    String amtStr  = order.getTotalAmount()!=null?nf.format(order.getTotalAmount()):"0";
                    String dateStr = "";
                    if(order.getCreatedAt()!=null){
                        String raw=order.getCreatedAt().toString();
                        dateStr=raw.length()>=16?raw.substring(0,16).replace('T',' '):raw;
                    }
                %>
                <tr class="order-row" data-status="<%=status%>" id="row-<%=order.getOrderId()%>">
                    <td><i class="bi bi-chevron-right toggle-icon" id="toggle-<%=order.getOrderId()%>"
                           onclick="toggleItems(<%=order.getOrderId()%>)"></i></td>
                    <td><strong>#<%=order.getOrderId()%></strong></td>
                    <td>
                        <div style="font-weight:600;"><%=order.getBuyerName()!=null?order.getBuyerName():""%></div>
                        <%if(order.getNote()!=null&&!order.getNote().isEmpty()){%>
                        <small style="color:#9E9E9E;">Ghi chú: <%=order.getNote()%></small>
                        <%}%>
                    </td>
                    <td><div class="ship-addr" title="<%=order.getShipAddress()!=null?order.getShipAddress():""%>">
                        <i class="bi bi-geo-alt" style="color:#9E9E9E;"></i>
                        <%=(order.getShipAddress()!=null&&!order.getShipAddress().isEmpty())?order.getShipAddress():"—"%>
                    </div></td>
                    <td style="color:var(--primary);font-weight:700;"><%=amtStr%>đ</td>
                    <td><span class="status-badge <%=badgeCls%>"><%=order.getStatusLabel()%></span></td>
                    <td style="font-size:12px;color:#6B7B6B;"><%=dateStr%></td>
                    <td><div style="display:flex;gap:6px;flex-wrap:wrap;">
                        <%if("PENDING".equals(status)){%>
                        <form action="<%=ctx%>/farmer/orders/confirm" method="post" style="display:inline;"
                              onsubmit="return confirmAction('Xác nhận đơn #<%=order.getOrderId()%>?')">
                            <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                            <button type="submit" class="btn-action btn-confirm"><i class="bi bi-check-lg"></i> Xác nhận</button>
                        </form>
                        <%}else if("CONFIRMED".equals(status)){%>
                        <form action="<%=ctx%>/farmer/orders/ship" method="post" style="display:inline;"
                              onsubmit="return confirmAction('Giao hàng đơn #<%=order.getOrderId()%>?')">
                            <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                            <button type="submit" class="btn-action btn-ship"><i class="bi bi-truck"></i> Giao hàng</button>
                        </form>
                        <%}else if("SHIPPED".equals(status)){%>
                        <form action="<%=ctx%>/farmer/orders/complete" method="post" style="display:inline;"
                              onsubmit="return confirmAction('Hoàn thành đơn #<%=order.getOrderId()%>?')">
                            <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                            <button type="submit" class="btn-action btn-complete"><i class="bi bi-patch-check"></i> Hoàn thành</button>
                        </form>
                        <%}else{%>
                        <span style="font-size:12px;color:#9E9E9E;"><i class="bi bi-dash"></i></span>
                        <%}%>
                        <%-- Nút nhắn tin người mua (luôn hiện) --%>
                        <a href="<%=ctx%>/market-chat?partner=<%=order.getBuyerId()%>"
                           class="btn-action"
                           style="background:#E8F5E9;color:#2E7D32;"
                           title="Nhắn tin người mua">
                            <i class="bi bi-chat-dots-fill"></i> Nhắn tin
                        </a>

                    </div></td>
                </tr>
                <!-- Items row -->
                <tr class="items-row order-row" data-status="<%=status%>" id="items-<%=order.getOrderId()%>" style="display:none;">
                    <td colspan="8"><div class="items-panel">
                        <div style="font-size:12px;color:#6B7B6B;font-weight:700;margin-bottom:8px;">CHI TIẾT SẢN PHẨM</div>
                        <%List<OrderItem> items=order.getItems();
                          if(items!=null&&!items.isEmpty()){
                            for(OrderItem item:items){
                                String qStr=item.getQuantity()!=null?nf.format(item.getQuantity()):"0";
                                String pStr=item.getUnitPrice()!=null?nf.format(item.getUnitPrice()):"0";
                                java.math.BigDecimal lt=(item.getQuantity()!=null&&item.getUnitPrice()!=null)
                                    ?item.getQuantity().multiply(item.getUnitPrice()):java.math.BigDecimal.ZERO;
                        %>
                        <div class="item-row">
                            <span><span class="item-name"><%=item.getProductName()!=null?item.getProductName():""%></span>
                                <span style="color:#9E9E9E;margin-left:8px;">x <%=qStr%></span>
                                <span style="color:#9E9E9E;margin-left:8px;">@ <%=pStr%>đ</span>
                            </span>
                            <span class="item-total"><%=nf.format(lt)%>đ</span>
                        </div>
                        <%  }%>
                        <div style="text-align:right;padding-top:8px;border-top:2px solid #C8E6C9;margin-top:4px;">
                            <span style="font-size:13px;color:#6B7B6B;margin-right:12px;">Tổng đơn:</span>
                            <strong style="color:var(--primary);font-size:15px;"><%=amtStr%>đ</strong>
                        </div>
                        <%}else{%>
                        <div style="color:#9E9E9E;font-size:13px;"><i class="bi bi-info-circle"></i> Không có chi tiết sản phẩm</div>
                        <%}%>
                        <%if(order.getShipAddress()!=null&&!order.getShipAddress().isEmpty()){%>
                        <div style="margin-top:8px;font-size:12px;color:#6B7B6B;">
                            <i class="bi bi-geo-alt-fill" style="color:var(--primary);"></i>
                            <strong>Giao đến:</strong> <%=order.getShipAddress()%>
                        </div>
                        <%}%>
                    </div></td>
                </tr>
                <%}%>
                </tbody>
            </table>
            <div id="noResults" style="display:none;text-align:center;padding:40px;color:#9E9E9E;">
                <i class="bi bi-funnel" style="font-size:32px;margin-bottom:12px;display:block;"></i>
                Không có đơn hàng nào trong trạng thái này
            </div>
            <%}else{%>
            <div class="empty-state">
                <div class="icon">📭</div>
                <h4>Chưa có đơn hàng nào</h4>
                <p style="font-size:14px;">Khi người mua đặt hàng sản phẩm của bạn, đơn hàng sẽ xuất hiện ở đây.</p>
                <a href="<%=ctx%>/farmer/listing/new" class="btn btn-sm"
                   style="background:var(--primary);color:white;border-radius:10px;padding:8px 20px;margin-top:8px;">
                    <i class="bi bi-plus-circle"></i> Đăng sản phẩm mới
                </a>
            </div>
            <%}%>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function toggleItems(orderId) {
            var r=document.getElementById('items-'+orderId),ic=document.getElementById('toggle-'+orderId);
            if(!r)return; var open=r.style.display!=='none';
            r.style.display=open?'none':'table-row'; ic&&ic.classList.toggle('open',!open);
        }
        document.querySelectorAll('#filterBar .filter-btn').forEach(function(btn){
            btn.addEventListener('click',function(e){
                e.preventDefault();
                document.querySelectorAll('#filterBar .filter-btn').forEach(function(b){b.classList.remove('active');});
                this.classList.add('active');
                var filter=this.dataset.filter,rows=document.querySelectorAll('#ordersTable .order-row'),visible=0;
                rows.forEach(function(row){
                    if(filter==='all'||row.dataset.status===filter){row.style.display='';visible++;}
                    else row.style.display='none';
                });
                var nr=document.getElementById('noResults');if(nr)nr.style.display=(visible===0)?'block':'none';
            });
        });
        function confirmAction(msg){return confirm(msg||'Bạn có chắc chắn không?');}
    </script>
</body>
</html>
