<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*, java.util.*" %>
<%
    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    Usuario u = (Usuario) ses.getAttribute("usuario");

    int totalActividades = 0, totalCorrectas = 0, totalPuntos = 0;
    Map<String,Integer> progCat = new LinkedHashMap<>();
    progCat.put("Animals", 0); progCat.put("Colors", 0); progCat.put("Numbers", 0);

    try (Connection conn = DBConnection.getConnection()) {
        PreparedStatement ps = conn.prepareStatement(
            "SELECT COUNT(*) as total, SUM(CASE WHEN resultado='correcto' THEN 1 ELSE 0 END) as correctas, " +
            "SUM(puntos) as puntos FROM actividades WHERE id_usuario = ?");
        ps.setInt(1, u.getId());
        ResultSet rs = ps.executeQuery();
        if (rs.next()) {
            totalActividades = rs.getInt("total");
            totalCorrectas   = rs.getInt("correctas");
            totalPuntos      = rs.getInt("puntos");
        }
        rs.close(); ps.close();

        ps = conn.prepareStatement(
            "SELECT c.nombre, COUNT(DISTINCT a.id_palabra) as palabras_practicadas " +
            "FROM actividades a JOIN palabras p ON a.id_palabra = p.id " +
            "JOIN categorias c ON p.id_categoria = c.id " +
            "WHERE a.id_usuario = ? AND a.resultado = 'correcto' GROUP BY c.nombre");
        ps.setInt(1, u.getId());
        rs = ps.executeQuery();
        while (rs.next()) { progCat.put(rs.getString("nombre"), rs.getInt("palabras_practicadas")); }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); }

    int pct = totalActividades > 0 ? (int)((totalCorrectas * 100.0) / totalActividades) : 0;

    // Determine greeting star level
    String starLevel = "🌟";
    if (totalPuntos >= 200) starLevel = "🏆";
    else if (totalPuntos >= 100) starLevel = "🥇";
    else if (totalPuntos >= 50) starLevel = "🥈";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Panel del Estudiante – EnglishKids">
    <title>¡Mi Panel! – EnglishKids</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Fredoka+One&family=Nunito:wght@400;600;700;800&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <style>
        * { box-sizing: border-box; }
        body {
            font-family: 'Nunito', sans-serif;
            background: linear-gradient(180deg, #87CEEB 0%, #B0E2FF 40%, #E0F7FA 100%);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ── Clouds ── */
        .clouds-bg {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            pointer-events: none; z-index: 0; overflow: hidden;
        }
        .cloud {
            position: absolute;
            background: rgba(255,255,255,0.85);
            border-radius: 50px;
            animation: float-cloud linear infinite;
        }
        .cloud::before, .cloud::after {
            content: '';
            position: absolute;
            background: inherit;
            border-radius: 50%;
        }
        .cloud::before { width: 60%; height: 140%; top: -50%; left: 15%; }
        .cloud::after  { width: 40%; height: 120%; top: -40%; left: 55%; }
        .c1 { width:120px; height:40px; top:8%;  animation-duration:30s; animation-delay:-5s;  }
        .c2 { width:180px; height:55px; top:18%; animation-duration:45s; animation-delay:-15s; }
        .c3 { width: 90px; height:32px; top:5%;  animation-duration:25s; animation-delay:-8s;  }
        .c4 { width:150px; height:48px; top:28%; animation-duration:55s; animation-delay:-20s; }
        @keyframes float-cloud {
            0%   { transform: translateX(-220px); }
            100% { transform: translateX(110vw);  }
        }

        /* ── Navbar ── */
        .kid-nav {
            background: linear-gradient(90deg, #FF9800, #FF5722);
            padding: 10px 24px;
            display: flex; align-items: center; justify-content: space-between;
            border-radius: 0 0 28px 28px;
            box-shadow: 0 4px 20px rgba(255,87,34,0.35);
            position: relative; z-index: 10;
        }
        .kid-nav .brand {
            font-family: 'Fredoka One', cursive;
            font-size: 1.6rem; color: #fff;
            text-decoration: none; display: flex; align-items: center; gap: 8px;
        }
        .logout-btn {
            background: rgba(255,255,255,0.25);
            color: #fff; border: 2px solid rgba(255,255,255,0.6);
            border-radius: 50px; padding: 6px 18px;
            font-family: 'Fredoka One', cursive; font-size: 0.95rem;
            cursor: pointer; text-decoration: none;
            transition: background 0.2s;
        }
        .logout-btn:hover { background: rgba(255,255,255,0.45); color: #fff; }

        /* ── Hero greeting ── */
        .hero-greeting {
            position: relative; z-index: 5;
            text-align: center; padding: 36px 20px 16px;
        }
        .hero-greeting .mascot { font-size: 5rem; animation: bounce 1.8s infinite; display: inline-block; }
        @keyframes bounce {
            0%,100% { transform: translateY(0); }
            50%      { transform: translateY(-16px); }
        }
        .hero-greeting h1 {
            font-family: 'Fredoka One', cursive;
            font-size: clamp(2rem, 5vw, 3rem);
            color: #1565C0; text-shadow: 3px 3px 0 rgba(255,255,255,0.6);
            margin: 10px 0 4px;
        }
        .hero-greeting .sub {
            font-size: 1.1rem; color: #5C6BC0; font-weight: 700;
        }
        .star-badge {
            display: inline-block;
            background: linear-gradient(135deg,#FFD600,#FF8F00);
            color: #fff; font-family: 'Fredoka One', cursive;
            font-size: 1.05rem; padding: 6px 20px;
            border-radius: 50px; margin-top: 10px;
            box-shadow: 0 3px 12px rgba(255,152,0,0.4);
            animation: pulse-badge 2s infinite;
        }
        @keyframes pulse-badge {
            0%,100% { transform: scale(1); }
            50%      { transform: scale(1.05); }
        }

        /* ── Section title ── */
        .section-heading {
            font-family: 'Fredoka One', cursive;
            font-size: 1.5rem; color: #1565C0;
            text-align: center; margin: 28px 0 16px;
            position: relative; z-index: 5;
        }

        /* ── Category cards ── */
        .cat-grid {
            display: grid;
            grid-template-columns: repeat(3, 1fr);
            gap: 18px;
            max-width: 700px; margin: 0 auto;
            position: relative; z-index: 5;
        }
        @media(max-width:576px) { .cat-grid { grid-template-columns: 1fr 1fr; } }
        .cat-card {
            background: #fff;
            border-radius: 24px;
            padding: 24px 12px 18px;
            text-align: center;
            text-decoration: none;
            display: block;
            box-shadow: 0 6px 0 rgba(0,0,0,0.12), 0 8px 24px rgba(0,0,0,0.08);
            transition: transform 0.15s, box-shadow 0.15s;
            cursor: pointer;
            border-bottom: 5px solid;
        }
        .cat-card:hover, .cat-card:focus {
            transform: translateY(-6px) scale(1.03);
            box-shadow: 0 12px 0 rgba(0,0,0,0.12), 0 16px 32px rgba(0,0,0,0.12);
            text-decoration: none;
        }
        .cat-card:active { transform: translateY(1px); box-shadow: 0 3px 0 rgba(0,0,0,0.15); }
        .cat-card .icon { font-size: 3.5rem; display: block; margin-bottom: 8px; }
        .cat-card .label {
            font-family: 'Fredoka One', cursive; font-size: 1.2rem;
            display: block; margin-bottom: 12px;
        }
        .cat-card .go-btn {
            display: inline-block;
            font-family: 'Fredoka One', cursive; font-size: 1rem;
            color: #fff; border-radius: 50px; padding: 7px 22px;
            box-shadow: 0 4px 0 rgba(0,0,0,0.2);
            transition: box-shadow 0.1s, transform 0.1s;
        }
        .cat-card:hover .go-btn { transform: scale(1.05); }

        .animals-card  { border-color: #FF7043; }
        .animals-card  .label  { color: #FF7043; }
        .animals-card  .go-btn { background: linear-gradient(135deg,#FF8A65,#FF5722); }

        .colors-card   { border-color: #AB47BC; }
        .colors-card   .label  { color: #AB47BC; }
        .colors-card   .go-btn { background: linear-gradient(135deg,#CE93D8,#9C27B0); }

        .numbers-card  { border-color: #29B6F6; }
        .numbers-card  .label  { color: #1E88E5; }
        .numbers-card  .go-btn { background: linear-gradient(135deg,#4FC3F7,#0288D1); }

        /* ── Quick actions ── */
        .quick-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 14px; max-width: 700px; margin: 0 auto;
            position: relative; z-index: 5;
        }
        .quick-card {
            border-radius: 20px; padding: 18px 16px;
            display: flex; align-items: center; gap: 14px;
            text-decoration: none; color: #fff;
            box-shadow: 0 5px 0 rgba(0,0,0,0.15), 0 8px 20px rgba(0,0,0,0.1);
            transition: transform 0.15s, box-shadow 0.15s;
            font-family: 'Fredoka One', cursive;
        }
        .quick-card:hover { transform: translateY(-4px); color: #fff; text-decoration: none; }
        .quick-card .qicon { font-size: 2.2rem; flex-shrink: 0; }
        .quick-card .qtitle { font-size: 1.1rem; line-height: 1.2; }
        .quick-card .qsub { font-size: 0.8rem; opacity: 0.85; font-family: 'Nunito', sans-serif; }
        .qc-quiz    { background: linear-gradient(135deg,#66BB6A,#2E7D32); }
        .qc-animlas { background: linear-gradient(135deg,#FFA726,#E65100); }
        .qc-colors  { background: linear-gradient(135deg,#AB47BC,#6A1B9A); }
        .qc-numbers { background: linear-gradient(135deg,#29B6F6,#0277BD); }

        /* ── Stats strip ── */
        .stats-strip {
            display: flex; gap: 12px; justify-content: center; flex-wrap: wrap;
            max-width: 700px; margin: 0 auto;
            position: relative; z-index: 5;
        }
        .stat-pill {
            background: #fff; border-radius: 50px;
            padding: 10px 22px; display: flex; align-items: center; gap: 8px;
            box-shadow: 0 3px 12px rgba(0,0,0,0.1);
            font-family: 'Fredoka One', cursive;
        }
        .stat-pill .snum { font-size: 1.5rem; }
        .stat-pill .slabel { font-size: 0.85rem; color: #78909C; font-family: 'Nunito', sans-serif; font-weight: 700; }

        /* ── Progress bars ── */
        .prog-section {
            background: #fff; border-radius: 24px;
            padding: 20px 24px;
            box-shadow: 0 4px 20px rgba(0,0,0,0.08);
            max-width: 700px; margin: 0 auto;
            position: relative; z-index: 5;
        }
        .prog-row { margin-bottom: 14px; }
        .prog-label { font-family: 'Fredoka One', cursive; font-size: 1rem; margin-bottom: 4px; display: flex; justify-content: space-between; }
        .prog-track { background: #E8EAF6; border-radius: 50px; height: 14px; overflow: hidden; }
        .prog-fill  { height: 100%; border-radius: 50px; transition: width 1s ease; }

        .footer-kid {
            text-align: center; padding: 24px;
            font-family: 'Fredoka One', cursive;
            color: #90A4AE; font-size: 0.9rem;
            position: relative; z-index: 5;
        }
    </style>
</head>
<body>

<!-- Clouds -->
<div class="clouds-bg" aria-hidden="true">
    <div class="cloud c1"></div>
    <div class="cloud c2"></div>
    <div class="cloud c3"></div>
    <div class="cloud c4"></div>
</div>

<!-- Navbar -->
<nav class="kid-nav" role="navigation" aria-label="Navegación principal">
    <a class="brand" href="${pageContext.request.contextPath}/index.jsp">
        <img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:32px; border-radius:50%; background:#fff; padding:2px; vertical-align:middle; margin-right:6px;" alt=""> EnglishKids
    </a>
    <div style="display:flex;align-items:center;gap:12px;">
        <span style="color:#fff;font-family:'Fredoka One',cursive;font-size:1rem;">
            👤 <%= u.getNombre() %>
        </span>
        <a href="${pageContext.request.contextPath}/logout" class="logout-btn" aria-label="Cerrar sesión">
            🚪 Salir
        </a>
    </div>
</nav>

<main id="contenido">

    <!-- Hero Greeting -->
    <div class="hero-greeting">
        <div class="mascot" aria-hidden="true">🦉</div>
        <h1>¡Hola, <%= u.getNombre() %>! 👋</h1>
        <p class="sub">¿Qué quieres aprender hoy?</p>
        <span class="star-badge"><%= starLevel %> <%= totalPuntos %> puntos acumulados</span>
    </div>

    <!-- Stats strip -->
    <div class="stats-strip mb-4 px-3">
        <div class="stat-pill">
            <span class="snum" style="color:#FF7043;">🎮</span>
            <div>
                <div class="snum" style="color:#FF7043;font-size:1.3rem;"><%= totalActividades %></div>
                <div class="slabel">Jugadas</div>
            </div>
        </div>
        <div class="stat-pill">
            <span class="snum" style="color:#43A047;">✅</span>
            <div>
                <div class="snum" style="color:#43A047;font-size:1.3rem;"><%= totalCorrectas %></div>
                <div class="slabel">Correctas</div>
            </div>
        </div>
        <div class="stat-pill">
            <span class="snum" style="color:#AB47BC;">🎯</span>
            <div>
                <div class="snum" style="color:#AB47BC;font-size:1.3rem;"><%= pct %>%</div>
                <div class="slabel">Precisión</div>
            </div>
        </div>
    </div>

    <!-- Category Cards -->
    <p class="section-heading">🗺️ ¿Qué quieres explorar hoy?</p>
    <div class="cat-grid px-3 mb-4">
        <a href="${pageContext.request.contextPath}/categorias/animals.jsp"
           class="cat-card animals-card" aria-label="Ir a Animals">
            <span class="icon">🐾</span>
            <span class="label">Animals</span>
            <span class="go-btn">¡EXPLORAR!</span>
        </a>
        <a href="${pageContext.request.contextPath}/categorias/colors.jsp"
           class="cat-card colors-card" aria-label="Ir a Colors">
            <span class="icon">🎨</span>
            <span class="label">Colors</span>
            <span class="go-btn">¡EXPLORAR!</span>
        </a>
        <a href="${pageContext.request.contextPath}/categorias/numbers.jsp"
           class="cat-card numbers-card" aria-label="Ir a Numbers">
            <span class="icon">🔢</span>
            <span class="label">Numbers</span>
            <span class="go-btn">¡EXPLORAR!</span>
        </a>
    </div>

    <!-- Quick Actions -->
    <p class="section-heading">⚡ Acciones Rápidas</p>
    <div class="quick-grid px-3 mb-4">
        <a href="${pageContext.request.contextPath}/estudiante/actividad.jsp?categoria=1&nombre=Animals"
           class="quick-card qc-quiz">
            <span class="qicon">🎯</span>
            <div>
                <div class="qtitle">¡Quiz Final!</div>
                <div class="qsub">Pon a prueba lo que aprendiste</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/categorias/animals.jsp"
           class="quick-card qc-animlas">
            <span class="qicon">🐶</span>
            <div>
                <div class="qtitle">Animals</div>
                <div class="qsub">Matching & Flashcards</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/categorias/colors.jsp"
           class="quick-card qc-colors">
            <span class="qicon">🌈</span>
            <div>
                <div class="qtitle">Colors</div>
                <div class="qsub">Paint & Match</div>
            </div>
        </a>
        <a href="${pageContext.request.contextPath}/categorias/numbers.jsp"
           class="quick-card qc-numbers">
            <span class="qicon">🔟</span>
            <div>
                <div class="qtitle">Numbers</div>
                <div class="qsub">Count & Choose</div>
            </div>
        </a>
    </div>

    <!-- Progress -->
    <p class="section-heading">📊 Mi Progreso</p>
    <div class="prog-section px-3 mb-5">
        <%
            String[] catColors = {"#FF7043","#AB47BC","#29B6F6"};
            String[] catEmojis2 = {"🐾","🎨","🔢"};
            int ci = 0;
            for (Map.Entry<String,Integer> e2 : progCat.entrySet()) {
                int palabrasPract = e2.getValue();
                int progPct2 = Math.min((palabrasPract * 100) / 10, 100);
                String col = catColors[ci % 3];
                String em = catEmojis2[ci % 3];
                ci++;
        %>
        <div class="prog-row">
            <div class="prog-label">
                <span style="color:<%= col %>;"><%= em %> <%= e2.getKey() %></span>
                <span style="color:#90A4AE;font-family:'Nunito',sans-serif;font-weight:700;font-size:0.85rem;"><%= palabrasPract %>/10 palabras</span>
            </div>
            <div class="prog-track">
                <div class="prog-fill" style="width:<%= progPct2 %>%;background:<%= col %>;"></div>
            </div>
        </div>
        <% } %>
    </div>

</main>

<div class="footer-kid"><img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:24px; border-radius:50%; background:#fff; padding:2px; vertical-align:middle; margin-right:6px;" alt=""> EnglishKids &copy; 2026 — ¡Sigue aprendiendo! 🚀</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
    // Animate progress bars on load
    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.prog-fill').forEach(function(bar) {
            const target = bar.style.width;
            bar.style.width = '0%';
            setTimeout(function() { bar.style.width = target; }, 300);
        });
    });
</script>
</body>
</html>
