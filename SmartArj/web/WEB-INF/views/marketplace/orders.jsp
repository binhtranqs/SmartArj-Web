<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="marketplace.model.Order,marketplace.model.OrderItem,java.util.List,java.text.NumberFormat,java.util.Locale" %>
<%
    List<Order> orders = (List<Order>) request.getAttribute("orders");
    if (orders == null) orders = new java.util.ArrayList<>();
    String ctx = request.getContextPath();
    String successParam = request.getParameter("success");
    String errorParam   = request.getParameter("error");

    int totalCount=0, pendingCount=0, confirmedCount=0, shippedCount=0, completedCount=0, cancelledCount=0;
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
    <title>Đơn hàng của tôi | SmartAgri</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Nunito:wght@700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #2E7D32; --primary-light: #43A047; --primary-dark: #1B5E20;
            --accent-yellow: #F9A825; --bg: #F1F8E9;
        }
        * { box-sizing: border-box; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); margin: 0; }

        /* ── Top bar ── */
        .top-bar {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 14px 28px; display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 100;
        }
        .top-bar a { color: rgba(255,255,255,.85); text-decoration: none; font-size: 13px; display: flex; align-items: center; gap: 6px; }
        .top-bar a:hover { color: white; }
        .top-bar h2 { color: white; font-family: 'Nunito', sans-serif; font-weight: 900; margin: 0; font-size: 1.3rem; }

        /* ── Container ── */
        .container-main { max-width: 1000px; margin: 28px auto; padding: 0 20px; }

        /* ── Stats ── */
        .stats-row {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(130px, 1fr));
            gap: 12px; margin-bottom: 24px;
        }
        .stat-box {
            background: white; border-radius: 14px; padding: 14px 16px;
            box-shadow: 0 3px 12px rgba(46,125,50,0.09); display: flex; align-items: center; gap: 10px;
            transition: transform .2s;
        }
        .stat-box:hover { transform: translateY(-2px); }
        .stat-box .ico { font-size: 22px; }
        .stat-box .num { font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 1.4rem; color: var(--primary-dark); line-height: 1; }
        .stat-box .lbl { font-size: 10px; color: #7B8B7B; }

        /* ── Filter tabs ── */
        .filter-bar {
            background: white; border-radius: 14px; padding: 12px 18px; margin-bottom: 22px;
            box-shadow: 0 3px 12px rgba(46,125,50,0.06); display: flex; gap: 8px; flex-wrap: wrap;
        }
        .filter-btn {
            padding: 6px 14px; border-radius: 20px; border: 1.5px solid #C8E6C9;
            background: white; color: #4A7A4A; font-size: 13px; font-weight: 600;
            cursor: pointer; transition: all .2s; text-decoration: none; display: inline-block;
        }
        .filter-btn:hover, .filter-btn.active { background: var(--primary); color: white; border-color: var(--primary); }

        /* ── Alert ── */
        .alert-custom {
            border-radius: 12px; padding: 12px 18px; margin-bottom: 18px;
            display: flex; align-items: center; gap: 10px; font-weight: 600; font-size: 14px;
        }
        .alert-success-c { background: #E8F5E9; border: 1px solid #A5D6A7; color: #2E7D32; }
        .alert-info-c    { background: #E3F2FD; border: 1px solid #90CAF9; color: #0D47A1; }
        .alert-error-c   { background: #FFEBEE; border: 1px solid #FFCDD2; color: #C62828; }

        /* ── Order card ── */
        .order-card {
            background: white; border-radius: 16px; box-shadow: 0 4px 18px rgba(46,125,50,0.09);
            margin-bottom: 20px; overflow: hidden; transition: box-shadow .2s;
        }
        .order-card:hover { box-shadow: 0 6px 24px rgba(46,125,50,0.14); }
        .order-card.hidden { display: none; }

        .order-header {
            padding: 14px 20px; background: #F9FBF9; border-bottom: 1px solid #E8F5E9;
            display: flex; align-items: center; gap: 12px; flex-wrap: wrap;
        }
        .order-id { font-weight: 800; color: var(--primary-dark); font-size: 15px; }

        /* Status badges */
        .status-badge { padding: 4px 12px; border-radius: 20px; font-size: 11px; font-weight: 700; }
        .badge-pending   { background: #FFF8E1; color: #E65100; }
        .badge-confirmed { background: #E3F2FD; color: #0D47A1; }
        .badge-shipped   { background: #EDE7F6; color: #4527A0; }
        .badge-completed { background: #E8F5E9; color: #1B5E20; }
        .badge-cancelled { background: #FFEBEE; color: #B71C1C; }

        /* Payment badges */
        .pay-tag { padding: 3px 10px; border-radius: 20px; font-size: 10px; font-weight: 800; display:inline-flex; align-items:center; gap:4px; }
        .pay-paid    { background: #E8F5E9; color: #1B5E20; border: 1px solid #A5D6A7; }
        .pay-unpaid  { background: #FFF8E1; color: #E65100; border: 1px solid #FFCC80; }
        .pay-failed  { background: #FFEBEE; color: #C62828; border: 1px solid #FFCDD2; }

        .order-date { font-size: 12px; color: #9E9E9E; margin-left: auto; }

        .order-body { padding: 16px 20px; }
        .info-row {
            display: flex; justify-content: space-between; font-size: 13px;
            padding: 6px 0; border-bottom: 1px solid #F1F8E9; align-items: center;
        }
        .info-row:last-child { border-bottom: none; }
        .info-label { color: #7B8B7B; display: flex; align-items: center; gap: 6px; }
        .info-value { font-weight: 600; color: #333; }
        .order-total { font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 1.3rem; color: var(--primary); }

        /* ── Progress timeline ── */
        .progress-timeline {
            padding: 14px 20px 8px; border-top: 1px solid #F1F8E9; border-bottom: 1px solid #F1F8E9;
            background: #FAFFF9;
        }
        .timeline-label { font-size: 11px; color: #7B8B7B; font-weight: 700; letter-spacing: .5px; margin-bottom: 10px; }
        .timeline-steps { display: flex; align-items: center; gap: 0; }
        .t-step {
            display: flex; flex-direction: column; align-items: center; position: relative; flex: 1;
        }
        .t-dot {
            width: 28px; height: 28px; border-radius: 50%; border: 2px solid #C8E6C9;
            background: white; display: flex; align-items: center; justify-content: center;
            font-size: 13px; z-index: 1; transition: all .3s;
        }
        .t-dot.done  { background: var(--primary); border-color: var(--primary); color: white; }
        .t-dot.current { background: white; border-color: var(--primary); box-shadow: 0 0 0 3px rgba(46,125,50,0.2); }
        .t-dot.cancelled-dot { background: #FFEBEE; border-color: #EF9A9A; color: #C62828; }
        .t-line {
            position: absolute; top: 14px; left: 50%; width: 100%; height: 2px;
            background: #C8E6C9; z-index: 0;
        }
        .t-line.done { background: var(--primary); }
        .t-step:last-child .t-line { display: none; }
        .t-label { font-size: 10px; color: #7B8B7B; margin-top: 4px; text-align: center; font-weight: 600; white-space: nowrap; }
        .t-label.active { color: var(--primary); }

        /* ── Items section ── */
        .items-section { padding: 12px 20px 0; border-top: 1px solid #F1F8E9; }
        .items-toggle {
            font-size: 12px; color: var(--primary); cursor: pointer; font-weight: 600;
            display: flex; align-items: center; gap: 4px; padding: 6px 0; user-select: none;
        }
        .items-list { display: none; padding-bottom: 10px; }
        .item-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 7px 0; border-bottom: 1px dashed #E8F5E9; font-size: 13px;
        }
        .item-row:last-child { border-bottom: none; }
        .item-name { font-weight: 600; color: var(--primary-dark); }
        .item-price { color: var(--primary); font-weight: 700; }

        /* ── Footer actions ── */
        .order-footer {
            padding: 12px 20px; background: #FAFAFA; border-top: 1px solid #F1F8E9;
            display: flex; justify-content: flex-end; gap: 10px; flex-wrap: wrap;
        }
        .btn-action {
            padding: 7px 16px; border-radius: 10px; border: none; font-size: 13px;
            font-weight: 600; cursor: pointer; text-decoration: none; display: inline-flex;
            align-items: center; gap: 5px; transition: all .2s;
        }
        .btn-cancel  { background: #FFEBEE; color: #C62828; }
        .btn-cancel:hover  { background: #C62828; color: white; }
        .btn-review  { background: #FFF8E1; color: #E65100; }
        .btn-review:hover  { background: #E65100; color: white; }

        /* ── Empty state ── */
        .empty-state { text-align: center; padding: 80px 20px; }
        .empty-state .icon { font-size: 72px; margin-bottom: 16px; }
        .empty-state h3 { font-family: 'Nunito', sans-serif; font-weight: 900; color: var(--primary-dark); }

        /* ── Modal ── */
        .modal-content { border-radius: 16px; }
        .modal-header { background: var(--primary); color: white; border-radius: 16px 16px 0 0; }
        .star-group label { font-size: 28px; cursor: pointer; }
        .star-group input[type=radio]:checked ~ label { color: orange; }

        @media (max-width: 600px) {
            .stats-row { grid-template-columns: repeat(3, 1fr); }
            .t-label { font-size: 9px; }
        }
    </style>
</head>
<body>

<!-- TOP BAR -->
<div class="top-bar">
    <a href="<%=ctx%>/marketplace"><i class="bi bi-arrow-left"></i> Marketplace</a>
    <h2>📦 Đơn hàng của tôi</h2>
    <a href="<%=ctx%>/buyer/cart"><i class="bi bi-cart3"></i> Giỏ hàng</a>
</div>

<div class="container-main">

    <!-- Alerts -->
    <%if("order_placed".equals(successParam)){%>
    <div class="alert-custom alert-success-c"><i class="bi bi-check-circle-fill"></i> Đặt hàng thành công! Nông dân sẽ xác nhận sớm.</div>
    <%}else if("cancelled".equals(successParam)){%>
    <div class="alert-custom alert-info-c"><i class="bi bi-info-circle-fill"></i> Đơn hàng đã được hủy thành công.</div>
    <%}else if("reviewed".equals(successParam)){%>
    <div class="alert-custom alert-success-c"><i class="bi bi-star-fill"></i> Cảm ơn bạn đã đánh giá!</div>
    <%}else if(errorParam!=null&&!errorParam.isEmpty()){%>
    <div class="alert-custom alert-error-c"><i class="bi bi-exclamation-triangle-fill"></i> Lỗi: <%=errorParam%></div>
    <%}%>

    <%if(!orders.isEmpty()){%>

    <!-- Stats -->
    <div class="stats-row">
        <div class="stat-box"><span class="ico">📦</span><div><div class="num"><%=totalCount%></div><div class="lbl">Tất cả</div></div></div>
        <div class="stat-box"><span class="ico">⏳</span><div><div class="num"><%=pendingCount%></div><div class="lbl">Chờ xác nhận</div></div></div>
        <div class="stat-box"><span class="ico">✅</span><div><div class="num"><%=confirmedCount%></div><div class="lbl">Đã xác nhận</div></div></div>
        <div class="stat-box"><span class="ico">🚚</span><div><div class="num"><%=shippedCount%></div><div class="lbl">Đang giao</div></div></div>
        <div class="stat-box"><span class="ico">🏆</span><div><div class="num"><%=completedCount%></div><div class="lbl">Hoàn thành</div></div></div>
        <div class="stat-box"><span class="ico">❌</span><div><div class="num"><%=cancelledCount%></div><div class="lbl">Đã hủy</div></div></div>
    </div>

    <!-- Filter -->
    <div class="filter-bar">
        <a href="#" class="filter-btn active" data-filter="all">Tất cả <span style="background:rgba(0,0,0,0.08);border-radius:10px;padding:1px 7px;margin-left:4px;"><%=totalCount%></span></a>
        <a href="#" class="filter-btn" data-filter="PENDING">⏳ Chờ xác nhận<%if(pendingCount>0){%> <span style="background:#E65100;color:white;border-radius:10px;padding:1px 6px;"><%=pendingCount%></span><%}%></a>
        <a href="#" class="filter-btn" data-filter="CONFIRMED">✅ Đã xác nhận</a>
        <a href="#" class="filter-btn" data-filter="SHIPPED">🚚 Đang giao</a>
        <a href="#" class="filter-btn" data-filter="COMPLETED">🏆 Hoàn thành</a>
        <a href="#" class="filter-btn" data-filter="CANCELLED">❌ Đã hủy</a>
    </div>

    <!-- Order cards -->
    <%for(Order order : orders){
        String status  = order.getStatus()!=null?order.getStatus():"";
        String badgeCls= "badge-"+status.toLowerCase();
        String amtStr  = order.getTotalAmount()!=null?nf.format(order.getTotalAmount()):"0";
        String dateStr = "";
        if(order.getCreatedAt()!=null){
            String raw=order.getCreatedAt().toString();
            dateStr=raw.length()>=16?raw.substring(0,16).replace('T',' '):raw;
        }
        // Timeline progress
        boolean isCancelled = "CANCELLED".equals(status);
        boolean isPending   = "PENDING".equals(status);
        boolean isConfirmed = "CONFIRMED".equals(status)||"SHIPPED".equals(status)||"COMPLETED".equals(status);
        boolean isShipped   = "SHIPPED".equals(status)||"COMPLETED".equals(status);
        boolean isCompleted = "COMPLETED".equals(status);
        // Payment info
        String pm  = order.getPaymentMethod() != null ? order.getPaymentMethod() : "COD";
        // Đơn COMPLETED → luôn coi là ĐÃ THANH TOÁN (COD: nhận tiền mặt khi giao)
        String ps2 = isCompleted ? "PAID"
                   : (order.getPaymentStatus() != null ? order.getPaymentStatus() : "UNPAID");
        String payTagCls = "PAID".equals(ps2) ? "pay-paid" : ("FAILED".equals(ps2) ? "pay-failed" : "pay-unpaid");
        String payIcon   = "PAID".equals(ps2) ? "✅" : ("FAILED".equals(ps2) ? "❌" : "💰");
        String payLabel  = "PAID".equals(ps2) ? "Đã thanh toán"
                         : ("FAILED".equals(ps2) ? "Thanh toán thất bại" : "Chưa thanh toán");
        String pmLabel   = "VNPAY".equals(pm) ? "VNPay" : "Tiền mặt (COD)";
    %>
    <div class="order-card" data-status="<%=status%>">
        <!-- Header -->
        <div class="order-header">
            <span class="order-id">#<%=order.getOrderId()%></span>
            <span class="status-badge <%=badgeCls%>">
                <%if("PENDING"  .equals(status)){%>⏳ Chờ xác nhận
                <%}else if("CONFIRMED".equals(status)){%>✅ Đã xác nhận
                <%}else if("SHIPPED"  .equals(status)){%>🚚 Đang giao
                <%}else if("COMPLETED".equals(status)){%>🏆 Hoàn thành
                <%}else if("CANCELLED".equals(status)){%>✗ Đã hủy
                <%}else{%><%=status%><%}%>
            </span>
            <%-- Payment badge --%>
            <span class="pay-tag <%=payTagCls%>"><%=payIcon%> <%=payLabel%> · <%=pmLabel%></span>
            <span class="order-date"><i class="bi bi-clock" style="margin-right:3px;"></i><%=dateStr%></span>
        </div>

        <!-- Progress Timeline (chỉ hiện khi không bị hủy) -->
        <%if(!isCancelled){%>
        <div class="progress-timeline">
            <div class="timeline-label">TIẾN TRÌNH ĐƠN HÀNG</div>
            <div class="timeline-steps">
                <!-- Bước 1: Đặt hàng -->
                <div class="t-step">
                    <div class="t-dot done">✓</div>
                    <div class="t-line done"></div>
                    <div class="t-label active">Đặt hàng</div>
                </div>
                <!-- Bước 2: Xác nhận -->
                <div class="t-step">
                    <div class="t-dot <%=isConfirmed?"done":(isPending?"current":"")%>"><%=isConfirmed?"✓":"2"%></div>
                    <div class="t-line <%=isConfirmed?"done":""%>"></div>
                    <div class="t-label <%=isConfirmed||isPending?"active":""%>">Xác nhận</div>
                </div>
                <!-- Bước 3: Giao hàng -->
                <div class="t-step">
                    <div class="t-dot <%=isShipped?"done":("CONFIRMED".equals(status)?"current":"")%>"><%=isShipped?"🚚":"3"%></div>
                    <div class="t-line <%=isShipped?"done":""%>"></div>
                    <div class="t-label <%=isShipped||"CONFIRMED".equals(status)?"active":""%>">Giao hàng</div>
                </div>
                <!-- Bước 4: Hoàn thành -->
                <div class="t-step">
                    <div class="t-dot <%=isCompleted?"done":("SHIPPED".equals(status)?"current":"")%>"><%=isCompleted?"🏆":"4"%></div>
                    <div class="t-label <%=isCompleted?"active":""%>">Hoàn thành</div>
                </div>
            </div>
        </div>
        <%}else{%>
        <div style="padding:10px 20px;background:#FFF8F8;border-top:1px solid #FFCDD2;">
            <span style="font-size:12px;color:#C62828;font-weight:600;"><i class="bi bi-x-circle-fill"></i> Đơn hàng đã bị hủy</span>
        </div>
        <%}%>

        <!-- Info body -->
        <div class="order-body">
            <div class="info-row">
                <span class="info-label"><i class="bi bi-person-circle"></i> Nông dân</span>
                <span class="info-value"><%=order.getFarmerName()!=null?order.getFarmerName():"—"%></span>
            </div>
            <%if(order.getShipAddress()!=null&&!order.getShipAddress().isEmpty()){%>
            <div class="info-row">
                <span class="info-label"><i class="bi bi-geo-alt"></i> Địa chỉ giao</span>
                <span class="info-value" style="text-align:right;max-width:55%;"><%=order.getShipAddress()%></span>
            </div>
            <%}%>
            <%if(order.getNote()!=null&&!order.getNote().isEmpty()){%>
            <div class="info-row">
                <span class="info-label"><i class="bi bi-chat-text"></i> Ghi chú</span>
                <span class="info-value"><%=order.getNote()%></span>
            </div>
            <%}%>
            <div class="info-row">
                <span class="info-label"><i class="bi bi-cash-coin"></i> <strong>Tổng tiền</strong></span>
                <span class="order-total"><%=amtStr%>đ</span>
            </div>
        </div>

        <!-- Items toggle -->
        <%List<OrderItem> items=order.getItems();
          if(items!=null&&!items.isEmpty()){%>
        <div class="items-section">
            <div class="items-toggle" onclick="toggleItems(this)">
                <i class="bi bi-chevron-right" style="transition:transform .2s;"></i>
                Xem <%=items.size()%> sản phẩm trong đơn
            </div>
            <div class="items-list">
                <%for(OrderItem item:items){
                    String qStr=item.getQuantity()!=null?nf.format(item.getQuantity()):"0";
                    String pStr=item.getUnitPrice()!=null?nf.format(item.getUnitPrice()):"0";
                    java.math.BigDecimal lt=(item.getQuantity()!=null&&item.getUnitPrice()!=null)
                        ?item.getQuantity().multiply(item.getUnitPrice()):java.math.BigDecimal.ZERO;
                %>
                <div class="item-row">
                    <div>
                        <div class="item-name"><%=item.getProductName()!=null?item.getProductName():""%></div>
                        <div style="font-size:11px;color:#9E9E9E;">x<%=qStr%> × <%=pStr%>đ</div>
                    </div>
                    <span class="item-price"><%=nf.format(lt)%>đ</span>
                </div>
                <%}%>
            </div>
        </div>
        <%}%>

        <!-- Footer actions -->
        <div class="order-footer">
            <%-- Hủy đơn — chỉ khi PENDING --%>
            <%if("PENDING".equals(status)){%>
            <form action="<%=ctx%>/buyer/orders/cancel" method="post" style="display:inline;"
                  onsubmit="return confirm('Bạn có chắc muốn hủy đơn #<%=order.getOrderId()%>?')">
                <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                <button type="submit" class="btn-action btn-cancel"><i class="bi bi-x-circle"></i> Hủy đơn</button>
            </form>
            <%}%>
            <%-- Đánh giá — chỉ khi COMPLETED --%>
            <%if("COMPLETED".equals(status)){%>
            <button class="btn-action btn-review" data-bs-toggle="modal"
                    data-bs-target="#reviewModal<%=order.getOrderId()%>">
                <i class="bi bi-star-fill"></i> Đánh giá
            </button>
            <%}%>
        </div>
    </div>

    <%-- Review Modal --%>
    <%if("COMPLETED".equals(status)){%>
    <div class="modal fade" id="reviewModal<%=order.getOrderId()%>" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="bi bi-star-fill"></i> Đánh giá đơn #<%=order.getOrderId()%></h5>
                    <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"></button>
                </div>
                <form action="<%=ctx%>/buyer/orders/review" method="post">
                    <div class="modal-body" style="padding:24px;">
                        <input type="hidden" name="farmerId" value="<%=order.getFarmerId()%>">
                        <input type="hidden" name="orderId"  value="<%=order.getOrderId()%>">
                        <div class="mb-3">
                            <label class="form-label fw-bold">Đánh giá sao</label>
                            <div style="display:flex;gap:8px;flex-direction:row-reverse;justify-content:flex-end;">
                                <%for(int s=5;s>=1;s--){%>
                                <label style="cursor:pointer;font-size:28px;color:#C8E6C9;" class="star-lbl" data-v="<%=s%>">☆
                                    <input type="radio" name="rating" value="<%=s%>" style="display:none;">
                                </label>
                                <%}%>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label fw-bold">Nhận xét</label>
                            <textarea name="comment" class="form-control" rows="3"
                                placeholder="Sản phẩm chất lượng, giao hàng nhanh..."></textarea>
                        </div>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Đóng</button>
                        <button type="submit" class="btn" style="background:var(--primary);color:white;">
                            <i class="bi bi-send"></i> Gửi đánh giá
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <%}%>

    <%}/* end forEach orders */%>

    <%}else{%>
    <!-- Empty state -->
    <div class="empty-state">
        <div class="icon">📦</div>
        <h3>Chưa có đơn hàng nào</h3>
        <p style="color:#9E9E9E;margin-bottom:24px;">Hãy khám phá marketplace và đặt hàng từ nông dân!</p>
        <a href="<%=ctx%>/marketplace" class="btn btn-lg"
           style="background:var(--primary);color:white;border-radius:14px;padding:12px 32px;font-weight:700;text-decoration:none;">
            <i class="bi bi-shop"></i> Đi mua sắm →
        </a>
    </div>
    <%}%>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Filter tabs
    document.querySelectorAll('.filter-btn').forEach(function(btn){
        btn.addEventListener('click', function(e){
            e.preventDefault();
            document.querySelectorAll('.filter-btn').forEach(function(b){b.classList.remove('active');});
            this.classList.add('active');
            var filter = this.dataset.filter;
            document.querySelectorAll('.order-card').forEach(function(card){
                if(filter === 'all' || card.dataset.status === filter)
                    card.classList.remove('hidden');
                else card.classList.add('hidden');
            });
        });
    });

    // Toggle items
    function toggleItems(el) {
        var list = el.nextElementSibling;
        var icon = el.querySelector('.bi');
        if(list.style.display === 'block'){
            list.style.display = 'none';
            icon.style.transform = 'rotate(0deg)';
        } else {
            list.style.display = 'block';
            icon.style.transform = 'rotate(90deg)';
        }
    }

    // Star rating hover
    document.querySelectorAll('.star-lbl').forEach(function(lbl){
        lbl.addEventListener('mouseenter', function(){
            var v = parseInt(this.dataset.v);
            var siblings = this.parentElement.querySelectorAll('.star-lbl');
            siblings.forEach(function(s){ s.style.color = parseInt(s.dataset.v) <= v ? '#F9A825' : '#C8E6C9'; });
        });
        lbl.addEventListener('mouseleave', function(){
            var parent = this.parentElement;
            var checked = parent.querySelector('input[type=radio]:checked');
            var v = checked ? parseInt(checked.value) : 0;
            parent.querySelectorAll('.star-lbl').forEach(function(s){
                s.style.color = parseInt(s.dataset.v) <= v ? '#F9A825' : '#C8E6C9';
            });
        });
        lbl.addEventListener('click', function(){
            var v = parseInt(this.dataset.v);
            var parent = this.parentElement;
            parent.querySelectorAll('.star-lbl').forEach(function(s){
                s.style.color = parseInt(s.dataset.v) <= v ? '#F9A825' : '#C8E6C9';
            });
        });
    });
</script>
</body>
</html>