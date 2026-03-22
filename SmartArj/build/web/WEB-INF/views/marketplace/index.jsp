<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Chợ nông sản Smart Agriculture - Kết nối nông dân và người mua, giá cả minh bạch">
    <title>🌱 Smart Agriculture Marketplace - Chợ Nông Sản Sạch</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Nunito:wght@700;800;900&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.0/font/bootstrap-icons.css">

    <style>
        :root {
            --primary:       #2E7D32;
            --primary-light: #43A047;
            --primary-dark:  #1B5E20;
            --accent:        #81C784;
            --accent-yellow: #F9A825;
            --bg-light:      #F1F8E9;
            --bg-white:      #FFFFFF;
            --text-dark:     #1A2E1A;
            --text-muted:    #6B7B6B;
            --border:        #C8E6C9;
            --shadow:        0 4px 24px rgba(46,125,50,0.10);
            --shadow-hover:  0 12px 40px rgba(46,125,50,0.22);
            --radius:        18px;
            --radius-sm:     10px;
        }

        *, *::before, *::after { box-sizing: border-box; }
        body { font-family: 'Plus Jakarta Sans', sans-serif; background: var(--bg-light); color: var(--text-dark); margin: 0; }

        /* ─── HEADER ─────────────────────────────────────────── */
        .site-header {
            background: linear-gradient(135deg, #0a2e0d 0%, #1B5E20 55%, #2E7D32 100%);
            position: sticky; top: 0; z-index: 1000;
            box-shadow: 0 2px 20px rgba(0,0,0,0.35);
            border-bottom: 1px solid rgba(255,255,255,0.08);
        }
        .header-inner {
            display: flex; align-items: center; gap: 16px;
            padding: 10px 24px;
            max-width: 1440px; margin: 0 auto;
        }

        /* Brand */
        .brand-logo {
            display: flex; align-items: center; gap: 9px;
            text-decoration: none; flex-shrink: 0;
        }
        .logo-icon {
            width: 36px; height: 36px;
            background: rgba(255,255,255,0.14);
            border-radius: 10px; border: 1px solid rgba(255,255,255,0.2);
            display: flex; align-items: center; justify-content: center;
            font-size: 18px; transition: transform .3s;
        }
        .brand-logo:hover .logo-icon { transform: rotate(-6deg) scale(1.08); }
        .brand-text .name { color: white; font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 16px; line-height: 1; }
        .brand-text .sub  { color: rgba(255,255,255,0.50); font-size: 9px; letter-spacing: 2px; text-transform: uppercase; }

        /* Search */
        .search-bar { flex: 1; max-width: 440px; position: relative; }
        .search-bar input {
            width: 100%; padding: 9px 16px 9px 40px;
            border-radius: 50px;
            border: 1.5px solid rgba(255,255,255,0.18);
            background: rgba(255,255,255,0.12);
            color: white; font-size: 13px; outline: none;
            transition: all .25s; backdrop-filter: blur(14px);
        }
        .search-bar input::placeholder { color: rgba(255,255,255,0.55); }
        .search-bar input:focus {
            background: rgba(255,255,255,0.22);
            border-color: var(--accent-yellow);
            box-shadow: 0 0 0 3px rgba(249,168,37,0.2);
        }
        .search-bar .si {
            position: absolute; left: 13px; top: 50%; transform: translateY(-50%);
            color: rgba(255,255,255,0.6); font-size: 15px; pointer-events: none;
        }
        .search-bar button { display: none; }

        /* Header actions */
        .header-actions { display: flex; align-items: center; gap: 6px; margin-left: auto; }

        /* Cart icon button */
        .btn-cart-icon {
            position: relative; width: 38px; height: 38px;
            background: rgba(255,255,255,0.12); border: 1.5px solid rgba(255,255,255,0.22);
            border-radius: 50%; color: white; font-size: 17px;
            display: flex; align-items: center; justify-content: center;
            text-decoration: none; transition: all .2s;
        }
        .btn-cart-icon:hover { background: rgba(255,255,255,0.24); color: white; transform: scale(1.08); }
        .cart-badge {
            position: absolute; top: -4px; right: -4px;
            background: var(--accent-yellow); color: #1A2E1A;
            border-radius: 50%; width: 17px; height: 17px;
            font-size: 9px; font-weight: 800;
            display: flex; align-items: center; justify-content: center;
            border: 1.5px solid #1B5E20;
        }

        /* User dropdown button */
        .btn-user {
            display: flex; align-items: center; gap: 7px;
            background: rgba(255,255,255,0.12); border: 1.5px solid rgba(255,255,255,0.22);
            border-radius: 50px; padding: 6px 14px 6px 8px;
            color: white; font-size: 13px; font-weight: 600;
            cursor: pointer; transition: all .2s; white-space: nowrap;
        }
        .btn-user:hover { background: rgba(255,255,255,0.22); color: white; }
        .btn-user .avatar {
            width: 26px; height: 26px; border-radius: 50%;
            background: var(--accent-yellow); color: #1A2E1A;
            font-size: 13px; font-weight: 900;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .btn-user .uname { max-width: 110px; overflow: hidden; text-overflow: ellipsis; }
        .vip-star { color: var(--accent-yellow); font-size: 10px; }

        /* Auth buttons */
        .nav-btn { padding: 7px 16px; border-radius: 50px; font-size: 13px; font-weight: 600; text-decoration: none; transition: all .2s; border: 1.5px solid transparent; white-space: nowrap; cursor: pointer; }
        .nav-btn-outline { border-color: rgba(255,255,255,0.45); color: white; background: transparent; }
        .nav-btn-outline:hover { background: rgba(255,255,255,0.14); color: white; }
        .nav-btn-solid { background: white; color: var(--primary); }
        .nav-btn-solid:hover { background: var(--bg-light); color: var(--primary-dark); }

        /* Dropdown */
        .dropdown-menu {
            border: none; border-radius: 16px;
            box-shadow: 0 16px 48px rgba(0,0,0,0.16);
            padding: 8px; min-width: 220px;
            margin-top: 6px !important;
        }
        .dropdown-item { border-radius: 9px; padding: 9px 14px; font-size: 13px; font-weight: 500; transition: background .15s; color: #333; }
        .dropdown-item:hover { background: var(--bg-light); color: var(--primary-dark); }
        .dropdown-item i { width: 18px; opacity: .7; }
        .dropdown-divider { margin: 5px 8px; opacity: .12; }

        /* ─── MARKET PRICE TICKER ───────────────────────────── */
        .ticker-wrap {
            background: linear-gradient(90deg, #0D3B11 0%, #1B5E20 30%, #2E7D32 100%);
            border-bottom: 3px solid var(--accent-yellow);
            overflow: hidden; height: 44px; position: relative;
        }
        .ticker-label {
            position: absolute; left: 0; top: 0; height: 100%;
            background: var(--accent-yellow); color: #1A2E1A;
            font-weight: 800; font-size: 11px; letter-spacing: .5px;
            padding: 0 18px; display: flex; align-items: center; gap: 6px;
            z-index: 10; white-space: nowrap;
            box-shadow: 4px 0 16px rgba(249,168,37,0.4);
        }
        .ticker-track-container { padding-left: 145px; height: 100%; overflow: hidden; }
        .ticker-track {
            display: flex; height: 100%; white-space: nowrap;
            animation: ticker-scroll 50s linear infinite;
            width: max-content;
        }
        .ticker-track:hover { animation-play-state: paused; }
        @keyframes ticker-scroll {
            0%   { transform: translateX(0); }
            100% { transform: translateX(-50%); }
        }
        .ticker-item {
            display: inline-flex; align-items: center;
            padding: 0 26px; height: 100%;
            color: white; font-size: 13px; font-weight: 500;
            border-right: 1px solid rgba(255,255,255,0.12);
            gap: 8px;
        }
        .ticker-item .t-product { color: #A5D6A7; font-weight: 600; }
        .ticker-item .t-price   { color: var(--accent-yellow); font-weight: 800; }
        .ticker-item .t-up      { color: #69F0AE; font-size: 10px; }
        .ticker-item .t-region  { color: rgba(255,255,255,0.45); font-size: 11px; }

        /* ─── HERO ───────────────────────────────────────────── */
        .hero {
            background: linear-gradient(135deg, #0D3B11 0%, var(--primary-dark) 45%, #2E8B34 100%);
            padding: 44px 28px 56px;
            position: relative; overflow: hidden;
        }
        .hero-bg-pattern {
            position: absolute; inset: 0; opacity: .04;
            background-image: url("data:image/svg+xml,%3Csvg width='60' height='60' xmlns='http://www.w3.org/2000/svg'%3E%3Ctext y='40' font-size='36'%3E🌾%3C/text%3E%3C/svg%3E");
            background-size: 90px 90px;
        }
        .hero-glow {
            position: absolute; right: -80px; top: -80px;
            width: 400px; height: 400px;
            background: radial-gradient(circle, rgba(129,199,132,0.15) 0%, transparent 70%);
        }
        .hero-content { max-width: 1440px; margin: 0 auto; position: relative; z-index: 1; }
        .hero h1 {
            font-family: 'Nunito', sans-serif; font-size: 2.6rem; font-weight: 900;
            color: white; margin: 0 0 10px; line-height: 1.15;
        }
        .hero h1 .hl { color: var(--accent-yellow); }
        .hero .sub {
            color: rgba(255,255,255,0.8); font-size: 1rem; margin: 0 0 28px;
            display: flex; align-items: center; gap: 10px; flex-wrap: wrap;
        }
        .hero .sub .dot { color: rgba(255,255,255,0.3); }

        .hero-stats { display: flex; gap: 16px; flex-wrap: wrap; }
        .hero-stat {
            background: rgba(255,255,255,0.10);
            border: 1px solid rgba(255,255,255,0.18);
            backdrop-filter: blur(14px);
            border-radius: 14px; padding: 14px 22px;
            text-align: center; color: white;
            min-width: 110px;
            transition: transform .3s, background .3s;
        }
        .hero-stat:hover { transform: translateY(-3px); background: rgba(255,255,255,0.16); }
        .hero-stat .val {
            font-size: 1.9rem; font-weight: 900;
            font-family: 'Nunito', sans-serif; color: var(--accent-yellow);
            display: block; line-height: 1;
        }
        .hero-stat .lab { font-size: 11px; opacity: .75; margin-top: 4px; display: block; letter-spacing: .3px; }

        /* ─── MAIN LAYOUT ─────────────────────────────────────  */
        .main-layout {
            max-width: 1440px; margin: 0 auto; padding: 28px 24px;
            display: grid; grid-template-columns: 272px 1fr; gap: 24px;
        }

        /* ─── SIDEBAR ─────────────────────────────────────────── */
        .filter-sidebar { position: sticky; top: 88px; align-self: start; }
        .filter-card {
            background: white; border-radius: var(--radius);
            padding: 20px; box-shadow: var(--shadow); margin-bottom: 18px;
            border: 1px solid rgba(46,125,50,0.06);
        }
        .filter-title {
            font-weight: 700; font-size: 13px; color: var(--primary);
            margin: 0 0 14px; display: flex; align-items: center; gap: 8px;
            border-bottom: 2px solid var(--bg-light); padding-bottom: 10px;
            text-transform: uppercase; letter-spacing: .5px;
        }
        .form-label { font-size: 11px; font-weight: 600; color: var(--text-muted); text-transform: uppercase; letter-spacing: .4px; margin-bottom: 5px; display: block; }
        .form-control, .form-select {
            border: 1.5px solid var(--border); border-radius: var(--radius-sm);
            font-size: 13px; padding: 8px 12px; transition: border-color .2s, box-shadow .2s;
        }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary-light); outline: none;
            box-shadow: 0 0 0 3px rgba(46,125,50,0.1);
        }
        .btn-filter {
            width: 100%; background: var(--primary); color: white; border: none;
            border-radius: var(--radius-sm); padding: 11px;
            font-weight: 700; font-size: 14px; cursor: pointer; transition: all .2s;
            display: flex; align-items: center; justify-content: center; gap: 6px;
        }
        .btn-filter:hover { background: var(--primary-dark); transform: translateY(-1px); box-shadow: 0 4px 14px rgba(46,125,50,0.35); }
        .btn-clear {
            width: 100%; background: transparent; color: var(--text-muted);
            border: 1.5px solid var(--border); border-radius: var(--radius-sm);
            padding: 8px; font-size: 13px; cursor: pointer; margin-top: 8px; transition: all .2s;
            text-decoration: none; display: block; text-align: center;
        }
        .btn-clear:hover { border-color: #e57373; color: #e57373; }

        /* Price mini list */
        .price-mini-list { list-style: none; padding: 0; margin: 0; }
        .price-mini-item {
            display: flex; justify-content: space-between; align-items: center;
            padding: 8px 0; border-bottom: 1px solid #f5f5f5;
            transition: background .15s; cursor: default;
        }
        .price-mini-item:last-child { border-bottom: none; }
        .price-mini-item:hover { background: var(--bg-light); margin: 0 -8px; padding: 8px 8px; border-radius: 8px; }
        .pm-info { display: flex; flex-direction: column; }
        .pm-name { font-size: 12px; font-weight: 600; color: var(--text-dark); }
        .pm-region { font-size: 10px; color: var(--text-muted); }
        .pm-right { display: flex; align-items: center; gap: 5px; }
        .pm-val { font-size: 12px; font-weight: 800; color: var(--primary); }
        .pm-trend-up   { font-size: 10px; color: #43A047; }
        .pm-trend-down { font-size: 10px; color: #E53935; }

        /* Crop CTA card */
        .crop-cta {
            background: linear-gradient(135deg, var(--primary-dark) 0%, #2e8b34 100%);
            border-radius: var(--radius); padding: 22px; color: white;
            margin-bottom: 18px; position: relative; overflow: hidden;
        }
        .crop-cta::after {
            content: '🌱'; position: absolute; right: -10px; bottom: -10px;
            font-size: 72px; opacity: .12; transform: rotate(-15deg);
        }
        .crop-cta .cta-title { font-weight: 800; font-size: 15px; margin: 0 0 6px; }
        .crop-cta p { font-size: 12px; opacity: .8; margin: 0 0 14px; line-height: 1.5; }
        .cta-btn {
            background: rgba(255,255,255,0.18); color: white;
            border: 1.5px solid rgba(255,255,255,0.4);
            padding: 8px 16px; border-radius: 8px;
            text-decoration: none; font-size: 13px; font-weight: 700;
            display: inline-block; transition: all .2s;
        }
        .cta-btn:hover { background: rgba(255,255,255,0.3); color: white; }

        /* ─── PRODUCT GRID ────────────────────────────────────── */
        .section-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 20px; }
        .section-title {
            font-family: 'Nunito', sans-serif; font-size: 1.25rem; font-weight: 900;
            color: var(--primary-dark); margin: 0; display: flex; align-items: center; gap: 8px;
        }
        .result-count {
            background: var(--bg-light); border: 1px solid var(--border);
            color: var(--text-muted); font-size: 12px; font-weight: 600;
            padding: 4px 12px; border-radius: 30px;
        }

        .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(232px, 1fr)); gap: 20px; }

        /* Product Card */
        .product-card {
            background: white; border-radius: var(--radius); overflow: hidden;
            box-shadow: var(--shadow); transition: all .3s cubic-bezier(.25,.8,.25,1);
            display: flex; flex-direction: column; position: relative;
            border: 1px solid rgba(46,125,50,0.06);
        }
        .product-card:hover { box-shadow: var(--shadow-hover); transform: translateY(-5px); }
        .badge-region {
            position: absolute; top: 12px; left: 12px;
            background: rgba(27,94,32,0.88); color: white;
            font-size: 10px; font-weight: 700; padding: 3px 9px;
            border-radius: 20px; backdrop-filter: blur(8px); z-index: 2;
        }
        .badge-vip-seller {
            position: absolute; top: 12px; right: 12px;
            background: linear-gradient(135deg, #F9A825, #F57F17);
            color: white; font-size: 9px; font-weight: 800;
            padding: 3px 8px; border-radius: 20px; z-index: 2;
            letter-spacing: .3px;
        }

        .product-img {
            height: 175px;
            background: linear-gradient(135deg, #E8F5E9, #DCEDC8);
            display: flex; align-items: center; justify-content: center;
            font-size: 60px; overflow: hidden; position: relative;
        }
        .product-img img { width: 100%; height: 100%; object-fit: cover; transition: transform .4s; }
        .product-card:hover .product-img img { transform: scale(1.05); }
        .product-img-overlay {
            position: absolute; inset: 0;
            background: linear-gradient(to top, rgba(27,94,32,0.3) 0%, transparent 50%);
        }

        .product-body { padding: 15px; flex: 1; display: flex; flex-direction: column; gap: 7px; }
        .product-name {
            font-weight: 700; font-size: 14px; color: var(--text-dark); line-height: 1.35;
            display: -webkit-box;
            -webkit-line-clamp: 2;
            line-clamp: 2;
            -webkit-box-orient: vertical;
            overflow: hidden;
        }
        .product-farmer { font-size: 12px; color: var(--text-muted); display: flex; align-items: center; gap: 4px; }
        .product-meta { display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 4px; }
        .qty-badge {
            font-size: 11px; color: var(--text-muted);
            background: var(--bg-light); padding: 2px 8px; border-radius: 20px;
            display: inline-flex; align-items: center; gap: 3px;
        }

        .product-price-row { display: flex; align-items: baseline; gap: 8px; margin-top: auto; padding-top: 6px; }
        .price-farmer { font-size: 1.15rem; font-weight: 900; color: var(--primary); font-family: 'Nunito', sans-serif; }
        .price-unit { font-size: 11px; color: var(--text-muted); }
        .price-market-ref { font-size: 11px; color: var(--text-muted); text-decoration: line-through; }
        .price-save-badge {
            background: #FFF8E1; color: #E65100; font-size: 10px;
            font-weight: 800; padding: 2px 6px; border-radius: 6px;
            border: 1px solid #FFCCBC;
        }

        .card-actions { padding: 0 15px 15px; display: flex; gap: 8px; }
        .btn-cart {
            flex: 1; background: var(--primary); color: white; border: none;
            border-radius: var(--radius-sm); padding: 10px;
            font-size: 13px; font-weight: 700; cursor: pointer; transition: all .2s;
            text-decoration: none; display: flex; align-items: center; justify-content: center; gap: 6px;
        }
        .btn-cart:hover { background: var(--primary-dark); color: white; box-shadow: 0 4px 12px rgba(46,125,50,0.35); }
        /* Quantity selector */
        .qty-selector {
            display: flex; align-items: center; gap: 0;
            border: 1.5px solid var(--border); border-radius: var(--radius-sm);
            overflow: hidden; background: white;
        }
        .qty-btn {
            width: 28px; height: 36px; background: var(--bg-light); border: none;
            color: var(--primary); font-size: 16px; font-weight: 700; cursor: pointer;
            display: flex; align-items: center; justify-content: center;
            transition: background .15s; flex-shrink: 0;
        }
        .qty-btn:hover { background: var(--primary); color: white; }
        .qty-btn:disabled { background: #F5F5F5 !important; color: #BDBDBD !important; cursor: not-allowed; }
        .qty-input {
            width: 38px; height: 36px; border: none; border-left: 1.5px solid var(--border);
            border-right: 1.5px solid var(--border); text-align: center;
            font-size: 13px; font-weight: 700; color: var(--primary-dark);
            outline: none; padding: 0; background: white;
        }
        .qty-input::-webkit-inner-spin-button,
        .qty-input::-webkit-outer-spin-button { -webkit-appearance: none; }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translate(-50%, 16px); }
            to   { opacity: 1; transform: translate(-50%, 0); }
        }

        /* Chat button on card - full width row above price */
        .btn-chat-seller {
            display: flex; align-items: center; justify-content: center; gap: 6px;
            width: 100%; padding: 7px 12px;
            background: #E8F5E9; color: var(--primary);
            border: 1.5px solid #C8E6C9; border-radius: var(--radius-sm);
            font-size: 12px; font-weight: 700; text-decoration: none;
            transition: all .2s; margin-bottom: 6px;
        }
        .btn-chat-seller:hover { background: var(--primary); color: white; border-color: var(--primary); transform: translateY(-1px); }
        .btn-chat-seller i { font-size: 15px; }

        /* Empty State */
        .empty-state {
            grid-column: 1 / -1; text-align: center; padding: 70px 20px;
            background: white; border-radius: var(--radius); box-shadow: var(--shadow);
        }
        .empty-icon-wrap {
            width: 100px; height: 100px; margin: 0 auto 20px;
            background: var(--bg-light); border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            font-size: 48px; animation: float 3s ease-in-out infinite;
        }
        @keyframes float { 0%,100% { transform: translateY(0); } 50% { transform: translateY(-8px); } }
        .empty-state h3 { color: var(--primary-dark); font-weight: 800; margin: 0 0 8px; }
        .empty-state p { color: var(--text-muted); margin: 0 0 20px; }

        /* Alert bar */
        .alert-success-bar {
            background: #E8F5E9; border: 1px solid #A5D6A7; color: var(--primary-dark);
            padding: 10px 18px; border-radius: var(--radius-sm); margin-bottom: 16px;
            font-size: 14px; display: flex; align-items: center; gap: 8px;
        }

        /* Farmer CTA banner */
        .farmer-cta {
            margin-top: 40px;
            background: linear-gradient(135deg, var(--primary-dark) 0%, #2e8b34 100%);
            border-radius: var(--radius); padding: 36px 32px;
            text-align: center; color: white; position: relative; overflow: hidden;
        }
        .farmer-cta::before {
            content: ''; position: absolute; top: -60px; right: -60px;
            width: 200px; height: 200px; border-radius: 50%;
            background: rgba(255,255,255,0.06);
        }
        .farmer-cta .emoji { font-size: 52px; display: block; margin: 0 auto 14px; }
        .farmer-cta h3 { font-family: 'Nunito',sans-serif; font-weight: 900; margin: 0 0 8px; font-size: 1.5rem; }
        .farmer-cta p { opacity: .85; margin: 0 0 22px; }
        .farmer-cta .cta-main {
            background: var(--accent-yellow); color: #1A2E1A;
            padding: 12px 30px; border-radius: 50px; text-decoration: none;
            font-weight: 800; display: inline-block; font-size: 15px;
            transition: transform .2s, box-shadow .2s;
            box-shadow: 0 4px 20px rgba(249,168,37,0.4);
        }
        .farmer-cta .cta-main:hover { transform: translateY(-2px); box-shadow: 0 8px 28px rgba(249,168,37,0.5); }

        /* ─── FOOTER ──────────────────────────────────────────── */
        .site-footer {
            background: linear-gradient(135deg, #0D3B11 0%, var(--primary-dark) 100%);
            color: rgba(255,255,255,0.65);
            padding: 40px 28px 28px;
            margin-top: 60px;
        }
        .footer-grid {
            max-width: 1440px; margin: 0 auto;
            display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 32px;
            margin-bottom: 30px;
        }
        .footer-col .footer-brand { font-family: 'Nunito',sans-serif; font-weight: 900; font-size: 18px; color: white; margin: 0 0 8px; }
        .footer-col p { font-size: 13px; line-height: 1.6; margin: 0; }
        .footer-col h4 { color: white; font-size: 13px; font-weight: 700; margin: 0 0 12px; text-transform: uppercase; letter-spacing: .5px; }
        .footer-links { list-style: none; padding: 0; margin: 0; }
        .footer-links li { margin-bottom: 7px; }
        .footer-links a { color: rgba(255,255,255,0.6); text-decoration: none; font-size: 13px; transition: color .2s; }
        .footer-links a:hover { color: var(--accent-yellow); }
        .footer-bottom { border-top: 1px solid rgba(255,255,255,0.12); padding-top: 20px; text-align: center; font-size: 12px; }
        .footer-bottom a { color: var(--accent); text-decoration: none; }

        /* ─── SMART RECOMMENDATION SECTION ─────────────────────── */
        .recommend-section {
            margin-bottom: 32px;
            border-radius: var(--radius);
            overflow: hidden;
            box-shadow: 0 6px 32px rgba(46,125,50,0.14);
            border: 1.5px solid rgba(46,125,50,0.12);
        }
        .recommend-header {
            background: linear-gradient(135deg, #0D3B11 0%, #1B5E20 45%, #2E8B34 100%);
            padding: 18px 22px;
            display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 12px;
        }
        .recommend-title {
            display: flex; align-items: center; gap: 10px;
            color: white;
        }
        .recommend-title .ai-badge {
            background: linear-gradient(135deg, #F9A825, #F57F17);
            color: #1A2E1A; font-size: 9px; font-weight: 900;
            padding: 2px 7px; border-radius: 20px; letter-spacing: .5px;
            text-transform: uppercase;
        }
        .recommend-title h3 {
            margin: 0; font-family: 'Nunito', sans-serif; font-weight: 900; font-size: 1.05rem;
            color: white;
        }
        .recommend-title p {
            margin: 2px 0 0; font-size: 12px; color: rgba(255,255,255,0.72);
        }
        .bought-tags {
            display: flex; flex-wrap: wrap; gap: 6px; align-items: center;
        }
        .bought-tag {
            background: rgba(255,255,255,0.15);
            border: 1px solid rgba(255,255,255,0.28);
            color: white; font-size: 11px; font-weight: 600;
            padding: 3px 11px; border-radius: 20px;
            backdrop-filter: blur(8px);
            display: flex; align-items: center; gap: 4px;
            transition: background .2s;
        }
        .bought-tag:hover { background: rgba(255,255,255,0.28); }
        .bought-tag-label {
            color: rgba(255,255,255,0.55); font-size: 10px; font-weight: 600;
            letter-spacing: .3px; white-space: nowrap;
        }
        .recommend-body {
            background: white; padding: 18px 20px 20px;
        }
        .recommend-scroll {
            display: flex; gap: 14px; overflow-x: auto; padding-bottom: 10px;
            scroll-snap-type: x mandatory;
            scrollbar-width: thin;
            scrollbar-color: var(--border) transparent;
        }
        .recommend-scroll::-webkit-scrollbar { height: 5px; }
        .recommend-scroll::-webkit-scrollbar-track { background: transparent; }
        .recommend-scroll::-webkit-scrollbar-thumb { background: var(--border); border-radius: 10px; }
        .rec-card {
            background: white; border-radius: 14px;
            border: 1.5px solid var(--border);
            min-width: 180px; max-width: 180px;
            flex-shrink: 0; scroll-snap-align: start;
            overflow: hidden;
            transition: all .28s cubic-bezier(.25,.8,.25,1);
            box-shadow: 0 2px 12px rgba(46,125,50,0.07);
            position: relative;
        }
        .rec-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 12px 32px rgba(46,125,50,0.18);
            border-color: var(--primary-light);
        }
        .rec-card .new-badge {
            position: absolute; top: 8px; right: 8px;
            background: linear-gradient(135deg, #E53935, #C62828);
            color: white; font-size: 9px; font-weight: 800;
            padding: 2px 7px; border-radius: 20px; letter-spacing: .3px;
            z-index: 2;
        }
        .rec-img {
            height: 110px;
            background: linear-gradient(135deg, #E8F5E9, #DCEDC8);
            display: flex; align-items: center; justify-content: center;
            font-size: 42px; overflow: hidden;
        }
        .rec-img img { width: 100%; height: 100%; object-fit: cover; transition: transform .35s; }
        .rec-card:hover .rec-img img { transform: scale(1.07); }
        .rec-body { padding: 10px 12px 12px; }
        .rec-name {
            font-size: 13px; font-weight: 700; color: var(--text-dark);
            line-height: 1.3; margin: 0 0 4px;
            display: -webkit-box; -webkit-line-clamp: 2; line-clamp: 2;
            -webkit-box-orient: vertical; overflow: hidden;
        }
        .rec-farmer { font-size: 10px; color: var(--text-muted); margin-bottom: 6px; }
        .rec-price {
            font-family: 'Nunito', sans-serif; font-size: 1.05rem; font-weight: 900;
            color: var(--primary); display: flex; align-items: baseline; gap: 4px;
        }
        .rec-price span { font-size: 10px; font-weight: 400; color: var(--text-muted); }
        .rec-add-btn {
            display: flex; align-items: center; justify-content: center; gap: 5px;
            background: var(--primary); color: white;
            border: none; border-radius: 8px; width: 100%;
            padding: 7px; font-size: 12px; font-weight: 700;
            cursor: pointer; margin-top: 8px; transition: all .2s;
            text-decoration: none;
        }
        .rec-add-btn:hover { background: var(--primary-dark); color: white; transform: none; }
        .recommend-empty {
            text-align: center; padding: 28px;
            color: var(--text-muted); font-size: 14px;
        }
        @keyframes shimmer {
            0% { background-position: -400px 0; }
            100% { background-position: 400px 0; }
        }
        .rec-scroll-arrow {
            position: absolute; top: 50%; transform: translateY(-50%);
            width: 32px; height: 32px; background: white;
            border-radius: 50%; box-shadow: 0 2px 12px rgba(0,0,0,0.16);
            display: flex; align-items: center; justify-content: center;
            cursor: pointer; z-index: 5; border: 1px solid var(--border);
            color: var(--primary); font-size: 14px; transition: all .2s;
        }
        .rec-scroll-arrow:hover { background: var(--primary); color: white; }
        .rec-scroll-wrap { position: relative; }

        /* ─── SIDEBAR MOBILE TOGGLE ───────────────────────────── */
        .sidebar-toggle-btn {
            display: none; width: 100%; padding: 12px;
            background: white; border: 1.5px solid var(--border);
            border-radius: var(--radius-sm); font-weight: 600; font-size: 14px;
            color: var(--primary); cursor: pointer; margin-bottom: 16px;
            align-items: center; justify-content: space-between;
        }

        /* ─── RESPONSIVE ──────────────────────────────────────── */
        @media (max-width: 1024px) {
            .main-layout { grid-template-columns: 1fr; }
            .filter-sidebar { position: static; }
        }
        @media (max-width: 900px) {
            .sidebar-toggle-btn { display: flex; }
            .filter-sidebar { position: static; }
            .sidebar-collapsible { display: none; }
            .sidebar-collapsible.open { display: block; }
        }
        @media (max-width: 768px) {
            .hero h1 { font-size: 1.9rem; }
            .header-inner { padding: 10px 16px; gap: 10px; }
            .search-bar { max-width: 180px; }
            .brand-text .sub { display: none; }
            .main-layout { padding: 16px; }
            .hero { padding: 30px 16px 40px; }
            .hero-stats { gap: 10px; }
            .hero-stat { padding: 10px 14px; min-width: 90px; }
            .hero-stat .val { font-size: 1.5rem; }
            .nav-btn-outline span { display: none; }
            .footer-grid { grid-template-columns: 1fr 1fr; gap: 20px; }
        }
        @media (max-width: 480px) {
            .product-grid { grid-template-columns: 1fr 1fr; gap: 12px; }
            .footer-grid { grid-template-columns: 1fr; }
        }
    </style>
</head>
<body>

<!-- ═══════════════ HEADER ═══════════════ -->
<header class="site-header">
    <div class="header-inner">
        <a href="${pageContext.request.contextPath}/marketplace" class="brand-logo">
            <div class="logo-icon">🌾</div>
            <div class="brand-text">
                <div class="name">SmartAgri</div>
                <div class="sub">Marketplace</div>
            </div>
        </a>

        <form class="search-bar" action="${pageContext.request.contextPath}/marketplace" method="get" id="search-form">
            <i class="bi bi-search si"></i>
            <input type="text" name="keyword" placeholder="Tìm sản phẩm nông sản..."
                   value="${keyword != null ? keyword : ''}" id="search-input">
        </form>

        <div class="header-actions">
            <c:choose>
                <c:when test="${sessionScope.user != null}">
                    <!-- Orders icon -->
                    <a href="${pageContext.request.contextPath}/buyer/orders" class="btn-cart-icon" title="Đơn hàng" style="margin-right: 4px;">
                        <i class="bi bi-bag-heart"></i>
                    </a>
                    <!-- Cart icon -->
                    <a href="${pageContext.request.contextPath}/buyer/cart" class="btn-cart-icon" title="Giỏ hàng">
                        <i class="bi bi-cart3"></i>
                        <c:if test="${cartCount != null && cartCount > 0}">
                            <span class="cart-badge">${cartCount}</span>
                        </c:if>
                    </a>
                    <!-- User dropdown -->
                    <div class="dropdown">
                        <button class="btn-user dropdown-toggle" data-bs-toggle="dropdown" style="border:none;">
                            <div class="avatar">
                                ${sessionScope.user.fullName != null ? sessionScope.user.fullName.substring(0,1).toUpperCase() : 'U'}
                            </div>
                            <span class="uname">${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}</span>
                            <c:if test="${sessionScope.user.VIP}"><span class="vip-star">★</span></c:if>
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end">
                            <!-- User info header -->
                            <li style="padding:10px 14px 8px;border-bottom:1px solid #f0f0f0;margin-bottom:4px;">
                                <div style="font-weight:700;font-size:13px;color:#1A2E1A;">${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}</div>
                                <div style="font-size:11px;color:#9E9E9E;"><c:if test="${sessionScope.user.VIP}">⭐ VIP Farmer</c:if><c:if test="${sessionScope.user.admin}">🔑 Admin</c:if><c:if test="${!sessionScope.user.VIP && !sessionScope.user.admin}">👤 Thành viên</c:if></div>
                            </li>
                            <li>
                                <a class="dropdown-item" href="${pageContext.request.contextPath}/dashboard"
                                   style="font-weight:600;color:#1B5E20;">
                                    <i class="bi bi-house-door-fill"></i>
                                    <c:choose>
                                        <c:when test="${sessionScope.user.VIP || sessionScope.user.admin}">Quay về Dashboard</c:when>
                                        <c:otherwise>Trang chủ Dashboard</c:otherwise>
                                    </c:choose>
                                </a>
                            </li>
                            <li><hr class="dropdown-divider"></li>
                            <c:if test="${sessionScope.user.VIP || sessionScope.user.admin}">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/farmer/dashboard"><i class="bi bi-speedometer2"></i> Farmer Dashboard</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/farmer/listing"><i class="bi bi-list-ul"></i> Quản lý sản phẩm</a></li>
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/farmer/orders"><i class="bi bi-bag-check"></i> Đơn hàng nhận</a></li>
                                <li><hr class="dropdown-divider"></li>
                            </c:if>
                            <c:if test="${sessionScope.user.admin}">
                                <li><a class="dropdown-item" href="${pageContext.request.contextPath}/admin/crawler"><i class="bi bi-bug"></i> Crawler Giá</a></li>
                                <li><hr class="dropdown-divider"></li>
                            </c:if>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/buyer/orders"><i class="bi bi-bag"></i> Đơn hàng của tôi</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/buyer/cart"><i class="bi bi-cart3"></i> Giỏ hàng</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item text-danger" href="${pageContext.request.contextPath}/logout"><i class="bi bi-box-arrow-right"></i> Đăng xuất</a></li>
                        </ul>
                    </div>
                </c:when>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/login" class="nav-btn nav-btn-outline">Đăng nhập</a>
                    <a href="${pageContext.request.contextPath}/register" class="nav-btn nav-btn-solid">Đăng ký</a>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</header>

<!-- ═══════════════ MARKET PRICE TICKER ═══════════════ -->
<div class="ticker-wrap">
    <div class="ticker-label">
        <i class="bi bi-graph-up-arrow"></i> GIÁ NÔNG SẢN
    </div>
    <div class="ticker-track-container">
        <div class="ticker-track" id="ticker-track">
            <c:forEach var="mp" items="${marketPrices}">
                <div class="ticker-item">
                    <span class="t-product">${mp.productName}</span>
                    <c:if test="${mp.regionName != null && mp.regionName != ''}">
                        <span class="t-region">(${mp.regionName})</span>
                    </c:if>
                    <span class="t-price"><fmt:formatNumber value="${mp.price}" pattern="#,##0"/> đ/kg</span>
                    <span class="t-up">▲</span>
                </div>
            </c:forEach>
            <%-- Duplicate for seamless loop --%>
            <c:forEach var="mp" items="${marketPrices}">
                <div class="ticker-item">
                    <span class="t-product">${mp.productName}</span>
                    <c:if test="${mp.regionName != null && mp.regionName != ''}">
                        <span class="t-region">(${mp.regionName})</span>
                    </c:if>
                    <span class="t-price"><fmt:formatNumber value="${mp.price}" pattern="#,##0"/> đ/kg</span>
                    <span class="t-up">▲</span>
                </div>
            </c:forEach>
        </div>
    </div>
</div>

<!-- ═══════════════ HERO ═══════════════ -->
<section class="hero">
    <div class="hero-bg-pattern"></div>
    <div class="hero-glow"></div>
    <div style="max-width:1440px;margin:0 auto;padding:44px 28px 56px;position:relative;z-index:1;display:flex;align-items:center;justify-content:space-between;gap:32px;flex-wrap:wrap;">
        <!-- Left: Headline + Stats -->
        <div style="flex:1;min-width:280px;">
            <h1>Chợ <span class="hl">Nông Sản</span> Sạch 🌱</h1>
            <p class="sub">
                Kết nối trực tiếp nông dân &amp; người mua
                <span class="dot">•</span>
                Giá cả minh bạch
                <span class="dot">•</span>
                Hàng hóa chuẩn vùng
            </p>
            <div class="hero-stats">
                <div class="hero-stat">
                    <span class="val">${totalListings}</span>
                    <span class="lab">🛒 Sản phẩm</span>
                </div>
                <div class="hero-stat">
                    <span class="val">${regions.size()}</span>
                    <span class="lab">📍 Vùng miền</span>
                </div>
                <div class="hero-stat">
                    <span class="val">${marketPrices.size()}</span>
                    <span class="lab">📊 Giá thị trường</span>
                </div>
                <c:if test="${sessionScope.user != null}">
                <div class="hero-stat" style="border-color:rgba(249,168,37,0.4);">
                    <span class="val" style="font-size:1.1rem;">Xin chào</span>
                    <span class="lab">👤 ${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.username}</span>
                </div>
                </c:if>
            </div>
        </div>

        <%-- Right: nút Dashboard (luôn hiện khi đã login) hoặc CTA nâng cấp khi chưa VIP --%>
        <c:choose>
            <c:when test="${sessionScope.user != null && (sessionScope.user.VIP || sessionScope.user.admin)}">
                <%-- Farmer/Admin: nút quay về dashboard --%>
                <div style="display:flex;flex-direction:column;gap:12px;align-items:center;flex-shrink:0;">
                    <a href="${pageContext.request.contextPath}/farmer/dashboard"
                       style="background:rgba(255,255,255,0.15);border:2px solid rgba(255,255,255,0.4);
                              backdrop-filter:blur(12px);color:white;padding:13px 28px;border-radius:50px;
                              text-decoration:none;font-weight:800;font-size:14px;
                              display:inline-flex;align-items:center;gap:10px;
                              box-shadow:0 4px 20px rgba(0,0,0,0.18);
                              transition:all .25s;white-space:nowrap;"
                       onmouseover="this.style.background='rgba(255,255,255,0.28)';this.style.transform='translateY(-2px)';"
                       onmouseout="this.style.background='rgba(255,255,255,0.15)';this.style.transform='';">
                        <i class="bi bi-speedometer2" style="font-size:18px;"></i>
                        <c:choose>
                            <c:when test="${sessionScope.user.admin}">⬅ Admin Dashboard</c:when>
                            <c:otherwise>⬅ Farmer Dashboard</c:otherwise>
                        </c:choose>
                    </a>
                    <a href="${pageContext.request.contextPath}/farmer/listing"
                       style="background:var(--accent-yellow);color:#1A2E1A;padding:10px 22px;border-radius:50px;
                              text-decoration:none;font-weight:700;font-size:13px;
                              display:inline-flex;align-items:center;gap:8px;
                              box-shadow:0 4px 16px rgba(249,168,37,0.35);
                              transition:all .2s;white-space:nowrap;"
                       onmouseover="this.style.transform='translateY(-2px)';"
                       onmouseout="this.style.transform='';">
                        <i class="bi bi-plus-circle-fill"></i> Đăng bán sản phẩm
                    </a>
                </div>
            </c:when>
            <c:when test="${sessionScope.user != null && !sessionScope.user.VIP && !sessionScope.user.admin}">
                <%-- Buyer thường: hiện card nâng cấp --%>
                <div style="
                    background:rgba(255,255,255,0.10);
                    border:1.5px solid rgba(255,255,255,0.22);
                    backdrop-filter:blur(14px);
                    border-radius:20px;
                    padding:24px 28px;
                    text-align:center;
                    color:white;
                    min-width:220px;
                    max-width:280px;
                    flex-shrink:0;
                ">
                    <div style="font-size:48px;margin-bottom:10px;">👨‍🌾</div>
                    <div style="font-family:'Nunito',sans-serif;font-weight:900;font-size:1.1rem;margin-bottom:6px;">Bạn là Nông Dân?</div>
                    <p style="font-size:12px;opacity:.8;margin:0 0 16px;line-height:1.5;">Nâng cấp VIP để bán nông sản trực tiếp đến hàng nghìn người mua</p>
                    <a href="${pageContext.request.contextPath}/upgrade"
                       style="background:var(--accent-yellow);color:#1A2E1A;padding:10px 20px;border-radius:50px;text-decoration:none;font-weight:800;font-size:13px;display:inline-block;box-shadow:0 4px 16px rgba(249,168,37,0.4);transition:transform .2s;"
                       onmouseover="this.style.transform='translateY(-2px)';"
                       onmouseout="this.style.transform='';"
                    >🚀 Nâng cấp Farmer VIP →</a>
                </div>
            </c:when>
            <c:otherwise>
                <%-- Guest: hiện card nâng cấp --%>
                <div style="
                    background:rgba(255,255,255,0.10);
                    border:1.5px solid rgba(255,255,255,0.22);
                    backdrop-filter:blur(14px);
                    border-radius:20px;
                    padding:24px 28px;
                    text-align:center;
                    color:white;
                    min-width:220px;
                    max-width:280px;
                    flex-shrink:0;
                ">
                    <div style="font-size:48px;margin-bottom:10px;">👨‍🌾</div>
                    <div style="font-family:'Nunito',sans-serif;font-weight:900;font-size:1.1rem;margin-bottom:6px;">Bạn là Nông Dân?</div>
                    <p style="font-size:12px;opacity:.8;margin:0 0 16px;line-height:1.5;">Nâng cấp VIP để bán nông sản trực tiếp đến hàng nghìn người mua</p>
                    <a href="${pageContext.request.contextPath}/upgrade"
                       style="background:var(--accent-yellow);color:#1A2E1A;padding:10px 20px;border-radius:50px;text-decoration:none;font-weight:800;font-size:13px;display:inline-block;box-shadow:0 4px 16px rgba(249,168,37,0.4);transition:transform .2s;"
                       onmouseover="this.style.transform='translateY(-2px)';"
                       onmouseout="this.style.transform='';"
                    >🚀 Nâng cấp Farmer VIP →</a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>
</section>

<!-- ═══════════════ MAIN CONTENT ═══════════════ -->
<div class="main-layout">

    <!-- ───── FILTER SIDEBAR ───── -->
    <aside class="filter-sidebar">

        <!-- Mobile toggle -->
        <button class="sidebar-toggle-btn" onclick="document.querySelector('.sidebar-collapsible').classList.toggle('open')">
            <span><i class="bi bi-funnel"></i> Bộ lọc &amp; Giá thị trường</span>
            <i class="bi bi-chevron-down"></i>
        </button>

        <div class="sidebar-collapsible">
            <!-- Filter Form -->
            <div class="filter-card">
                <div class="filter-title"><i class="bi bi-sliders"></i> Lọc sản phẩm</div>
                <form action="${pageContext.request.contextPath}/marketplace" method="get" id="filter-form">
                    <div class="mb-3">
                        <label class="form-label">Tên sản phẩm</label>
                        <input type="text" class="form-control" name="keyword"
                               placeholder="Cà phê, hồ tiêu..."
                               value="${keyword != null ? keyword : ''}">
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Vùng miền</label>
                        <select class="form-select" name="regionId">
                            <option value="">-- Tất cả vùng --</option>
                            <c:forEach var="region" items="${regions}">
                                <option value="${region.regionId}" ${selectedRegionId == region.regionId ? 'selected' : ''}>
                                    ${region.regionName}
                                </option>
                            </c:forEach>
                        </select>
                    </div>
                    <div class="row mb-3">
                        <div class="col-6">
                            <label class="form-label">Giá từ</label>
                            <input type="number" class="form-control" name="minPrice"
                                   placeholder="0" value="${minPrice != null ? minPrice : ''}">
                        </div>
                        <div class="col-6">
                            <label class="form-label">Đến</label>
                            <input type="number" class="form-control" name="maxPrice"
                                   placeholder="∞" value="${maxPrice != null ? maxPrice : ''}">
                        </div>
                    </div>
                    <button type="submit" class="btn-filter">
                        <i class="bi bi-search"></i> Tìm kiếm
                    </button>
                    <a href="${pageContext.request.contextPath}/marketplace" class="btn-clear mt-2">
                        ✕ Xóa bộ lọc
                    </a>
                </form>
            </div>

            <!-- Crop CTA -->
            <div class="crop-cta">
                <div class="cta-title">🌱 Gợi ý cây trồng</div>
                <p>Tìm cây phù hợp theo vùng địa lý và dự báo thời tiết</p>
                <a href="${pageContext.request.contextPath}/crop-recommend" class="cta-btn">Khám phá →</a>
            </div>


        </div>
    </aside>

    <!-- ───── PRODUCT LISTINGS ───── -->
    <main>
        <!-- Alert messages -->
        <c:if test="${param.success == 'added_to_cart'}">
            <div class="alert-success-bar"><i class="bi bi-check-circle-fill"></i> Đã thêm vào giỏ hàng!</div>
        </c:if>
        <c:if test="${param.error == 'vip_required'}">
            <div class="alert alert-warning alert-dismissible fade show" role="alert">
                <i class="bi bi-shield-exclamation"></i>
                <strong>Yêu cầu tài khoản VIP Farmer</strong> để đăng bán sản phẩm.
                <a href="${pageContext.request.contextPath}/upgrade">Nâng cấp ngay →</a>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        </c:if>

        <!-- ═══ MARKET PRICE SHOWCASE ═══ -->
        <c:if test="${not empty marketPrices}">
        <div style="margin-bottom:28px;">
            <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">
                <h2 style="font-family:'Nunito',sans-serif;font-size:1.1rem;font-weight:900;color:var(--primary-dark);margin:0;display:flex;align-items:center;gap:8px;">
                    <i class="bi bi-bar-chart-line-fill" style="color:var(--primary-light);"></i> Bảng Giá Nông Sản Hôm Nay
                </h2>
                <span style="font-size:11px;color:var(--text-muted);display:flex;align-items:center;gap:4px;">
                    <i class="bi bi-clock"></i> Cập nhật 7:00 AM hàng ngày
                </span>
            </div>
            <div style="display:grid;grid-template-columns:repeat(auto-fill,minmax(160px,1fr));gap:12px;">
                <c:forEach var="mp" items="${marketPrices}" varStatus="st">
                    <c:if test="${st.index < 6}">
                    <div style="
                        background:white;border-radius:14px;padding:14px 16px;
                        box-shadow:0 2px 12px rgba(46,125,50,0.09);
                        border:1px solid rgba(46,125,50,0.08);
                        transition:transform .2s,box-shadow .2s;
                        cursor:default;
                    "
                    onmouseover="this.style.transform='translateY(-3px)';this.style.boxShadow='0 8px 24px rgba(46,125,50,0.18)';"
                    onmouseout="this.style.transform='';this.style.boxShadow='0 2px 12px rgba(46,125,50,0.09)';">
                        <div style="font-size:11px;font-weight:600;color:var(--text-muted);text-transform:uppercase;letter-spacing:.4px;margin-bottom:4px;">${mp.regionName}</div>
                        <div style="font-size:13px;font-weight:700;color:var(--text-dark);margin-bottom:8px;line-height:1.3;">${mp.productName}</div>
                        <div style="display:flex;align-items:baseline;gap:4px;">
                            <span style="font-family:'Nunito',sans-serif;font-size:1.3rem;font-weight:900;color:var(--primary);">
                                <fmt:formatNumber value="${mp.price}" pattern="#,##0"/>
                            </span>
                            <span style="font-size:10px;color:var(--text-muted);">đ/kg</span>
                            <span style="font-size:11px;color:#43A047;font-weight:700;margin-left:auto;">▲</span>
                        </div>
                    </div>
                    </c:if>
                </c:forEach>
            </div>
        </div>
        </c:if>


        <%-- ═══ GỢI Ý THÔNG MINH (chỉ khi đã login & có lịch sử mua) ═══ --%>
        <c:if test="${sessionScope.user != null && not empty recommendedListings}">
        <div class="recommend-section" id="smart-recommend">
            <div class="recommend-header">
                <div class="recommend-title">
                    <div>
                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:4px;">
                            <span style="font-size:22px;">🤖</span>
                            <h3>Gợi ý dành riêng cho bạn</h3>
                            <span class="ai-badge">AI</span>
                        </div>
                        <p>Dựa trên lịch sử mua hàng của bạn · <strong style="color:rgba(255,255,255,0.9);">${recommendedListings.size()} sản phẩm</strong> phù hợp mới nhất</p>
                    </div>
                </div>
                <c:if test="${not empty boughtProductNames}">
                <div style="display:flex;flex-direction:column;align-items:flex-end;gap:6px;">
                    <span class="bought-tag-label">🛍️ Bạn đã mua:</span>
                    <div class="bought-tags">
                        <c:forEach var="pname" items="${boughtProductNames}">
                            <span class="bought-tag">✓ ${pname}</span>
                        </c:forEach>
                    </div>
                </div>
                </c:if>
            </div>
            <div class="recommend-body">
                <div class="rec-scroll-wrap">
                    <button class="rec-scroll-arrow" style="left:-12px;" onclick="scrollRec(-1)" id="rec-prev" title="Trước"><i class="bi bi-chevron-left"></i></button>
                    <div class="recommend-scroll" id="rec-scroll-track">
                        <c:forEach var="rec" items="${recommendedListings}">
                        <div class="rec-card">
                            <span class="new-badge">🆕 Mới</span>
                            <div class="rec-img">
                                <c:choose>
                                    <c:when test="${rec.imageUrl != null && rec.imageUrl != ''}">
                                        <img src="${rec.imageUrl}" alt="${rec.productName}" loading="lazy">
                                    </c:when>
                                    <c:otherwise>
                                        <c:choose>
                                            <c:when test="${rec.productName.toLowerCase().contains('cà phê') || rec.productName.toLowerCase().contains('cafe')}">☕</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('tiêu') || rec.productName.toLowerCase().contains('hồ tiêu')}">🌶️</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('sầu riêng')}">🍈</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('xoài')}">🥭</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('lúa') || rec.productName.toLowerCase().contains('gạo')}">🌾</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('dừa')}">🥥</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('chanh')}">🍋</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('rau')}">🥬</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('bơ')}">🥑</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('chuối')}">🍌</c:when>
                                            <c:when test="${rec.productName.toLowerCase().contains('vải')}">🍇</c:when>
                                            <c:otherwise>🌿</c:otherwise>
                                        </c:choose>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                            <div class="rec-body">
                                <div class="rec-name">${rec.productName}</div>
                                <div class="rec-farmer"><i class="bi bi-person-circle"></i> ${rec.farmerName}</div>
                                <div class="rec-price">
                                    <fmt:formatNumber value="${rec.price}" pattern="#,##0"/>đ
                                    <span>/${rec.unit}</span>
                                </div>
                                <button type="button" class="rec-add-btn"
                                        onclick="ajaxAddToCart('${rec.listingId}', 'rec-qty-${rec.listingId}', this)">
                                    <i class="bi bi-cart-plus"></i> Thêm giỏ
                                </button>
                                <%-- hidden qty input dùng để pass vào ajaxAddToCart --%>
                                <input type="hidden" id="rec-qty-${rec.listingId}" data-max="${rec.quantity}" data-min="1" value="1">
                            </div>
                        </div>
                        </c:forEach>
                    </div>
                    <button class="rec-scroll-arrow" style="right:-12px;" onclick="scrollRec(1)" id="rec-next" title="Tiếp"><i class="bi bi-chevron-right"></i></button>
                </div>
            </div>
        </div>
        </c:if>

        <div class="section-header">
            <h2 class="section-title">
                <span>🛒</span>
                <c:choose>
                    <c:when test="${keyword != null && keyword != ''}">Kết quả: "${keyword}"</c:when>
                    <c:otherwise>Tất cả sản phẩm</c:otherwise>
                </c:choose>
            </h2>
            <span class="result-count">${totalListings} sản phẩm</span>
        </div>

        <!-- Product Grid -->
        <div class="product-grid">
            <c:choose>
                <c:when test="${not empty listings}">
                    <c:forEach var="listing" items="${listings}">
                        <div class="product-card">

                            <c:if test="${listing.regionName != null}">
                                <span class="badge-region">📍 ${listing.regionName}</span>
                            </c:if>
                            <span class="badge-vip-seller">★ VIP Seller</span>

                            <div class="product-img">
                                <c:choose>
                                    <c:when test="${listing.imageUrl != null && listing.imageUrl != ''}">
                                        <img src="${listing.imageUrl}" alt="${listing.productName}" loading="lazy">
                                        <div class="product-img-overlay"></div>
                                    </c:when>
                                    <c:otherwise>
                                        <c:choose>
                                            <c:when test="${listing.productName.toLowerCase().contains('cà phê') || listing.productName.toLowerCase().contains('cafe')}">☕</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('tiêu') || listing.productName.toLowerCase().contains('hồ tiêu')}">🌶️</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('sầu riêng')}">🍈</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('xoài')}">🥭</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('lúa') || listing.productName.toLowerCase().contains('gạo')}">🌾</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('dừa')}">🥥</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('chanh')}">🍋</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('rau')}">🥬</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('bơ')}">🥑</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('chuối')}">🍌</c:when>
                                            <c:when test="${listing.productName.toLowerCase().contains('vải')}">🍇</c:when>
                                            <c:otherwise>🌿</c:otherwise>
                                        </c:choose>
                                    </c:otherwise>
                                </c:choose>
                            </div>

                            <div class="product-body">
                                <div class="product-name">${listing.productName}</div>
                                <div class="product-farmer">
                                    <i class="bi bi-person-circle"></i> ${listing.farmerName}
                                </div>
                                <%-- Chỉ seller/admin mới thấy số lượng trong kho --%>
                                <c:if test="${sessionScope.user != null && (sessionScope.user.VIP || sessionScope.user.admin)}">
                                    <div class="product-meta">
                                        <span class="qty-badge">
                                            <i class="bi bi-box"></i>
                                            Kho: <fmt:formatNumber value="${listing.quantity}" pattern="#,##0"/> ${listing.unit}
                                        </span>
                                    </div>
                                </c:if>
                                <div class="product-price-row">
                                    <span class="price-farmer">
                                        <fmt:formatNumber value="${listing.price}" pattern="#,##0"/>đ
                                    </span>
                                    <span class="price-unit">/${listing.unit}</span>
                                    <c:if test="${listing.marketPrice != null}">
                                        <span class="price-market-ref">
                                            <fmt:formatNumber value="${listing.marketPrice}" pattern="#,##0"/>đ
                                        </span>
                                    </c:if>
                                </div>
                            </div>

                            <div class="card-actions" style="flex-direction:column;gap:8px;">
                                <c:choose>
                                    <c:when test="${sessionScope.user != null}">
                                        <%-- Nút nhắn tin --%>
                                        <a href="${pageContext.request.contextPath}/market-chat?partner=${listing.farmerId}&amp;listing=${listing.listingId}"
                                           class="btn-chat-seller" id="chat-btn-${listing.listingId}">
                                            <i class="bi bi-chat-dots-fill"></i>
                                            <c:choose>
                                                <c:when test="${sessionScope.user.VIP || sessionScope.user.admin}">Nhắn tin người mua</c:when>
                                                <c:otherwise>Nhắn tin người bán</c:otherwise>
                                            </c:choose>
                                        </a>
                                        <%-- Chọn số lượng + Thêm giỏ dùng AJAX --%>
                                        <div style="display:flex;gap:4px;align-items:center;"
                                             id="cart-form-${listing.listingId}">
                                            <div class="qty-selector">
                                                <button type="button" class="qty-btn"
                                                        id="btn-minus-${listing.listingId}"
                                                        onclick="changeQty('qty-${listing.listingId}',-1)" aria-label="Giảm">−</button>
                                                <input type="text" inputmode="numeric" pattern="[0-9]*"
                                                       class="qty-input"
                                                       id="qty-${listing.listingId}"
                                                       data-max="${listing.quantity}"
                                                       data-min="1"
                                                       value="1"
                                                       onchange="sanitizeQty(this)"
                                                       onkeydown="blockNonNumeric(event)">
                                                <button type="button" class="qty-btn"
                                                        id="btn-plus-${listing.listingId}"
                                                        onclick="changeQty('qty-${listing.listingId}',1)" aria-label="Tăng">+</button>
                                            </div>
                                            <button type="button" class="btn-cart" style="flex:1; padding: 10px 4px; font-size: 12px;"
                                                    id="add-btn-${listing.listingId}"
                                                    onclick="ajaxAddToCart('${listing.listingId}', 'qty-${listing.listingId}', this)">
                                                <i class="bi bi-cart-plus"></i> Thêm
                                            </button>
                                            <button type="button" class="btn-cart" style="flex:1; background: #F9A825; color: #1A2E1A; padding: 10px 4px; font-size: 12px; box-shadow: 0 4px 12px rgba(249,168,37,0.35);"
                                                    id="buy-btn-${listing.listingId}"
                                                    onclick="ajaxBuyNow('${listing.listingId}', 'qty-${listing.listingId}', this)">
                                                <i class="bi bi-lightning-charge-fill"></i> Mua ngay
                                            </button>
                                        </div>

                                    </c:when>
                                    <c:otherwise>
                                        <a href="${pageContext.request.contextPath}/login" class="btn-cart" style="width:100%;">
                                            <i class="bi bi-lock"></i> Đăng nhập để mua
                                        </a>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="empty-state">
                        <div class="empty-icon-wrap">🌾</div>
                        <h3>Chưa có sản phẩm nào</h3>
                        <p>Thử tìm kiếm khác hoặc xóa bộ lọc để xem thêm</p>
                        <a href="${pageContext.request.contextPath}/marketplace"
                           class="btn-filter" style="width:auto;display:inline-flex;padding:10px 28px;">
                            Xem tất cả sản phẩm
                        </a>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>


    </main>
</div>

<!-- ═══════════════ FOOTER ═══════════════ -->
<footer class="site-footer">
    <div style="max-width:1440px;margin:0 auto;text-align:center;">
        <div class="footer-brand">🌾 SmartAgri</div>
        <p style="font-size:13px;margin:8px 0 0;opacity:.75;">Marketplace kết nối trực tiếp nông dân &amp; người mua. Giá cả minh bạch, hàng hóa chuẩn vùng.</p>
    </div>
    <div class="footer-bottom" style="margin-top:20px;">
        🌱 <strong style="color:white;">Smart Agriculture Marketplace</strong> &copy; 2026
        &nbsp;|&nbsp; Kết nối nông dân &amp; người mua
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Search submit on Enter
    document.getElementById('search-input')?.addEventListener('keypress', function(e) {
        if (e.key === 'Enter') this.form.submit();
    });

    // Auto-dismiss success alert after 3s
    setTimeout(() => {
        document.querySelector('.alert-success-bar')?.remove();
    }, 3000);

    // ─── Qty helpers ───
    function getQtyBounds(input) {
        var min = parseInt(input.dataset.min) || 1;
        var max = parseInt(input.dataset.max);
        if (isNaN(max) || max <= 0) max = 999999; // Nếu ko có data-max thì không giới hạn
        return { min: min, max: max };
    }

    function updateBtnState(inputId) {
        var input = document.getElementById(inputId);
        if (!input) return;
        var b = getQtyBounds(input);
        var val = parseInt(input.value) || 1;
        var btnMinus = document.getElementById('btn-minus-' + inputId.replace('qty-',''));
        var btnPlus  = document.getElementById('btn-plus-'  + inputId.replace('qty-',''));
        if (btnMinus) btnMinus.disabled = (val <= b.min);
        if (btnPlus)  btnPlus.disabled  = (val >= b.max);
    }

    function changeQty(inputId, delta) {
        var input = document.getElementById(inputId);
        if (!input) return;
        var b   = getQtyBounds(input);
        var val = parseInt(input.value) || b.min;
        val = Math.max(b.min, Math.min(b.max, val + delta));
        input.value = val;
        updateBtnState(inputId);
    }

    function sanitizeQty(input) {
        var b   = getQtyBounds(input);
        var val = parseInt(input.value);
        if (isNaN(val) || val < b.min) val = b.min;
        if (val > b.max) val = b.max;
        input.value = val;
        updateBtnState(input.id);
    }

    function blockNonNumeric(e) {
        // Cho phép: số 0-9, Backspace, Delete, Tab, ArrowLeft/Right, Home, End
        var allowed = ['Backspace','Delete','Tab','ArrowLeft','ArrowRight','Home','End'];
        if (allowed.indexOf(e.key) !== -1) return;
        if (e.key >= '0' && e.key <= '9') return;
        e.preventDefault();
    }

    // ─── Toast notification ───
    function showQtyToast(msg) {
        var old = document.getElementById('qty-toast');
        if (old) old.remove();
        var toast = document.createElement('div');
        toast.id = 'qty-toast';
        toast.innerHTML = '<i class="bi bi-exclamation-circle-fill"></i> ' + msg;
        toast.style.cssText = [
            'position:fixed','bottom:24px','left:50%','transform:translateX(-50%)',
            'background:#D32F2F','color:white','padding:12px 22px','border-radius:50px',
            'font-size:14px','font-weight:600','z-index:9999','box-shadow:0 4px 20px rgba(0,0,0,0.25)',
            'display:flex','align-items:center','gap:8px','animation:fadeInUp .25s ease'
        ].join(';');
        document.body.appendChild(toast);
        setTimeout(function(){ if(toast.parentNode) toast.remove(); }, 3000);
    }

    // ─── AJAX Add to Cart ───
    var _ctx = '${pageContext.request.contextPath}';

    function ajaxAddToCart(listingId, qtyInputId, btn) {
        var input = document.getElementById(qtyInputId);
        if (!input) return;
        var b   = getQtyBounds(input);
        var val = parseInt(input.value);
        if (isNaN(val) || val < 1) {
            showQtyToast('Số lượng phải ít nhất là 1!');
            input.value = 1; updateBtnState(qtyInputId); return;
        }
        if (val > b.max) {
            showQtyToast('Chỉ còn ' + b.max.toLocaleString('vi-VN') + ' trong kho!');
            input.value = b.max; updateBtnState(qtyInputId); return;
        }

        // Dùng hidden form POST (tương thích cả servlet cũ lẫn mới)
        btn.disabled = true;
        btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Đang thêm...';

        var form = document.createElement('form');
        form.method = 'POST';
        form.action = _ctx + '/buyer/cart/add';
        form.style.display = 'none';

        var fListingId = document.createElement('input');
        fListingId.name = 'listingId'; fListingId.value = listingId;
        form.appendChild(fListingId);

        var fQty = document.createElement('input');
        fQty.name = 'quantity'; fQty.value = val;
        form.appendChild(fQty);

        // Redirect về marketplace?success=added_to_cart sau khi thêm
        var fRedirect = document.createElement('input');
        fRedirect.name = 'redirect'; fRedirect.value = 'marketplace';
        form.appendChild(fRedirect);

        document.body.appendChild(form);
        form.submit();
    }

    function ajaxBuyNow(listingId, qtyInputId, btn) {
        var input = document.getElementById(qtyInputId);
        if (!input) return;
        var b   = getQtyBounds(input);
        var val = parseInt(input.value);
        if (isNaN(val) || val < 1) {
            showQtyToast('Số lượng phải ít nhất là 1!');
            input.value = 1; updateBtnState(qtyInputId); return;
        }
        if (val > b.max) {
            showQtyToast('Chỉ còn ' + b.max.toLocaleString('vi-VN') + ' trong kho!');
            input.value = b.max; updateBtnState(qtyInputId); return;
        }

        btn.disabled = true;
        btn.innerHTML = '<i class="bi bi-hourglass-split"></i> Đang xử lý...';

        var form = document.createElement('form');
        form.method = 'POST';
        form.action = _ctx + '/buyer/cart/add';
        form.style.display = 'none';

        var fListingId = document.createElement('input');
        fListingId.name = 'listingId'; fListingId.value = listingId;
        form.appendChild(fListingId);

        var fQty = document.createElement('input');
        fQty.name = 'quantity'; fQty.value = val;
        form.appendChild(fQty);

        var fAction = document.createElement('input');
        fAction.name = 'action'; fAction.value = 'buy_now';
        form.appendChild(fAction);

        document.body.appendChild(form);
        form.submit();
    }

    function updateCartBadge(delta) {
        var badge = document.querySelector('.cart-badge');
        if (badge) {
            var cur = parseInt(badge.textContent) || 0;
            badge.textContent = cur + delta;
        } else {
            // Tạo badge mới nếu chưa có
            var cartIcon = document.querySelector('.btn-cart-icon');
            if (cartIcon) {
                var b2 = document.createElement('span');
                b2.className = 'cart-badge';
                b2.textContent = '1';
                cartIcon.appendChild(b2);
            }
        }
    }

    // ─── Toast giỏ hàng (màu xanh) ───
    function showCartToast(html) {
        var old = document.getElementById('cart-toast');
        if (old) old.remove();
        var toast = document.createElement('div');
        toast.id = 'cart-toast';
        toast.innerHTML = html;
        toast.style.cssText = [
            'position:fixed','bottom:24px','left:50%','transform:translateX(-50%)',
            'background:#2E7D32','color:white','padding:14px 26px','border-radius:50px',
            'font-size:14px','font-weight:600','z-index:9999','box-shadow:0 4px 24px rgba(46,125,50,0.4)',
            'display:flex','align-items:center','gap:8px','animation:fadeInUp .25s ease',
            'white-space:nowrap'
        ].join(';');
        document.body.appendChild(toast);
        setTimeout(function(){ if(toast.parentNode) toast.remove(); }, 2500);
    }

    // Khởi tạo trạng thái nút khi load
    document.querySelectorAll('.qty-input').forEach(function(inp) {
        updateBtnState(inp.id);
    });

    // ─── Smart Recommend scroll ───
    function scrollRec(dir) {
        var track = document.getElementById('rec-scroll-track');
        if (!track) return;
        var cardW = 194; // 180px card + 14px gap
        track.scrollBy({ left: dir * cardW * 3, behavior: 'smooth' });
    }
    // Ẩn/hiện nút prev/next dựa trên scroll position
    (function() {
        var track = document.getElementById('rec-scroll-track');
        if (!track) return;
        var prev = document.getElementById('rec-prev');
        var next = document.getElementById('rec-next');
        function updateArrows() {
            if (!prev || !next) return;
            prev.style.opacity = track.scrollLeft > 10 ? '1' : '0.3';
            prev.style.pointerEvents = track.scrollLeft > 10 ? 'auto' : 'none';
            var atEnd = track.scrollLeft + track.clientWidth >= track.scrollWidth - 10;
            next.style.opacity = atEnd ? '0.3' : '1';
            next.style.pointerEvents = atEnd ? 'none' : 'auto';
        }
        track.addEventListener('scroll', updateArrows);
        updateArrows();
    })();

    // Highlight section gợi ý nếu có
    (function() {
        var sec = document.getElementById('smart-recommend');
        if (!sec) return;
        // Pulse animation nho nhỏ khi load
        setTimeout(function() {
            sec.style.transition = 'box-shadow 0.5s';
            sec.style.boxShadow = '0 0 0 3px rgba(46,125,50,0.25), 0 6px 32px rgba(46,125,50,0.14)';
            setTimeout(function() { sec.style.boxShadow = ''; }, 700);
        }, 400);
    })();

    // Hiển thị toast khi quay về từ add-to-cart redirect
    (function() {
        var params = new URLSearchParams(window.location.search);
        if (params.get('success') === 'added_to_cart') {
            showCartToast('✅ Đã thêm sản phẩm vào giỏ hàng!');
            updateCartBadge(1);
            // Xóa param khỏi URL (không reload trang)
            var url = window.location.pathname;
            var rest = params.toString().replace('success=added_to_cart', '').replace(/^&|&$/, '');
            history.replaceState(null, '', url + (rest ? '?' + rest : ''));
        }
        if (params.get('error')) {
            showQtyToast('❌ ' + decodeURIComponent(params.get('error').replace(/\+/g, ' ')));
        }
    })();
</script>
</body>
</html>
