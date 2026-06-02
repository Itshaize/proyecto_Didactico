<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.englishkids.db.DBConnection, com.englishkids.model.*, java.sql.*, java.util.*" %>
<%
    HttpSession ses = request.getSession(false);
    if (ses == null || ses.getAttribute("usuario") == null) {
        response.sendRedirect(request.getContextPath() + "/login.jsp"); return;
    }
    Usuario admin = (Usuario) ses.getAttribute("usuario");
    if (!admin.isAdmin()) {
        response.sendRedirect(request.getContextPath() + "/estudiante/dashboard.jsp"); return;
    }

    String estado = request.getParameter("estado");
    if (estado == null) estado = "";
    String ok = request.getParameter("ok");

    List<Map<String,Object>> actividades = new ArrayList<>();
    int totalReg = 0;

    try (Connection conn = DBConnection.getConnection()) {
        String where = "";
        if ("pendientes".equals(estado)) where = "WHERE a.revisado=false ";
        if ("aprobadas".equals(estado)) where = "WHERE a.revisado=true AND a.aprobado=true ";
        if ("revision".equals(estado)) where = "WHERE a.revisado=true AND a.aprobado=false ";

        PreparedStatement psCount = conn.prepareStatement("SELECT COUNT(*) FROM actividades a " + where);
        ResultSet rc = psCount.executeQuery();
        if (rc.next()) totalReg = rc.getInt(1);
        rc.close(); psCount.close();

        String sql = "SELECT a.id, a.tipo, a.resultado, a.puntos, a.fecha, a.revisado, a.aprobado, " +
                     "a.observacion_revision, a.fecha_revision, u.nombre, u.apellido, u.correo, " +
                     "p.palabra_en, p.palabra_es, c.nombre AS categoria " +
                     "FROM actividades a JOIN usuarios u ON a.id_usuario=u.id " +
                     "LEFT JOIN palabras p ON a.id_palabra=p.id " +
                     "LEFT JOIN categorias c ON p.id_categoria=c.id " +
                     where + "ORDER BY a.fecha DESC LIMIT 100";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String,Object> row = new HashMap<>();
            row.put("id", rs.getInt("id"));
            row.put("estudiante", rs.getString("nombre") + " " + rs.getString("apellido"));
            row.put("correo", rs.getString("correo"));
            row.put("categoria", rs.getString("categoria"));
            row.put("palabra", rs.getString("palabra_en") + " / " + rs.getString("palabra_es"));
            row.put("tipo", rs.getString("tipo"));
            row.put("resultado", rs.getString("resultado"));
            row.put("puntos", rs.getInt("puntos"));
            row.put("fecha", rs.getTimestamp("fecha"));
            row.put("revisado", rs.getBoolean("revisado"));
            row.put("aprobado", rs.getObject("aprobado"));
            row.put("observacion", rs.getString("observacion_revision"));
            row.put("fechaRevision", rs.getTimestamp("fecha_revision"));
            actividades.add(row);
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Actividades - Admin EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
    <style>
        .review-form { min-width: 260px; }
        .review-form textarea { min-height: 42px; resize: vertical; }
    </style>
</head>
<body>
<a href="#contenido" class="skip-link">Saltar a revisión de actividades</a>
<div class="d-flex" style="min-height:100vh;">
    <nav class="admin-sidebar d-flex flex-column" style="width:240px;min-width:240px;" aria-label="Menú de administración">
        <div class="px-4 py-3">
            <div style="font-family:'Fredoka One',cursive;color:#fff;font-size:1.4rem;"><img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:32px; border-radius:50%; background:#fff; padding:2px; vertical-align:middle; margin-right:6px;" alt=""> EnglishKids</div>
            <div style="color:rgba(255,255,255,0.6);font-size:0.8rem;">Panel Administrador</div>
        </div>
        <hr style="border-color:rgba(255,255,255,0.15);margin:0;">
        <div class="p-3 flex-grow-1">
            <ul class="nav flex-column">
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i> Dashboard</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/usuarios.jsp"><i class="fas fa-users me-2"></i> Usuarios</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/admin/bitacora.jsp"><i class="fas fa-list-alt me-2"></i> Bitácora</a></li>
                <li class="nav-item"><a class="nav-link active" href="${pageContext.request.contextPath}/admin/actividades.jsp" aria-current="page"><i class="fas fa-clipboard-check me-2"></i> Actividades</a></li>
                <li class="nav-item"><a class="nav-link" href="${pageContext.request.contextPath}/index.jsp"><i class="fas fa-globe me-2"></i> Ver Sitio</a></li>
            </ul>
        </div>
        <div class="p-3 border-top" style="border-color:rgba(255,255,255,0.15)!important;">
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline-light btn-sm w-100" style="border-radius:8px;" aria-label="Cerrar sesión">
                <i class="fas fa-sign-out-alt me-1"></i> Salir
            </a>
        </div>
    </nav>

    <main id="contenido" class="admin-content flex-grow-1">
        <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
            <div>
                <h1 style="font-family:'Fredoka One',cursive;color:#0288D1;font-size:1.8rem;margin:0;">Revisión de Actividades</h1>
                <p class="text-muted small mb-0"><%= totalReg %> registro(s) encontrado(s)</p>
            </div>
            <button id="btn-contraste" aria-label="Activar modo alto contraste">🌗 Alto Contraste</button>
        </div>

        <% if (ok != null) { %>
        <div class="alert-custom-success mb-3" role="alert">Actividad revisada correctamente.</div>
        <% } %>

        <form method="GET" action="${pageContext.request.contextPath}/admin/actividades.jsp" class="mb-4" role="search">
            <div class="input-group" style="max-width:420px;">
                <select name="estado" class="form-control form-select" aria-label="Filtrar actividades">
                    <option value="" <%= estado.isEmpty() ? "selected" : "" %>>Todas</option>
                    <option value="pendientes" <%= "pendientes".equals(estado) ? "selected" : "" %>>Pendientes</option>
                    <option value="aprobadas" <%= "aprobadas".equals(estado) ? "selected" : "" %>>Aprobadas</option>
                    <option value="revision" <%= "revision".equals(estado) ? "selected" : "" %>>Para revisar</option>
                </select>
                <button class="btn btn-primary" type="submit" style="border-radius:0 12px 12px 0;">
                    <i class="fas fa-filter" aria-hidden="true"></i>
                </button>
            </div>
        </form>

        <div class="table-responsive">
            <table class="table table-custom" aria-label="Actividades registradas por estudiantes">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Estudiante</th>
                        <th>Actividad</th>
                        <th>Resultado</th>
                        <th>Estado</th>
                        <th>Acción admin</th>
                    </tr>
                </thead>
                <tbody>
                <% if (actividades.isEmpty()) { %>
                    <tr><td colspan="6" class="text-center text-muted py-4">No hay actividades para mostrar</td></tr>
                <% } %>
                <% for (Map<String,Object> a : actividades) {
                    boolean revisado = Boolean.TRUE.equals(a.get("revisado"));
                    Object aprobadoObj = a.get("aprobado");
                    String estadoTexto = !revisado ? "Pendiente" : (Boolean.TRUE.equals(aprobadoObj) ? "Aprobada" : "Para revisar");
                    String badge = !revisado ? "badge-bloqueado" : (Boolean.TRUE.equals(aprobadoObj) ? "badge-activo" : "badge-admin");
                %>
                    <tr>
                        <td><%= a.get("id") %></td>
                        <td>
                            <div class="fw-bold small"><%= a.get("estudiante") %></div>
                            <div class="text-muted" style="font-size:0.75rem;"><%= a.get("correo") %></div>
                        </td>
                        <td>
                            <div class="fw-bold small"><%= a.get("categoria") != null ? a.get("categoria") : "-" %></div>
                            <div class="text-muted small"><%= a.get("palabra") %></div>
                            <div class="text-muted" style="font-size:0.75rem;"><%= a.get("fecha") %></div>
                        </td>
                        <td>
                            <span class="badge <%= "correcto".equals(a.get("resultado")) ? "badge-activo" : "badge-bloqueado" %>"><%= a.get("resultado") %></span>
                            <div class="small text-muted mt-1"><%= a.get("puntos") %> puntos</div>
                        </td>
                        <td>
                            <span class="badge <%= badge %>"><%= estadoTexto %></span>
                            <% if (a.get("observacion") != null && !String.valueOf(a.get("observacion")).isEmpty()) { %>
                                <div class="small text-muted mt-1"><%= a.get("observacion") %></div>
                            <% } %>
                        </td>
                        <td>
                            <form method="POST" action="${pageContext.request.contextPath}/admin/accion" class="review-form">
                                <input type="hidden" name="action" value="revisar_actividad">
                                <input type="hidden" name="id" value="<%= a.get("id") %>">
                                <textarea name="observacion" class="form-control form-control-sm mb-2" placeholder="Observación opcional"></textarea>
                                <div class="d-flex gap-2">
                                    <button type="submit" name="decision" value="aprobar" class="btn btn-success btn-sm" style="border-radius:8px;">
                                        <i class="fas fa-check me-1"></i> Aprobar
                                    </button>
                                    <button type="submit" name="decision" value="revisar" class="btn btn-warning btn-sm" style="border-radius:8px;">
                                        <i class="fas fa-eye me-1"></i> Revisar
                                    </button>
                                </div>
                            </form>
                        </td>
                    </tr>
                <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
</body>
</html>

