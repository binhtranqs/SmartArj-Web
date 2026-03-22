<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Kết quả thanh toán | SmartAgri</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;700&family=Nunito:wght@800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root { --primary: #2E7D32; --primary-dark: #1B5E20; --bg: #F1F8E9; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); display: flex; flex-direction: column; align-items: center; justify-content: center; min-height: 100vh; padding: 20px; }
        .result-card {
            background: white; border-radius: 24px;
            box-shadow: 0 8px 40px rgba(46,125,50,0.12);
            padding: 52px 44px; max-width: 480px; width: 100%; text-align: center;
            animation: popIn .4s cubic-bezier(.34,1.56,.64,1);
        }
        @keyframes popIn { from { opacity: 0; transform: scale(.85); } to { opacity: 1; transform: scale(1); } }
        .result-icon { font-size: 72px; margin-bottom: 20px; display: block; }
        .result-title { font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 1.7rem; margin-bottom: 10px; }
        .result-title.success { color: var(--primary-dark); }
        .result-title.fail { color: #C62828; }
        .result-msg { font-size: 14px; color: #666; margin-bottom: 28px; line-height: 1.6; }
        .order-badge {
            background: var(--bg); border: 2px solid #A5D6A7; border-radius: 14px;
            padding: 14px 20px; margin-bottom: 28px; font-size: 13px;
        }
        .order-badge strong { color: var(--primary-dark); font-size: 1rem; }
        .btn-success-primary {
            background: linear-gradient(135deg, var(--primary), #43A047);
            color: white; border: none; border-radius: 14px; padding: 14px 28px;
            font-size: 14px; font-weight: 700; text-decoration: none; display: inline-flex;
            align-items: center; gap: 8px; transition: all .2s;
            box-shadow: 0 4px 16px rgba(46,125,50,0.3); margin: 4px;
        }
        .btn-success-primary:hover { transform: translateY(-2px); color: white; box-shadow: 0 8px 24px rgba(46,125,50,0.35); }
        .btn-outline-sm {
            background: transparent; border: 2px solid #C8E6C9; color: var(--primary);
            border-radius: 14px; padding: 11px 22px; font-size: 13px; font-weight: 600;
            text-decoration: none; display: inline-flex; align-items: center; gap: 8px;
            transition: all .2s; margin: 4px;
        }
        .btn-outline-sm:hover { background: #E8F5E9; color: var(--primary); }
        .btn-fail-primary {
            background: linear-gradient(135deg, #E53935, #EF5350);
            color: white; border: none; border-radius: 14px; padding: 14px 28px;
            font-size: 14px; font-weight: 700; text-decoration: none; display: inline-flex;
            align-items: center; gap: 8px; transition: all .2s;
            box-shadow: 0 4px 16px rgba(229,57,53,0.3); margin: 4px;
        }
        .btn-fail-primary:hover { transform: translateY(-2px); color: white; }
        .txn-info { font-size: 11px; color: #BDBDBD; margin-top: 20px; }
    </style>
</head>
<body>
<div class="result-card">
    <c:choose>
        <c:when test="${paymentSuccess}">
            <%-- ─── SUCCESS ─── --%>
            <span class="result-icon">✅</span>
            <div class="result-title success">Thanh toán thành công!</div>
            <div class="result-msg">${paymentMessage}</div>

            <c:if test="${orderId != null}">
                <div class="order-badge">
                    Mã đơn hàng của bạn:<br>
                    <strong>#${orderId}</strong>
                </div>
            </c:if>

            <div>
                <a href="${pageContext.request.contextPath}/buyer/orders" class="btn-success-primary">
                    <i class="bi bi-bag-check-fill"></i> Xem đơn hàng
                </a>
                <a href="${pageContext.request.contextPath}/marketplace" class="btn-outline-sm">
                    <i class="bi bi-shop"></i> Tiếp tục mua
                </a>
            </div>

        </c:when>
        <c:otherwise>
            <%-- ─── FAILURE ─── --%>
            <span class="result-icon">❌</span>
            <div class="result-title fail">Thanh toán thất bại</div>
            <div class="result-msg">${paymentMessage}</div>

            <div>
                <a href="${pageContext.request.contextPath}/buyer/checkout" class="btn-fail-primary">
                    <i class="bi bi-arrow-counterclockwise"></i> Thử lại
                </a>
                <a href="${pageContext.request.contextPath}/marketplace" class="btn-outline-sm">
                    <i class="bi bi-shop"></i> Marketplace
                </a>
            </div>
        </c:otherwise>
    </c:choose>

    <c:if test="${txnRef != null}">
        <div class="txn-info">Mã giao dịch: ${txnRef}</div>
    </c:if>
</div>
</body>
</html>
