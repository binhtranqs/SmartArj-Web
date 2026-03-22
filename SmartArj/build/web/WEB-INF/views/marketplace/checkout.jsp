<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Thanh toán | SmartAgri</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Nunito:wght@700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #2E7D32;
            --primary-dark: #1B5E20;
            --primary-light: #43A047;
            --bg: #F1F8E9;
            --accent: #F9A825;
        }
        *, *::before, *::after { box-sizing: border-box; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); min-height: 100vh; }

        /* ── Top bar ── */
        .top-bar {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 13px 24px; display: flex; align-items: center; gap: 16px;
        }
        .top-bar a {
            color: rgba(255,255,255,.85); text-decoration: none; font-size: 13px;
            display: inline-flex; align-items: center; gap: 6px; transition: color .2s;
        }
        .top-bar a:hover { color: white; }
        .top-bar-title {
            color: white; font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 1.05rem;
            display: flex; align-items: center; gap: 8px;
        }

        /* ── Steps ── */
        .steps {
            display: flex; align-items: center; justify-content: center;
            gap: 6px; padding: 24px 0 20px;
        }
        .step { display: flex; align-items: center; gap: 6px; font-size: 12px; color: #9E9E9E; }
        .step.active { color: var(--primary); font-weight: 700; }
        .step.done { color: #4CAF50; }
        .step-num {
            width: 26px; height: 26px; border-radius: 50%; border: 2px solid #E0E0E0;
            display: flex; align-items: center; justify-content: center; font-size: 11px; font-weight: 700;
        }
        .step.active .step-num { background: var(--primary); border-color: var(--primary); color: white; }
        .step.done .step-num { background: #4CAF50; border-color: #4CAF50; color: white; }
        .step-line { width: 50px; height: 2px; background: #E0E0E0; }
        .step-line.done { background: #4CAF50; }

        /* ── Cards ── */
        .wrap { max-width: 960px; margin: 0 auto; padding: 0 20px 40px; }
        .page-title {
            font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 1.6rem;
            color: var(--primary-dark); margin-bottom: 24px;
            display: flex; align-items: center; gap: 10px;
        }
        .card-box {
            background: white; border-radius: 18px;
            box-shadow: 0 3px 20px rgba(46,125,50,0.09);
            padding: 26px 28px; margin-bottom: 18px;
        }
        .sec-title {
            font-weight: 700; font-size: 14px; color: var(--primary-dark);
            display: flex; align-items: center; gap: 8px;
            padding-bottom: 14px; border-bottom: 2px solid var(--bg); margin-bottom: 18px;
        }
        .f-label { font-size: 13px; font-weight: 600; color: #555; margin-bottom: 6px; display: block; }
        .f-input {
            width: 100%; border: 2px solid #C8E6C9; border-radius: 11px;
            padding: 11px 14px; font-size: 14px; font-family: 'Plus Jakarta Sans', sans-serif;
            transition: border-color .2s;
        }
        .f-input:focus { border-color: var(--primary); outline: none; box-shadow: 0 0 0 3px rgba(46,125,50,0.1); }

        /* ── Payment options ── */
        .pay-opts { display: flex; flex-direction: column; gap: 12px; }
        .pay-opt {
            display: flex; align-items: center; gap: 14px;
            padding: 15px 18px; border: 2.5px solid #E8E8E8; border-radius: 14px;
            cursor: pointer; transition: all .22s; position: relative; background: white;
            user-select: none;
        }
        .pay-opt:hover { border-color: #A5D6A7; background: #FAFFF9; }
        .pay-opt.selected { border-color: var(--primary); background: #F1F8E9; box-shadow: 0 0 0 3px rgba(46,125,50,0.10); }
        .pay-opt input[type="radio"] { width: 18px; height: 18px; accent-color: var(--primary); cursor: pointer; flex-shrink: 0; }
        .pay-icon { width: 42px; height: 42px; border-radius: 11px; display: flex; align-items: center; justify-content: center; font-size: 20px; flex-shrink: 0; }
        .pay-icon.cod { background: #E8F5E9; }
        .pay-icon.vnp { background: #E3F2FD; }
        .pay-name { font-weight: 700; font-size: 14px; color: #1A1A1A; }
        .pay-desc { font-size: 12px; color: #777; margin-top: 2px; }
        .pay-badge { font-size: 10px; font-weight: 800; padding: 2px 8px; border-radius: 20px; margin-top: 4px; display: inline-block; }
        .badge-blue { background: #1565C0; color: white; }
        .badge-teal { background: #00796B; color: white; }
        .badge-red  { background: #C62828; color: white; }
        .badge-or   { background: #E65100; color: white; }
        .hot-tag {
            position: absolute; top: -9px; right: 14px;
            background: var(--accent); color: #1A1A1A;
            font-size: 10px; font-weight: 800; padding: 2px 10px; border-radius: 20px;
        }

        /* ── Summary ── */
        .sum-row { display: flex; justify-content: space-between; padding: 9px 0; font-size: 13px; border-bottom: 1px solid #F5F5F5; }
        .sum-row:last-child { border-bottom: none; }
        .total-row { display: flex; justify-content: space-between; align-items: center; padding-top: 14px; margin-top: 6px; border-top: 2px solid var(--bg); }
        .total-val { font-family: 'Nunito', sans-serif; font-size: 1.55rem; font-weight: 900; color: var(--primary); }

        /* ── Buttons ── */
        .btn-cod {
            width: 100%; padding: 15px; border: none; border-radius: 14px; cursor: pointer;
            font-size: 15px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 8px;
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            color: white; box-shadow: 0 4px 18px rgba(46,125,50,0.28); transition: all .22s;
        }
        .btn-cod:hover { transform: translateY(-2px); box-shadow: 0 8px 26px rgba(46,125,50,0.35); }
        .btn-vnp {
            width: 100%; padding: 15px; border: none; border-radius: 14px; cursor: pointer;
            font-size: 15px; font-weight: 700; display: flex; align-items: center; justify-content: center; gap: 8px;
            background: linear-gradient(135deg, #1565C0, #1E88E5);
            color: white; box-shadow: 0 4px 18px rgba(21,101,192,0.28); transition: all .22s;
        }
        .btn-vnp:hover { transform: translateY(-2px); box-shadow: 0 8px 26px rgba(21,101,192,0.38); }
        .secure-note { text-align: center; font-size: 11px; color: #BDBDBD; margin-top: 10px; display: flex; align-items: center; justify-content: center; gap: 5px; }
    </style>
</head>
<body>

<%-- Top Nav --%>
<div class="top-bar">
    <a href="${pageContext.request.contextPath}/buyer/cart"><i class="bi bi-arrow-left"></i> Giỏ hàng</a>
    <span class="top-bar-title"><i class="bi bi-receipt-cutoff"></i> Đặt hàng</span>
    <a href="${pageContext.request.contextPath}/marketplace" style="margin-left:auto;"><i class="bi bi-shop"></i> Marketplace</a>
</div>

<div class="wrap">
    <%-- Steps --%>
    <div class="steps">
        <div class="step done">
            <div class="step-num"><i class="bi bi-check"></i></div>
            <span>Giỏ hàng</span>
        </div>
        <div class="step-line done"></div>
        <div class="step active">
            <div class="step-num">2</div>
            <span>Thanh toán</span>
        </div>
        <div class="step-line"></div>
        <div class="step">
            <div class="step-num">3</div>
            <span>Xác nhận</span>
        </div>
    </div>

    <div class="page-title"><i class="bi bi-bag-check-fill" style="color:var(--primary);"></i> Hoàn tất đặt hàng</div>

    <c:if test="${error != null}">
        <div class="alert alert-danger mb-4" style="border-radius:12px;"><i class="bi bi-exclamation-circle-fill"></i> ${error}</div>
    </c:if>

    <form action="${pageContext.request.contextPath}/buyer/checkout" method="post" id="checkout-form">
        <%-- Hidden: truyền các cartId được chọn từ cart.jsp --%>
        <c:forEach var="id" items="${selectedCartIds}">
            <input type="hidden" name="cartId" value="${id}">
        </c:forEach>
        <div class="row g-4">

            <%-- LEFT: Shipping + Payment --%>
            <div class="col-lg-7">

                <%-- Shipping Info --%>
                <div class="card-box">
                    <div class="sec-title"><i class="bi bi-geo-alt-fill" style="color:var(--primary);"></i> Thông tin giao hàng</div>
                    <div class="mb-3">
                        <label class="f-label">Địa chỉ giao hàng <span style="color:red;">*</span></label>
                        <input class="f-input" type="text" name="shipAddress" required
                               placeholder="Số nhà, đường, phường/xã, quận/huyện, tỉnh/thành">
                    </div>
                    <div>
                        <label class="f-label">Ghi chú cho nông dân <span style="color:#BDBDBD;">(tuỳ chọn)</span></label>
                        <textarea class="f-input" name="note" rows="2"
                                  placeholder="Yêu cầu đặc biệt về đóng gói, thời gian giao..."></textarea>
                    </div>
                </div>

                <%-- Payment Method --%>
                <div class="card-box">
                    <div class="sec-title"><i class="bi bi-credit-card-2-front-fill" style="color:var(--primary);"></i> Chọn phương thức thanh toán</div>

                    <div class="pay-opts">
                        <%-- COD --%>
                        <label class="pay-opt selected" for="pay-cod">
                            <input type="radio" id="pay-cod" name="paymentMethod" value="COD" checked>
                            <div class="pay-icon cod">💵</div>
                            <div style="flex:1;">
                                <div class="pay-name">Thanh toán khi nhận hàng (COD)</div>
                                <div class="pay-desc">Trả tiền mặt trực tiếp khi nhận hàng, an toàn và đơn giản</div>
                            </div>
                        </label>

                        <%-- VNPay --%>
                        <label class="pay-opt" for="pay-vnpay">
                            <span class="hot-tag">⚡ Nhanh hơn</span>
                            <input type="radio" id="pay-vnpay" name="paymentMethod" value="VNPAY">
                            <div class="pay-icon vnp">
                                <img src="https://sandbox.vnpayment.vn/paymentv2/Assets/Images/logoVNP.svg"
                                     alt="VNPay" style="height:26px;"
                                     onerror="this.parentNode.innerHTML='🏦';">
                            </div>
                            <div style="flex:1;">
                                <div class="pay-name">Thanh toán Online qua VNPay</div>
                                <div class="pay-desc">App ngân hàng, thẻ ATM/Visa, QR Code – xử lý tức thì</div>
                                <div style="display:flex;gap:5px;flex-wrap:wrap;margin-top:5px;">
                                    <span class="pay-badge badge-blue">VNPAY QR</span>
                                    <span class="pay-badge badge-teal">ATM</span>
                                    <span class="pay-badge badge-red">VISA / Master</span>
                                    <span class="pay-badge badge-or">App Bank</span>
                                </div>
                            </div>
                        </label>
                    </div>
                </div>
            </div>

            <%-- RIGHT: Order Summary --%>
            <div class="col-lg-5">
                <div class="card-box" style="position:sticky;top:20px;">
                    <div class="sec-title"><i class="bi bi-receipt" style="color:var(--primary);"></i> Tóm tắt đơn hàng</div>

                    <c:forEach var="item" items="${cartItems}">
                        <div class="sum-row">
                            <span>
                                ${item.productName}
                                <span style="color:#BDBDBD;">× <fmt:formatNumber value="${item.quantity}" pattern="#,##0"/>
                                    <c:if test="${item.unit != null}"> ${item.unit}</c:if>
                                </span>
                            </span>
                            <strong><fmt:formatNumber value="${item.subTotal}" pattern="#,##0"/>đ</strong>
                        </div>
                    </c:forEach>

                    <div class="total-row">
                        <span style="font-weight:700;font-size:15px;color:#1A2E1A;">Tổng cộng</span>
                        <span class="total-val"><fmt:formatNumber value="${cartTotal}" pattern="#,##0"/>đ</span>
                    </div>

                    <div style="margin-top:22px;" id="btn-wrap">
                        <button type="submit" class="btn-cod" id="btn-submit">
                            <i class="bi bi-bag-check-fill"></i> Đặt hàng (COD)
                        </button>
                        <div class="secure-note">
                            <i class="bi bi-shield-lock-fill" style="color:#43A047;"></i> Giao dịch được bảo mật SSL
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </form>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Toggle payment option highlight + update submit button
    const radios = document.querySelectorAll('input[name="paymentMethod"]');
    const btn = document.getElementById('btn-submit');

    function syncBtn(val) {
        if (val === 'VNPAY') {
            btn.className = 'btn-vnp';
            btn.innerHTML = '<i class="bi bi-lightning-charge-fill"></i> Thanh toán qua VNPay';
        } else {
            btn.className = 'btn-cod';
            btn.innerHTML = '<i class="bi bi-bag-check-fill"></i> Đặt hàng (COD)';
        }
    }

    radios.forEach(function(r) {
        r.addEventListener('change', function() {
            document.querySelectorAll('.pay-opt').forEach(function(o) { o.classList.remove('selected'); });
            this.closest('.pay-opt').classList.add('selected');
            syncBtn(this.value);
        });
    });

    // Validate
    document.getElementById('checkout-form').addEventListener('submit', function(e) {
        const addr = this.shipAddress.value.trim();
        if (!addr) {
            e.preventDefault();
            alert('Vui lòng nhập địa chỉ giao hàng!');
            this.shipAddress.focus();
        }
    });
</script>
</body>
</html>