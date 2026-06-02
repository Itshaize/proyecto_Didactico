<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*, java.util.*" %>
<%
    // Verificar sesión de admin
    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    Usuario admin = (Usuario) ses.getAttribute("usuario");
    if (!admin.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/estudiante/dashboard.jsp"); return;
    }

    // Estadísticas generales
    int totalUsuarios = 0, totalEstudiantes = 0, totalBloqueados = 0, totalActividades = 0, pendientesRevision = 0;
    try (Connection conn = DBConnection.getConnection()) {
        ResultSet rs;

        rs = conn.createStatement().executeQuery(
            "SELECT COUNT(*) FROM usuarios WHERE perfil='estudiante'");
        if (rs.next()) totalEstudiantes = rs.getInt(1);
        rs.close();

        rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM usuarios");
        if (rs.next()) totalUsuarios = rs.getInt(1);
        rs.close();

        rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM usuarios WHERE activo=false");
        if (rs.next()) totalBloqueados = rs.getInt(1);
        rs.close();

        rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM actividades");
        if (rs.next()) totalActividades = rs.getInt(1);
        rs.close();

        rs = conn.createStatement().executeQuery("SELECT COUNT(*) FROM actividades WHERE revisado=false");
        if (rs.next()) pendientesRevision = rs.getInt(1);
        rs.close();
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Panel de Administración – EnglishKids">
    <title>Admin Dashboard – EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css?v=2">
</head>
<body>

<a href="#contenido" class="skip-link">Saltar al panel de administración</a>

<div class="d-flex" style="min-height:100vh;">

    <!-- Sidebar -->
    <nav class="admin-sidebar d-flex flex-column" style="width:240px;min-width:240px;"
         aria-label="Menú de administración">
        <div class="px-4 py-3">
            <div style="font-family:'Fredoka One',cursive;color:#fff;font-size:1.4rem;margin-bottom:4px;">
                <img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:32px; border-radius:50%; background:#fff; padding:2px; vertical-align:middle; margin-right:6px;" alt=""> EnglishKids
            </div>
            <div style="color:rgba(255,255,255,0.6);font-size:0.8rem;">Panel Administrador</div>
        </div>
        <hr style="border-color:rgba(255,255,255,0.15);margin:0;">
        <div class="p-3 flex-grow-1">
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/admin/dashboard.jsp"
                       aria-current="page">
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
                        <i class="fas fa-list-alt me-2" aria-hidden="true"></i> Bitácora
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/actividades.jsp">
                        <i class="fas fa-clipboard-check me-2" aria-hidden="true"></i> Actividades
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">
                        <i class="fas fa-globe me-2" aria-hidden="true"></i> Ver Sitio
                    </a>
                </li>
            </ul>
        </div>
        <div class="p-3 border-top" style="border-color:rgba(255,255,255,0.15)!important;">
            <div class="d-flex align-items-center gap-2 mb-2">
                <div style="width:36px;height:36px;background:rgba(255,255,255,0.2);border-radius:50%;
                            display:flex;align-items:center;justify-content:center;font-weight:700;color:#fff;">
                    <%= admin.getNombre().charAt(0) %>
                </div>
                <div>
                    <div style="color:#fff;font-size:0.85rem;font-weight:700;"><%= admin.getNombre() %></div>
                    <div style="color:rgba(255,255,255,0.6);font-size:0.72rem;">Administrador</div>
                </div>
            </div>
            <a href="${pageContext.request.contextPath}/logout"
               class="btn btn-outline-light btn-sm w-100"
               style="border-radius:8px;"
               aria-label="Cerrar sesión de administrador">
               <i class="fas fa-sign-out-alt me-1" aria-hidden="true"></i> Salir
            </a>
        </div>
    </nav>

    <!-- Contenido Principal -->
    <main id="contenido" class="admin-content flex-grow-1">
        <!-- Encabezado -->
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
            <div>
                <h1 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.8rem;margin:0;">
                    Dashboard Administrativo
                </h1>
                <p class="text-muted small mb-0">Resumen del sistema EnglishKids</p>
            </div>
            <button id="btn-contraste" aria-label="Activar modo alto contraste">🌗 Alto Contraste</button>
        </div>

        <!-- Tarjetas de Estadísticas -->
        <div class="row g-3 mb-4">
            <div class="col-sm-6 col-xl-3">
                <div class="stats-card" style="border-left:4px solid #0288D1;">
                    <div class="stats-number" style="color:#0288D1;">
                        <%= totalUsuarios %>
                    </div>
                    <div class="stats-label">Total Usuarios</div>
                    <i class="fas fa-users" style="color:#E3F2FD;font-size:2rem;position:absolute;right:20px;top:20px;" aria-hidden="true"></i>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="stats-card" style="border-left:4px solid #43A047;">
                    <div class="stats-number" style="color:#43A047;">
                        <%= totalEstudiantes %>
                    </div>
                    <div class="stats-label">Estudiantes</div>
                    <i class="fas fa-graduation-cap" style="color:#E8F5E9;font-size:2rem;position:absolute;right:20px;top:20px;" aria-hidden="true"></i>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="stats-card" style="border-left:4px solid #EF5350;">
                    <div class="stats-number" style="color:#EF5350;">
                        <%= totalBloqueados %>
                    </div>
                    <div class="stats-label">Bloqueados</div>
                    <i class="fas fa-user-lock" style="color:#FFEBEE;font-size:2rem;position:absolute;right:20px;top:20px;" aria-hidden="true"></i>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="stats-card" style="border-left:4px solid #FF7043;">
                    <div class="stats-number" style="color:#FF7043;">
                        <%= totalActividades %>
                    </div>
                    <div class="stats-label">Actividades</div>
                    <i class="fas fa-list-check" style="color:#FBE9E7;font-size:2rem;position:absolute;right:20px;top:20px;" aria-hidden="true"></i>
                </div>
            </div>
            <div class="col-sm-6 col-xl-3">
                <div class="stats-card" style="border-left:4px solid #7E57C2;">
                    <div class="stats-number" style="color:#7E57C2;">
                        <%= pendientesRevision %>
                    </div>
                    <div class="stats-label">Pendientes Revisión</div>
                    <i class="fas fa-clipboard-check" style="color:#F3E5F5;font-size:2rem;position:absolute;right:20px;top:20px;" aria-hidden="true"></i>
                </div>
            </div>
        </div>

        <!-- Acciones Rápidas -->
        <h2 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.2rem;" class="mb-3">
            ⚡ Acciones Rápidas
        </h2>
        <div class="row g-3">
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/admin/usuarios.jsp"
                   class="d-block p-4 text-decoration-none"
                   style="background:#fff;border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,0.08);
                          transition:all 0.3s ease;border:2px solid transparent;"
                   onmouseover="this.style.borderColor='#0288D1'"
                   onmouseout="this.style.borderColor='transparent'"
                   aria-label="Gestionar usuarios del sistema">
                    <div style="font-size:2.5rem;margin-bottom:12px;" aria-hidden="true">👥</div>
                    <h3 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.1rem;">Gestionar Usuarios</h3>
                    <p class="text-muted small mb-0">Ver, agregar, editar y bloquear usuarios</p>
                </a>
            </div>
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/admin/bitacora.jsp"
                   class="d-block p-4 text-decoration-none"
                   style="background:#fff;border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,0.08);
                          transition:all 0.3s ease;border:2px solid transparent;"
                   onmouseover="this.style.borderColor='#7E57C2'"
                   onmouseout="this.style.borderColor='transparent'"
                   aria-label="Ver bitácora del sistema">
                    <div style="font-size:2.5rem;margin-bottom:12px;" aria-hidden="true">📋</div>
                    <h3 style="font-family:'Fredoka One',cursive;color:#7E57C2;font-size:1.1rem;">Ver Bitácora</h3>
                    <p class="text-muted small mb-0">Registro completo de actividades del sistema</p>
                </a>
            </div>
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/admin/actividades.jsp"
                   class="d-block p-4 text-decoration-none"
                   style="background:#fff;border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,0.08);
                          transition:all 0.3s ease;border:2px solid transparent;"
                   onmouseover="this.style.borderColor='#FF7043'"
                   onmouseout="this.style.borderColor='transparent'"
                   aria-label="Revisar actividades de estudiantes">
                    <div style="font-size:2.5rem;margin-bottom:12px;" aria-hidden="true">✅</div>
                    <h3 style="font-family:'Fredoka One',cursive;color:#FF7043;font-size:1.1rem;">Revisar Actividades</h3>
                    <p class="text-muted small mb-0">Aprobar y revisar información registrada por estudiantes</p>
                </a>
            </div>
            <div class="col-md-4">
                <a href="${pageContext.request.contextPath}/index.jsp"
                   class="d-block p-4 text-decoration-none"
                   style="background:#fff;border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,0.08);
                          transition:all 0.3s ease;border:2px solid transparent;"
                   onmouseover="this.style.borderColor='#26A69A'"
                   onmouseout="this.style.borderColor='transparent'"
                   aria-label="Ver el sitio web público">
                    <div style="font-size:2.5rem;margin-bottom:12px;" aria-hidden="true">🌐</div>
                    <h3 style="font-family:'Fredoka One',cursive;color:#26A69A;font-size:1.1rem;">Ver Sitio Web</h3>
                    <p class="text-muted small mb-0">Vista pública del sitio EnglishKids</p>
                </a>
            </div>
        </div>
    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
