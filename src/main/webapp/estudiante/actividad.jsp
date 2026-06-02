<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*, java.util.*" %>
<%
    // Verificar sesión
    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    Usuario u = (Usuario) ses.getAttribute("usuario");

    // Parámetros
    int    catId  = 1;
    String catNom = "Animals";
    try {
        catId  = Integer.parseInt(request.getParameter("categoria"));
        catNom = request.getParameter("nombre");
        if (catNom == null) catNom = "Animals";
    } catch (Exception e) {}

    // Cargar palabras de la categoría
    List<Palabra> palabras = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection();
         PreparedStatement ps = conn.prepareStatement(
             "SELECT * FROM palabras WHERE id_categoria = ? ORDER BY RANDOM() LIMIT 8")) {
        ps.setInt(1, catId);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Palabra p = new Palabra(rs.getInt("id"), catId,
                rs.getString("palabra_en"), rs.getString("palabra_es"),
                rs.getString("imagen_url"), rs.getString("audio_url"),
                rs.getString("modelo_3d"), rs.getString("nivel"));
            palabras.add(p);
        }
    } catch (Exception e) { e.printStackTrace(); }

    // Serializar palabras a JSON para el quiz JS
    StringBuilder jsonPalabras = new StringBuilder("[");
    for (int i = 0; i < palabras.size(); i++) {
        Palabra p = palabras.get(i);
        String imgUrl = p.getImagenUrl() != null ? p.getImagenUrl().replace("'", "\\'") : "";
        jsonPalabras.append("{")
            .append("\"id\":").append(p.getId()).append(",")
            .append("\"palabraEn\":\"").append(p.getPalabraEn()).append("\",")
            .append("\"palabraEs\":\"").append(p.getPalabraEs()).append("\",")
            .append("\"imagenUrl\":\"").append(imgUrl).append("\"")
            .append("}");
        if (i < palabras.size() - 1) jsonPalabras.append(",");
    }
    jsonPalabras.append("]");

    String[] catColors = {"","#FF7043","#7E57C2","#26A69A"};
    String   catColor  = (catId >= 1 && catId <= 3) ? catColors[catId] : "#0288D1";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Quiz de inglés – EnglishKids">
    <title>Quiz – <%= catNom %> – EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body style="background:linear-gradient(135deg,#E3F2FD,#F0F8FF);min-height:100vh;">

<a href="#quiz" class="skip-link">Saltar al quiz</a>

<nav class="navbar" role="navigation" aria-label="Navegación">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp">
            <img src="${pageContext.request.contextPath}/img/englishkids_logo.png" alt="Logo" class="brand-icon" style="background:transparent; padding:0; animation:none; border-radius:50%; box-shadow:0 4px 10px rgba(0,0,0,0.2);"> EnglishKids
        </a>
        <div class="d-flex align-items-center gap-3">
            <button id="btn-contraste" aria-label="Activar modo alto contraste">🌗 Alto Contraste</button>
            <a href="${pageContext.request.contextPath}/estudiante/dashboard.jsp"
               class="btn-outline-custom btn-sm"
               aria-label="Volver a mi panel">
               <i class="fas fa-arrow-left me-1" aria-hidden="true"></i> Mi Panel
            </a>
            <a href="${pageContext.request.contextPath}/logout"
               class="btn-outline-custom btn-sm"
               aria-label="Cerrar sesión">
               <i class="fas fa-sign-out-alt" aria-hidden="true"></i>
            </a>
        </div>
    </div>
</nav>

<main id="quiz">
<div class="container py-4">
    <div class="row justify-content-center">
        <div class="col-lg-7">

            <!-- Encabezado del Quiz -->
            <div class="text-center mb-4">
                <h1 style="font-family:'Fredoka One',cursive;font-size:2rem;color:<%= catColor %>;">
                    🎯 Quiz: <%= catNom %>
                </h1>
                <p class="text-muted">¿Cuál es la traducción correcta? | What is the correct translation?</p>
                <!-- Puntaje en tiempo real -->
                <div class="d-inline-flex align-items-center gap-3 px-4 py-2"
                     style="background:#fff;border-radius:20px;box-shadow:0 4px 12px rgba(0,0,0,0.08);">
                    <div>
                        <span class="fw-bold" style="color:#0288D1;">⭐ Puntos: </span>
                        <span id="quiz-score" style="font-family:'Fredoka One',cursive;font-size:1.3rem;color:#0288D1;">0</span>
                    </div>
                    <div style="height:24px;width:1px;background:#E0E0E0;"></div>
                    <div>
                        <span class="fw-bold" style="color:#546E7A;">Respondidas: </span>
                        <span id="quiz-total" style="font-family:'Fredoka One',cursive;font-size:1.3rem;color:#546E7A;">0</span>
                    </div>
                </div>
            </div>

            <!-- Cuerpo del Quiz -->
            <div id="quiz-body">
                <div class="quiz-card">
                    <!-- Imagen de la palabra -->
                    <img id="quiz-word-img"
                         src="${pageContext.request.contextPath}/images/placeholder.png"
                         alt="Imagen de la palabra a adivinar"
                         class="quiz-img">

                    <p class="text-muted small mb-3">
                        ¿Cómo se dice en inglés? | How do you say this in English?
                    </p>

                    <!-- Opciones del quiz -->
                    <div id="quiz-options" role="group" aria-label="Opciones de respuesta"></div>
                </div>
            </div>

            <!-- Pantalla Final -->
            <div id="quiz-final" style="display:none;">
                <div class="quiz-card">
                    <div style="font-size:4rem;margin-bottom:12px;" aria-hidden="true">🏆</div>
                    <h2 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.6rem;">
                        ¡Quiz Completado!
                    </h2>
                    <div class="quiz-score mt-3" aria-live="polite" aria-atomic="true">
                        <span id="final-score">0</span>
                    </div>
                    <p class="text-muted" style="font-size:1rem;">puntos totales</p>
                    <p id="final-msg" class="fw-bold fs-5 mt-2" aria-live="polite"></p>

                    <div class="d-flex gap-3 justify-content-center mt-4 flex-wrap">
                        <button onclick="location.reload()"
                                class="btn-primary-custom"
                                aria-label="Intentar el quiz nuevamente">
                            🔄 Intentar de Nuevo
                        </button>
                        <a href="${pageContext.request.contextPath}/estudiante/dashboard.jsp"
                           class="btn-outline-custom"
                           style="color:#0288D1;border-color:#0288D1;"
                           aria-label="Volver al panel del estudiante">
                            Mi Panel
                        </a>
                    </div>
                </div>
            </div>

        </div>
    </div>
</div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
    // Iniciar quiz con datos del servidor
    var palabrasData = <%= jsonPalabras.toString() %>;
    var contextPath  = '${pageContext.request.contextPath}';

    if (palabrasData.length > 0) {
        QuizApp.init(palabrasData, contextPath);
    } else {
        document.getElementById('quiz-body').innerHTML =
            '<div class="alert alert-warning text-center p-4">' +
            '⚠️ No hay palabras disponibles para esta categoría todavía.' +
            '</div>';
    }
</script>
</body>
</html>
