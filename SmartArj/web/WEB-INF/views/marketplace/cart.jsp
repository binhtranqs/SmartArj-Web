<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ hàng | SmartAgri Marketplace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&family=Nunito:wght@700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #2E7D32;
            --primary-dark: #1B5E20;
            --primary-light: #4CAF50;
            --bg-light: #F1F8E9;
            --accent-yellow: #F9A825;
            --border: #E8F5E9;
        }

        body { font-family: 'Plus Jakarta Sans', sans-serif; background: #F5F7F5; margin: 0; }

        /* ── Top bar ── */
        .top-bar {
            background: linear-gradient(135deg, var(--primary-dark), var(--primary));
            padding: 14px 28px; display: flex; align-items: center; justify-content: space-between;
        }
        .top-bar a { color: white; text-decoration: none; font-weight: 600; font-size: 14px;
            display: inline-flex; align-items: center; gap: 6px; }
        .top-bar a:hover { opacity: .85; }
        .top-bar .brand { font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 18px; color: white; }

        /* ── Layout ── */
        .cart-container { max-width: 1060px; margin: 32px auto; padding: 0 20px; }

        .cart-title {
            font-family: 'Nunito', sans-serif; font-size: 1.7rem; font-weight: 900;
            color: var(--primary-dark); margin: 0 0 20px;
            display: flex; align-items: center; gap: 10px;
        }

        /* ── Cart card ── */
        .cart-card {
            background: white; border-radius: 18px;
            box-shadow: 0 4px 24px rgba(46,125,50,0.09); overflow: hidden; margin-bottom: 20px;
        }

        /* ── Select-all header ── */
        .cart-header-row {
            display: flex; align-items: center; gap: 14px;
            padding: 14px 22px; border-bottom: 2px solid var(--bg-light);
            background: #FAFFF9;
        }
        .cart-header-row label { font-size: 13px; font-weight: 700; color: #555; cursor: pointer; }

        /* ── Cart item ── */
        .cart-item {
            display: flex; align-items: center; gap: 14px;
            padding: 16px 22px; border-bottom: 1px solid var(--border);
            transition: background .15s;
        }
        .cart-item:last-child { border-bottom: none; }
        .cart-item:hover { background: #FAFFF9; }
        .cart-item.dimmed { opacity: .45; }

        /* Custom checkbox */
        .item-check {
            width: 20px; height: 20px; border-radius: 6px;
            border: 2px solid #C8E6C9; background: white;
            cursor: pointer; flex-shrink: 0; appearance: none;
            -webkit-appearance: none; transition: all .18s;
            display: flex; align-items: center; justify-content: center;
        }
        .item-check:checked {
            background: var(--primary); border-color: var(--primary);
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 16 16'%3E%3Cpath d='M13.5 3.5L6 11 2.5 7.5' stroke='white' stroke-width='2' fill='none' stroke-linecap='round' stroke-linejoin='round'/%3E%3C/svg%3E");
            background-repeat: no-repeat; background-position: center;
        }

        /* Item image */
        .item-img {
            width: 68px; height: 68px; border-radius: 12px; background: var(--bg-light);
            display: flex; align-items: center; justify-content: center;
            font-size: 30px; flex-shrink: 0; overflow: hidden;
        }
        .item-img img { width: 100%; height: 100%; object-fit: cover; }

        /* Item info */
        .item-info { flex: 1; min-width: 0; }
        .item-name { font-weight: 700; font-size: 14px; color: #1A2E1A; margin: 0 0 4px;
            white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .item-farmer { font-size: 12px; color: #6B7B6B; display: flex; align-items: center; gap: 4px; }

        /* Price column */
        .item-price-col { text-align: right; min-width: 110px; flex-shrink: 0; }
        .item-unit-price { font-size: 11px; color: #9E9E9E; margin-bottom: 2px; }
        .item-subtotal { font-family: 'Nunito', sans-serif; font-weight: 800; font-size: 1rem; color: var(--primary); }

        /* Qty badge */
        .item-qty-badge {
            background: var(--bg-light); color: var(--primary-dark);
            font-size: 12px; font-weight: 700; padding: 4px 12px;
            border-radius: 20px; flex-shrink: 0;
        }

        /* Remove btn */
        .btn-remove {
            background: #FFEBEE; color: #C62828; border: none;
            border-radius: 8px; padding: 6px 10px; font-size: 13px;
            cursor: pointer; transition: all .2s; flex-shrink: 0;
        }
        .btn-remove:hover { background: #C62828; color: white; }

        /* ── Summary card ── */
        .summary-card {
            background: white; border-radius: 18px;
            box-shadow: 0 4px 24px rgba(46,125,50,0.09);
            padding: 24px; position: sticky; top: 16px;
        }
        .summary-title {
            font-family: 'Nunito', sans-serif; font-weight: 900;
            color: var(--primary-dark); margin: 0 0 18px; font-size: 1.1rem;
            display: flex; align-items: center; gap: 8px;
        }
        .summary-row {
            display: flex; justify-content: space-between;
            padding: 9px 0; font-size: 13.5px;
            border-bottom: 1px solid var(--border);
        }
        .summary-row:last-of-type { border-bottom: none; }
        .summary-total-row {
            display: flex; justify-content: space-between; align-items: center;
            padding: 14px 0 0; margin-top: 4px; border-top: 2px solid var(--bg-light);
        }
        .summary-total-label { font-weight: 700; font-size: 15px; }
        .summary-total-val {
            font-family: 'Nunito', sans-serif; font-size: 1.5rem;
            font-weight: 900; color: var(--primary);
        }

        /* Selected count chip */
        .selected-chip {
            background: var(--bg-light); color: var(--primary-dark);
            font-size: 12px; font-weight: 700; padding: 4px 12px;
            border-radius: 20px; display: inline-block; margin-bottom: 14px;
        }

        /* Checkout btn */
        .btn-checkout {
            background: var(--primary); color: white; border: none;
            border-radius: 14px; padding: 15px; font-size: 15px; font-weight: 700;
            width: 100%; cursor: pointer; transition: all .2s; margin-top: 16px;
            display: flex; align-items: center; justify-content: center; gap: 8px;
            text-decoration: none;
        }
        .btn-checkout:hover { background: var(--primary-dark); color: white; transform: translateY(-2px); }
        .btn-checkout:disabled {
            background: #BDBDBD; color: white; cursor: not-allowed; transform: none;
            opacity: .7;
        }

        /* Empty state */
        .empty-state { text-align: center; padding: 70px 20px; }
        .empty-state .emoji { font-size: 64px; display: block; margin-bottom: 16px; }
        .empty-state h3 { font-size: 18px; font-weight: 700; color: #555; margin-bottom: 8px; }
        .empty-state p { color: #9E9E9E; margin-bottom: 20px; }

        /* No selection warning */
        .warn-box {
            background: #FFF8E1; border: 1px solid #FFE082; color: #E65100;
            border-radius: 10px; padding: 12px 16px; font-size: 13px; font-weight: 600;
            display: none; align-items: center; gap: 8px; margin-top: 12px;
        }
        .warn-box.show { display: flex; }

        /* Qty editor in cart */
        .cart-qty-wrap { display: flex; align-items: center; gap: 6px; flex-shrink: 0; }
        .cq-btn {
            width: 28px; height: 28px; border-radius: 8px; border: 2px solid #C8E6C9;
            background: white; color: var(--primary); font-size: 16px; font-weight: 700;
            cursor: pointer; display: flex; align-items: center; justify-content: center;
            transition: all .18s; line-height:1;
        }
        .cq-btn:hover { background: var(--primary); color: white; border-color: var(--primary); }
        .cq-input {
            width: 75px; text-align: center; border: 2px solid #C8E6C9;
            border-radius: 8px; font-size: 13px; font-weight: 700;
            padding: 3px 4px; color: var(--primary-dark);
        }
        .cq-input:focus { border-color: var(--primary); outline: none; }
        .cq-unit { font-size: 11px; color: #9E9E9E; }
    </style>
</head>
<body>

<div class="top-bar">
    <a href="${pageContext.request.contextPath}/marketplace">
        <i class="bi bi-arrow-left"></i> Tiếp tục mua sắm
    </a>
    <span class="brand">🌾 SmartAgri</span>
    <a href="${pageContext.request.contextPath}/buyer/orders"
       style="margin-left:auto;color:white;text-decoration:none;font-weight:600;font-size:13px;
              display:inline-flex;align-items:center;gap:6px;opacity:.9;"
       title="Xem đơn hàng của tôi">
        <i class="bi bi-bag-heart-fill"></i> Đơn hàng của tôi
    </a>
</div>

<div class="cart-container">
    <h1 class="cart-title">🛒 Giỏ hàng</h1>

    <c:if test="${param.error == 'empty'}">
        <div class="alert alert-warning mb-3">Vui l&#xf2;ng ch&#x1ecd;n &#xed;t nh&#x1ea5;t 1 s&#x1ea3;n ph&#x1ea9;m &#x111;&#x1ec3; &#x111;&#x1eb7;t h&#xe0;ng!</div>
    </c:if>
    <c:if test="${param.error != null && param.error != 'empty'}">
        <div class="alert alert-danger mb-3">${param.error}</div>
    </c:if>
    <c:if test="${unavailableCount > 0}">
        <div class="alert alert-warning mb-3 d-flex align-items-center gap-2">
            <i class="bi bi-exclamation-triangle-fill"></i>
            <span><strong>${unavailableCount} s&#x1ea3;n ph&#x1ea9;m</strong> trong gi&#x1ecf; &#x111;&#xe3; h&#x1ebf;t h&#xe0;ng ho&#x1eb7;c kh&#xf4;ng c&#xf2;n b&#xe1;n. H&#xe3;y x&#xf3;a ch&#xfa;ng tr&#x01b0;&#x1edb;c khi thanh to&#xe1;n.</span>
        </div>
    </c:if>

    <div class="row g-4">
        <!-- ── Item list ── -->
        <div class="col-lg-8">
            <div class="cart-card">
                <c:choose>
                    <c:when test="${not empty cartItems}">
                        <!-- Select all header -->
                        <div class="cart-header-row">
                            <input type="checkbox" class="item-check" id="check-all" checked
                                   onchange="toggleAll(this)">
                            <label for="check-all">Chọn tất cả (${cartItems.size()} sản phẩm)</label>
                        </div>

                        <!-- Items -->
                        <c:forEach var="item" items="${cartItems}">
                            <div class="cart-item${not item.available ? ' dimmed' : ''}" id="row-${item.cartId}">
                                <%-- Disable checkbox khi listing kh&#xf4;ng kh&#x1ea3; d&#x1ee5;ng --%>
                                <input type="checkbox" class="item-check item-cb"
                                       id="cb-${item.cartId}"
                                       data-subtotal="${item.available ? item.subTotal : 0}"
                                       ${item.available ? 'checked' : 'disabled'}
                                       onchange="recalcTotal()">

                                <div class="item-img">
                                    <c:choose>
                                        <c:when test="${item.imageUrl != null && item.imageUrl != ''}">
                                            <img src="${item.imageUrl}" alt="${item.productName}">
                                        </c:when>
                                        <c:otherwise>🌿</c:otherwise>
                                    </c:choose>
                                </div>

                                <div class="item-info">
                                    <p class="item-name">
                                        ${item.productName}
                                        <c:if test="${item.listingDeleted}">
                                            <span class="badge bg-secondary ms-1" style="font-size:10px;">&#x0110;&#xe3; x&#xf3;a</span>
                                        </c:if>
                                        <c:if test="${not item.listingDeleted && 'SOLD_OUT' eq item.listingStatus}">
                                            <span class="badge bg-danger ms-1" style="font-size:10px;">H&#x1ebf;t h&#xe0;ng</span>
                                        </c:if>
                                        <c:if test="${not item.listingDeleted && 'HIDDEN' eq item.listingStatus}">
                                            <span class="badge bg-warning text-dark ms-1" style="font-size:10px;">T&#x1ea1;m &#x1ea9;n</span>
                                        </c:if>
                                    </p>
                                    <p class="item-farmer">
                                        <i class="bi bi-person-circle"></i> ${item.farmerName}
                                        <c:if test="${item.regionName != null}">
                                            &nbsp;•&nbsp; 📍 ${item.regionName}
                                        </c:if>
                                    </p>
                                </div>

                                <%-- Qty editor: ch&#x1ec9; cho ph&#xe9;p khi c&#xf2;n kh&#x1ea3; d&#x1ee5;ng --%>
                                <div class="cart-qty-wrap" id="qty-wrap-${item.cartId}">
                                    <c:choose>
                                        <c:when test="${item.available}">
                                            <button type="button" class="cq-btn"
                                                    onclick="cartQtyChange(${item.cartId}, -1)">&#8722;</button>
                                            <input type="number" class="cq-input"
                                                   id="cq-${item.cartId}"
                                                   value="${item.quantity}"
                                                   min="1" step="1"
                                                   max="${item.availableQty}"
                                                   data-unit-price="${item.unitPrice}"
                                                   oninput="cartQtyUpdate(${item.cartId}, true)"
                                                   onblur="cartQtyUpdate(${item.cartId}, false)">
                                            <span class="cq-unit">${item.unit}</span>
                                            <button type="button" class="cq-btn"
                                                    onclick="cartQtyChange(${item.cartId}, 1)">+</button>
                                        </c:when>
                                        <c:otherwise>
                                            <span class="cq-unit text-muted">${item.quantity} ${item.unit}</span>
                                        </c:otherwise>
                                    </c:choose>
                                </div>

                                <!-- Hidden update form -->
                                <form id="upd-form-${item.cartId}"
                                      action="${pageContext.request.contextPath}/buyer/cart/update"
                                      method="post" style="display:none;">
                                    <input type="hidden" name="cartId" value="${item.cartId}">
                                    <input type="hidden" name="quantity" id="upd-qty-${item.cartId}" value="${item.quantity}">
                                </form>

                                <!-- Price -->
                                <div class="item-price-col">
                                    <div class="item-unit-price">
                                        <fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/>đ/${item.unit}
                                    </div>
                                    <div class="item-subtotal" id="sub-${item.cartId}">
                                        <fmt:formatNumber value="${item.subTotal}" pattern="#,##0"/>đ
                                    </div>
                                </div>

                                <!-- Remove -->
                                <form action="${pageContext.request.contextPath}/buyer/cart/remove"
                                      method="post" style="margin:0;">
                                    <input type="hidden" name="cartId" value="${item.cartId}">
                                    <button type="submit" class="btn-remove" title="Xóa khỏi giỏ">
                                        <i class="bi bi-trash"></i>
                                    </button>
                                </form>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-state">
                            <span class="emoji">🛒</span>
                            <h3>Giỏ hàng trống</h3>
                            <p>Hãy thêm sản phẩm vào giỏ để bắt đầu mua sắm</p>
                            <a href="${pageContext.request.contextPath}/marketplace" class="btn-checkout"
                               style="width:auto;display:inline-flex;margin:0 auto;">
                                Khám phá sản phẩm →
                            </a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <!-- ── Summary ── -->
        <c:if test="${not empty cartItems}">
            <div class="col-lg-4">
                <div class="summary-card">
                    <div class="summary-title">
                        <i class="bi bi-receipt"></i> Tóm tắt đơn hàng
                    </div>

                    <span class="selected-chip" id="selectedChip">
                        Đang chọn: ${cartItems.size()} loại
                    </span>

                    <div class="summary-row">
                        <span>Phí vận chuyển</span>
                        <span style="color:var(--primary);font-weight:600;">Thỏa thuận</span>
                    </div>

                    <div class="summary-total-row">
                        <span class="summary-total-label">Tổng cộng</span>
                        <span class="summary-total-val" id="summaryTotal">
                            <fmt:formatNumber value="${cartTotal}" pattern="#,##0"/>đ
                        </span>
                    </div>

                    <!-- Warning when nothing selected -->
                    <div class="warn-box" id="warnBox">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                        Vui lòng chọn ít nhất 1 sản phẩm!
                    </div>

                    <!-- Checkout form — passes selected cartIds -->
                    <form id="checkoutForm"
                          action="${pageContext.request.contextPath}/buyer/checkout"
                          method="get">
                        <div id="selectedInputs"></div>
                        <button type="button" class="btn-checkout" id="checkoutBtn"
                                onclick="submitCheckout()">
                            <i class="bi bi-bag-check"></i>
                            <span id="checkoutBtnLabel">Đặt hàng ngay</span>
                        </button>
                    </form>
                </div>
            </div>
        </c:if>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // ── Precompute subtotals from data-subtotal attributes ──
    function getCheckedItems() {
        return Array.from(document.querySelectorAll('.item-cb:checked'));
    }

    function recalcTotal() {
        var checked = getCheckedItems();
        var total = 0;
        checked.forEach(function(cb) {
            total += parseFloat(cb.dataset.subtotal) || 0;
        });

        // Update total display
        document.getElementById('summaryTotal').textContent =
            total.toLocaleString('vi-VN') + 'đ';

        // Update chip
        var chip = document.getElementById('selectedChip');
        if (chip) chip.textContent = 'Đang chọn: ' + checked.length + ' loại';

        // Dim unselected rows
        document.querySelectorAll('.item-cb').forEach(function(cb) {
            var row = document.getElementById('row-' + cb.id.replace('cb-', ''));
            if (row) row.classList.toggle('dimmed', !cb.checked);
        });

        // Show/hide warning
        var warn = document.getElementById('warnBox');
        if (warn) warn.classList.toggle('show', checked.length === 0);

        // Disable/enable checkout btn
        var btn = document.getElementById('checkoutBtn');
        if (btn) btn.disabled = checked.length === 0;

        // Update select-all state
        var all = document.querySelectorAll('.item-cb');
        var checkAll = document.getElementById('check-all');
        if (checkAll) {
            checkAll.indeterminate = checked.length > 0 && checked.length < all.length;
            checkAll.checked = checked.length === all.length;
        }

        // Rebuild hidden inputs for selected cartIds
        var container = document.getElementById('selectedInputs');
        if (container) {
            container.innerHTML = '';
            checked.forEach(function(cb) {
                var inp = document.createElement('input');
                inp.type = 'hidden';
                inp.name = 'cartId';
                inp.value = cb.id.replace('cb-', '');
                container.appendChild(inp);
            });
        }
    }

    function toggleAll(cb) {
        document.querySelectorAll('.item-cb').forEach(function(c) {
            c.checked = cb.checked;
        });
        recalcTotal();
    }

    function submitCheckout() {
        var checked = getCheckedItems();
        if (checked.length === 0) {
            document.getElementById('warnBox').classList.add('show');
            return;
        }
        document.getElementById('checkoutForm').submit();
    }

    // Init on load
    recalcTotal();

    // ─── Cart qty editor ───
    var _qtyTimers = {};

    function cartQtyChange(cartId, delta) {
        var inp = document.getElementById('cq-' + cartId);
        if (!inp) return;
        var val = Math.max(1, (parseInt(inp.value) || 1) + delta);
        inp.value = val;
        cartQtyUpdate(cartId, false);
    }

    function cartQtyUpdate(cartId, isInput = false) {
        var inp = document.getElementById('cq-' + cartId);
        if (!inp) return;
        
        var maxQty = parseFloat(inp.getAttribute('max')) || 9999999;
        var rawVal = parseInt(inp.value);
        var qty;
        
        if (isNaN(rawVal)) {
            if (isInput) {
                qty = 1; // Nội bộ xem là 1 để tính tiền, nhưng chưa can thiệp sửa UI
            } else {
                qty = 1;
                inp.value = 1;
            }
        } else {
            qty = Math.max(1, rawVal);
            if (qty > maxQty) {
                qty = maxQty;
                inp.value = qty;
            } else if (!isInput) {
                inp.value = qty;
            }
        }

        var unitPrice = parseFloat(inp.dataset.unitPrice) || 0;
        var subtotal = qty * unitPrice;

        // Cập nhật giá hiển thị ngay lập tức
        var subEl = document.getElementById('sub-' + cartId);
        if (subEl) subEl.textContent = subtotal.toLocaleString('vi-VN') + 'đ';

        // Cập nhật data-subtotal trên checkbox để recalcTotal đúng
        var cb = document.getElementById('cb-' + cartId);
        if (cb) cb.dataset.subtotal = subtotal;

        recalcTotal();

        // Debounce 800ms rồi submit update form
        clearTimeout(_qtyTimers[cartId]);
        _qtyTimers[cartId] = setTimeout(function() {
            var hiddenQty = document.getElementById('upd-qty-' + cartId);
            var form = document.getElementById('upd-form-' + cartId);
            if (hiddenQty && form) {
                hiddenQty.value = qty;
                form.submit();
            }
        }, 800);
    }
</script>
</body>
</html>