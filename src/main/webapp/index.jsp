<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.Categoria, java.sql.*, java.util.*" %>
<%
    // Cargar categorías desde la BD
    List<Categoria> categorias = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection();
         Statement st = conn.createStatement();
         ResultSet rs = st.executeQuery("SELECT * FROM categorias ORDER BY id")) {
        while (rs.next()) {
            Categoria c = new Categoria(
                rs.getInt("id"), rs.getString("nombre"), rs.getString("nombre_es"),
                rs.getString("descripcion"), rs.getString("icono"), rs.getString("color_hex"));
            categorias.add(c);
        }
    } catch (Exception e) { e.printStackTrace(); }

    String[] catClasses = {"animals", "colors", "numbers"};
    String[] catLinks   = {"animals", "colors", "numbers"};
    String[] catEmojis  = {"🐾", "🎨", "🔢"};
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="EnglishKids – Aprende inglés de manera divertida. Animales, colores y números en inglés para niños.">
    <meta name="keywords" content="inglés para niños, aprender inglés, EnglishKids, educación, ODS 4">
    <title>EnglishKids – Aprende Inglés de Forma Divertida</title>

    <!-- Bootstrap 5 -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <!-- Estilos personalizados -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>

<!-- Skip to content (Accesibilidad) -->
<a href="#contenido-principal" class="skip-link">Saltar al contenido principal</a>

