<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*, java.util.*" %>
<%
    // Verificar sesión admin
    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    Usuario admin = (Usuario) ses.getAttribute("usuario");
    if (!admin.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/estudiante/dashboard.jsp"); return;
    }

    // Filtros
    String filtroAccion = request.getParameter("accion");
    String filtroFecha  = request.getParameter("fecha");
    if (filtroAccion == null) filtroAccion = "";
    if (filtroFecha  == null) filtroFecha  = "";

    // Paginación
    int paginaActual = 1;
    int pageSize = 25;
    try { paginaActual = Integer.parseInt(request.getParameter("page")); } catch(Exception e) {}
    if (paginaActual < 1) paginaActual = 1;
    int offset = (paginaActual - 1) * pageSize;

    List<Bitacora> bitacoras = new ArrayList<>();
    int totalReg = 0;

    try (Connection conn = DBConnection.getConnection()) {
        StringBuilder where = new StringBuilder("WHERE 1=1 ");
        if (!filtroAccion.isEmpty()) where.append("AND b.accion ILIKE ? ");
        if (!filtroFecha.isEmpty())  where.append("AND DATE(b.fecha) = ? ");

        // Contar total
        String countSql = "SELECT COUNT(*) FROM bitacora b " + where;
        PreparedStatement psCount = conn.prepareStatement(countSql);
        int pi = 1;
        if (!filtroAccion.isEmpty()) psCount.setString(pi++, "%" + filtroAccion + "%");
        if (!filtroFecha.isEmpty())  psCount.setString(pi++, filtroFecha);
        ResultSet rsC = psCount.executeQuery();
        if (rsC.next()) totalReg = rsC.getInt(1);
        rsC.close(); psCount.close();

        // Datos con JOIN
        String sql = "SELECT b.*, COALESCE(u.nombre || ' ' || u.apellido, 'Sistema') as nombre_usuario, " +
                     "COALESCE(u.correo, '-') as correo_usuario " +
                     "FROM bitacora b LEFT JOIN usuarios u ON b.id_usuario = u.id " +
                     where + " ORDER BY b.fecha DESC LIMIT ? OFFSET ?";
        PreparedStatement ps = conn.prepareStatement(sql);
        pi = 1;
        if (!filtroAccion.isEmpty()) ps.setString(pi++, "%" + filtroAccion + "%");
        if (!filtroFecha.isEmpty())  ps.setString(pi++, filtroFecha);
        ps.setInt(pi++, pageSize);
        ps.setInt(pi,   offset);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Bitacora b = new Bitacora();
            b.setId(rs.getInt("id"));
            b.setNombreUsuario(rs.getString("nombre_usuario"));
            b.setCorreoUsuario(rs.getString("correo_usuario"));
            b.setAccion(rs.getString("accion"));
            b.setDetalle(rs.getString("detalle"));
            b.setIp(rs.getString("ip"));
            b.setFecha(rs.getTimestamp("fecha"));
            bitacoras.add(b);
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); }

    int totalPages = (int) Math.ceil((double) totalReg / pageSize);
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Bitácora del Sistema – Admin EnglishKids">
    <title>Bitácora – Admin EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <style>
        .badge-accion { border-radius: 8px; font-size: 0.75rem; padding: 4px 8px; font-weight: 700; }
        .accion-login    { background: #E8F5E9; color: #2E7D32; }
        .accion-logout   { background: #E3F2FD; color: #1565C0; }
        .accion-registro { background: #F3E5F5; color: #6A1B9A; }
        .accion-admin    { background: #FFF3E0; color: #E65100; }
        .accion-error    { background: #FFEBEE; color: #C62828; }
        .accion-categoria{ background: #E0F2F1; color: #004D40; }
        .accion-quiz     { background: #FFF8E1; color: #F57F17; }
        .accion-default  { background: #ECEFF1; color: #455A64; }
    </style>
</head>
<body>

<a href="#contenido" class="skip-link">Saltar a la bitácora del sistema</a>

<div class="d-flex" style="min-height:100vh;">

    <!-- Sidebar -->
    <nav class="admin-sidebar d-flex flex-column" style="width:240px;min-width:240px;"
         aria-label="Menú de administración">
        <div class="px-4 py-3">
            <div style="font-family:'Fredoka One',cursive;color:#fff;font-size:1.4rem;"><img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:32px; border-radius:50%; background:#fff; padding:2px; vertical-align:middle; margin-right:6px;" alt=""> EnglishKids</div>
            <div style="color:rgba(255,255,255,0.6);font-size:0.8rem;">Panel Administrador</div>
        </div>
        <hr style="border-color:rgba(255,255,255,0.15);margin:0;">
        <div class="p-3 flex-grow-1">
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard.jsp">
                        <i class="fas fa-tachometer-alt me-2"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/usuarios.jsp">
                        <i class="fas fa-users me-2"></i> Usuarios
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link active" href="${pageContext.request.contextPath}/admin/bitacora.jsp" aria-current="page">
                        <i class="fas fa-list-alt me-2"></i> Bitácora
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/index.jsp">
                        <i class="fas fa-globe me-2"></i> Ver Sitio
                    </a>
                </li>
            </ul>
        </div>
        <div class="p-3 border-top" style="border-color:rgba(255,255,255,0.15)!important;">
            <a href="${pageContext.request.contextPath}/logout"
               class="btn btn-outline-light btn-sm w-100"
               style="border-radius:8px;"
               aria-label="Cerrar sesión">
               <i class="fas fa-sign-out-alt me-1"></i> Salir
            </a>
        </div>
    </nav>

    <!-- Contenido -->
    <main id="contenido" class="admin-content flex-grow-1">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
            <div>
                <h1 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.8rem;margin:0;">
                    📋 Bitácora del Sistema
                </h1>
                <p class="text-muted small mb-0">
                    <%= totalReg %> registro(s) encontrado(s) · Página <%= paginaActual %> de <%= Math.max(1, totalPages) %>
                </p>
            </div>
            <button id="btn-contraste" aria-label="Activar modo alto contraste">🌗 Alto Contraste</button>
        </div>

        <!-- Filtros -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/bitacora.jsp"
              class="card mb-4 p-3" style="border:none;border-radius:16px;box-shadow:0 4px 20px rgba(0,0,0,0.06);"
              role="search" aria-label="Filtros de bitácora">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label class="form-label fw-bold small" for="filtro-accion">
                        <i class="fas fa-filter me-1" aria-hidden="true"></i> Acción
                    </label>
                    <select id="filtro-accion" name="accion" class="form-control form-select"
                            aria-label="Filtrar por tipo de acción">
                        <option value="">-- Todas las acciones --</option>
                        <option value="LOGIN" <%= "LOGIN".equals(filtroAccion) ? "selected" : "" %>>Login</option>
                        <option value="LOGOUT" <%= "LOGOUT".equals(filtroAccion) ? "selected" : "" %>>Logout</option>
                        <option value="REGISTRO" <%= "REGISTRO".equals(filtroAccion) ? "selected" : "" %>>Registro</option>
                        <option value="ADMIN" <%= filtroAccion.contains("ADMIN") ? "selected" : "" %>>Acciones Admin</option>
                        <option value="VER_CATEGORIA" <%= "VER_CATEGORIA".equals(filtroAccion) ? "selected" : "" %>>Ver Categoría</option>
                        <option value="ACTIVIDAD" <%= filtroAccion.contains("ACTIVIDAD") ? "selected" : "" %>>Quiz/Actividad</option>
                        <option value="BLOQUEADO" <%= filtroAccion.contains("BLOQUEADO") ? "selected" : "" %>>Login Bloqueado</option>
                    </select>
                </div>
                <div class="col-md-4">
                    <label class="form-label fw-bold small" for="filtro-fecha">
                        <i class="fas fa-calendar me-1" aria-hidden="true"></i> Fecha
                    </label>
                    <input type="date" id="filtro-fecha" name="fecha" class="form-control"
                           value="<%= filtroFecha %>"
                           aria-label="Filtrar por fecha específica">
                </div>
                <div class="col-md-4 d-flex gap-2">
                    <button type="submit" class="btn btn-primary" style="border-radius:10px;flex:1;"
                            aria-label="Aplicar filtros">
                        <i class="fas fa-filter me-1" aria-hidden="true"></i> Filtrar
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/bitacora.jsp"
                       class="btn btn-outline-secondary" style="border-radius:10px;"
                       aria-label="Limpiar filtros">
                        <i class="fas fa-times" aria-hidden="true"></i>
                    </a>
                </div>
            </div>
        </form>

        <!-- Tabla Bitácora -->
        <div class="table-responsive">
            <table class="table table-custom" aria-label="Registro de actividades del sistema">
                <thead>
                    <tr>
                        <th scope="col">#</th>
                        <th scope="col">Usuario</th>
                        <th scope="col">Acción</th>
                        <th scope="col">Detalle</th>
                        <th scope="col">IP</th>
                        <th scope="col">Fecha y Hora</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (bitacoras.isEmpty()) { %>
                    <tr>
                        <td colspan="6" class="text-center text-muted py-4">
                            No se encontraron registros con los filtros seleccionados
                        </td>
                    </tr>
                    <% } %>
                    <% for (Bitacora b : bitacoras) {
                        String accion    = b.getAccion() != null ? b.getAccion() : "";
                        String badgeCls  = "accion-default";
                        if (accion.contains("LOGIN_EXITOSO") || accion.contains("LOGIN") && !accion.contains("FALLO") && !accion.contains("BLOQUEADO"))
                            badgeCls = "accion-login";
                        else if (accion.contains("LOGOUT"))    badgeCls = "accion-logout";
                        else if (accion.contains("REGISTRO"))  badgeCls = "accion-registro";
                        else if (accion.contains("ADMIN"))     badgeCls = "accion-admin";
                        else if (accion.contains("BLOQUEADO") || accion.contains("FALLO")) badgeCls = "accion-error";
                        else if (accion.contains("CATEGORIA")) badgeCls = "accion-categoria";
                        else if (accion.contains("ACTIVIDAD") || accion.contains("QUIZ")) badgeCls = "accion-quiz";
                    %>
                    <tr>
                        <td class="text-muted small"><%= b.getId() %></td>
                        <td>
                            <div class="fw-bold small"><%= b.getNombreUsuario() %></div>
                            <div class="text-muted" style="font-size:0.75rem;"><%= b.getCorreoUsuario() %></div>
                        </td>
                        <td>
                            <span class="badge-accion <%= badgeCls %>"
                                  aria-label="Tipo de acción: <%= accion %>">
                                <%= accion.replace("_", " ") %>
                            </span>
                        </td>
                        <td class="small text-muted" style="max-width:220px;word-break:break-word;">
                            <%= b.getDetalle() != null ? b.getDetalle() : "-" %>
                        </td>
                        <td class="small text-muted font-monospace"><%= b.getIp() != null ? b.getIp() : "-" %></td>
                        <td class="small text-muted">
                            <%= b.getFecha() != null ? b.getFecha().toString().substring(0, 19) : "-" %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

        <!-- Paginación -->
        <% if (totalPages > 1) { %>
        <nav aria-label="Paginación de la bitácora" class="mt-3">
            <ul class="pagination justify-content-center">
                <li class="page-item <%= paginaActual <= 1 ? "disabled" : "" %>">
                    <a class="page-link" style="border-radius:8px 0 0 8px;"
                       href="?page=<%= paginaActual-1 %>&accion=<%= filtroAccion %>&fecha=<%= filtroFecha %>"
                       aria-label="Página anterior">
                        <i class="fas fa-chevron-left" aria-hidden="true"></i>
                    </a>
                </li>
                <% for (int p2 = Math.max(1, paginaActual-2); p2 <= Math.min(totalPages, paginaActual+2); p2++) { %>
                <li class="page-item <%= p2 == paginaActual ? "active" : "" %>">
                    <a class="page-link"
                       href="?page=<%= p2 %>&accion=<%= filtroAccion %>&fecha=<%= filtroFecha %>"
                       aria-label="Ir a página <%= p2 %>"
                       <%= p2 == paginaActual ? "aria-current='page'" : "" %>>
                        <%= p2 %>
                    </a>
                </li>
                <% } %>
                <li class="page-item <%= paginaActual >= totalPages ? "disabled" : "" %>">
                    <a class="page-link" style="border-radius:0 8px 8px 0;"
                       href="?page=<%= paginaActual+1 %>&accion=<%= filtroAccion %>&fecha=<%= filtroFecha %>"
                       aria-label="Página siguiente">
                        <i class="fas fa-chevron-right" aria-hidden="true"></i>
                    </a>
                </li>
            </ul>
        </nav>
        <% } %>

    </main>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>
