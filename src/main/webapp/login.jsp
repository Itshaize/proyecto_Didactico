<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // Si ya está autenticado, redirigir
    if (session != null && session.getAttribute("usuario") != null) {
        com.englishkids.model.Usuario u = (com.englishkids.model.Usuario) session.getAttribute("usuario");
        if (u.isAdmin())      response.sendRedirect(request.getContextPath() + "/admin/dashboard.jsp");
        else                  response.sendRedirect(request.getContextPath() + "/estudiante/dashboard.jsp");
        return;
    }
    String error  = (String) request.getAttribute("error");
    String exito  = (String) request.getAttribute("exito");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Iniciar sesión en EnglishKids – aprende inglés en línea">
    <title>Iniciar Sesión – EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body style="background:linear-gradient(135deg,#E3F2FD 0%,#F0F8FF 100%);min-height:100vh;">

<a href="#form-login" class="skip-link">Saltar al formulario de inicio de sesión</a>

<!-- Navbar simple -->
<nav class="navbar" role="navigation" aria-label="Navegación">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp" aria-label="Volver al inicio">
            <img src="${pageContext.request.contextPath}/img/englishkids_logo.png" alt="Logo" class="brand-icon" style="background:transparent; padding:0; animation:none; border-radius:50%; box-shadow:0 4px 10px rgba(0,0,0,0.2);">
            EnglishKids
        </a>
        <button id="btn-contraste" aria-label="Activar modo alto contraste">🌗 Alto Contraste</button>
    </div>
</nav>

<main id="form-login">
<div class="container">
    <div class="auth-card">
        <!-- Icono -->
        <div class="auth-icon" aria-hidden="true">
            <i class="fas fa-user-circle"></i>
        </div>

        <h1 class="auth-title">¡Bienvenido!</h1>
        <p class="text-center text-muted mb-4" style="font-size:0.95rem;">
            Ingresa tus datos para comenzar a aprender
        </p>

        <!-- Alertas -->
        <% if (error != null && !error.isEmpty()) { %>
        <div class="alert-custom-error" role="alert" aria-live="assertive">
            <i class="fas fa-exclamation-circle" aria-hidden="true"></i>
            <%= error %>
        </div>
        <% } %>
        <% if (exito != null && !exito.isEmpty()) { %>
        <div class="alert-custom-success" role="alert" aria-live="polite">
            <i class="fas fa-check-circle" aria-hidden="true"></i>
            <%= exito %>
        </div>
        <% } %>

        <!-- Formulario -->
        <form action="${pageContext.request.contextPath}/login" method="POST"
              aria-label="Formulario de inicio de sesión" novalidate>

            <div class="mb-3">
                <label class="form-label" for="correo">
                    <i class="fas fa-envelope me-1" aria-hidden="true"></i>
                    Correo Electrónico
                </label>
                <input type="email" id="correo" name="correo"
                       class="form-control"
                       placeholder="tu@correo.com"
                       required
                       autocomplete="email"
                       aria-required="true"
                       aria-describedby="correo-hint">
                <div id="correo-hint" class="form-text">Ingresa el correo con el que te registraste</div>
            </div>

            <div class="mb-4">
                <label class="form-label" for="clave">
                    <i class="fas fa-lock me-1" aria-hidden="true"></i>
                    Contraseña
                </label>
                <div class="input-group">
                    <input type="password" id="clave" name="clave"
                           class="form-control"
                           placeholder="Mínimo 8 caracteres"
                           required
                           minlength="8"
                           autocomplete="current-password"
                           aria-required="true">
                    <button class="btn btn-outline-secondary" type="button" id="togglePwd"
                            aria-label="Mostrar u ocultar contraseña"
                            aria-pressed="false">
                        <i class="fas fa-eye" id="eye-icon" aria-hidden="true"></i>
                    </button>
                </div>
            </div>

            <button type="submit" class="btn-primary-custom w-100 text-center"
                    id="btn-login"
                    aria-label="Iniciar sesión en EnglishKids">
                <i class="fas fa-sign-in-alt me-2" aria-hidden="true"></i>
                Iniciar Sesión
            </button>
        </form>

        <hr class="my-4">
        <p class="text-center text-muted" style="font-size:0.9rem;">
            ¿Aún no tienes cuenta?
            <a href="${pageContext.request.contextPath}/registro.jsp"
               style="color:#0288D1;font-weight:700;text-decoration:none;">
                ¡Regístrate gratis!
            </a>
        </p>
        <p class="text-center">
            <a href="${pageContext.request.contextPath}/index.jsp"
               style="color:#546E7A;font-size:0.88rem;text-decoration:none;">
                <i class="fas fa-arrow-left me-1" aria-hidden="true"></i>
                Volver al inicio
            </a>
        </p>

        <!-- Credenciales de demo -->
        <div class="mt-3 p-3" style="background:#EEF7FF;border-radius:12px;font-size:0.85rem;">
            <strong>🔑 Cuentas de demostración:</strong>
            <div class="d-flex gap-2 mt-2 flex-wrap">
                <button type="button" onclick="fillDemo('admin@englishkids.edu','Admin1234')"
                        class="btn btn-sm btn-outline-primary flex-fill" aria-label="Usar cuenta admin demo">
                    👑 Admin Demo
                </button>
                <button type="button" onclick="fillDemo('estudiante@englishkids.edu','Estudia1234')"
                        class="btn btn-sm btn-outline-success flex-fill" aria-label="Usar cuenta estudiante demo">
                    🎓 Estudiante Demo
                </button>
            </div>
        </div>
    </div>
</div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
    // Toggle mostrar/ocultar contraseña
    document.getElementById('togglePwd').addEventListener('click', function () {
        var inp  = document.getElementById('clave');
        var icon = document.getElementById('eye-icon');
        var show = inp.type === 'password';
        inp.type = show ? 'text' : 'password';
        icon.className = show ? 'fas fa-eye-slash' : 'fas fa-eye';
        this.setAttribute('aria-pressed', show.toString());
        this.setAttribute('aria-label', show ? 'Ocultar contraseña' : 'Mostrar contraseña');
    });

    // Validación del formulario en cliente
    document.querySelector('form').addEventListener('submit', function (e) {
        var correo = document.getElementById('correo').value.trim();
        var clave  = document.getElementById('clave').value;
        if (!correo || !clave) {
            e.preventDefault();
            alert('Por favor completa todos los campos.');
        }
    });

    // Autocompletar cuentas demo
    function fillDemo(correo, clave) {
        document.getElementById('correo').value = correo;
        document.getElementById('clave').value  = clave;
        document.querySelector('form').submit();
    }

</script>
</body>
</html>
