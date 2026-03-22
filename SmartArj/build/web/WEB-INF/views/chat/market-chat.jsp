<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ page import="marketplace.model.MarketChatMessage,java.util.*,java.time.LocalDateTime,java.time.format.DateTimeFormatter" %>
<%
    List<MarketChatMessage> messages     = (List<MarketChatMessage>) request.getAttribute("messages");
    Integer partnerId                    = (Integer) request.getAttribute("partnerId");
    Integer listingId                    = (Integer) request.getAttribute("listingId");
    List<Map<String, Object>> chatPartners = (List<Map<String, Object>>) request.getAttribute("chatPartners");
    String partnerNameAttr               = (String) request.getAttribute("partnerName");

    String ctx   = request.getContextPath();
    model.User me = (model.User) session.getAttribute("user");
    int myId = (me != null) ? me.getUserId() : -1;

    DateTimeFormatter timeFmt = DateTimeFormatter.ofPattern("HH:mm");
    DateTimeFormatter dateFmt = DateTimeFormatter.ofPattern("dd/MM");

    boolean isConversationView = (partnerId != null && partnerId > 0);

    // Xác định tên partner
    String partnerName = (partnerNameAttr != null && !partnerNameAttr.isEmpty()) ? partnerNameAttr : "Người dùng";

    // Xác định role của partner để hiển thị (farmer hay buyer)
    boolean iAmFarmer = (me != null && me.isVIP());
    String partnerRole = iAmFarmer ? "👤 Người mua" : "👨‍🌾 Nông dân";
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chat | SmartAgri</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">
    <style>
        :root {
            --primary: #2E7D32; --primary-dark: #1B5E20; --primary-light: #43A047;
            --bg: #F1F8E9; --accent-yellow: #F9A825;
        }
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        html, body { height: 100%; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg); display: flex; flex-direction: column; }

        /* ── Header ── */
        .chat-header {
            background: linear-gradient(135deg, #0a2e0d, var(--primary));
            padding: 12px 20px; color: white;
            display: flex; align-items: center; justify-content: space-between;
            flex-shrink: 0; box-shadow: 0 2px 12px rgba(0,0,0,0.25);
            gap: 12px;
        }
        .chat-header-link { color: rgba(255,255,255,.8); text-decoration: none; font-size: 13px; display: flex; align-items: center; gap: 5px; white-space: nowrap; }
        .chat-header-link:hover { color: white; }
        .header-center { display: flex; align-items: center; gap: 10px; flex: 1; justify-content: center; }
        .partner-avatar {
            width: 38px; height: 38px; border-radius: 50%;
            background: var(--accent-yellow); color: #1A2E1A;
            font-weight: 900; font-size: 16px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Plus Jakarta Sans', sans-serif; flex-shrink: 0;
        }
        .partner-info .pname { font-weight: 700; font-size: 15px; display: flex; align-items: center; gap: 6px; }
        .partner-info .prole { font-size: 10px; color: rgba(255,255,255,.65); margin-top: 1px; }
        .online-dot { width: 8px; height: 8px; border-radius: 50%; background: #69F0AE; box-shadow: 0 0 6px #69F0AE; display: inline-block; }

        /* ── Inbox ── */
        .inbox-wrap { flex: 1; overflow-y: auto; padding: 20px 16px; max-width: 680px; width: 100%; margin: 0 auto; }
        .inbox-title { font-family: 'Plus Jakarta Sans', sans-serif; font-weight: 900; color: var(--primary-dark); font-size: 1.2rem; margin-bottom: 16px; display: flex; align-items: center; gap: 8px; }
        .inbox-item {
            background: white; border-radius: 16px; padding: 14px 16px;
            margin-bottom: 10px; display: flex; align-items: center; gap: 14px;
            box-shadow: 0 3px 12px rgba(46,125,50,0.08);
            text-decoration: none; color: inherit;
            transition: box-shadow .2s, transform .2s;
            border: 1.5px solid transparent; cursor: pointer;
        }
        .inbox-item:hover { box-shadow: 0 6px 20px rgba(46,125,50,0.16); transform: translateY(-2px); border-color: #C8E6C9; color: inherit; }
        .inbox-avatar {
            width: 48px; height: 48px; border-radius: 50%; flex-shrink: 0;
            background: linear-gradient(135deg, var(--primary), var(--primary-light));
            color: white; font-weight: 900; font-size: 20px;
            display: flex; align-items: center; justify-content: center;
            font-family: 'Plus Jakarta Sans', sans-serif;
        }
        .inbox-name { font-weight: 700; font-size: 14px; color: #1A2E1A; }
        .inbox-preview { font-size: 12px; color: #9E9E9E; margin-top: 3px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; max-width: 260px; }
        .inbox-time { font-size: 11px; color: #BDBDBD; margin-left: auto; flex-shrink: 0; }
        .inbox-empty { text-align: center; padding: 80px 20px; color: #9E9E9E; }
        .inbox-empty .icon { font-size: 64px; margin-bottom: 16px; }

        /* ── Chat area ── */
        .chat-layout { flex: 1; display: flex; flex-direction: column; overflow: hidden; }
        .chat-area {
            flex: 1; overflow-y: auto; padding: 16px 16px 8px;
            display: flex; flex-direction: column; gap: 8px;
            max-width: 820px; width: 100%; margin: 0 auto;
        }

        /* Listing pill */
        .listing-pill {
            background: rgba(46,125,50,0.08); border: 1px solid #C8E6C9;
            border-radius: 50px; padding: 5px 14px; font-size: 12px; color: var(--primary);
            display: inline-flex; align-items: center; gap: 6px; align-self: center; margin-bottom: 4px;
        }

        /* Date separator */
        .date-sep { text-align: center; font-size: 11px; color: #BDBDBD; margin: 6px 0; display: flex; align-items: center; gap: 8px; }
        .date-sep::before, .date-sep::after { content:''; flex:1; height:1px; background:#E0E0E0; }

        /* Messages */
        .msg-row { display: flex; gap: 8px; align-items: flex-end; }
        .msg-row.sent { flex-direction: row-reverse; }
        .msg-avatar {
            width: 30px; height: 30px; border-radius: 50%; flex-shrink: 0;
            background: #E8F5E9; color: var(--primary); font-size: 13px; font-weight: 700;
            display: flex; align-items: center; justify-content: center;
        }
        .msg-content { display: flex; flex-direction: column; max-width: 65%; }
        .msg-row.sent .msg-content { align-items: flex-end; }
        .msg-bubble {
            padding: 10px 14px; border-radius: 18px;
            font-size: 14px; line-height: 1.5; word-break: break-word;
            box-shadow: 0 2px 8px rgba(0,0,0,0.06);
        }
        .msg-received { background: white; color: #1A2E1A; border-bottom-left-radius: 4px; }
        .msg-sent     { background: var(--primary); color: white; border-bottom-right-radius: 4px; }
        .msg-time { font-size: 10px; color: #BDBDBD; margin-top: 3px; display: flex; align-items: center; gap: 4px; }
        .msg-row.sent .msg-time { color: rgba(255,255,255,.0); justify-content: flex-end; }
        .msg-row.sent .msg-time { color: rgba(46,125,50,0.5); }

        /* Input area */
        .chat-input-wrap { background: white; border-top: 1px solid #E8F5E9; padding: 10px 16px; flex-shrink: 0; }
        .chat-input-inner { max-width: 820px; margin: 0 auto; display: flex; gap: 10px; align-items: center; }
        .chat-input {
            flex: 1; border: 2px solid #C8E6C9; border-radius: 50px;
            padding: 10px 18px; font-size: 14px; outline: none;
            transition: border-color .2s; font-family: 'Plus Jakarta Sans', sans-serif;
        }
        .chat-input:focus { border-color: var(--primary); }
        .btn-send {
            background: var(--primary); color: white; border: none;
            border-radius: 50%; width: 44px; height: 44px; font-size: 18px; cursor: pointer;
            flex-shrink: 0; display: flex; align-items: center; justify-content: center;
            transition: background .2s, transform .15s;
        }
        .btn-send:hover { background: var(--primary-dark); transform: scale(1.08); }

        /* Listing context banner (trong conversation) */
        .listing-context-bar {
            background: #F1F8E9; border-bottom: 1px solid #C8E6C9;
            padding: 8px 16px; font-size: 12px; color: var(--primary-dark);
            display: flex; align-items: center; gap: 8px; flex-shrink: 0;
            max-width: 820px; width: 100%; margin: 0 auto;
        }
    </style>
</head>
<body>

<!-- ═══ HEADER ═══ -->
<div class="chat-header">
    <a href="<%=ctx%>/marketplace" class="chat-header-link"><i class="bi bi-arrow-left"></i> Marketplace</a>

    <%if(isConversationView){%>
    <div class="header-center">
        <div class="partner-avatar"><%=partnerName.length()>0?String.valueOf(partnerName.charAt(0)).toUpperCase():"N"%></div>
        <div class="partner-info">
            <div class="pname"><%=partnerName%> <span class="online-dot"></span></div>
            <div class="prole"><%=partnerRole%></div>
        </div>
    </div>
    <%}else{%>
    <div class="header-center">
        <span style="font-family:'Plus Jakarta Sans',sans-serif;font-weight:900;font-size:16px;">💬 Hộp thư của tôi</span>
    </div>
    <%}%>

    <a href="<%=ctx%>/market-chat" class="chat-header-link" title="Hộp thư">
        <i class="bi bi-chat-dots"></i> Hộp thư
    </a>
</div>

<%if(isConversationView){%>
<!-- ═══ CONVERSATION VIEW ═══ -->
<div class="chat-layout">

    <%if(listingId != null){%>
    <div style="background:#F1F8E9;border-bottom:1px solid #C8E6C9;padding:7px 16px;font-size:12px;color:var(--primary-dark);display:flex;align-items:center;gap:6px;flex-shrink:0;">
        <i class="bi bi-box-seam"></i> Đang hỏi về sản phẩm #<%=listingId%>
    </div>
    <%}%>

    <div class="chat-area" id="chat-area">
        <%if(messages == null || messages.isEmpty()){%>
        <div style="text-align:center;padding:60px 20px;color:#9E9E9E;margin:auto;">
            <div style="font-size:56px;margin-bottom:14px;">💬</div>
            <div style="font-size:16px;font-weight:700;color:#555;margin-bottom:6px;">Bắt đầu cuộc trò chuyện</div>
            <div style="font-size:13px;">Hỏi về sản phẩm, chất lượng, giá cả, giao hàng...</div>
        </div>
        <%}else{
            String lastDate = "";
            for(MarketChatMessage msg : messages){
                boolean isSent = (msg.getSenderId() != null && msg.getSenderId() == myId);
                String timeStr = (msg.getSentAt() != null) ? msg.getSentAt().format(timeFmt) : "";
                String dateStr = (msg.getSentAt() != null) ? msg.getSentAt().format(dateFmt) : "";
                String avatarLetter = isSent
                    ? (me!=null&&me.getFullName()!=null ? String.valueOf(me.getFullName().charAt(0)).toUpperCase() : "T")
                    : (msg.getSenderName()!=null&&!msg.getSenderName().isEmpty() ? String.valueOf(msg.getSenderName().charAt(0)).toUpperCase() : "N");

                if (!dateStr.equals(lastDate)) {
                    lastDate = dateStr;
        %>
        <div class="date-sep"><%=dateStr%></div>
        <%      }%>
        <div class="msg-row <%=isSent?"sent":"received"%>">
            <%if(!isSent){%><div class="msg-avatar"><%=avatarLetter%></div><%}%>
            <div class="msg-content">
                <div class="msg-bubble <%=isSent?"msg-sent":"msg-received"%>"><%=msg.getMessage()!=null?msg.getMessage():""%></div>
                <div class="msg-time">
                    <%if(!isSent && msg.getSenderName()!=null){%>
                        <span style="color:#9E9E9E;"><%=msg.getSenderName()%></span>·
                    <%}%>
                    <%=timeStr%>
                    <%if(isSent && msg.isRead()){%>
                        <i class="bi bi-check2-all" style="color:#43A047;font-size:11px;"></i>
                    <%}else if(isSent){%>
                        <i class="bi bi-check2" style="color:#aaa;font-size:11px;"></i>
                    <%}%>
                </div>
            </div>
        </div>
        <%  }
        }%>
    </div>

    <!-- Input -->
    <div class="chat-input-wrap">
        <div class="chat-input-inner">
            <form id="market-chat-form" action="<%=ctx%>/market-chat/send" method="post"
                  style="display:flex;gap:10px;flex:1;align-items:center;"
                  onsubmit="return handleChatSubmit(event, this);">
                <input type="hidden" name="receiverId" value="<%=partnerId%>">
                <%if(listingId!=null){%><input type="hidden" name="listingId" value="<%=listingId%>"><%}%>
                <input type="text" name="message" class="chat-input" id="msg-input"
                       placeholder="Nhập tin nhắn..." autocomplete="off">
                <button type="submit" class="btn-send" title="Gửi">
                    <i class="bi bi-send-fill"></i>
                </button>
            </form>
        </div>
    </div>
</div>

<%}else{%>
<!-- ═══ INBOX VIEW ═══ -->
<div class="inbox-wrap">
    <div class="inbox-title"><i class="bi bi-chat-dots-fill"></i> Hội thoại của tôi</div>

    <%if(chatPartners == null || chatPartners.isEmpty()){%>
    <div class="inbox-empty">
        <div class="icon">💬</div>
        <div style="font-size:16px;font-weight:700;color:#555;margin-bottom:8px;">Chưa có cuộc hội thoại nào</div>
        <div style="margin-bottom:20px;font-size:13px;">Vào marketplace và nhắn tin với người bán về sản phẩm!</div>
        <a href="<%=ctx%>/marketplace"
           style="background:var(--primary);color:white;padding:10px 24px;border-radius:50px;text-decoration:none;font-weight:700;display:inline-flex;align-items:center;gap:8px;">
            <i class="bi bi-shop"></i> Đi đến Marketplace
        </a>
    </div>
    <%}else{
        DateTimeFormatter inboxFmt = DateTimeFormatter.ofPattern("HH:mm dd/MM");
        for(Map<String, Object> p : chatPartners){
            int pid = (Integer) p.get("partnerId");
            String pname = (String) p.get("partnerName");
            Integer pListingId = (Integer) p.get("listingId");
            String pProductName = (String) p.get("productName");
            if (pProductName != null && pProductName.length() > 30) pProductName = pProductName.substring(0, 30) + "...";

            String lastMsg = (String) p.get("lastMsg");
            LocalDateTime lastTime = (LocalDateTime) p.get("lastTime");
            String timeDisplay = (lastTime != null) ? lastTime.format(inboxFmt) : "";
            String initial = (pname != null && !pname.isEmpty()) ? String.valueOf(pname.charAt(0)).toUpperCase() : "N";
            
            String link = ctx + "/market-chat?partner=" + pid;
            if (pListingId != null) link += "&listing=" + pListingId;
    %>
    <a href="<%=link%>" class="inbox-item">
        <div class="inbox-avatar"><%=initial%></div>
        <div style="flex:1;min-width:0;">
            <div class="inbox-name">
                <%=pname%> 
                <% if (pProductName != null) { %>
                    <span style="font-size: 11px; font-weight: normal; color: var(--primary); background: #E8F5E9; padding: 2px 6px; border-radius: 4px; margin-left: 6px;">
                        <%=pProductName%>
                    </span>
                <% } %>
            </div>
            <div class="inbox-preview"><%=lastMsg != null ? lastMsg : "Nhấn để xem hội thoại"%></div>
        </div>
        <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px;flex-shrink:0;">
            <span class="inbox-time"><%=timeDisplay%></span>
            <i class="bi bi-chevron-right" style="color:#C8E6C9;font-size:12px;"></i>
        </div>
    </a>
    <%  }
    }%>
</div>
<%}%>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    console.log("[Chat Debug] Script loaded cleanly.");

    // Auto scroll to bottom
    var chatArea = document.getElementById('chat-area');
    if (chatArea) chatArea.scrollTop = chatArea.scrollHeight;

    function handleChatSubmit(event, form) {
        console.log("[Chat Debug] handleChatSubmit invoked!");
        if (event) event.preventDefault();
        
        var inp = document.getElementById('msg-input');
        if (!inp || inp.value.trim().length === 0) {
            console.log("[Chat Debug] Message empty, aborting.");
            return false;
        }

        var btn = form.querySelector('.btn-send');
        var originalBtnHtml = btn ? btn.innerHTML : '';
        
        console.log("[Chat Debug] Collecting FormData...");
        var formData = new URLSearchParams(new FormData(form));
        
        // Disable inputs
        inp.disabled = true;
        if (btn) {
            btn.disabled = true;
            btn.innerHTML = '<i class="bi bi-hourglass-split"></i>';
        }
        
        console.log("[Chat Debug] Fetching: " + form.action);
        fetch(form.action, {
            method: 'POST',
            body: formData,
            headers: { 
                'Content-Type': 'application/x-www-form-urlencoded',
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
        .then(response => {
            console.log("[Chat Debug] Response status: " + response.status);
            return response.json();
        })
        .then(data => {
            console.log("[Chat Debug] JSON Response:", data);
            if (data.success) {
                inp.value = '';
                console.log("[Chat Debug] Success! Reloading UI to show new message.");
                window.location.reload();
            } else {
                console.error("[Chat Debug] Server returned failure:", data.error);
                alert("Lỗi: " + (data.error || "Không thể gửi tin nhắn."));
                restoreInput(inp, btn, originalBtnHtml);
            }
        })
        .catch(err => {
            console.error("[Chat Debug] Fetch Error or JSON Parse Error:", err);
            // If the server didn't return JSON (e.g. standard redirect or server crash), error out safely
            alert("Lỗi mạng: Không thể gửi tin nhắn.");
            restoreInput(inp, btn, originalBtnHtml);
        });

        return false;
    }

    function restoreInput(inp, btn, originalBtnHtml) {
        if (inp) {
            inp.disabled = false;
            inp.focus();
        }
        if (btn) {
            btn.disabled = false;
            btn.innerHTML = originalBtnHtml;
        }
    }

    // Bind Enter key natively
    var inp = document.getElementById('msg-input');
    if (inp) {
        inp.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                console.log("[Chat Debug] Enter key intercepted.");
                e.preventDefault();
                var form = document.getElementById('market-chat-form');
                if (form) {
                    handleChatSubmit(null, form);
                }
            }
        });
    }
</script>
</body>
</html>