<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*" %>
<%
    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }

    Usuario admin = (Usuario) ses.getAttribute("usuario");
    if (!admin.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/estudiante/dashboard.jsp");
        return;
    }

    int totalUsuarios = 0;
    int totalEstudiantes = 0;
    int totalBloqueados = 0;

    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM usuarios");
        if (rs.next()) totalUsuarios = rs.getInt(1);
        rs.close();

        rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM usuarios WHERE perfil='estudiante'");
        if (rs.next()) totalEstudiantes = rs.getInt(1);
        rs.close();

        rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM usuarios WHERE activo=false");
        if (rs.next()) totalBloqueados = rs.getInt(1);
        rs.close();
    } catch (Exception e) {
        e.printStackTrace();
    }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Panel de Administracion EnglishKids">
    <title>Admin Dashboard - EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css?v=dashboard4">
</head>
<body>

<a href="#contenido" class="skip-link">Saltar al panel de administracion</a>

<div class="d-flex" style="min-height:100vh;">
    <nav class="admin-sidebar d-flex flex-column" style="width:240px;min-width:240px;" aria-label="Menu de administracion">
        <div class="px-4 py-3">
            <div style="font-family:'Fredoka One',cursive;color:#fff;font-size:1.4rem;margin-bottom:4px;">
                <img src="${pageContext.request.contextPath}/img/englishkids_logo.png"
                     style="height:32px;border-radius:50%;background:#fff;padding:2px;vertical-align:middle;margin-right:6px;"
                     alt="Logo de EnglishKids">
                EnglishKids
            </div>
            <div style="color:#fff;font-size:1rem;">Panel Administrador</div>
        </div>

        <hr style="border-color:rgba(255,255,255,0.25);margin:0;">

        <div class="p-3 flex-grow-1">
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/admin/dashboard.jsp" aria-current="page">
                        <i class="fas fa-tachometer-alt me-2" aria-hidden="true"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/usuarios.jsp">
                        <i class="fas fa-users me-2" aria-hidden="true"></i> Usuarios
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/bitacora.jsp">
                        <i class="fas fa-list-alt me-2" aria-hidden="true"></i> Bitacora
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">
                        <i class="fas fa-globe me-2" aria-hidden="true"></i> Ver Sitio
                    </a>
                </li>
            </ul>
        </div>

        <div class="p-3 border-top" style="border-color:rgba(255,255,255,0.25)!important;">
            <div class="d-flex align-items-center gap-2 mb-2">
                <div style="width:36px;height:36px;background:rgba(255,255,255,0.2);border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:700;color:#fff;">
                    <%= admin.getNombre().charAt(0) %>
                </div>
                <div>
                    <div style="color:#fff;font-size:1rem;font-weight:700;"><%= admin.getNombre() %></div>
                    <div style="color:#fff;font-size:0.95rem;">Administrador</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout"
               class="btn btn-outline-light btn-sm w-100"
               style="border-radius:8px;"
               aria-label="Cerrar sesion de administrador">
                <i class="fas fa-sign-out-alt me-1" aria-hidden="true"></i> Salir
            </a>
        </div>
    </nav>

    <main id="contenido" class="admin-content flex-grow-1">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
            <div>
                <h1 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.8rem;margin:0;">
                    Dashboard Administrativo
                </h1>
                <p class="text-muted small mb-0">Resumen del sistema EnglishKids</p>
            </div>
            <button id="btn-contraste" aria-label="Activar modo alto contraste">
                <i class="fas fa-adjust me-1" aria-hidden="true"></i> Alto Contraste
            </button>
        </div>

        <div class="row g-3 mb-4">
            <div class="col-md-4">
                <div class="stats-card dashboard-stat-card" style="border-left:4px solid #0288D1;">
                    <i class="fas fa-users dashboard-stat-icon" style="color:#D7EEFF;" aria-hidden="true"></i>
                    <div class="stats-number" style="color:#0288D1;"><%= totalUsuarios %></div>
                    <div class="stats-label">Total Usuarios</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stats-card dashboard-stat-card" style="border-left:4px solid #43A047;">
                    <i class="fas fa-graduation-cap dashboard-stat-icon" style="color:#DFF4E3;" aria-hidden="true"></i>
                    <div class="stats-number" style="color:#43A047;"><%= totalEstudiantes %></div>
                    <div class="stats-label">Estudiantes</div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="stats-card dashboard-stat-card" style="border-left:4px solid #EF5350;">
                    <i class="fas fa-user-lock dashboard-stat-icon" style="color:#FFE1E5;" aria-hidden="true"></i>
                    <div class="stats-number" style="color:#EF5350;"><%= totalBloqueados %></div>
                    <div class="stats-label">Bloqueados</div>
                </div>
            </div>
        </div>

        <h2 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.25rem;" class="mb-3">
            <i class="fas fa-bolt me-2" aria-hidden="true"></i> Acciones Rapidas
        </h2>

        <div class="row g-3">
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/admin/usuarios.jsp"
                   class="dashboard-action-card dashboard-action-users"
                   aria-label="Gestionar usuarios del sistema">
                    <span class="dashboard-action-icon" aria-hidden="true">
                        <i class="fas fa-users"></i>
                    </span>
                    <span class="dashboard-action-title">Gestionar Usuarios</span>
                    <span class="dashboard-action-text">Ver, agregar, editar y bloquear usuarios</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/admin/bitacora.jsp"
                   class="dashboard-action-card dashboard-action-log"
                   aria-label="Ver bitacora del sistema">
                    <span class="dashboard-action-icon" aria-hidden="true">
                        <i class="fas fa-clipboard-list"></i>
                    </span>
                    <span class="dashboard-action-title">Ver Bitacora</span>
                    <span class="dashboard-action-text">Registro completo de actividades del sistema</span>
                </a>
            </div>
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/index.jsp"
                   class="dashboard-action-card dashboard-action-site"
                   aria-label="Ver el sitio web publico">
                    <span class="dashboard-action-icon" aria-hidden="true">
                        <i class="fas fa-globe"></i>
                    </span>
                    <span class="dashboard-action-title">Ver Sitio Web</span>
                    <span class="dashboard-action-text">Vista publica del sitio EnglishKids</span>
                </a>
            </div>
        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
