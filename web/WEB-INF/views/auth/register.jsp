<%@ page contentType="text/html; charset=UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng Ký - SmartArj</title>

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">

        <!-- Custom CSS -->
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/app.css">

        <style>
            body {
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 2rem;
            }

            .register-container {
                background: white;
                border-radius: 1.5rem;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                max-width: 500px;
                width: 100%;
                padding: 3rem;
            }

            .register-header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .register-logo {
                font-size: 3rem;
                margin-bottom: 1rem;
            }

            .register-title {
                font-size: 1.75rem;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 0.5rem;
            }

            .register-subtitle {
                color: var(--text-secondary);
                font-size: 0.9375rem;
            }

            .form-group {
                margin-bottom: 1.25rem;
            }

            .form-label {
                display: block;
                margin-bottom: 0.5rem;
                color: var(--text-primary);
                font-weight: 600;
                font-size: 0.875rem;
            }

            .form-input {
                width: 100%;
                padding: 0.875rem 1rem;
                border: 2px solid var(--border-color);
                border-radius: var(--radius-md);
                font-size: 0.9375rem;
                transition: all 0.2s;
            }

            .form-input:focus {
                outline: none;
                border-color: #667eea;
                box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
            }

            .form-checkbox {
                display: flex;
                align-items: flex-start;
                gap: 0.5rem;
                margin-bottom: 1.5rem;
            }

            .error-message {
                background: rgba(239, 68, 68, 0.1);
                color: var(--danger);
                padding: 0.875rem 1rem;
                border-radius: var(--radius-md);
                margin-bottom: 1.5rem;
                font-size: 0.875rem;
                border-left: 4px solid var(--danger);
            }

            .register-footer {
                text-align: center;
                margin-top: 2rem;
                padding-top: 2rem;
                border-top: 1px solid var(--border-color);
            }

            .register-footer a {
                color: #667eea;
                text-decoration: none;
                font-weight: 600;
            }

            .register-footer a:hover {
                text-decoration: underline;
            }
        </style>
    </head>

    <body>

        <div class="register-container">
            <div class="register-header">
                <div class="register-logo">🌱</div>
                <h1 class="register-title">Đăng Ký</h1>
                <p class="register-subtitle">Tạo tài khoản miễn phí ngay hôm nay</p>
            </div>

            <% if (request.getAttribute("error") !=null) { %>
                <div class="error-message">
                    ⚠️ <%= request.getAttribute("error") %>
                </div>
                <% } %>

                    <form method="POST" action="${pageContext.request.contextPath}/register">
                        <div class="form-group">
                            <label class="form-label">Tên đăng nhập *</label>
                            <input type="text" name="username" class="form-input" placeholder="Chọn tên đăng nhập"
                                value="<%= request.getAttribute(" username") !=null ? request.getAttribute("username")
                                : "" %>"
                            required
                            autofocus>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Email *</label>
                            <input type="email" name="email" class="form-input" placeholder="email@example.com"
                                value="<%= request.getAttribute(" email") !=null ? request.getAttribute("email") : ""
                                %>"
                            required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Họ và tên</label>
                            <input type="text" name="fullName" class="form-input" placeholder="Nguyễn Văn A"
                                value="<%= request.getAttribute(" fullName") !=null ? request.getAttribute("fullName")
                                : "" %>">
                        </div>

                        <div class="form-group">
                            <label class="form-label">Nơi bạn sống *</label>
                            <select name="cityId" class="form-input" required>
                                <option value="" disabled selected>Chọn tỉnh/thành phố</option>
                                <option value="1">Đà Nẵng</option>
                                <option value="3">Hà Nội</option>
                                <option value="2">Hồ Chí Minh</option>
                                <option value="4">Cần Thơ</option>
                                <option value="5">Đà Lạt</option>
                                <option value="6">Đắk Lắk</option>
                                <option value="7">Hải Phòng</option>
                                <option value="8">Huế</option>
                                <option value="9">Nha Trang</option>
                                <option value="10">Sapa</option>
                            </select>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Mật khẩu *</label>
                            <input type="password" name="password" class="form-input" placeholder="Ít nhất 6 ký tự"
                                required>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Xác nhận mật khẩu *</label>
                            <input type="password" name="confirmPassword" class="form-input"
                                placeholder="Nhập lại mật khẩu" required>
                        </div>

                        <div class="form-checkbox">
                            <input type="checkbox" name="agree" id="agree" required>
                            <label for="agree"
                                style="color: var(--text-secondary); font-size: 0.875rem; line-height: 1.5;">
                                Tôi đồng ý với <a href="#" style="color: #667eea;">Điều khoản sử dụng</a>
                                và <a href="#" style="color: #667eea;">Chính sách bảo mật</a>
                            </label>
                        </div>

                        <button type="submit" class="btn btn-primary"
                            style="width: 100%; padding: 1rem; font-size: 1rem;">
                            🚀 Đăng Ký Ngay
                        </button>
                    </form>

                    <div class="register-footer">
                        <p style="color: var(--text-secondary); margin-bottom: 0.5rem;">
                            Đã có tài khoản?
                        </p>
                        <a href="${pageContext.request.contextPath}/login">
                            Đăng nhập ngay →
                        </a>
                    </div>
        </div>

    </body>

    </html>