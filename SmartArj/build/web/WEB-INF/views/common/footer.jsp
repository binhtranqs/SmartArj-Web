<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
    <%@ page import="model.User" %>
        <% User currentUser=(User) session.getAttribute("user"); boolean isVIP=(currentUser !=null &&
            currentUser.isVIP()); %>

            <% if (isVIP) { %>
                <button id="chatToggle" class="chat-toggle"
                    onclick="(function(){var w=document.getElementById('chatWindow');w.classList.toggle('show');if(w.classList.contains('show'))document.getElementById('chatInput').focus();})()">
                    💬
                </button>

                <div id="chatWindow" class="chat-window">
                    <div class="chat-header">
                        <div class="chat-title">🤖 ChatBox AI</div>
                        <button class="chat-close"
                            onclick="document.getElementById('chatWindow').classList.remove('show')">✕</button>
                    </div>
                    <div id="chatMessages" class="chat-messages">
                        <div class="chat-message bot">
                            Chào bạn! 👋 Mình là SmartArj AI — bạn đồng hành nông nghiệp của bạn. Bạn muốn biết gì nào?
                            Thời tiết hôm nay ☀️, cảnh báo ⚠️, hay cây trồng 🌱?
                        </div>
                    </div>
                    <div class="chat-input-wrapper">
                        <input type="text" id="chatInput" class="chat-input" placeholder="Nhập câu hỏi...">
                        <button id="chatSend" class="chat-send" onclick="smartArjChat()">Gửi</button>
                    </div>
                </div>

                <script>
                    var STORAGE_KEY = 'smartarj_chat_history';

                    // Load history từ sessionStorage (tồn tại khi navigate, mất khi đóng tab)
                    var conversationHistory = [];
                    try {
                        var saved = sessionStorage.getItem(STORAGE_KEY);
                        if (saved) conversationHistory = JSON.parse(saved);
                    } catch (e) { }

                    // Render lại các tin nhắn cũ khi trang load
                    (function restoreMessages() {
                        var msgs = document.getElementById('chatMessages');
                        if (!msgs || conversationHistory.length === 0) return;
                        for (var i = 0; i < conversationHistory.length; i++) {
                            var item = conversationHistory[i];
                            var div = document.createElement('div');
                            div.className = 'chat-message ' + (item.role === 'user' ? 'user' : 'bot');
                            div.style.whiteSpace = 'pre-line';
                            div.textContent = item.content;
                            msgs.appendChild(div);
                        }
                        msgs.scrollTop = msgs.scrollHeight;
                    })();

                    document.getElementById('chatInput').addEventListener('keypress', function (e) {
                        if (e.key === 'Enter') smartArjChat();
                    });

                    function saveHistory() {
                        try { sessionStorage.setItem(STORAGE_KEY, JSON.stringify(conversationHistory)); }
                        catch (e) { }
                    }

                    function smartArjChat() {
                        var input = document.getElementById('chatInput');
                        var msgs = document.getElementById('chatMessages');
                        var msg = input.value.trim();
                        if (!msg) return;

                        // Hiện tin user
                        var uDiv = document.createElement('div');
                        uDiv.className = 'chat-message user';
                        uDiv.textContent = msg;
                        msgs.appendChild(uDiv);
                        msgs.scrollTop = msgs.scrollHeight;
                        input.value = '';

                        // Hiện typing indicator
                        var typing = document.createElement('div');
                        typing.className = 'chat-message bot';
                        typing.innerHTML = '<em>⏳ Đang xử lý...</em>';
                        typing.id = 'chatTyping';
                        msgs.appendChild(typing);
                        msgs.scrollTop = msgs.scrollHeight;

                        var zoneEl = document.getElementById('zoneId');
                        var zoneId = zoneEl ? zoneEl.value : '';
                        var ctx = '<%= request.getContextPath() %>';

                        // === Frontend enrichment: fix "thời tiết hôm nay" routing ===
                        // Backend có 2 path xử lý thời tiết:
                        //   1. getWeatherByDateOffset → SQL: RecordedAt = TODAY (strict, có thể trả về rỗng)
                        //   2. getWeatherAnswerWithContext → SQL: TOP 1 ORDER BY RecordedAt DESC (luôn có data)
                        // Để route sang path 2 (luôn hoạt động), thêm từ khoá "hiện tại"
                        // vào các câu hỏi thời tiết đơn giản về hôm nay mà chưa có từ phân tích.
                        var msgToSend = msg;
                        var msgLower = msg.toLowerCase();
                        var isWeatherQuery = msgLower.includes('thời tiết') || msgLower.includes('nhiệt độ')
                            || msgLower.includes('độ ẩm') || msgLower.includes('lượng mưa')
                            || msgLower.includes('weather') || msgLower.includes('temperature');
                        var isTodayQuery = msgLower.includes('hôm nay') || msgLower.includes('bây giờ')
                            || (!msgLower.includes('ngày mai') && !msgLower.includes('hôm qua')
                                && !msgLower.includes('ngày trước') && !msgLower.includes('ngày sau')
                                && !msgLower.includes('tuần') && !msgLower.includes('dự báo')
                                && !msgLower.includes('forecast'));
                        var isAlreadyAnalysis = msgLower.includes('hiện tại') || msgLower.includes('ảnh hưởng')
                            || msgLower.includes('có nên') || msgLower.includes('lời khuyên')
                            || msgLower.includes('phân tích') || msgLower.includes('tư vấn');
                        if (isWeatherQuery && isTodayQuery && !isAlreadyAnalysis) {
                            // Thêm "hiện tại" để kích hoạt path getWeatherAnswerWithContext
                            // (dùng TOP 1 ORDER BY RecordedAt DESC, không bị lỗi ngày tháng)
                            msgToSend = msg + ' hiện tại';
                        }

                        // Build body — gửi kèm history (tối đa 10 tin gần nhất)
                        var body = 'message=' + encodeURIComponent(msgToSend);
                        if (zoneId) body += '&zoneId=' + encodeURIComponent(zoneId);
                        if (conversationHistory.length > 0) {
                            var recent = conversationHistory.slice(-10);
                            body += '&history=' + encodeURIComponent(JSON.stringify(recent));
                        }

                        // Thêm tin user vào history và lưu
                        conversationHistory.push({ role: 'user', content: msg });
                        saveHistory();

                        fetch(ctx + '/api/chat', {
                            method: 'POST',
                            headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
                            body: body
                        })
                            .then(function (r) { return r.json(); })
                            .then(function (json) {
                                var t = document.getElementById('chatTyping');
                                if (t) t.remove();
                                var reply = json.reply || 'Không có phản hồi.';

                                // Render markdown bold: **text** → <strong>text</strong>
                                function renderMarkdown(text) {
                                    return text
                                        .replace(/&/g, '&amp;')
                                        .replace(/</g, '&lt;')
                                        .replace(/>/g, '&gt;')
                                        .replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>')
                                        .replace(/\n/g, '<br>');
                                }

                                var bDiv = document.createElement('div');
                                bDiv.style.whiteSpace = 'pre-line';

                                // Nếu là thông báo "chưa có dữ liệu" → hiển thị dạng info nhẹ, không phải lỗi
                                var isNoDataMsg = reply.includes('Không có dữ liệu thời tiết')
                                    || reply.includes('chưa có dữ liệu')
                                    || reply.includes('Chưa có dữ liệu');

                                if (isNoDataMsg) {
                                    bDiv.className = 'chat-message bot';
                                    bDiv.style.cssText = 'white-space:pre-line; background:rgba(59,130,246,0.08); border-left:3px solid #3b82f6; border-radius:8px; padding:0.75rem 1rem; font-size:0.9rem; color:var(--text-secondary);';
                                    bDiv.innerHTML = renderMarkdown(reply);
                                } else {
                                    bDiv.className = 'chat-message bot';
                                    bDiv.innerHTML = renderMarkdown(reply);
                                }

                                msgs.appendChild(bDiv);
                                msgs.scrollTop = msgs.scrollHeight;

                                // Lưu phản hồi bot vào history
                                conversationHistory.push({ role: 'assistant', content: reply });
                                saveHistory();
                            })
                            .catch(function (err) {
                                var t = document.getElementById('chatTyping');
                                if (t) t.remove();
                                var bDiv = document.createElement('div');
                                bDiv.className = 'chat-message bot';
                                bDiv.textContent = 'Lỗi kết nối: ' + err.message;
                                msgs.appendChild(bDiv);
                                msgs.scrollTop = msgs.scrollHeight;
                            });
                    }
                </script>
                <% } %>

                    <script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
                    </div><%-- /.main-content-wrapper --%>
                    </body>
                    </html>