<!-- ── NAVBAR ─────────────────────────────────────────────────────────────── -->
<nav class="navbar navbar-expand-lg" role="navigation" aria-label="Navegación principal">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp" aria-label="EnglishKids - Inicio">
            <img src="${pageContext.request.contextPath}/img/englishkids_logo.png" alt="Logo de EnglishKids" class="brand-icon" style="background:transparent; padding:0; animation:none; border-radius:50%; box-shadow:0 4px 10px rgba(0,0,0,0.2);">
            EnglishKids
        </a>

        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse"
                data-bs-target="#navMenu" aria-controls="navMenu"
                aria-expanded="false" aria-label="Abrir menú de navegación">
            <span class="navbar-toggler-icon"></span>
        </button>

        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp"
                       aria-current="page">
                        <i class="fas fa-home me-1" aria-hidden="true"></i> Inicio
                    </a>
                </li>
                <li class="nav-item dropdown">
                    <a class="nav-link dropdown-toggle" href="#" role="button"
                       data-bs-toggle="dropdown" aria-expanded="false"
                       aria-haspopup="true" id="dropdown-categorias">
                        <i class="fas fa-book-open me-1" aria-hidden="true"></i> Categorías
                    </a>
                    <ul class="dropdown-menu" aria-labelledby="dropdown-categorias">
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/categorias/animals.jsp">
                            🐾 Animals (Animales)</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/categorias/colors.jsp">
                            🎨 Colors (Colores)</a></li>
                        <li><a class="dropdown-item" href="${pageContext.request.contextPath}/categorias/numbers.jsp">
                            🔢 Numbers (Números)</a></li>
                    </ul>
                </li>
            </ul>

            <div class="d-flex align-items-center gap-3 flex-wrap">
                <!-- Accesibilidad: Alto Contraste -->
                <button id="btn-contraste" class="btn-contraste"
                        aria-label="Activar modo alto contraste para mejorar visibilidad">
                    🌗 Alto Contraste
                </button>

                <% if (session != null && session.getAttribute("usuario") != null) {
                       com.englishkids.model.Usuario usuLogin =
                           (com.englishkids.model.Usuario) session.getAttribute("usuario");
                %>
                    <span class="text-white fw-bold small">
                        <i class="fas fa-user-circle me-1" aria-hidden="true"></i>
                        <%= usuLogin.getNombre() %>
                    </span>
                    <% if (usuLogin.isAdmin()) { %>
                        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp"
                           class="btn-outline-custom btn-sm">
                           <i class="fas fa-cog me-1" aria-hidden="true"></i>Admin
                        </a>
                    <% } else { %>
                        <a href="${pageContext.request.contextPath}/estudiante/dashboard.jsp"
                           class="btn-outline-custom btn-sm">
                           <i class="fas fa-graduation-cap me-1" aria-hidden="true"></i>Mi Panel
                        </a>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/logout"
                       class="btn-outline-custom btn-sm"
                       aria-label="Cerrar sesión">
                       <i class="fas fa-sign-out-alt" aria-hidden="true"></i>
                    </a>
                <% } else { %>
                    <a href="${pageContext.request.contextPath}/login.jsp"
                       class="btn-outline-custom"
                       aria-label="Iniciar sesión en EnglishKids">
                        <i class="fas fa-sign-in-alt me-1" aria-hidden="true"></i> Iniciar Sesión
                    </a>
                    <a href="${pageContext.request.contextPath}/registro.jsp"
                       class="btn-primary-custom"
                       aria-label="Registrarse en EnglishKids">
                        <i class="fas fa-user-plus me-1" aria-hidden="true"></i> Registrarse
                    </a>
                <% } %>
            </div>
        </div>
    </div>
</nav>

<!-- ── HERO ───────────────────────────────────────────────────────────────── -->
<main id="contenido-principal">
<section class="hero-section" aria-labelledby="hero-titulo">
    <div class="container position-relative z-1">
        <div class="row align-items-center">
            <div class="col-lg-7">
                <div class="hero-badge">🌟 ODS 4 – Educación de Calidad</div>
                <h1 class="hero-title" id="hero-titulo">
                    Learn English<br>the Fun Way! 🎉
                </h1>
                <p class="hero-subtitle mb-4">
                    Aprende palabras en inglés con imágenes, audio, videos y modelos 3D.<br>
                    ¡Una aventura de aprendizaje para los más pequeños!
                </p>
                <div class="d-flex gap-3 flex-wrap">
                    <a href="${pageContext.request.contextPath}/registro.jsp"
                       class="btn-primary-custom"
                       aria-label="Empezar a aprender inglés gratis">
                        🚀 ¡Empezar Ahora!
                    </a>
                    <a href="#categorias"
                       class="btn-outline-custom"
                       aria-label="Ver todas las categorías de aprendizaje">
                        Ver Categorías <i class="fas fa-arrow-down ms-1" aria-hidden="true"></i>
                    </a>
                </div>

                <!-- Estadísticas -->
                <div class="d-flex gap-4 mt-4 flex-wrap">
                    <div class="text-white">
                        <div style="font-family:'Fredoka One',cursive;font-size:1.8rem;">30+</div>
                        <div style="font-size:0.85rem;opacity:0.85;">Palabras</div>
                    </div>
                    <div class="text-white">
                        <div style="font-family:'Fredoka One',cursive;font-size:1.8rem;">3</div>
                        <div style="font-size:0.85rem;opacity:0.85;">Categorías</div>
                    </div>
                    <div class="text-white">
                        <div style="font-family:'Fredoka One',cursive;font-size:1.8rem;">∞</div>
                        <div style="font-size:0.85rem;opacity:0.85;">Diversión</div>
                    </div>
                </div>
            </div>
            <div class="col-lg-5 d-none d-lg-block text-center">
                <div class="hero-letters" aria-hidden="true">A B C</div>
                <div style="font-size:8rem;animation:float 3s ease-in-out infinite;" aria-hidden="true">🌍📚✨</div>
            </div>
        </div>
    </div>
</section>

<!-- ── CATEGORÍAS ─────────────────────────────────────────────────────────── -->
<section id="categorias" class="py-5" aria-labelledby="sec-cat-titulo">
    <div class="container">
        <h2 class="section-title" id="sec-cat-titulo">Choose Your Category</h2>
        <p class="section-subtitle">Elige una categoría y comienza a aprender palabras en inglés</p>

        <div class="row g-4">
            <% for (int i = 0; i < categorias.size() && i < 3; i++) {
                   Categoria cat = categorias.get(i);
                   String cls    = catClasses[i];
                   String link   = catLinks[i];
                   String emoji  = catEmojis[i];
            %>
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/categorias/<%= link %>.jsp"
                   class="category-card <%= cls %> fade-up delay-<%= i+1 %>"
                   aria-label="Categoría <%= cat.getNombre() %> – <%= cat.getNombreEs() %>">
                    <div class="category-icon <%= cls %>" aria-hidden="true">
                        <i class="<%= cat.getIcono() %>"></i>
                    </div>
                    <div class="category-title <%= cls %>">
                        <%= emoji %> <%= cat.getNombre() %>
                    </div>
                    <p class="text-muted small mb-2"><%= cat.getNombreEs() %></p>
                    <p class="text-muted small mb-3"><%= cat.getDescripcion() %></p>
                    <span class="category-count <%= cls %>">10 palabras</span>
                </a>
            </div>
            <% } %>
        </div>
    </div>
</section>

<!-- ── CÓMO FUNCIONA ──────────────────────────────────────────────────────── -->
<section class="py-5" style="background:#fff;" aria-labelledby="sec-como-titulo">
    <div class="container">
        <h2 class="section-title" id="sec-como-titulo">How It Works</h2>
        <p class="section-subtitle">Aprende inglés en 4 sencillos pasos</p>
        <div class="row g-4">
            <div class="col-md-3">
                <div class="how-card fade-up delay-1">
                    <div class="how-icon" aria-hidden="true"><i class="fas fa-user-plus"></i></div>
                    <h3 style="font-family:'Fredoka One',cursive;font-size:1.1rem;color:#0288D1;">1. Regístrate</h3>
                    <p class="text-muted small">Crea tu cuenta gratis en segundos</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="how-card fade-up delay-2">
                    <div class="how-icon" aria-hidden="true"><i class="fas fa-book-reader"></i></div>
                    <h3 style="font-family:'Fredoka One',cursive;font-size:1.1rem;color:#0288D1;">2. Elige</h3>
                    <p class="text-muted small">Selecciona una categoría de tu interés</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="how-card fade-up delay-3">
                    <div class="how-icon" aria-hidden="true"><i class="fas fa-headphones"></i></div>
                    <h3 style="font-family:'Fredoka One',cursive;font-size:1.1rem;color:#0288D1;">3. Escucha</h3>
                    <p class="text-muted small">Aprende la pronunciación correcta</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="how-card fade-up delay-4">
                    <div class="how-icon" aria-hidden="true"><i class="fas fa-gamepad"></i></div>
                    <h3 style="font-family:'Fredoka One',cursive;font-size:1.1rem;color:#0288D1;">4. Practica</h3>
                    <p class="text-muted small">¡Pon a prueba lo que aprendiste con el quiz!</p>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ── VIDEO DEMO ─────────────────────────────────────────────────────────── -->
<section class="py-5" aria-labelledby="sec-video-titulo">
    <div class="container">
        <h2 class="section-title" id="sec-video-titulo">Watch &amp; Learn</h2>
        <p class="section-subtitle">Videos educativos para reforzar el aprendizaje</p>
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="video-wrapper fade-up">
                    <iframe
                        src="https://www.youtube.com/embed/tVlcKp3bWH8?rel=0"
                        title="Video educativo – English for Kids"
                        allowfullscreen
                        loading="lazy"
                        aria-label="Video de introducción a palabras en inglés para niños">
                    </iframe>
                </div>
            </div>
        </div>
    </div>
</section>

<!-- ── CTA ───────────────────────────────────────────────────────────────── -->
<section class="py-5" style="background:linear-gradient(135deg,#0288D1,#4FC3F7);" aria-labelledby="sec-cta-titulo">
    <div class="container text-center">
        <h2 class="hero-title mb-3" id="sec-cta-titulo">¡Únete a EnglishKids hoy! 🎓</h2>
        <p class="hero-subtitle mb-4">Aprende inglés de forma divertida e interactiva. ¡Es gratis!</p>
        <a href="${pageContext.request.contextPath}/registro.jsp"
           class="btn-primary-custom"
           aria-label="Registrarse ahora en EnglishKids">
            ✨ ¡Registrarse Gratis!
        </a>
    </div>
</section>

</main>

<!-- ── FOOTER ────────────────────────────────────────────────────────────── -->
<footer class="footer-section" role="contentinfo">
    <div class="container">
        <div class="row">
            <div class="col-md-4 mb-4">
                <div class="footer-logo mb-2"><img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:28px; border-radius:50%; vertical-align:middle; background:#fff; margin-right:6px;" alt="Logo de EnglishKids"> EnglishKids</div>
                <p class="small" style="color:rgba(255,255,255,0.6);">
                    Aplicación web educativa para enseñar inglés a niños.<br>
                    ODS 4: Educación de Calidad.
                </p>
            </div>
            <div class="col-md-4 mb-4">
                <h5 style="color:#fff;font-family:'Fredoka One',cursive;">Categorías</h5>
                <ul class="list-unstyled">
                    <li><a href="${pageContext.request.contextPath}/categorias/animals.jsp" class="footer-link">🐾 Animals</a></li>
                    <li><a href="${pageContext.request.contextPath}/categorias/colors.jsp"  class="footer-link">🎨 Colors</a></li>
                    <li><a href="${pageContext.request.contextPath}/categorias/numbers.jsp" class="footer-link">🔢 Numbers</a></li>
                </ul>
            </div>
            <div class="col-md-4 mb-4">
                <h5 style="color:#fff;font-family:'Fredoka One',cursive;">Acceso</h5>
                <ul class="list-unstyled">
                    <li><a href="${pageContext.request.contextPath}/login.jsp"    class="footer-link">Iniciar Sesión</a></li>
                    <li><a href="${pageContext.request.contextPath}/registro.jsp" class="footer-link">Registrarse</a></li>
                </ul>
            </div>
        </div>
        <div class="footer-copy text-center">
            &copy; 2026 EnglishKids – ODS 4 Educación de Calidad &nbsp;|&nbsp;
            Desarrollado con ❤️ para el aprendizaje infantil
        </div>
    </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- JS Personalizado -->
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
