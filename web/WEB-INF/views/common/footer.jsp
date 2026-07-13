<%@ page import="model.User" %>
    <% User currentUser=(User) session.getAttribute("user"); boolean isVIP=(currentUser !=null && currentUser.isVIP());
        %>

        <!-- Chatbot (Ch? dành cho VIP users) -->
        <% if (isVIP) { %>
            <!-- Chatbot Toggle Button -->
            <button id="chatToggle" class="chat-toggle">ðŸ’¬</button>

            <!-- Chatbot Window -->
            <div id="chatWindow" class="chat-window">
                <div class="chat-header">
                    <div class="chat-title">ChatBox AI</div>
                    <button id="chatClose" class="chat-close">?óng</button>
                </div>
                <div id="chatMessages" class="chat-messages">
                    <div class="chat-message bot">
                        hello babe
                    </div>
                </div>
                <div class="chat-input-wrapper">
                    <input type="text" id="chatInput" class="chat-input" placeholder="Nh?p tin nh?n ...">
                    <button id="chatSend" class="chat-send">g?i</button>
                </div>
            </div>
            <% } %>

                <!-- JavaScript -->
                <script src="${pageContext.request.contextPath}/assets/js/dashboard.js"></script>
                </body>

                </html>