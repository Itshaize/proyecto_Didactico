<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*, java.util.*" %>
<% 
    List<Palabra> palabras = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
         "SELECT * FROM palabras WHERE id_categoria = 1 ORDER BY id")) {
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Palabra p = new Palabra(rs.getInt("id"), 1,
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
            conn, u.getId(), "VER_CATEGORIA", "Visitó Animals", request.getRemoteAddr());
    } catch (Exception e) { e.printStackTrace(); }

    // Build JSON for JS games
    java.util.Map<String,String> emojiMap = new java.util.LinkedHashMap<>();
    emojiMap.put("Dog","🐶"); emojiMap.put("Cat","🐱");
    emojiMap.put("Bird","🐦"); emojiMap.put("Fish","🐠");
    emojiMap.put("Rabbit","🐇"); emojiMap.put("Lion","🦁");
    emojiMap.put("Elephant","🐘"); emojiMap.put("Butterfly","🦋");
    emojiMap.put("Frog","🐸"); emojiMap.put("Horse","🐴");

    StringBuilder wordsJson = new StringBuilder("[");
    int idx = 0;
    for (Palabra p : palabras) {
        if (idx > 0) wordsJson.append(",");
        String emoji = emojiMap.getOrDefault(p.getPalabraEn(), "🐾");
        String imgUrl = p.getImagenUrl() != null ? p.getImagenUrl() : "";
        wordsJson.append("{\"en\":\"").append(p.getPalabraEn().replace("\"","\\\""))
                 .append("\",\"es\":\"").append(p.getPalabraEs().replace("\"","\\\""))
                 .append("\",\"emoji\":\"").append(emoji)
                 .append("\",\"img\":\"").append(imgUrl.replace("\"","\\\""))
                 .append("\",\"nivel\":\"").append(p.getNivel() != null ? p.getNivel() : "basico")
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
    <meta name="description" content="Aprende animales en inglés con juegos – EnglishKids">
    <title>🐾 Animals – EnglishKids</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Fredoka+One&family=Nunito:wght@600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
        --orange: #F97316;
        --orange-dark: #C2410C;
        --orange-light: #FFEDD5;
        --yellow: #FACC15;
        --red: #EF4444;
    }

    body {
        font-family: 'Nunito', sans-serif;
        background: #FFF7ED;
        min-height: 100vh;
        overflow-x: hidden;
    }

    /* ── TOP NAV ── */
    .top-nav {
        background: linear-gradient(90deg, var(--orange-dark), var(--orange), var(--yellow));
        padding: 12px 24px;
        display: flex; align-items: center; justify-content: space-between;
        box-shadow: 0 4px 20px rgba(194,65,12,.35);
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
        background: linear-gradient(135deg, var(--orange-dark) 0%, var(--orange) 50%, var(--yellow) 100%);
        padding: 48px 20px 56px;
        text-align: center;
        position: relative;
        overflow: hidden;
    }
    .hero::before {
        content: '';
        position: absolute; inset: 0;
        background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.08'%3E%3Cpath d='M30,10 C41,10 50,19 50,30 C50,41 41,50 30,50 C19,50 10,41 10,30 C10,19 19,10 30,10 Z' /%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
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
        color: rgba(255,255,255,0.9);
        font-size: 1.15rem; font-weight: 700;
        margin-bottom: 20px; position: relative; z-index: 1;
    }
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
        margin-top: -2px; background: #FFF7ED;
    }

    /* ── SECTION WRAPPER ── */
    .section-wrap {
        max-width: 860px; margin: 0 auto; padding: 0 20px;
    }
    .kid-heading {
        font-family: 'Fredoka One', cursive;
        font-size: 1.8rem; color: var(--orange-dark);
        text-align: center; margin: 36px 0 20px;
        display: flex; align-items: center; justify-content: center; gap: 10px;
    }
    .kid-heading::before, .kid-heading::after {
        content: ''; flex: 1; height: 3px;
        background: linear-gradient(90deg, transparent, var(--orange-light));
        border-radius: 10px;
    }
    .kid-heading::after { background: linear-gradient(90deg, var(--orange-light), transparent); }

    /* ── GAME TABS ── */
    .game-tabs {
        display: flex; gap: 14px; justify-content: center;
        flex-wrap: wrap; margin-bottom: 32px;
    }
    .game-tab {
        background: #fff;
        border: none; border-radius: 22px;
        padding: 16px 24px; cursor: pointer;
        font-family: 'Fredoka One', cursive; font-size: 1.1rem; color: #9CA3AF;
        box-shadow: 0 6px 0 #D1D5DB, 0 4px 16px rgba(0,0,0,0.08);
        transition: transform 0.15s, box-shadow 0.15s;
        display: flex; flex-direction: column; align-items: center; gap: 6px;
        min-width: 120px;
    }
    .game-tab .ti { font-size: 2.2rem; }
    .game-tab:hover { transform: translateY(-5px); box-shadow: 0 11px 0 #D1D5DB; }
    .game-tab:active { transform: translateY(0); box-shadow: 0 2px 0 #D1D5DB; }
    .game-tab.active {
        background: var(--orange);
        color: #fff;
        box-shadow: 0 6px 0 var(--orange-dark), 0 8px 24px rgba(249,115,22,0.35);
        transform: translateY(-5px);
    }
    .game-section { display: none; }
    .game-section.active { display: block; }

    /* ── GAME CARD WRAPPER ── */
    .game-card {
        background: #fff;
        border-radius: 28px;
        padding: 32px 28px;
        box-shadow: 0 8px 40px rgba(249,115,22,0.12);
        margin-bottom: 16px;
    }
    .game-title {
        font-family: 'Fredoka One', cursive;
        font-size: 1.6rem; color: var(--orange-dark);
        text-align: center; margin-bottom: 6px;
    }
    .game-hint {
        text-align: center; color: #9CA3AF;
        font-size: 0.95rem; margin-bottom: 24px;
    }

    /* ── FLASHCARD ── */
    .fc-progress { height: 12px; background: var(--orange-light); border-radius: 50px; margin-bottom: 6px; overflow: hidden; }
    .fc-progress-fill { height: 100%; background: linear-gradient(90deg, var(--orange), var(--yellow)); border-radius: 50px; transition: width .4s; }
    .fc-counter { font-family:'Fredoka One',cursive; font-size:1rem; color:var(--orange); text-align:center; margin-bottom: 18px; }
    .flashcard-wrap { perspective:1000px; width:240px; height:240px; margin:0 auto; cursor:pointer; }
    .flashcard { width:100%;height:100%;position:relative;transform-style:preserve-3d;transition:transform .5s;border-radius:24px; }
    .flashcard.flipped { transform:rotateY(180deg); }
    .flashcard-front, .flashcard-back {
        position:absolute;width:100%;height:100%;backface-visibility:hidden;
        border-radius:24px;display:flex;flex-direction:column;align-items:center;justify-content:center;
    }
    .flashcard-front { background:linear-gradient(135deg,var(--orange),var(--yellow));color:#fff;font-size:6rem; }
    .flashcard-back  { background:#fff;transform:rotateY(180deg);color:var(--orange);
                       border:3px solid var(--orange);font-family:'Fredoka One',cursive;font-size:1.8rem;text-align:center; }
    .flashcard-back .es { font-size:1.1rem; color:#9CA3AF; margin-top:4px; }
    .fc-btns { display:flex;gap:12px;justify-content:center;flex-wrap:wrap;margin-top:24px; }
    .fc-btn {
        background: var(--orange-light); border: none; border-radius: 16px;
        padding: 12px 24px; font-family:'Fredoka One',cursive; font-size:1rem;
        color: var(--orange-dark); cursor:pointer;
        box-shadow: 0 4px 0 #FDBA74; transition: .15s;
    }
    .fc-btn:hover { background: var(--orange); color: #fff; transform: translateY(-2px); }
    .fc-btn:active { transform: translateY(1px); box-shadow: 0 1px 0 #FDBA74; }
    .fc-btn.speak { background: linear-gradient(135deg,#10B981,#059669); color:#fff; box-shadow:0 4px 0 #047857; }
    .fc-btn.speak:hover { background: #059669; }

    /* ── LISTEN & PICK ── */
    .listen-options {
        display: grid; grid-template-columns: repeat(2, 1fr); gap: 16px;
        max-width: 460px; margin: 16px auto 0;
    }
    .listen-btn {
        padding: 24px 10px; border-radius: 20px; border: 4px solid #E5E7EB; background: #fff;
        font-family: 'Fredoka One', cursive; font-size: 2.5rem;
        cursor: pointer; transition: .2s; box-shadow: 0 4px 0 #E5E7EB;
        display: flex; flex-direction: column; align-items: center; gap: 8px;
    }
    .listen-btn span { font-size: 1.2rem; color: #4B5563; }
    .listen-btn:hover:not(:disabled) { transform: scale(1.05) translateY(-4px); border-color: var(--orange); box-shadow: 0 8px 0 var(--orange-light); }
    .listen-btn.correct { border-color: #10B981; background: #D1FAE5; box-shadow: 0 4px 0 #10B981; }
    .listen-btn.wrong { border-color: #EF4444; background: #FEE2E2; box-shadow: 0 4px 0 #EF4444; }
    .listen-btn:disabled { cursor: default; opacity: .85; }

    /* ── MATCHING ── */
    .match-grid { display:grid;grid-template-columns:repeat(4,1fr);gap:12px;max-width:620px;margin:0 auto; }
    @media(max-width:480px){ .match-grid { grid-template-columns:repeat(3,1fr); } }
    .match-card {
        aspect-ratio:1; border-radius:18px; border:3px solid #E5E7EB;
        display:flex;align-items:center;justify-content:center;
        cursor:pointer;font-family:'Fredoka One',cursive;font-size:1.1rem;
        background:#fff;transition:.2s;user-select:none;text-align:center;padding:6px;
        box-shadow: 0 4px 0 #E5E7EB;
    }
    .match-card.emoji { font-size: 2.8rem; }
    .match-card:hover:not(.matched) { border-color:var(--orange);transform:scale(1.06);box-shadow:0 6px 0 #FDBA74; }
    .match-card.selected { border-color:var(--orange);background:var(--orange-light);transform:scale(1.08); }
    .match-card.matched  { background:linear-gradient(135deg,#10B981,#059669);color:#fff;border-color:#047857;cursor:default;box-shadow:0 4px 0 #047857; }
    .match-card.wrong    { background:#FEF2F2;border-color:#EF4444;animation:shake .3s; }
    @keyframes shake { 0%,100%{transform:translateX(0)} 25%{transform:translateX(-8px)} 75%{transform:translateX(8px)} }
    .match-meta { font-family:'Fredoka One',cursive; font-size:1.1rem; color:var(--orange); text-align:center; margin-bottom:14px; }

    /* ── MEDIA SECTION (video + 3D) ── */
    .media-grid {
        display: grid; grid-template-columns: 1fr 1fr; gap: 20px;
        max-width: 860px; margin: 0 auto;
    }
    @media(max-width:640px){ .media-grid { grid-template-columns: 1fr; } }
    .media-card {
        background: #fff; border-radius: 24px; overflow: hidden;
        box-shadow: 0 8px 32px rgba(249,115,22,0.13);
    }
    .media-card-header {
        background: linear-gradient(90deg, var(--orange), var(--yellow));
        padding: 14px 20px; font-family: 'Fredoka One', cursive;
        color: #fff; font-size: 1.15rem;
        display: flex; align-items: center; gap: 8px;
    }
    .media-embed { position: relative; padding-bottom: 56.25%; height: 0; overflow: hidden; }
    .media-embed iframe { position: absolute; top:0; left:0; width:100%; height:100%; border:none; }
    .media-desc { padding: 10px 16px 12px; font-size: 0.82rem; color: #9CA3AF; text-align: center; }
    .media-desc a { color: var(--orange-dark); font-weight: 700; text-decoration: none; }

    /* ── SCORE BAR ── */
    .score-bar {
        font-family:'Fredoka One',cursive; font-size:1.2rem;
        color: var(--orange); text-align:center; margin-bottom:16px;
    }

    /* ── QUIZ BUTTON ── */
    .quiz-section { text-align: center; padding: 40px 20px 56px; }
    .quiz-btn {
        display: inline-block;
        background: linear-gradient(135deg, var(--orange), var(--red));
        color: #fff; border: none; border-radius: 50px;
        padding: 18px 52px;
        font-family: 'Fredoka One', cursive; font-size: 1.5rem;
        cursor: pointer; text-decoration: none;
        box-shadow: 0 8px 0 var(--orange-dark), 0 12px 30px rgba(249,115,22,0.35);
        transition: transform 0.15s, box-shadow 0.15s;
        animation: pulse-quiz 2.5s infinite;
    }
    @keyframes pulse-quiz { 0%,100% { transform: scale(1); } 50% { transform: scale(1.04); } }
    .quiz-btn:hover { transform: translateY(-4px) scale(1.03); color:#fff; text-decoration:none; box-shadow:0 12px 0 var(--orange-dark),0 16px 36px rgba(249,115,22,0.45); }
    .quiz-btn:active { transform: translateY(2px); box-shadow:0 4px 0 var(--orange-dark); }
    .quiz-label { font-family:'Fredoka One',cursive; color:#9CA3AF; font-size:0.95rem; margin-bottom:12px; }

    .btn-orange {
        background: linear-gradient(135deg,var(--orange),var(--orange-dark));
        color:#fff; border:none; border-radius:16px; padding:12px 28px;
        font-family:'Fredoka One',cursive; font-size:1rem; cursor:pointer;
        box-shadow:0 4px 0 var(--orange-dark); transition:.15s;
    }
    .btn-orange:hover { transform:translateY(-2px); color:#fff; }
    .btn-orange:active { transform:translateY(1px); box-shadow:0 1px 0 var(--orange-dark); }
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
    <div class="mascot" aria-hidden="true">🐾</div>
    <h1 id="cat-titulo">Animals</h1>
    <p class="hero-sub">¡Aprende los animales en inglés jugando!</p>

    <div class="hero-cats">
        <a href="${pageContext.request.contextPath}/categorias/colors.jsp" class="hero-cat-btn">🎨 Colors</a>
        <a href="${pageContext.request.contextPath}/categorias/numbers.jsp" class="hero-cat-btn">🔢 Numbers</a>
    </div>
</div>

<!-- Wave -->
<svg class="wave" viewBox="0 0 1440 60" preserveAspectRatio="none" aria-hidden="true">
    <path d="M0,40 C360,80 1080,0 1440,40 L1440,60 L0,60 Z" fill="#FFF7ED"/>
</svg>

<main id="contenido">

    <!-- GAMES SECTION -->
    <div class="section-wrap">
        <div class="kid-heading">🎮 ¡A Jugar!</div>

        <!-- TABS -->
        <div class="game-tabs" role="tablist" aria-label="Juegos de Animals">
            <button class="game-tab active" onclick="switchTab('flashcards')" role="tab" aria-selected="true">
                <span class="ti">🃏</span> Tarjetas
            </button>
            <button class="game-tab" onclick="switchTab('listen')" role="tab" aria-selected="false">
                <span class="ti">🎧</span> Escuchar
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
                     aria-label="Flashcard de animal – toca para voltear"
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

        <!-- TAB 2: Listen & Pick -->
        <div id="tab-listen" class="game-section">
            <div class="game-card">
                <div class="game-title">🎧 ¡Escucha y elige!</div>
                <div class="game-hint">🔊 Escucha la palabra y toca el animal correcto</div>
                <div class="score-bar" id="lp-score">⭐ 0 / 0</div>
                <div class="text-center">
                    <button class="btn-orange" onclick="speakListenWord()" style="font-size:1.4rem;padding:14px 32px;border-radius:24px;">🔊 ¡Escuchar palabra!</button>
                </div>
                <div class="listen-options" id="lp-options" role="group" aria-label="Opciones de respuesta"></div>
                <div class="score-bar mt-4" id="lp-feedback" style="min-height:30px; font-size:1.4rem;"></div>
            </div>
        </div>

        <!-- TAB 3: Matching -->
        <div id="tab-matching" class="game-section">
            <div class="game-card">
                <div class="game-title">🔗 ¡Empareja los animales!</div>
                <div class="game-hint">Une el dibujo con su nombre en inglés</div>
                <div class="match-meta" id="match-meta">⭐ 0 pts &nbsp;|&nbsp; 0/8 parejas</div>
                <div class="match-grid" id="match-grid" role="grid" aria-label="Cuadrícula de parejas"></div>
                <div class="text-center mt-4">
                    <button class="btn-orange" onclick="initMatching()">🔄 Nuevo Juego</button>
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
                <div class="media-card-header">📹 Animals Song</div>
                <div class="media-embed">
                    <iframe src="https://www.youtube.com/embed/FwWQRlXv1AY?rel=0"
                            title="Animals Actions Song for Kids - Fun Kids English"
                            allowfullscreen loading="lazy"
                            allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture">
                    </iframe>
                </div>
                <div class="media-desc">🎵 ¡Aprende los animales con canciones!</div>
            </div>

            <!-- SKETCHFAB 3D -->
            <div class="media-card">
                <div class="media-card-header">🦁 Modelo 3D Interactivo</div>
                <div class="media-embed">
                    <iframe
                        title="Animal Head Pack"
                        frameborder="0" allowfullscreen
                        mozallowfullscreen="true" webkitallowfullscreen="true"
                        allow="autoplay; fullscreen; xr-spatial-tracking"
                        xr-spatial-tracking execution-while-out-of-viewport
                        execution-while-not-rendered web-share
                        src="https://sketchfab.com/models/a9c6c9ca3a3848c092270ac74700db92/embed">
                    </iframe>
                </div>
                <div class="media-desc">
                    🖱️ Arrastra para rotar •
                    <a href="https://sketchfab.com/3d-models/animal-head-pack-a9c6c9ca3a3848c092270ac74700db92"
                       target="_blank" rel="nofollow">ver en Sketchfab</a>
                </div>
            </div>

        </div>
    </div>

    <!-- QUIZ CTA -->
    <div class="quiz-section">
        <div class="quiz-label">¿Estás listo para el reto final? 🏆</div>
        <a href="${pageContext.request.contextPath}/estudiante/actividad.jsp?categoria=1&nombre=Animals"
           class="quiz-btn" aria-label="Comenzar Quiz de Animals">
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
    if (name === 'listen')   initListen();
}

// ── FLASHCARDS ────────────────────────────────────────────────────────────────
let fcIdx = 0;
function renderCard() {
    const w = WORDS[fcIdx];
    document.getElementById('fc').classList.remove('flipped');
    const front = document.getElementById('fc-front');
    if (w.img) {
        front.innerHTML = '<img src="' + window.location.origin + '/englishkids/' + w.img + '" alt="' + w.en + '" style="width:140px;height:140px;object-fit:cover;border-radius:50%;border:6px solid rgba(255,255,255,0.8);box-shadow:0 6px 20px rgba(0,0,0,0.2)">' +
                          '<div style="display:none;font-size:5rem">' + w.emoji + '</div>';
    } else {
        front.innerHTML = w.emoji;
    }
    document.getElementById('fc-back').innerHTML =
        '<div>' + w.en + '</div><div class="es">' + w.es + '</div>';
    document.getElementById('fc-counter').textContent = (fcIdx+1) + ' / ' + WORDS.length;
    document.getElementById('fc-prog').style.width = Math.round((fcIdx+1)/WORDS.length*100) + '%';
    speakWord();
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

// ── LISTEN & PICK ─────────────────────────────────────────────────────────────
let lpIdx=0, lpCorrect=0, lpTotal=0, lpOrder=[];
function initListen() {
    lpOrder = shuffle(WORDS.slice(0, WORDS.length)).slice(0, 10);
    lpIdx=0; lpCorrect=0; lpTotal=lpOrder.length;
    renderListen();
}
function renderListen() {
    if (lpIdx >= lpTotal) {
        document.getElementById('lp-feedback').textContent = '🎉 ¡Terminaste! ' + lpCorrect + '/' + lpTotal;
        document.getElementById('lp-options').innerHTML = '<div class="text-center" style="grid-column:span 2"><button class="btn-orange" onclick="initListen()">🔄 Jugar de nuevo</button></div>';
        return;
    }
    const correct = lpOrder[lpIdx];
    document.getElementById('lp-score').textContent = '⭐ ' + lpCorrect + ' / ' + lpTotal;
    document.getElementById('lp-feedback').textContent = '';

    const others = shuffle(WORDS.filter(w => w.en !== correct.en)).slice(0, 3);
    const options = shuffle([correct, ...others]);
    const cont = document.getElementById('lp-options');
    cont.innerHTML = '';
    options.forEach(opt => {
        const btn = document.createElement('button');
        btn.className = 'listen-btn';
        btn.innerHTML = '<div>' + opt.emoji + '</div><span>' + opt.en + '</span>';
        btn.setAttribute('aria-label', 'Respuesta: ' + opt.en);
        btn.addEventListener('click', () => {
            const isCorrect = opt.en === correct.en;
            btn.classList.add(isCorrect ? 'correct' : 'wrong');
            cont.querySelectorAll('.listen-btn').forEach(b => b.disabled = true);
            if (window.speechSynthesis) {
                window.speechSynthesis.cancel();
                const utter = new SpeechSynthesisUtterance(correct.en);
                utter.lang = 'en-US'; utter.rate = 0.85; utter.pitch = 1.1;
                window.speechSynthesis.speak(utter);
            }
            if (isCorrect) {
                lpCorrect++;
                document.getElementById('lp-feedback').textContent = '✅ ¡Correcto! ' + correct.en;
            } else {
                document.getElementById('lp-feedback').textContent = '❌ Era: ' + correct.en;
            }
            lpIdx++;
            setTimeout(renderListen, 1400);
        });
        cont.appendChild(btn);
    });
}
function speakListenWord() {
    if (lpIdx < lpTotal) {
        window.speechSynthesis.cancel();
        const u = new SpeechSynthesisUtterance(lpOrder[lpIdx].en); u.lang = 'en-US'; u.rate=0.85; u.pitch=1.1; window.speechSynthesis.speak(u);
    }
}

// ── MATCHING ──────────────────────────────────────────────────────────────────
let matchScore=0, matchSelected=null, matchPairsFound=0, matchTotal=0;
function initMatching() {
    matchScore=0; matchSelected=null; matchPairsFound=0;
    const pool = shuffle(WORDS).slice(0,8); matchTotal = pool.length;
    const emojis = pool.map(w => ({id:w.en, type:'emoji', val:w.emoji, word:w.en}));
    const labels = pool.map(w => ({id:w.en, type:'word',  val:w.en,    word:w.en}));
    const all = shuffle([...emojis, ...labels]);
    const grid = document.getElementById('match-grid');
    grid.innerHTML = '';
    updateMatchMeta();
    all.forEach(item => {
        const div = document.createElement('div');
        div.className = 'match-card ' + (item.type==='emoji' ? 'emoji' : '');
        div.textContent = item.val;
        div.dataset.id = item.id;
        div.dataset.type = item.type;
        div.setAttribute('tabindex','0');
        div.addEventListener('click', () => selectMatchCard(div));
        div.addEventListener('keydown', e => { if(e.key==='Enter') selectMatchCard(div); });
        grid.appendChild(div);
    });
}
function updateMatchMeta() {
    document.getElementById('match-meta').textContent = '⭐ ' + matchScore + ' pts  |  ' + matchPairsFound + '/' + matchTotal + ' parejas';
}
function selectMatchCard(el) {
    if (el.classList.contains('matched')) return;
    if (matchSelected===el) { el.classList.remove('selected'); matchSelected=null; return; }
    if (matchSelected && matchSelected.dataset.type===el.dataset.type) {
        matchSelected.classList.remove('selected'); matchSelected=null; return;
    }
    el.classList.add('selected');
    if (!matchSelected) { matchSelected=el; return; }
    const a=matchSelected, b=el;
    if (a.dataset.id===b.dataset.id && a.dataset.type!==b.dataset.type) {
        a.classList.remove('selected'); b.classList.remove('selected');
        a.classList.add('matched');     b.classList.add('matched');
        matchScore+=10; matchPairsFound++;
        updateMatchMeta();
        window.speechSynthesis.cancel();
        const u = new SpeechSynthesisUtterance(a.dataset.id); u.lang='en-US'; u.rate=0.85; u.pitch=1.1;
        window.speechSynthesis.speak(u);
        if (matchPairsFound===matchTotal) {
            setTimeout(() => {
                const g = document.getElementById('match-grid');
                if (g) g.innerHTML =
                    '<div style="grid-column:1/-1;text-align:center;padding:40px 20px;">' +
                    '<div style="font-size:3.5rem">🎉</div>' +
                    '<div style="font-family:\'Fredoka One\',cursive;font-size:2rem;color:var(--orange-dark);margin:8px 0">¡Completaste el juego!</div>' +
                    '<div style="font-size:1.1rem;color:#9CA3AF">Puntaje: <strong>' + matchScore + ' pts</strong></div>' +
                    '<button class="btn-orange" onclick="initMatching()" style="margin-top:20px;">🔄 Jugar de nuevo</button>' +
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