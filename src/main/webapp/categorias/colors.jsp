<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*, java.util.*" %>
<%
    List<Palabra> palabras = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT * FROM palabras WHERE id_categoria = 2 ORDER BY id")) {
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Palabra p = new Palabra(rs.getInt("id"), 2,
                rs.getString("palabra_en"), rs.getString("palabra_es"),
                rs.getString("imagen_url"), rs.getString("audio_url"),
                rs.getString("modelo_3d"), rs.getString("nivel"));
            palabras.add(p);
        }
    } catch (Exception e) { e.printStackTrace(); }

    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Usuario u = (Usuario) ses.getAttribute("usuario");
    try (Connection conn = DBConnection.getConnection()) {
        com.englishkids.servlet.LoginServlet.registrarBitacora(
            conn, u.getId(), "VER_CATEGORIA", "Visitó Colors", request.getRemoteAddr());
    } catch (Exception e) { e.printStackTrace(); }

    java.util.Map<String,String> colorHex = new java.util.LinkedHashMap<>();
    colorHex.put("Red","#F44336"); colorHex.put("Blue","#2196F3");
    colorHex.put("Green","#4CAF50"); colorHex.put("Yellow","#FFEB3B");
    colorHex.put("Purple","#9C27B0"); colorHex.put("Orange","#FF9800");
    colorHex.put("Pink","#E91E63"); colorHex.put("Black","#212121");
    colorHex.put("White","#ECEFF1"); colorHex.put("Brown","#795548");

    StringBuilder wordsJson = new StringBuilder("[");
    int idx = 0;
    for (Palabra p : palabras) {
        if (idx > 0) wordsJson.append(",");
        String hex = colorHex.getOrDefault(p.getPalabraEn(), "#9E9E9E");
        wordsJson.append("{\"en\":\"").append(p.getPalabraEn().replace("\"","\\\""))
                 .append("\",\"es\":\"").append(p.getPalabraEs().replace("\"","\\\""))
                 .append("\",\"hex\":\"").append(hex)
                 .append("\"}");
        idx++;
    }
    wordsJson.append("]");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Aprende los colores en inglés con juegos – EnglishKids">
    <title>🎨 Colors – EnglishKids</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Fredoka+One&family=Nunito:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
        --purple: #8B5CF6;
        --purple-dark: #6D28D9;
        --purple-light: #EDE9FE;
        --pink: #EC4899;
        --blue: #3B82F6;
        --green: #10B981;
        --yellow: #F59E0B;
    }

    body {
        font-family: 'Nunito', sans-serif;
        background: #F5F3FF;
        min-height: 100vh;
        overflow-x: hidden;
    }

    /* ── TOP NAV ── */
    .top-nav {
        background: linear-gradient(90deg, var(--purple-dark), var(--purple), var(--pink));
        padding: 12px 24px;
        display: flex; align-items: center; justify-content: space-between;
        box-shadow: 0 4px 20px rgba(109,40,217,.35);
    }
    .top-nav .brand {
        font-family: 'Fredoka One', cursive;
        font-size: 1.5rem; color: #fff;
        text-decoration: none; display: flex; align-items: center; gap: 8px;
    }
    .top-nav .nav-pills-wrap { display: flex; gap: 8px; align-items: center; }
    .top-nav .npill {
        background: rgba(255,255,255,0.2);
        color: #fff; border: 2px solid rgba(255,255,255,0.5);
        border-radius: 50px; padding: 7px 18px;
        font-family: 'Fredoka One', cursive; font-size: 0.95rem;
        text-decoration: none; transition: background 0.2s;
    }
    .top-nav .npill:hover { background: rgba(255,255,255,0.4); color: #fff; }

    /* ── HERO ── */
    .hero {
        background: linear-gradient(135deg, var(--purple-dark) 0%, var(--purple) 50%, var(--pink) 100%);
        padding: 48px 20px 56px;
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    .hero::before {
        content: '';
        position: absolute; inset: 0;
        background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.06'%3E%3Ccircle cx='30' cy='30' r='20'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
        pointer-events: none;
    }
    .hero .mascot {
        font-size: 6rem;
        display: inline-block;
        animation: bounce-mascot 2s ease-in-out infinite;
        position: relative; z-index: 1;
    }
    @keyframes bounce-mascot {
        0%,100% { transform: translateY(0) rotate(-5deg); }
        50%      { transform: translateY(-18px) rotate(5deg); }
    }
    .hero h1 {
        font-family: 'Fredoka One', cursive;
        color: #fff; font-size: clamp(2.4rem,6vw,4rem);
        text-shadow: 0 4px 12px rgba(0,0,0,0.2);
        margin: 12px 0 6px; position: relative; z-index: 1;
    }
    .hero .hero-sub {
        color: rgba(255,255,255,0.88);
        font-size: 1.15rem; font-weight: 700;
        margin-bottom: 20px; position: relative; z-index: 1;
    }
    /* Rainbow color dots in hero */
    .color-dots {
        display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;
        margin-bottom: 20px; position: relative; z-index: 1;
    }
    .color-dot {
        width: 40px; height: 40px; border-radius: 50%;
        border: 3px solid rgba(255,255,255,0.7);
        box-shadow: 0 4px 12px rgba(0,0,0,0.25);
        animation: pop-dot 0.4s ease backwards;
    }
    @keyframes pop-dot { from { transform: scale(0); opacity: 0; } to { transform: scale(1); opacity: 1; } }
    .hero-cats { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; position: relative; z-index: 1; }
    .hero-cat-btn {
        background: rgba(255,255,255,0.2);
        color: #fff; border: 2px solid rgba(255,255,255,0.6);
        border-radius: 50px; padding: 8px 22px;
        font-family: 'Fredoka One', cursive; font-size: 1rem;
        text-decoration: none; transition: 0.2s;
    }
    .hero-cat-btn:hover { background: rgba(255,255,255,0.4); color: #fff; transform: translateY(-2px); }

    /* ── WAVE DIVIDER ── */
    .wave {
        display: block; width: 100%;
        margin-top: -2px; background: #F5F3FF;
    }

    /* ── SECTION WRAPPER ── */
    .section-wrap {
        max-width: 860px; margin: 0 auto; padding: 0 20px;
    }
    .kid-heading {
        font-family: 'Fredoka One', cursive;
        font-size: 1.8rem; color: var(--purple-dark);
        text-align: center; margin: 36px 0 20px;
        display: flex; align-items: center; justify-content: center; gap: 10px;
    }
    .kid-heading::before, .kid-heading::after {
        content: ''; flex: 1; height: 3px;
        background: linear-gradient(90deg, transparent, var(--purple-light));
        border-radius: 10px;
    }
    .kid-heading::after { background: linear-gradient(90deg, var(--purple-light), transparent); }

    /* ── GAME TABS ── */
    .game-tabs {
        display: flex; gap: 14px; justify-content: center;
        flex-wrap: wrap; margin-bottom: 32px;
    }
    .game-tab {
        background: #fff;
        border: none; border-radius: 22px;
        padding: 16px 24px; cursor: pointer;
        font-family: 'Fredoka One', cursive; font-size: 1.1rem; color: #94A3B8;
        box-shadow: 0 6px 0 #D1D5DB, 0 4px 16px rgba(0,0,0,0.08);
        transition: transform 0.15s, box-shadow 0.15s;
        display: flex; flex-direction: column; align-items: center; gap: 6px;
        min-width: 120px;
    }
    .game-tab .ti { font-size: 2.2rem; }
    .game-tab:hover { transform: translateY(-5px); box-shadow: 0 11px 0 #D1D5DB; }
    .game-tab:active { transform: translateY(0); box-shadow: 0 2px 0 #D1D5DB; }
    .game-tab.active {
        background: var(--purple);
        color: #fff;
        box-shadow: 0 6px 0 var(--purple-dark), 0 8px 24px rgba(139,92,246,0.35);
        transform: translateY(-5px);
    }
    .game-section { display: none; }
    .game-section.active { display: block; }

    /* ── GAME CARD WRAPPER ── */
    .game-card {
        background: #fff;
        border-radius: 28px;
        padding: 32px 28px;
        box-shadow: 0 8px 40px rgba(139,92,246,0.12);
        margin-bottom: 16px;
    }
    .game-title {
        font-family: 'Fredoka One', cursive;
        font-size: 1.6rem; color: var(--purple-dark);
        text-align: center; margin-bottom: 6px;
    }
    .game-hint {
        text-align: center; color: #94A3B8;
        font-size: 0.95rem; margin-bottom: 24px;
    }

    /* ── FLASHCARD ── */
    .fc-progress { height: 12px; background: var(--purple-light); border-radius: 50px; margin-bottom: 6px; overflow: hidden; }
    .fc-progress-fill { height: 100%; background: linear-gradient(90deg, var(--purple), var(--pink)); border-radius: 50px; transition: width .4s; }
    .fc-counter { font-family:'Fredoka One',cursive; font-size:1rem; color:var(--purple); text-align:center; margin-bottom: 18px; }
    .flashcard-wrap { perspective:1000px; width:230px; height:230px; margin:0 auto; cursor:pointer; }
    .flashcard { width:100%;height:100%;position:relative;transform-style:preserve-3d;transition:transform .5s;border-radius:24px; }
    .flashcard.flipped { transform:rotateY(180deg); }
    .flashcard-front, .flashcard-back {
        position:absolute;width:100%;height:100%;backface-visibility:hidden;
        border-radius:24px;display:flex;flex-direction:column;align-items:center;justify-content:center;
    }
    .flashcard-front { background:linear-gradient(135deg,var(--purple),var(--pink));color:#fff; }
    .flashcard-back  { background:#fff;transform:rotateY(180deg);color:var(--purple);
                       border:3px solid var(--purple);font-family:'Fredoka One',cursive;font-size:1.7rem;text-align:center; }
    .flashcard-back .es { font-size:1rem; color:#94A3B8; margin-top:4px; }
    .fc-btns { display:flex;gap:12px;justify-content:center;flex-wrap:wrap;margin-top:22px; }
    .fc-btn {
        background: var(--purple-light); border: none; border-radius: 16px;
        padding: 12px 24px; font-family:'Fredoka One',cursive; font-size:1rem;
        color: var(--purple-dark); cursor:pointer;
        box-shadow: 0 4px 0 #C4B5FD; transition: .15s;
    }
    .fc-btn:hover { background: var(--purple); color: #fff; transform: translateY(-2px); }
    .fc-btn:active { transform: translateY(1px); box-shadow: 0 1px 0 #C4B5FD; }
    .fc-btn.speak { background: linear-gradient(135deg,#10B981,#059669); color:#fff; box-shadow:0 4px 0 #047857; }
    .fc-btn.speak:hover { background: #059669; }

    /* ── PAINT GAME ── */
    .paint-prompt {
        font-family:'Fredoka One',cursive; font-size:2.4rem;
        color: var(--purple-dark); text-align:center; margin-bottom: 20px;
    }
    .color-circles { display:flex;flex-wrap:wrap;gap:16px;justify-content:center; }
    .color-circle {
        width:76px;height:76px;border-radius:50%;border:4px solid transparent;
        cursor:pointer;transition:.25s;box-shadow:0 4px 14px rgba(0,0,0,0.18);
    }
    .color-circle:hover { transform:scale(1.18);box-shadow:0 8px 22px rgba(0,0,0,0.28); }
    .color-circle.ok  { border:4px solid #10B981;box-shadow:0 0 0 4px #A7F3D0; }
    .color-circle.bad { border:4px solid #EF4444;box-shadow:0 0 0 4px #FECACA;animation:shake .3s; }
    @keyframes shake { 0%,100%{transform:translateX(0)} 25%{transform:translateX(-8px)} 75%{transform:translateX(8px)} }
    .paint-feedback {
        font-family:'Fredoka One',cursive; font-size:1.5rem;
        text-align:center; min-height:44px; margin-top:16px;
    }
    .paint-score-bar {
        font-family:'Fredoka One',cursive; font-size:1.1rem;
        color: var(--purple); text-align:center; margin-bottom:16px;
    }

    /* ── MATCHING ── */
    .match-grid { display:grid;grid-template-columns:repeat(4,1fr);gap:12px;max-width:580px;margin:0 auto; }
    @media(max-width:480px){ .match-grid { grid-template-columns:repeat(3,1fr); } }
    .match-card {
        aspect-ratio:1; border-radius:18px; border:3px solid #E2E8F0;
        display:flex;align-items:center;justify-content:center;
        cursor:pointer;font-family:'Fredoka One',cursive;font-size:1rem;
        background:#fff;transition:.2s;user-select:none;text-align:center;padding:6px;
        box-shadow: 0 3px 0 #E2E8F0;
    }
    .match-card:hover:not(.matched) { border-color:var(--purple);transform:scale(1.06);box-shadow:0 5px 0 #C4B5FD; }
    .match-card.selected { border-color:var(--purple);background:var(--purple-light);transform:scale(1.08); }
    .match-card.matched  { background:linear-gradient(135deg,#10B981,#059669);color:#fff;border-color:#047857;cursor:default;box-shadow:0 3px 0 #047857; }
    .match-card.wrong    { background:#FFF1F2;border-color:#EF4444;animation:shake .3s; }
    .match-meta { font-family:'Fredoka One',cursive; font-size:1.1rem; color:var(--purple); text-align:center; margin-bottom:14px; }

    /* ── MEDIA SECTION (video + 3D) ── */
    .media-grid {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
        max-width: 860px;
        margin: 0 auto;
    }
    @media(max-width:640px){ .media-grid { grid-template-columns: 1fr; } }
    .media-card {
        background: #fff;
        border-radius: 24px;
        overflow: hidden;
        box-shadow: 0 8px 32px rgba(139,92,246,0.13);
    }
    .media-card-header {
        background: linear-gradient(90deg, var(--purple), var(--pink));
        padding: 14px 20px;
        font-family: 'Fredoka One', cursive;
        color: #fff; font-size: 1.15rem;
        display: flex; align-items: center; gap: 8px;
    }
    .media-embed {
        position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden;
    }
    .media-embed iframe {
        position: absolute; top:0; left:0; width:100%; height:100%; border:none;
    }
    .media-desc {
        padding: 10px 16px 12px;
        font-size: 0.82rem; color: #94A3B8; text-align: center;
    }
    .media-desc a { color: #8B5CF6; font-weight: 700; text-decoration: none; }

    /* ── QUIZ BUTTON ── */
    .quiz-section {
        text-align: center; padding: 40px 20px 56px;
    }
    .quiz-btn {
        display: inline-block;
        background: linear-gradient(135deg, var(--purple), var(--pink));
        color: #fff; border: none; border-radius: 50px;
        padding: 18px 52px;
        font-family: 'Fredoka One', cursive; font-size: 1.5rem;
        cursor: pointer; text-decoration: none;
        box-shadow: 0 8px 0 var(--purple-dark), 0 12px 30px rgba(139,92,246,0.35);
        transition: transform 0.15s, box-shadow 0.15s;
        animation: pulse-quiz 2.5s infinite;
    }
    @keyframes pulse-quiz {
        0%,100% { transform: scale(1); }
        50% { transform: scale(1.04); }
    }
    .quiz-btn:hover { transform: translateY(-4px) scale(1.03); color:#fff; text-decoration:none; box-shadow:0 12px 0 var(--purple-dark),0 16px 36px rgba(139,92,246,0.45); }
    .quiz-btn:active { transform: translateY(2px); box-shadow:0 4px 0 var(--purple-dark); }
    .quiz-label { font-family:'Fredoka One',cursive; color:#94A3B8; font-size:0.95rem; margin-bottom:12px; }

    /* ── SCORE BADGE ── */
    .score-badge {
        display:inline-block;
        background:linear-gradient(135deg,var(--purple),var(--pink));
        color:#fff;font-family:'Fredoka One',cursive;
        font-size:1.1rem;padding:6px 20px;border-radius:50px;margin-bottom:14px;
    }

    /* ── BTN PRIMARY ── */
    .btn-purple {
        background: linear-gradient(135deg,var(--purple),var(--purple-dark));
        color:#fff; border:none; border-radius:16px; padding:12px 28px;
        font-family:'Fredoka One',cursive; font-size:1rem; cursor:pointer;
        box-shadow:0 4px 0 var(--purple-dark); transition:.15s;
    }
    .btn-purple:hover { transform:translateY(-2px); }
    .btn-purple:active { transform:translateY(1px); box-shadow:0 1px 0 var(--purple-dark); }
    </style>
</head>
<body>

<!-- TOP NAV -->
<nav class="top-nav" role="navigation" aria-label="Navegación principal">
    <a class="brand" href="${pageContext.request.contextPath}/index.jsp"><img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:32px; border-radius:50%; background:#fff; padding:2px; vertical-align:middle; margin-right:6px;" alt=""> EnglishKids</a>
    <div class="nav-pills-wrap">
        <a href="${pageContext.request.contextPath}/estudiante/dashboard.jsp" class="npill">🏠 Mi Panel</a>
        <% if (ses != null && ses.getAttribute("usuario") != null) { %>
        <a href="${pageContext.request.contextPath}/logout" class="npill">🚪 Salir</a>
        <% } %>
    </div>
</nav>

<!-- HERO -->
<div class="hero">
    <div class="mascot" aria-hidden="true">🎨</div>
    <h1 id="cat-titulo">Colors</h1>
    <p class="hero-sub">¡Aprende los colores en inglés jugando!</p>

    <!-- Rainbow dots -->
    <div class="color-dots" aria-hidden="true">
        <div class="color-dot" style="background:#F44336;animation-delay:.0s"></div>
        <div class="color-dot" style="background:#FF9800;animation-delay:.05s"></div>
        <div class="color-dot" style="background:#FFEB3B;animation-delay:.1s"></div>
        <div class="color-dot" style="background:#4CAF50;animation-delay:.15s"></div>
        <div class="color-dot" style="background:#2196F3;animation-delay:.2s"></div>
        <div class="color-dot" style="background:#9C27B0;animation-delay:.25s"></div>
        <div class="color-dot" style="background:#E91E63;animation-delay:.3s"></div>
    </div>

    <div class="hero-cats">
        <a href="${pageContext.request.contextPath}/categorias/animals.jsp" class="hero-cat-btn">🐾 Animals</a>
        <a href="${pageContext.request.contextPath}/categorias/numbers.jsp" class="hero-cat-btn">🔢 Numbers</a>
    </div>
</div>

<!-- Wave -->
<svg class="wave" viewBox="0 0 1440 60" preserveAspectRatio="none" aria-hidden="true">
    <path d="M0,40 C360,80 1080,0 1440,40 L1440,60 L0,60 Z" fill="#F5F3FF"/>
</svg>

<main id="contenido">

    <!-- GAMES SECTION -->
    <div class="section-wrap">
        <div class="kid-heading">🎮 ¡A Jugar!</div>

        <!-- TABS -->
        <div class="game-tabs" role="tablist" aria-label="Juegos de Colors">
            <button class="game-tab active" onclick="switchTab('flashcards')" role="tab" aria-selected="true">
                <span class="ti">🃏</span> Tarjetas
            </button>
            <button class="game-tab" onclick="switchTab('paint')" role="tab" aria-selected="false">
                <span class="ti">🎨</span> Pintar
            </button>
            <button class="game-tab" onclick="switchTab('matching')" role="tab" aria-selected="false">
                <span class="ti">🔗</span> Parejas
            </button>
        </div>

        <!-- TAB 1: Flashcards -->
        <div id="tab-flashcards" class="game-section active">
            <div class="game-card">
                <div class="game-title">🃏 ¡Toca la tarjeta!</div>
                <div class="game-hint">👆 Toca para ver el nombre en español</div>
                <div class="fc-progress"><div class="fc-progress-fill" id="fc-prog" style="width:0%"></div></div>
                <div class="fc-counter" id="fc-counter"></div>
                <div class="flashcard-wrap" id="fc-wrap" onclick="flipCard()" tabindex="0" role="button"
                     aria-label="Flashcard de color – toca para voltear"
                     onkeydown="if(event.key==='Enter')flipCard()">
                    <div class="flashcard" id="fc">
                        <div class="flashcard-front" id="fc-front"></div>
                        <div class="flashcard-back"  id="fc-back"></div>
                    </div>
                </div>
                <div class="fc-btns">
                    <button class="fc-btn" onclick="prevCard()" aria-label="Tarjeta anterior">← Antes</button>
                    <button class="fc-btn speak" onclick="speakWord()" aria-label="Escuchar pronunciación">🔊 Escuchar</button>
                    <button class="fc-btn" onclick="nextCard()" aria-label="Siguiente tarjeta">Siguiente →</button>
                </div>
            </div>
        </div>

        <!-- TAB 2: Paint & Match -->
        <div id="tab-paint" class="game-section">
            <div class="game-card">
                <div class="game-title">🎨 ¡Pinta el color!</div>
                <div class="game-hint">👀 Lee la palabra y toca el color correcto</div>
                <div class="paint-score-bar" id="paint-score">⭐ 0 / 0</div>
                <div class="paint-prompt" id="paint-word" aria-live="polite"></div>
                <div class="color-circles" id="paint-choices" role="group" aria-label="Elige el color correcto"></div>
                <div class="paint-feedback" id="paint-feedback" aria-live="assertive"></div>
            </div>
        </div>

        <!-- TAB 3: Matching -->
        <div id="tab-matching" class="game-section">
            <div class="game-card">
                <div class="game-title">🔗 ¡Empareja los colores!</div>
                <div class="game-hint">Une el círculo de color con su nombre en inglés</div>
                <div class="match-meta" id="match-meta">⭐ 0 pts &nbsp;|&nbsp; 0/6 parejas</div>
                <div class="match-grid" id="match-grid" role="grid" aria-label="Cuadrícula de parejas"></div>
                <div class="text-center mt-4">
                    <button class="btn-purple" onclick="initMatching()">🔄 Nuevo Juego</button>
                </div>
            </div>
        </div>
    </div>

    <!-- MEDIA SECTION: Video + 3D side by side -->
    <div class="section-wrap" style="margin-top:8px;">
        <div class="kid-heading">🌟 Explorar</div>
        <div class="media-grid">

            <!-- VIDEO -->
            <div class="media-card">
                <div class="media-card-header">📹 Colors Song</div>
                <div class="media-embed">
                    <iframe src="https://www.youtube.com/embed/hXl5D8ewLQ4?rel=0"
                            title="Fun Colors Vocabulary Chant for Kids"
                            allowfullscreen loading="lazy"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture">
                    </iframe>
                </div>
                <div class="media-desc">🎵 ¡Canta los colores en inglés!</div>
            </div>

            <!-- SKETCHFAB 3D -->
            <div class="media-card">
                <div class="media-card-header">🌈 Espacio RGB 3D</div>
                <div class="media-embed">
                    <iframe
                        title="RGB Color Space 949 Most Common Colors XKCD"
                        frameborder="0" allowfullscreen
                        mozallowfullscreen="true" webkitallowfullscreen="true"
                        allow="autoplay; fullscreen; xr-spatial-tracking"
                        xr-spatial-tracking execution-while-out-of-viewport
                        execution-while-not-rendered web-share
                        src="https://sketchfab.com/models/b46531f6db504ef1894d6a2a71a743d6/embed">
                    </iframe>
                </div>
                <div class="media-desc">
                    🖱️ Arrastra para rotar •
                    <a href="https://sketchfab.com/3d-models/rgb-color-space-949-most-common-colors-xkcd-b46531f6db504ef1894d6a2a71a743d6"
                       target="_blank" rel="nofollow">ver en Sketchfab</a>
                </div>
            </div>

        </div>
    </div>

    <!-- QUIZ CTA -->
    <div class="quiz-section">
        <div class="quiz-label">¿Estás listo para el reto final? 🏆</div>
        <a href="${pageContext.request.contextPath}/estudiante/actividad.jsp?categoria=2&nombre=Colors"
           class="quiz-btn" aria-label="Comenzar Quiz de Colors">
            🎯 ¡Quiz Final!
        </a>
    </div>

</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
const WORDS = <%= wordsJson %>;

function switchTab(name) {
    document.querySelectorAll('.game-section').forEach(s => s.classList.remove('active'));
    document.querySelectorAll('.game-tab').forEach(t => t.classList.remove('active'));
    document.getElementById('tab-' + name).classList.add('active');
    document.querySelectorAll('.game-tab').forEach(t => {
        if (t.getAttribute('onclick').includes(name)) t.classList.add('active');
    });
    if (name === 'matching') initMatching();
    if (name === 'paint')    initPaint();
}

// ── FLASHCARDS ────────────────────────────────────────────────────────────────
let fcIdx = 0;
function renderCard() {
    const w = WORDS[fcIdx];
    document.getElementById('fc').classList.remove('flipped');
    document.getElementById('fc-front').innerHTML =
        '<div style="width:100px;height:100px;border-radius:50%;background:'+w.hex+';border:5px solid rgba(255,255,255,0.8);margin-bottom:10px;box-shadow:0 6px 20px rgba(0,0,0,0.2)"></div>' +
        '<div style="font-family:\'Fredoka One\',cursive;font-size:1.4rem;letter-spacing:1px;">' + w.en + '</div>';
    document.getElementById('fc-back').innerHTML =
        '<div>' + w.en + '</div><div class="es">' + w.es + '</div>';
    document.getElementById('fc-counter').textContent = (fcIdx+1) + ' / ' + WORDS.length;
    document.getElementById('fc-prog').style.width = Math.round((fcIdx+1)/WORDS.length*100) + '%';
}
function flipCard()  { document.getElementById('fc').classList.toggle('flipped'); }
function nextCard()  { fcIdx = (fcIdx+1) % WORDS.length; renderCard(); }
function prevCard()  { fcIdx = (fcIdx-1+WORDS.length) % WORDS.length; renderCard(); }
function speakWord() {
    window.speechSynthesis.cancel();
    const u = new SpeechSynthesisUtterance(WORDS[fcIdx].en);
    u.lang='en-US'; u.rate=0.85; u.pitch=1.1;
    window.speechSynthesis.speak(u);
}

// ── PAINT & MATCH ─────────────────────────────────────────────────────────────
let paintIdx=0, paintOrder=[], paintCorrect=0, paintTotal=0;
function initPaint() {
    paintOrder = shuffle(WORDS).slice(0,10); paintIdx=0; paintCorrect=0; paintTotal=paintOrder.length;
    renderPaint();
}
function renderPaint() {
    if (paintIdx >= paintTotal) {
        document.getElementById('paint-word').textContent = '🎉 ¡Ganaste!';
        document.getElementById('paint-choices').innerHTML =
            '<button class="btn-purple" onclick="initPaint()" style="margin-top:12px;">🔄 Jugar de nuevo</button>';
        document.getElementById('paint-feedback').textContent = '';
        return;
    }
    const correct = paintOrder[paintIdx];
    document.getElementById('paint-word').textContent = correct.en;
    document.getElementById('paint-score').textContent = '⭐ ' + paintCorrect + ' / ' + paintTotal;
    document.getElementById('paint-feedback').textContent = '';
    const others = shuffle(WORDS.filter(w => w.en !== correct.en)).slice(0,5);
    const choices = shuffle([correct,...others]);
    const cont = document.getElementById('paint-choices');
    cont.innerHTML = '';
    choices.forEach(c => {
        const div = document.createElement('div');
        div.className = 'color-circle';
        div.style.background = c.hex;
        div.setAttribute('aria-label','Color: '+c.en);
        div.setAttribute('tabindex','0');
        div.setAttribute('title',c.en);
        div.addEventListener('click', () => {
            const ok = c.en === correct.en;
            div.classList.add(ok ? 'ok' : 'bad');
            cont.querySelectorAll('.color-circle').forEach(d => d.style.pointerEvents='none');
            if (ok) {
                paintCorrect++;
                document.getElementById('paint-feedback').textContent = '✅ ¡Correcto! ' + correct.en + ' = ' + correct.es;
                window.speechSynthesis.cancel();
                const u = new SpeechSynthesisUtterance(correct.en); u.lang='en-US'; u.rate=0.85; u.pitch=1.1;
                window.speechSynthesis.speak(u);
            } else {
                document.getElementById('paint-feedback').textContent = '❌ Era ' + correct.en + ' (' + correct.es + ')';
            }
            paintIdx++;
            setTimeout(renderPaint, 1300);
        });
        cont.appendChild(div);
    });
}

// ── MATCHING ──────────────────────────────────────────────────────────────────
let matchScore=0, matchSelected=null, matchPairs=0, matchTotal2=0;
function initMatching() {
    matchScore=0; matchSelected=null; matchPairs=0;
    const pool = shuffle(WORDS).slice(0,6); matchTotal2 = pool.length;
    const swatches = pool.map(w => ({id:w.en, type:'swatch', hex:w.hex, en:w.en}));
    const labels   = pool.map(w => ({id:w.en, type:'word',   val:w.en}));
    const all = shuffle([...swatches,...labels]);
    const grid = document.getElementById('match-grid');
    grid.innerHTML = '';
    updateMatchMeta();
    all.forEach(item => {
        const div = document.createElement('div');
        div.className = 'match-card';
        if (item.type==='swatch') {
            div.style.background = item.hex;
            div.style.color = 'transparent';
            div.textContent = 'X';
        } else {
            div.textContent = item.val;
        }
        div.dataset.id   = item.id;
        div.dataset.type = item.type;
        div.setAttribute('tabindex','0');
        div.setAttribute('aria-label', item.type==='swatch' ? 'Color: '+item.en : item.val);
        div.addEventListener('click', () => selectCard(div));
        div.addEventListener('keydown', e => { if(e.key==='Enter') selectCard(div); });
        grid.appendChild(div);
    });
}
function updateMatchMeta() {
    document.getElementById('match-meta').textContent = '⭐ ' + matchScore + ' pts  |  ' + matchPairs + '/' + matchTotal2 + ' parejas';
}
function selectCard(el) {
    if (el.classList.contains('matched')) return;
    if (matchSelected===el) { el.classList.remove('selected'); matchSelected=null; return; }
    if (matchSelected && matchSelected.dataset.type===el.dataset.type) {
        matchSelected.classList.remove('selected'); matchSelected=null;
    }
    el.classList.add('selected');
    if (!matchSelected) { matchSelected=el; return; }
    const a=matchSelected, b=el;
    if (a.dataset.id===b.dataset.id && a.dataset.type!==b.dataset.type) {
        a.classList.remove('selected'); b.classList.remove('selected');
        a.classList.add('matched');     b.classList.add('matched');
        matchScore+=10; matchPairs++;
        updateMatchMeta();
        window.speechSynthesis.cancel();
        const u = new SpeechSynthesisUtterance(a.dataset.id); u.lang='en-US'; u.rate=0.85; u.pitch=1.1;
        window.speechSynthesis.speak(u);
        if (matchPairs===matchTotal2) {
            setTimeout(() => {
                const g = document.getElementById('match-grid');
                if (g) g.innerHTML =
                    '<div style="grid-column:1/-1;text-align:center;padding:40px 20px;">' +
                    '<div style="font-size:3.5rem">🎉</div>' +
                    '<div style="font-family:\'Fredoka One\',cursive;font-size:2rem;color:#6D28D9;margin:8px 0">¡Completaste el juego!</div>' +
                    '<div style="font-size:1.1rem;color:#94A3B8">Puntaje: <strong>' + matchScore + ' pts</strong></div>' +
                    '<button class="btn-purple" onclick="initMatching()" style="margin-top:20px;">🔄 Jugar de nuevo</button>' +
                    '</div>';
            }, 400);
        }
    } else {
        a.classList.add('wrong'); b.classList.add('wrong');
        setTimeout(() => { a.classList.remove('selected','wrong'); b.classList.remove('selected','wrong'); }, 700);
    }
    matchSelected = null;
}

function shuffle(arr) { return [...arr].sort(() => Math.random() - .5); }
if (WORDS.length) renderCard();
</script>
</body>
</html>
