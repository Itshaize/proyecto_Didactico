<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String error = (String) request.getAttribute("error");
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Regístrate en EnglishKids y comienza a aprender inglés gratis">
    <title>Registro – EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body style="background:linear-gradient(135deg,#E8F5E9 0%,#F0F8FF 100%);min-height:100vh;">

<a href="#form-registro" class="skip-link">Saltar al formulario de registro</a>

<nav class="navbar" role="navigation" aria-label="Navegación">
    <div class="container">
        <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp" aria-label="Volver al inicio">
            <img src="${pageContext.request.contextPath}/img/englishkids_logo.png" alt="Logo" class="brand-icon" style="background:transparent; padding:0; animation:none; border-radius:50%; box-shadow:0 4px 10px rgba(0,0,0,0.2);">
            EnglishKids
        </a>
        <button id="btn-contraste" aria-label="Activar modo alto contraste">🌗 Alto Contraste</button>
    </div>
</nav>

<main id="form-registro">
<div class="container">
    <div class="auth-card" style="max-width:520px;">

        <div class="auth-icon" style="background:linear-gradient(135deg,#81C784,#388E3C);" aria-hidden="true">
            <i class="fas fa-user-plus"></i>
        </div>

        <h1 class="auth-title">¡Únete a EnglishKids!</h1>
        <p class="text-center text-muted mb-4" style="font-size:0.95rem;">
            Crea tu cuenta gratis y empieza a aprender inglés
        </p>

        <% if (error != null && !error.isEmpty()) { %>
        <div class="alert-custom-error" role="alert" aria-live="assertive">
            <i class="fas fa-exclamation-circle" aria-hidden="true"></i>
            <%= error %>
        </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/registro" method="POST"
              id="form-reg"
              aria-label="Formulario de registro de nuevo usuario" novalidate>

            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label" for="nombre">
                        <i class="fas fa-user me-1" aria-hidden="true"></i> Nombre
                    </label>
                    <input type="text" id="nombre" name="nombre"
                           class="form-control" placeholder="Tu nombre"
                           required maxlength="100"
                           autocomplete="given-name"
                           aria-required="true">
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label" for="apellido">
                        <i class="fas fa-user me-1" aria-hidden="true"></i> Apellido
                    </label>
                    <input type="text" id="apellido" name="apellido"
                           class="form-control" placeholder="Tu apellido"
                           required maxlength="100"
                           autocomplete="family-name"
                           aria-required="true">
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="correo">
                    <i class="fas fa-envelope me-1" aria-hidden="true"></i> Correo Electrónico
                </label>
                <input type="email" id="correo" name="correo"
                       class="form-control" placeholder="tu@correo.com"
                       required maxlength="150"
                       autocomplete="email"
                       aria-required="true"
                       aria-describedby="correo-desc">
                <div id="correo-desc" class="form-text">
                    Debe ser un correo electrónico válido (ej: nombre@dominio.com)
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label" for="clave">
                    <i class="fas fa-lock me-1" aria-hidden="true"></i> Contraseña
                </label>
                <div class="input-group">
                    <input type="password" id="clave" name="clave"
                           class="form-control" placeholder="Mínimo 8 caracteres"
                           required minlength="8"
                           autocomplete="new-password"
                           aria-required="true"
                           aria-describedby="clave-desc"
                           oninput="checkStrength(this.value)">
                    <button class="btn btn-outline-secondary" type="button" id="togglePwd1"
                            aria-label="Mostrar u ocultar contraseña" aria-pressed="false">
                        <i class="fas fa-eye" id="eye1" aria-hidden="true"></i>
                    </button>
                </div>
                <!-- Medidor de fortaleza -->
                <div class="mt-2">
                    <div class="progress" style="height:6px;" role="progressbar"
                         aria-label="Fortaleza de contraseña" aria-valuenow="0" aria-valuemin="0" aria-valuemax="100">
                        <div id="pwd-bar" class="progress-bar" style="width:0%;"></div>
                    </div>
                    <small id="pwd-text" class="form-text" id="clave-desc"></small>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label" for="confirma">
                    <i class="fas fa-lock me-1" aria-hidden="true"></i> Confirmar Contraseña
                </label>
                <div class="input-group">
                    <input type="password" id="confirma" name="confirma"
                           class="form-control" placeholder="Repite tu contraseña"
                           required minlength="8"
                           autocomplete="new-password"
                           aria-required="true">
                    <button class="btn btn-outline-secondary" type="button" id="togglePwd2"
                            aria-label="Mostrar u ocultar confirmación" aria-pressed="false">
                        <i class="fas fa-eye" id="eye2" aria-hidden="true"></i>
                    </button>
                </div>
                <small id="match-msg" class="form-text"></small>
            </div>

            <button type="submit" class="btn-primary-custom w-100 text-center"
                    id="btn-registro"
                    aria-label="Crear cuenta en EnglishKids">
                <i class="fas fa-user-plus me-2" aria-hidden="true"></i>
                Crear Cuenta Gratis
            </button>
        </form>

        <hr class="my-4">
        <p class="text-center text-muted" style="font-size:0.9rem;">
            ¿Ya tienes cuenta?
            <a href="${pageContext.request.contextPath}/login.jsp"
               style="color:#0288D1;font-weight:700;text-decoration:none;">
                Iniciar Sesión
            </a>
        </p>
        <p class="text-center">
            <a href="${pageContext.request.contextPath}/index.jsp"
               style="color:#546E7A;font-size:0.88rem;text-decoration:none;">
                <i class="fas fa-arrow-left me-1" aria-hidden="true"></i> Volver al inicio
            </a>
        </p>
    </div>
</div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
    // Toggle contraseña 1
    document.getElementById('togglePwd1').addEventListener('click', function () {
        var inp = document.getElementById('clave');
        var eye = document.getElementById('eye1');
        var show = inp.type === 'password';
        inp.type = show ? 'text' : 'password';
        eye.className = show ? 'fas fa-eye-slash' : 'fas fa-eye';
        this.setAttribute('aria-pressed', show.toString());
    });

    // Toggle contraseña 2
    document.getElementById('togglePwd2').addEventListener('click', function () {
        var inp = document.getElementById('confirma');
        var eye = document.getElementById('eye2');
        var show = inp.type === 'password';
        inp.type = show ? 'text' : 'password';
        eye.className = show ? 'fas fa-eye-slash' : 'fas fa-eye';
        this.setAttribute('aria-pressed', show.toString());
    });

    // Medidor de fortaleza de contraseña
    function checkStrength(val) {
        var bar  = document.getElementById('pwd-bar');
        var txt  = document.getElementById('pwd-text');
        var prog = bar.closest('[role="progressbar"]');
        var score = 0;
        if (val.length >= 8)                score += 25;
        if (/[A-Z]/.test(val))              score += 25;
        if (/[0-9]/.test(val))              score += 25;
        if (/[^A-Za-z0-9]/.test(val))       score += 25;

        bar.style.width = score + '%';
        prog.setAttribute('aria-valuenow', score);

        if (score < 25)      { bar.style.background = '#EF5350'; txt.textContent = 'Muy débil'; txt.style.color='#C62828'; }
        else if (score < 50) { bar.style.background = '#FF7043'; txt.textContent = 'Débil';     txt.style.color='#BF360C'; }
        else if (score < 75) { bar.style.background = '#FFD54F'; txt.textContent = 'Regular';   txt.style.color='#F57F17'; }
        else if (score < 100){ bar.style.background = '#81C784'; txt.textContent = 'Fuerte';    txt.style.color='#2E7D32'; }
        else                 { bar.style.background = '#4CAF50'; txt.textContent = '¡Excelente!';txt.style.color='#1B5E20'; }
    }

    // Verificar coincidencia de contraseñas en tiempo real
    document.getElementById('confirma').addEventListener('input', function () {
        var c1  = document.getElementById('clave').value;
        var msg = document.getElementById('match-msg');
        if (this.value === c1 && c1.length >= 8) {
            msg.textContent = '✅ Las contraseñas coinciden';
            msg.style.color = '#2E7D32';
        } else {
            msg.textContent = '❌ Las contraseñas no coinciden';
            msg.style.color = '#C62828';
        }
    });

    // Validación final del formulario
    document.getElementById('form-reg').addEventListener('submit', function (e) {
        var nombre   = document.getElementById('nombre').value.trim();
        var apellido = document.getElementById('apellido').value.trim();
        var correo   = document.getElementById('correo').value.trim();
        var clave    = document.getElementById('clave').value;
        var confirma = document.getElementById('confirma').value;
        var emailReg = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

        if (!nombre || !apellido) {
            e.preventDefault(); alert('Por favor ingresa nombre y apellido.'); return;
        }
        if (!emailReg.test(correo)) {
            e.preventDefault(); alert('Por favor ingresa un correo electrónico válido.'); return;
        }
        if (clave.length < 8) {
            e.preventDefault(); alert('La contraseña debe tener mínimo 8 caracteres.'); return;
        }
        if (clave !== confirma) {
            e.preventDefault(); alert('Las contraseñas no coinciden.'); return;
        }
    });
</script>
</body>
</html>
