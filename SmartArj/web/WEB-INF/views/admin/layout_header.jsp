<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
    <%@ page import="model.User" %>
        <% User currentUser=(User) session.getAttribute("user"); String ctx=request.getContextPath(); String
            uri=request.getRequestURI(); boolean isDash=uri.endsWith("/admin"); boolean
            isUsers=uri.contains("/admin/users"); boolean isSubscriptions=uri.contains("/admin/subscriptions"); boolean
            isVip=uri.contains("/admin/vip-queue"); boolean isChat=uri.contains("/admin/chat-stats"); boolean
            isAi=uri.contains("/admin/ai-insights"); boolean isSystem=uri.contains("/admin/system");
            boolean isEvents=uri.contains("/admin/events"); boolean isCrawler=uri.contains("/admin/crawler");
            String adminName=(currentUser !=null && currentUser.getUsername() !=null) ? currentUser.getUsername() : "Admin" ;
            String adminInit=adminName.length()> 0 ? adminName.substring(0,1).toUpperCase() : "A";
            %>
            <!DOCTYPE html>
            <html lang="vi">

            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>SmartArj Admin</title>

                <!-- Plus Jakarta Sans Font -->
                <link rel="preconnect" href="https://fonts.googleapis.com">
                <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
                <link
                    href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap"
                    rel="stylesheet">

                <!-- Tailwind -->
                <script src="https://cdn.tailwindcss.com"></script>

                <!-- Lucide Icons -->
                <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.js"></script>

                <!-- AOS -->
                <link href="https://unpkg.com/aos@2.3.1/dist/aos.css" rel="stylesheet">
                <script src="https://unpkg.com/aos@2.3.1/dist/aos.js"></script>

                <!-- GSAP -->
                <script src="https://cdnjs.cloudflare.com/ajax/libs/gsap/3.12.5/gsap.min.js"></script>

                <style>
                    /* ════════════════════════════════════════════════════
   DESIGN TOKENS – v2 (polish)
════════════════════════════════════════════════════ */
                    :root {
                        /* Palette */
                        --blue: #52B788;
                        --blue-dim: rgba(82, 183, 136, 0.12);
                        --blue-glow: rgba(82, 183, 136, 0.22);
                        --earth: #C4956A;
                        --purple-dim: rgba(196, 149, 106, 0.12);
                        --green: #34d399;
                        --green-dim: rgba(52, 211, 153, 0.10);
                        --amber: #f59e0b;
                        --amber-dim: rgba(245, 158, 11, 0.10);
                        --red: #ef4444;
                        --red-dim: rgba(239, 68, 68, 0.10);

                        /* Background layers */
                        --bg-base: #040E08;
                        --bg-surface: #071A0E;
                        --bg-card: rgba(4, 14, 8, 0.72);
                        --bg-card-h: rgba(7, 26, 14, 0.88);
                        --bg-input: rgba(4, 14, 8, 0.65);

                        /* Borders */
                        --bdr: rgba(82, 183, 136, 0.08);
                        --bdr-md: rgba(82, 183, 136, 0.14);
                        --bdr-hi: rgba(82, 183, 136, 0.26);

                        /* Text */
                        --t1: #eef4ff;
                        --t2: #7BAF97;
                        --t3: #1B3A2D;

                        /* Layout & Spacing System (8px grid) */
                        --sb-w: 260px;
                        --sb-c: 72px;
                        --hdr-h: 64px;
                        --r: 12px;
                        --r-lg: 16px;
                        --r-xl: 24px;

                        --sp-4: 4px;
                        --sp-8: 8px;
                        --sp-12: 12px;
                        --sp-16: 16px;
                        --sp-24: 24px;
                        --sp-32: 32px;
                        --sp-48: 48px;

                        /* Shadows & Depth */
                        --shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.4), 0 2px 8px rgba(0, 0, 0, 0.2);
                        --shadow-md: 0 4px 12px rgba(0, 0, 0, 0.4), 0 8px 16px rgba(0, 0, 0, 0.2);
                        --shadow-lg: 0 12px 24px rgba(0, 0, 0, 0.5), 0 16px 32px rgba(0, 0, 0, 0.3);

                        /* Transitions / Easing */
                        --ease-out: cubic-bezier(.22, 1, .36, 1);
                        --ease-in: cubic-bezier(.4, 0, 1, 1);
                        --ease-std: cubic-bezier(.4, 0, .2, 1);
                        --transition-base: all 0.25s var(--ease-out);
                    }

                    /* ── RESET ─────────────────────────────────── */
                    *,
                    *::before,
                    *::after {
                        box-sizing: border-box;
                        margin: 0;
                        padding: 0;
                    }

                    html {
                        scroll-behavior: smooth;
                    }

                    body {
                        font-family: 'Plus Jakarta Sans', sans-serif;
                        background: var(--bg-base);
                        color: var(--t1);
                        min-height: 100vh;
                        overflow-x: hidden;
                        -webkit-font-smoothing: antialiased;
                        font-feature-settings: 'cv11', 'ss01';
                    }

                    /* ── BACKDROP AMBIANCE ──────────────────────── */
                    body::before {
                        content: '';
                        position: fixed;
                        inset: 0;
                        z-index: 0;
                        pointer-events: none;
                        background:
                            radial-gradient(ellipse 70% 55% at 12% -5%, rgba(82, 183, 136, 0.07) 0%, transparent 70%),
                            radial-gradient(ellipse 55% 45% at 85% 95%, rgba(196, 149, 106, 0.07) 0%, transparent 70%),
                            radial-gradient(ellipse 40% 35% at 50% 50%, rgba(4, 14, 8, 0.7) 0%, transparent 100%);
                    }

                    /* Subtle noise grain */
                    body::after {
                        content: '';
                        position: fixed;
                        inset: 0;
                        z-index: 0;
                        pointer-events: none;
                        opacity: .018;
                        background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='200'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='0.8' numOctaves='4'/%3E%3C/filter%3E%3Crect width='200' height='200' filter='url(%23n)'/%3E%3C/svg%3E");
                        background-size: 200px 200px;
                    }

                    /* ── LAYOUT ─────────────────────────────────── */
                    #app {
                        display: flex;
                        min-height: 100vh;
                        position: relative;
                        z-index: 1;
                    }

                    /* ════════════════════════════════════════════════════
   SIDEBAR
════════════════════════════════════════════════════ */
                    #sidebar {
                        width: var(--sb-w);
                        min-height: 100vh;
                        position: fixed;
                        top: 0;
                        left: 0;
                        z-index: 50;
                        display: flex;
                        flex-direction: column;
                        transition: width 0.3s var(--ease-out);
                        background: rgba(15, 23, 42, 0.95);
                        /* Deep slate */
                        border-right: 1px solid rgba(255, 255, 255, 0.05);
                        backdrop-filter: blur(24px);
                        -webkit-backdrop-filter: blur(24px);
                        overflow: hidden;
                        will-change: width;
                    }

                    #sidebar.collapsed {
                        width: var(--sb-c);
                    }

                    /* — Logo */
                    .sb-logo {
                        display: flex;
                        align-items: center;
                        gap: 11px;
                        padding: 0 14px;
                        height: var(--hdr-h);
                        border-bottom: 1px solid var(--bdr);
                        flex-shrink: 0;
                    }

                    .sb-logo-mark {
                        width: 34px;
                        height: 34px;
                        border-radius: 10px;
                        flex-shrink: 0;
                        background: linear-gradient(135deg, var(--blue) 0%, var(--purple) 100%);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        box-shadow: 0 0 18px rgba(56, 189, 248, 0.28), 0 2px 8px rgba(0, 0, 0, .4);
                    }

                    .sb-logo-text {
                        overflow: hidden;
                        white-space: nowrap;
                    }

                    .sb-logo-text .sb-name {
                        font-size: .92rem;
                        font-weight: 800;
                        color: var(--t1);
                        letter-spacing: -.025em;
                    }

                    .sb-logo-text .sb-sub {
                        font-size: .6rem;
                        font-weight: 600;
                        color: var(--blue);
                        text-transform: uppercase;
                        letter-spacing: .12em;
                        margin-top: 1px;
                        opacity: .75;
                    }

                    .sb-logo-text,
                    .sb-label {
                        transition: opacity .25s var(--ease-std), max-width .32s var(--ease-out);
                    }

                    #sidebar.collapsed .sb-logo-text {
                        opacity: 0;
                        max-width: 0;
                        overflow: hidden;
                    }

                    /* — Nav */
                    .sb-nav {
                        flex: 1;
                        padding: 10px 8px;
                        overflow-y: auto;
                        overflow-x: hidden;
                    }

                    .sb-nav::-webkit-scrollbar {
                        display: none;
                    }

                    .sb-section {
                        font-size: .58rem;
                        font-weight: 700;
                        color: var(--t3);
                        text-transform: uppercase;
                        letter-spacing: .12em;
                        padding: 10px 10px 4px;
                        white-space: nowrap;
                        transition: opacity .2s;
                    }

                    #sidebar.collapsed .sb-section {
                        opacity: 0;
                    }

                    .sb-item {
                        display: flex;
                        align-items: center;
                        gap: var(--sp-12);
                        padding: var(--sp-8) var(--sp-12);
                        border-radius: var(--r-lg);
                        color: rgba(255, 255, 255, 0.6);
                        text-decoration: none;
                        font-size: 0.875rem;
                        font-weight: 500;
                        line-height: 1.2;
                        transition: var(--transition-base);
                        position: relative;
                        white-space: nowrap;
                        margin-bottom: var(--sp-4);
                    }

                    .sb-item svg {
                        flex-shrink: 0;
                        transition: transform .2s var(--ease-out), opacity .2s;
                    }

                    .sb-item .sb-label {
                        flex: 1;
                        overflow: hidden;
                        max-width: 160px;
                        opacity: 1;
                        transition: opacity .22s, max-width .32s var(--ease-out);
                    }

                    #sidebar.collapsed .sb-item .sb-label {
                        opacity: 0;
                        max-width: 0;
                    }

                    .sb-item:hover {
                        background: rgba(56, 189, 248, 0.07);
                        color: var(--t1);
                    }

                    .sb-item:hover svg {
                        transform: scale(1.12) translateX(1px);
                    }

                    .sb-item.active {
                        background: linear-gradient(135deg, rgba(56, 189, 248, .1) 0%, rgba(139, 92, 246, .06) 100%);
                        color: var(--blue);
                        border: 1px solid rgba(56, 189, 248, .16);
                        font-weight: 600;
                    }

                    .sb-item.active::before {
                        content: '';
                        position: absolute;
                        left: 0;
                        top: 22%;
                        bottom: 22%;
                        width: 3px;
                        border-radius: 0 3px 3px 0;
                        background: linear-gradient(180deg, var(--blue), var(--purple));
                        box-shadow: 0 0 10px rgba(56, 189, 248, .6);
                    }

                    /* Collapsed tooltip */
                    #sidebar.collapsed .sb-item {
                        position: relative;
                        justify-content: center;
                        padding: 10px;
                    }

                    #sidebar.collapsed .sb-item:hover::after {
                        content: attr(data-label);
                        position: absolute;
                        left: calc(var(--sb-c) + 10px);
                        background: rgba(8, 15, 39, .97);
                        border: 1px solid var(--bdr-md);
                        border-radius: 8px;
                        padding: 6px 12px;
                        font-size: .78rem;
                        font-weight: 500;
                        color: var(--t1);
                        white-space: nowrap;
                        z-index: 999;
                        backdrop-filter: blur(10px);
                        box-shadow: 0 8px 32px rgba(0, 0, 0, .5);
                        pointer-events: none;
                    }

                    /* — Bottom user strip */
                    .sb-foot {
                        padding: 10px;
                        border-top: 1px solid var(--bdr);
                        flex-shrink: 0;
                    }

                    .sb-user {
                        display: flex;
                        align-items: center;
                        gap: 8px;
                        padding: 7px 8px;
                        border-radius: 10px;
                        cursor: pointer;
                        transition: background .2s;
                        overflow: hidden;
                    }

                    .sb-user:hover {
                        background: rgba(56, 189, 248, .04);
                    }

                    .sb-avatar {
                        width: 32px;
                        height: 32px;
                        border-radius: 9px;
                        flex-shrink: 0;
                        background: linear-gradient(135deg, var(--blue), var(--purple));
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: .78rem;
                        font-weight: 800;
                        color: #fff;
                        box-shadow: 0 0 10px rgba(56, 189, 248, .25);
                    }

                    .sb-uinfo {
                        flex: 1;
                        overflow: hidden;
                        transition: opacity .22s, max-width .32s var(--ease-out);
                        max-width: 150px;
                    }

                    #sidebar.collapsed .sb-uinfo {
                        opacity: 0;
                        max-width: 0;
                    }

                    .sb-uname {
                        font-size: .8rem;
                        font-weight: 600;
                        color: var(--t1);
                        white-space: nowrap;
                        overflow: hidden;
                        text-overflow: ellipsis;
                    }

                    .sb-urole {
                        font-size: .64rem;
                        color: var(--blue);
                        font-weight: 500;
                        opacity: .8;
                    }

                    .sb-logout {
                        color: var(--t3);
                        margin-left: auto;
                        flex-shrink: 0;
                        transition: color .18s, opacity .18s;
                        opacity: .7;
                        transition: opacity .22s, max-width .3s var(--ease-out);
                        max-width: 20px;
                    }

                    .sb-logout:hover {
                        color: var(--red);
                        opacity: 1;
                    }

                    #sidebar.collapsed .sb-logout {
                        opacity: 0;
                        max-width: 0;
                        overflow: hidden;
                    }

                    /* ════════════════════════════════════════════════════
   MAIN CONTENT AREA
════════════════════════════════════════════════════ */
                    #main {
                        margin-left: var(--sb-w);
                        flex: 1;
                        display: flex;
                        flex-direction: column;
                        min-height: 100vh;
                        transition: margin-left .38s var(--ease-out);
                        will-change: margin-left;
                    }

                    #main.expanded {
                        margin-left: var(--sb-c);
                    }

                    /* ════════════════════════════════════════════════════
   TOPBAR / HEADER
════════════════════════════════════════════════════ */
                    #topbar {
                        position: sticky;
                        top: 0;
                        z-index: 40;
                        height: var(--hdr-h);
                        display: flex;
                        align-items: center;
                        justify-content: space-between;
                        padding: 0 22px;
                        gap: 14px;
                        background: rgba(2, 8, 23, .75);
                        backdrop-filter: blur(28px);
                        -webkit-backdrop-filter: blur(28px);
                        border-bottom: 1px solid var(--bdr);
                        box-shadow: 0 1px 0 rgba(0, 0, 0, .25), 0 4px 24px rgba(0, 0, 0, .2);
                        flex-shrink: 0;
                    }

                    .hdr-left {
                        display: flex;
                        align-items: center;
                        gap: 10px;
                    }

                    .hdr-right {
                        display: flex;
                        align-items: center;
                        gap: 8px;
                    }

                    /* Toggle */
                    .toggle-btn {
                        width: 34px;
                        height: 34px;
                        border-radius: 9px;
                        flex-shrink: 0;
                        background: transparent;
                        border: 1px solid var(--bdr);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        cursor: pointer;
                        color: var(--t2);
                        transition: all .2s var(--ease-std);
                    }

                    .toggle-btn:hover {
                        border-color: var(--bdr-hi);
                        color: var(--blue);
                        background: var(--blue-dim);
                    }

                    /* Breadcrumb */
                    .breadcrumb {
                        font-size: .75rem;
                        color: var(--t3);
                        display: flex;
                        align-items: center;
                        gap: 5px;
                    }

                    .breadcrumb .bc-sep {
                        opacity: .35;
                    }

                    .breadcrumb .bc-cur {
                        color: var(--t2);
                    }

                    /* Search */
                    .search-wrap {
                        position: relative;
                    }

                    .search-ico {
                        position: absolute;
                        left: 10px;
                        top: 50%;
                        transform: translateY(-50%);
                        color: var(--t3);
                        pointer-events: none;
                    }

                    .search-inp {
                        width: 260px;
                        background: rgba(8, 15, 39, .65);
                        border: 1px solid var(--bdr);
                        border-radius: 9px;
                        padding: 7px 12px 7px 32px;
                        font-size: .82rem;
                        font-family: inherit;
                        color: var(--t1);
                        outline: none;
                        transition: all .24s var(--ease-std);
                    }

                    .search-inp::placeholder {
                        color: var(--t3);
                    }

                    .search-inp:focus {
                        width: 300px;
                        border-color: rgba(56, 189, 248, .32);
                        background: rgba(8, 15, 39, .9);
                        box-shadow: 0 0 0 3px rgba(56, 189, 248, .06), 0 0 18px rgba(56, 189, 248, .04);
                    }

                    /* Icon btn */
                    .icon-btn {
                        width: 34px;
                        height: 34px;
                        border-radius: 9px;
                        flex-shrink: 0;
                        background: transparent;
                        border: 1px solid var(--bdr);
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        cursor: pointer;
                        color: var(--t2);
                        transition: all .2s var(--ease-std);
                        position: relative;
                    }

                    .icon-btn:hover {
                        border-color: var(--bdr-hi);
                        color: var(--blue);
                        box-shadow: 0 0 12px rgba(56, 189, 248, .1);
                    }

                    .notif-dot {
                        position: absolute;
                        top: 7px;
                        right: 7px;
                        width: 6px;
                        height: 6px;
                        border-radius: 50%;
                        background: var(--blue);
                        box-shadow: 0 0 6px var(--blue);
                        border: 1.5px solid var(--bg-base);
                        animation: pulse-dot 2.4s ease infinite;
                    }

                    @keyframes pulse-dot {

                        0%,
                        100% {
                            box-shadow: 0 0 4px var(--blue);
                        }

                        50% {
                            box-shadow: 0 0 10px var(--blue), 0 0 18px rgba(56, 189, 248, .3);
                        }
                    }

                    /* Top avatar */
                    .top-avatar {
                        width: 34px;
                        height: 34px;
                        border-radius: 9px;
                        flex-shrink: 0;
                        background: linear-gradient(135deg, var(--blue), var(--purple));
                        display: flex;
                        align-items: center;
                        justify-content: center;
                        font-size: .78rem;
                        font-weight: 800;
                        color: #fff;
                        cursor: pointer;
                        border: 1px solid rgba(56, 189, 248, .28);
                        box-shadow: 0 0 14px rgba(56, 189, 248, .18);
                        transition: all .22s var(--ease-out);
                    }

                    .top-avatar:hover {
                        box-shadow: 0 0 22px rgba(56, 189, 248, .35);
                        transform: scale(1.06);
                    }

                    /* ════════════════════════════════════════════════════
   PAGE BODY
════════════════════════════════════════════════════ */
                    .page-body {
                        flex: 1;
                        padding: 28px 26px 48px;
                    }

                    /* Page header */
                    .page-header {
                        margin-bottom: 26px;
                    }

                    .page-header h1 {
                        font-size: 1.55rem;
                        font-weight: 800;
                        color: var(--t1);
                        letter-spacing: -.035em;
                        line-height: 1.15;
                    }

                    .page-header p {
                        font-size: .83rem;
                        color: var(--t2);
                        margin-top: 5px;
                        line-height: 1.5;
                    }

                    /* Section title */
                    .sec-title {
                        font-size: .67rem;
                        font-weight: 700;
                        color: var(--t3);
                        text-transform: uppercase;
                        letter-spacing: .1em;
                        display: flex;
                        align-items: center;
                        gap: 7px;
                        margin-bottom: 16px;
                    }

                    .sec-title::after {
                        content: '';
                        flex: 1;
                        height: 1px;
                        background: var(--bdr);
                        opacity: .7;
                    }

                    /* ════════════════════════════════════════════════════
   GLASS CARD SYSTEM
════════════════════════════════════════════════════ */
                    .glass {
                        background: var(--bg-card);
                        border: 1px solid var(--bdr);
                        border-radius: var(--r);
                        backdrop-filter: blur(18px);
                        -webkit-backdrop-filter: blur(18px);
                    }

                    /* Hover lift – smooth with will-change */
                    .glass-hover {
                        transition: transform .3s var(--ease-out), box-shadow .3s var(--ease-out), border-color .25s;
                        will-change: transform;
                    }

                    .glass-hover:hover {
                        transform: translateY(-5px);
                        border-color: var(--bdr-md);
                        box-shadow: 0 22px 60px rgba(0, 0, 0, .42), 0 0 0 1px rgba(56, 189, 248, .07), 0 6px 24px rgba(56, 189, 248, .05);
                    }

                    /* Gradient border top accent */
                    .accent-blue {
                        border-top: 2px solid rgba(56, 189, 248, .42);
                    }

                    .accent-gold {
                        border-top: 2px solid rgba(251, 191, 36, .42);
                    }

                    .accent-amber {
                        border-top: 2px solid rgba(245, 158, 11, .42);
                    }

                    .accent-red {
                        border-top: 2px solid rgba(239, 68, 68, .42);
                    }

                    .accent-green {
                        border-top: 2px solid rgba(52, 211, 153, .42);
                    }

                    .accent-purple {
                        border-top: 2px solid rgba(139, 92, 246, .42);
                    }

                    /* ════════════════════════════════════════════════════
   BADGE CLASSES  (no JSP quote issue)
════════════════════════════════════════════════════ */
                    .badge {
                        display: inline-flex;
                        align-items: center;
                        gap: 4px;
                        padding: 3px 9px;
                        border-radius: 20px;
                        font-size: .7rem;
                        font-weight: 600;
                        letter-spacing: .01em;
                    }

                    .badge-admin {
                        background: rgba(168, 85, 247, .1);
                        color: #c084fc;
                        border: 1px solid rgba(168, 85, 247, .22);
                    }

                    .badge-user {
                        background: rgba(99, 179, 237, .08);
                        color: var(--t2);
                        border: 1px solid rgba(99, 179, 237, .15);
                    }

                    .badge-vip {
                        background: rgba(251, 191, 36, .1);
                        color: #fbbf24;
                        border: 1px solid rgba(251, 191, 36, .25);
                    }

                    .badge-free {
                        background: rgba(99, 179, 237, .06);
                        color: var(--t2);
                        border: 1px solid rgba(99, 179, 237, .12);
                    }

                    .badge-locked {
                        background: var(--red-dim);
                        color: var(--red);
                        border: 1px solid rgba(239, 68, 68, .22);
                    }

                    .badge-active {
                        background: var(--green-dim);
                        color: var(--green);
                        border: 1px solid rgba(52, 211, 153, .22);
                    }

                    .badge-db {
                        background: var(--green-dim);
                        color: var(--green);
                        border: 1px solid rgba(52, 211, 153, .22);
                    }

                    .badge-ai {
                        background: var(--purple-dim);
                        color: #c084fc;
                        border: 1px solid rgba(139, 92, 246, .22);
                    }

                    .badge-dot::before {
                        content: '';
                        width: 5px;
                        height: 5px;
                        border-radius: 50%;
                        background: currentColor;
                        display: inline-block;
                    }

                    /* ════════════════════════════════════════════════════
   BUTTONS
════════════════════════════════════════════════════ */
                    .btn {
                        display: inline-flex;
                        align-items: center;
                        gap: 6px;
                        padding: 8px 15px;
                        border-radius: 9px;
                        border: none;
                        font-size: .82rem;
                        font-weight: 600;
                        font-family: inherit;
                        cursor: pointer;
                        text-decoration: none;
                        transition: all .22s var(--ease-out);
                        white-space: nowrap;
                        line-height: 1;
                    }

                    .btn:active {
                        transform: scale(.97);
                    }

                    .btn-primary {
                        background: linear-gradient(135deg, var(--blue) 0%, #6366f1 100%);
                        color: #fff;
                        box-shadow: 0 4px 16px rgba(56, 189, 248, .22), inset 0 1px 0 rgba(255, 255, 255, .1);
                    }

                    .btn-primary:hover {
                        box-shadow: 0 6px 26px rgba(56, 189, 248, .38);
                        filter: brightness(1.06);
                    }

                    .btn-danger {
                        background: var(--red-dim);
                        color: var(--red);
                        border: 1px solid rgba(239, 68, 68, .22);
                    }

                    .btn-danger:hover {
                        background: rgba(239, 68, 68, .18);
                        box-shadow: 0 4px 16px rgba(239, 68, 68, .12);
                    }

                    .btn-success {
                        background: var(--green-dim);
                        color: var(--green);
                        border: 1px solid rgba(52, 211, 153, .22);
                    }

                    .btn-success:hover {
                        background: rgba(52, 211, 153, .18);
                        box-shadow: 0 4px 16px rgba(52, 211, 153, .12);
                    }

                    .btn-ghost {
                        background: var(--blue-dim);
                        color: var(--blue);
                        border: 1px solid rgba(56, 189, 248, .18);
                    }

                    .btn-ghost:hover {
                        background: rgba(56, 189, 248, .16);
                        box-shadow: 0 4px 16px rgba(56, 189, 248, .1);
                    }

                    .btn-sm {
                        padding: 5px 11px;
                        font-size: .76rem;
                        border-radius: 7px;
                        gap: 4px;
                    }

                    /* ════════════════════════════════════════════════════
   TABLE SYSTEM
════════════════════════════════════════════════════ */
                    .data-table {
                        width: 100%;
                        border-collapse: collapse;
                    }

                    .data-th {
                        padding: 12px 16px;
                        text-align: left;
                        font-size: .65rem;
                        font-weight: 700;
                        color: var(--t3);
                        text-transform: uppercase;
                        letter-spacing: .1em;
                        border-bottom: 1px solid var(--bdr);
                        white-space: nowrap;
                    }

                    .data-td {
                        padding: 14px 16px;
                        font-size: .84rem;
                        border-bottom: 1px solid rgba(8, 15, 39, .9);
                    }

                    .data-tr {
                        transition: background .15s;
                    }

                    .data-tr:hover .data-td {
                        background: rgba(56, 189, 248, .022);
                    }

                    .data-tr:last-child .data-td {
                        border-bottom: none;
                    }

                    /* ════════════════════════════════════════════════════
   FORM CONTROLS
════════════════════════════════════════════════════ */
                    .form-input,
                    .form-select {
                        background: var(--bg-input);
                        border: 1px solid var(--bdr);
                        border-radius: 9px;
                        color: var(--t1);
                        padding: 9px 13px;
                        font-size: .84rem;
                        font-family: inherit;
                        outline: none;
                        transition: border-color .2s, box-shadow .2s;
                        -webkit-appearance: none;
                    }

                    .form-input:focus,
                    .form-select:focus {
                        border-color: rgba(56, 189, 248, .35);
                        box-shadow: 0 0 0 3px rgba(56, 189, 248, .07);
                    }

                    .form-input::placeholder {
                        color: var(--t3);
                    }

                    /* ════════════════════════════════════════════════════
   FLASH ALERTS
════════════════════════════════════════════════════ */
                    .flash {
                        display: flex;
                        align-items: center;
                        gap: 9px;
                        padding: 11px 15px;
                        border-radius: 10px;
                        font-size: .84rem;
                        font-weight: 500;
                        margin-bottom: 20px;
                        animation: slide-in .35s var(--ease-out);
                    }

                    @keyframes slide-in {
                        from {
                            opacity: 0;
                            transform: translateY(-8px);
                        }

                        to {
                            opacity: 1;
                            transform: translateY(0);
                        }
                    }

                    .flash-ok {
                        background: var(--green-dim);
                        color: #6ee7b7;
                        border: 1px solid rgba(52, 211, 153, .22);
                    }

                    .flash-err {
                        background: var(--red-dim);
                        color: #fca5a5;
                        border: 1px solid rgba(239, 68, 68, .22);
                    }

                    /* ════════════════════════════════════════════════════
   UTILITY KEYFRAMES
════════════════════════════════════════════════════ */
                    @keyframes float-y {

                        0%,
                        100% {
                            transform: translateY(0);
                        }

                        50% {
                            transform: translateY(-5px);
                        }
                    }

                    @keyframes shimmer {
                        0% {
                            background-position: -500px 0;
                        }

                        100% {
                            background-position: 500px 0;
                        }
                    }

                    .shimmer {
                        animation: shimmer 1.8s ease infinite;
                        background: linear-gradient(90deg, rgba(255, 255, 255, .02) 0%, rgba(255, 255, 255, .055) 50%, rgba(255, 255, 255, .02) 100%);
                        background-size: 500px 100%;
                    }

                    /* Tabular numbers */
                    .tabnum {
                        font-variant-numeric: tabular-nums;
                        letter-spacing: -.02em;
                    }

                    /* ── SCROLLBAR ────────────────────────────── */
                    ::-webkit-scrollbar {
                        width: 5px;
                        height: 5px;
                    }

                    ::-webkit-scrollbar-track {
                        background: transparent;
                    }

                    ::-webkit-scrollbar-thumb {
                        background: rgba(56, 189, 248, .12);
                        border-radius: 3px;
                    }

                    ::-webkit-scrollbar-thumb:hover {
                        background: rgba(56, 189, 248, .25);
                    }

                    /* ── AOS OVERRIDE for smoother reveal ───── */
                    [data-aos] {
                        will-change: transform, opacity;
                    }
                </style>
            </head>

            <body>
                <div id="app">

                    <!-- ════════════ SIDEBAR ════════════ -->
                    <aside id="sidebar">

                        <!-- Logo -->
                        <div class="sb-logo">
                            <div class="sb-logo-mark">
                                <svg width="17" height="17" viewBox="0 0 24 24" fill="none" stroke="#fff"
                                    stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M12 2L2 7l10 5 10-5-10-5z" />
                                    <path d="M2 17l10 5 10-5" />
                                    <path d="M2 12l10 5 10-5" />
                                </svg>
                            </div>
                            <div class="sb-logo-text">
                                <div class="sb-name">SmartArj</div>
                                <div class="sb-sub">Admin Panel</div>
                            </div>
                        </div>

                        <!-- Nav items -->
                        <nav class="sb-nav">
                            <div class="sb-section">Tổng quan</div>

                            <a href="<%= ctx %>/admin" class="sb-item <%= isDash?" active":"" %>"
                                data-label="Dashboard">
                                <i data-lucide="layout-dashboard" width="18" height="18"></i>
                                <span class="sb-label">Dashboard</span>
                            </a>

                            <div class="sb-section" style="margin-top:16px;">Quản lý</div>

                            <a href="<%= ctx %>/admin/users" class="sb-item <%= isUsers?" active":"" %>"
                                data-label="Người dùng">
                                <i data-lucide="users" width="18" height="18"></i>
                                <span class="sb-label">Người dùng</span>
                            </a>

                            <!-- Subscriptions Group -->
                            <a href="<%= ctx %>/admin/subscriptions" class="sb-item <%= isSubscriptions?" active":"" %>"
                                style="margin-top:8px;" data-label="Gói đăng ký">
                                <i data-lucide="credit-card" width="18" height="18"></i>
                                <span class="sb-label" style="font-weight: 600;">Gói đăng ký</span>
                            </a>

                            <a href="<%= ctx %>/admin/vip-queue" class="sb-item <%= isVip?" active":"" %>"
                                data-label="Hàng chờ VIP" style="padding-left: 42px; font-size: 0.8rem; margin-top:
                                -4px;">
                                <i data-lucide="star" width="15" height="15"></i>
                                <span class="sb-label">Hàng chờ VIP</span>
                            </a>

                            <!-- ── Sự kiện hệ thống ──────────────── -->
                            <div class="sb-section" style="margin-top:16px;">Sự kiện</div>

                            <a href="<%= ctx %>/admin/events" class="sb-item <%= isEvents ? " active":"" %>"
                                data-label="Marketplace Events">
                                <i data-lucide="activity" width="18" height="18"></i>
                                <span class="sb-label">Marketplace Events</span>
                            </a>

                            <a href="<%= ctx %>/admin/crawler" class="sb-item <%= isCrawler ? " active":"" %>"
                                data-label="Crawler giá">
                                <i data-lucide="cpu" width="18" height="18"></i>
                                <span class="sb-label">Crawler giá</span>
                            </a>

                            <div class="sb-section" style="margin-top:16px;">Phân tích</div>

                            <a href="<%= ctx %>/admin/chat-stats" class="sb-item <%= isChat?" active":"" %>"
                                data-label="Thống kê chat">
                                <i data-lucide="bar-chart-2" width="18" height="18"></i>
                                <span class="sb-label">Thống kê chat</span>
                            </a>

                            <%-- <a href="<%= ctx %>/admin/ai-insights" class="sb-item <%= isAi?" active":"" %>"
                                data-label="Phân tích AI">
                                <i data-lucide="sparkles" width="18" height="18"></i>
                                <span class="sb-label">Phân tích AI</span>
                            </a> --%>

                            <div class="sb-section" style="margin-top:16px;">Cài đặt</div>

                            <%-- <a href="<%= ctx %>/admin/system" class="sb-item <%= isSystem?" active":"" %>"
                                data-label="Cài đặt hệ thống">
                                <i data-lucide="settings" width="18" height="18"></i>
                                <span class="sb-label">Cài đặt hệ thống</span>
                            </a> --%>

                            <a href="<%= ctx %>/dashboard" class="sb-item" style="margin-top:8px;"
                                data-label="Vào ứng dụng">
                                <i data-lucide="external-link" width="18" height="18"></i>
                                <span class="sb-label">Vào ứng dụng</span>
                            </a>
                        </nav>

                        <!-- Footer user -->
                        <div class="sb-foot">
                            <div class="sb-user">
                                <div class="sb-avatar">
                                    <%= adminInit %>
                                </div>
                                <div class="sb-uinfo">
                                    <div class="sb-uname">
                                        <%= adminName %>
                                    </div>
                                    <div class="sb-urole">Quản trị viên</div>
                                </div>
                                <a href="<%= ctx %>/logout" class="sb-logout" title="Đăng xuất">
                                    <i data-lucide="log-out" width="15" height="15"></i>
                                </a>
                            </div>
                        </div>
                    </aside>

                    <!-- ════════════ MAIN ════════════ -->
                    <div id="main">

                        <!-- TOPBAR -->
                        <header id="topbar">
                            <div class="hdr-left">
                                <button class="toggle-btn" onclick="toggleSidebar()" aria-label="Toggle sidebar">
                                    <i data-lucide="panel-left" width="15" height="15"></i>
                                </button>
                                <nav class="breadcrumb">
                                    SmartArj <span class="bc-sep">/</span>
                                    <span class="bc-cur">Admin</span>
                                </nav>
                            </div>

                            <div class="hdr-right">
                                <div class="search-wrap">
                                    <i data-lucide="search" width="13" height="13" class="search-ico"></i>
                                    <input class="search-inp" type="text" placeholder="Tìm kiếm...">
                                </div>
                                <button class="icon-btn" title="Thông báo">
                                    <i data-lucide="bell" width="15" height="15"></i>
                                    <span class="notif-dot"></span>
                                </button>
                                <div class="top-avatar" title="<%= adminName %>">
                                    <%= adminInit %>
                                </div>
                            </div>
                        </header>

                        <!-- PAGE BODY -->
                        <div class="page-body">
                            <% String flash=(String) session.getAttribute("flash"); if (flash !=null) {
                                session.removeAttribute("flash"); boolean isOk=flash.contains("Da duoc") ||
                                flash.contains("Mo khoa") || !flash.startsWith("Loi"); %>
                                <div class="flash <%= isOk ? " flash-ok" : "flash-err" %>"
                                    data-aos="fade-down" data-aos-duration="350">
                                    <i data-lucide="<%= isOk ? " check-circle" : "alert-triangle" %>" width="15"
                                        height="15"></i>
                                    <%= flash %>
                                </div>
                                <% } %>