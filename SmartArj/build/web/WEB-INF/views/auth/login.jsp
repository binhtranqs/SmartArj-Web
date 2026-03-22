<%@ page contentType="text/html; charset=UTF-8" %>
    <!DOCTYPE html>
    <html lang="vi">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Đăng Nhập - SmartArj</title>

        <!-- Google Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet">

        <!-- Custom CSS -->
        <link rel="stylesheet"
            href="${pageContext.request.contextPath}/assets/app.css?v=<%= System.currentTimeMillis() %>">

        <style>
            body {
                background:
                    linear-gradient(135deg, rgba(27,67,50,0.92) 0%, rgba(45,106,79,0.85) 50%, rgba(82,183,136,0.75) 100%),
                    url('${pageContext.request.contextPath}/assets/backgrounds/tay-bac-farm.jpg');
                background-size: cover;
                background-position: center;
                min-height: 100vh;
                display: flex;
                align-items: center;
                justify-content: center;
                padding: 2rem;
                font-family: 'Plus Jakarta Sans', sans-serif;
            }

            .login-container {
                background: white;
                border-radius: 1.5rem;
                box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
                max-width: 450px;
                width: 100%;
                padding: 3rem;
            }

            .login-header {
                text-align: center;
                margin-bottom: 2rem;
            }

            .login-logo {
                font-size: 3rem;
                margin-bottom: 1rem;
            }

            .login-title {
                font-size: 1.75rem;
                font-weight: 700;
                color: var(--text-primary);
                margin-bottom: 0.5rem;
            }

            .login-subtitle {
                color: var(--text-secondary);
                font-size: 0.9375rem;
            }

            .form-group {
                margin-bottom: 1.5rem;
            }

            .form-label {
                display: block;
                margin-bottom: 0.5rem;
                color: var(--text-primary);
                font-weight: 600;
                font-size: 0.9375rem;
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
                border-color: var(--primary);
                box-shadow: 0 0 0 3px rgba(45, 106, 79, 0.12);
            }

            .form-checkbox {
                display: flex;
                align-items: center;
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

            .login-footer {
                text-align: center;
                margin-top: 2rem;
                padding-top: 2rem;
                border-top: 1px solid var(--border-color);
            }

            .login-footer a {
                color: var(--primary);
                text-decoration: none;
                font-weight: 600;
            }

            .login-footer a:hover {
                text-decoration: underline;
            }
        </style>
    </head>

    <body>

        <div class="login-container">
            <div class="login-header">
                <div class="login-logo">🌿</div>
                <h1 class="login-title">Đăng Nhập</h1>
                <p class="login-subtitle">Chào mừng trở lại với SmartArj</p>
            </div>

            <% if (request.getAttribute("error") !=null) { %>
                <div class="error-message">
                    ⚠️ <%= request.getAttribute("error") %>
                </div>
                <% } %>

                    <form method="POST" action="${pageContext.request.contextPath}/login">
                        <div class="form-group">
                            <label class="form-label">Tên đăng nhập</label>
                            <input type="text" name="username" class="form-input" placeholder="Nhập tên đăng nhập"
                                value="<%= request.getAttribute(" username") !=null ? request.getAttribute("username")
                                : "" %>"
                            required
                            autofocus>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Mật khẩu</label>
                            <input type="password" name="password" class="form-input" placeholder="Nhập mật khẩu"
                                required>
                        </div>

                        <div class="form-checkbox">
                            <input type="checkbox" name="remember" id="remember">
                            <label for="remember" style="color: var(--text-secondary); font-size: 0.875rem;">
                                Ghi nhớ đăng nhập
                            </label>
                        </div>

                        <button type="submit" class="btn btn-primary"
                            style="width: 100%; padding: 1rem; font-size: 1rem;">
                            🔐 Đăng Nhập
                        </button>
                    </form>

                    <div class="login-footer">
                        <p style="color: var(--text-secondary); margin-bottom: 0.5rem;">
                            Chưa có tài khoản?
                        </p>
                        <a href="${pageContext.request.contextPath}/register">
                            Đăng ký ngay →
                        </a>
                    </div>
        </div>

    </body>

    </html>