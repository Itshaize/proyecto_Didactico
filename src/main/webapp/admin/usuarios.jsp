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

    String ok    = request.getParameter("ok");
    String err   = request.getParameter("error");

    // Buscar usuarios con filtro opcional
    String buscar = request.getParameter("buscar");
    if (buscar == null) buscar = "";

    List<Usuario> usuarios = new ArrayList<>();
    try (Connection conn = DBConnection.getConnection()) {
        String sql = "SELECT * FROM usuarios WHERE " +
            "(nombre ILIKE ? OR apellido ILIKE ? OR correo ILIKE ?) " +
            "ORDER BY fecha_registro DESC";
        PreparedStatement ps = conn.prepareStatement(sql);
        String q = "%" + buscar + "%";
        ps.setString(1, q); ps.setString(2, q); ps.setString(3, q);
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            usuarios.add(com.englishkids.servlet.LoginServlet.mapUsuario(rs));
        }
        rs.close(); ps.close();
    } catch (Exception e) { e.printStackTrace(); }
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Gestión de Usuarios – Admin EnglishKids">
    <title>Usuarios – Admin EnglishKids</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/estilos.css">
</head>
<body>

<a href="#contenido" class="skip-link">Saltar a la gestión de usuarios</a>

<div class="d-flex" style="min-height:100vh;">

    <!-- Sidebar -->
    <nav class="admin-sidebar d-flex flex-column" style="width:240px;min-width:240px;"
         aria-label="Menú de administración">
        <div class="px-4 py-3">
            <div style="font-family:'Fredoka One',cursive;color:#fff;font-size:1.4rem;"><img src="${pageContext.request.contextPath}/img/englishkids_logo.png" style="height:32px; border-radius:50%; background:#fff; padding:2px; vertical-align:middle; margin-right:6px;" alt="Logo de EnglishKids"> EnglishKids</div>
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
                    <a class="nav-link active" href="${pageContext.request.contextPath}/admin/usuarios.jsp" aria-current="page">
                        <i class="fas fa-users me-2"></i> Usuarios
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="${pageContext.request.contextPath}/admin/bitacora.jsp">
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
                    👥 Gestión de Usuarios
                </h1>
                <p class="text-muted small mb-0">
                    <%= usuarios.size() %> usuario(s) encontrado(s)
                </p>
            </div>
            <div class="d-flex gap-2">
                <button id="btn-contraste" aria-label="Activar modo alto contraste">🌗 Alto Contraste</button>
                <button class="btn btn-success btn-sm" data-bs-toggle="modal" data-bs-target="#modalAgregar"
                        style="border-radius:10px;"
                        aria-label="Agregar nuevo usuario">
                    <i class="fas fa-user-plus me-1" aria-hidden="true"></i> Agregar Usuario
                </button>
            </div>
        </div>

        <!-- Alertas de estado -->
        <% if (ok != null && !ok.isEmpty()) { %>
        <div class="alert-custom-success mb-3" role="alert" aria-live="polite">
            <i class="fas fa-check-circle" aria-hidden="true"></i>
            Operación exitosa: <%= ok %>
        </div>
        <% } %>
        <% if (err != null && !err.isEmpty()) { %>
        <div class="alert-custom-error mb-3" role="alert" aria-live="assertive">
            <i class="fas fa-exclamation-circle" aria-hidden="true"></i>
            Error en la operación. Por favor intente nuevamente.
        </div>
        <% } %>

        <!-- Buscador -->
        <form method="GET" action="${pageContext.request.contextPath}/admin/usuarios.jsp"
              class="mb-4" role="search" aria-label="Buscar usuarios">
            <div class="input-group" style="max-width:400px;">
                <input type="text" name="buscar" class="form-control"
                       placeholder="Buscar por nombre, apellido o correo..."
                       value="<%= buscar %>"
                       aria-label="Término de búsqueda de usuarios">
                <button class="btn btn-primary" type="submit" style="border-radius:0 12px 12px 0;"
                        aria-label="Ejecutar búsqueda">
                    <i class="fas fa-search" aria-hidden="true"></i>
                </button>
            </div>
        </form>

        <!-- Tabla de Usuarios -->
        <div class="table-responsive">
            <table class="table table-custom" aria-label="Lista de usuarios del sistema">
                <thead>
                    <tr>
                        <th scope="col">#</th>
                        <th scope="col">Nombre</th>
                        <th scope="col">Correo</th>
                        <th scope="col">Perfil</th>
                        <th scope="col">Estado</th>
                        <th scope="col">Registro</th>
                        <th scope="col">Acciones</th>
                    </tr>
                </thead>
                <tbody>
                    <% if (usuarios.isEmpty()) { %>
                    <tr>
                        <td colspan="7" class="text-center text-muted py-4">
                            No se encontraron usuarios
                        </td>
                    </tr>
                    <% } %>
                    <% for (Usuario u2 : usuarios) { %>
                    <tr>
                        <td><%= u2.getId() %></td>
                        <td>
                            <div class="d-flex align-items-center gap-2">
                                <div style="width:36px;height:36px;border-radius:50%;
                                            background:linear-gradient(135deg,#4FC3F7,#0288D1);
                                            display:flex;align-items:center;justify-content:center;
                                            color:#fff;font-weight:700;font-size:0.9rem;flex-shrink:0;"
                                     aria-hidden="true">
                                    <%= u2.getNombre().charAt(0) %>
                                </div>
                                <div>
                                    <div class="fw-bold small"><%= u2.getNombre() %> <%= u2.getApellido() %></div>
                                </div>
                            </div>
                        </td>
                        <td class="small text-muted"><%= u2.getCorreo() %></td>
                        <td>
                            <span class="badge <%= u2.isAdmin() ? "badge-admin" : "badge-estudiante" %>"
                                  aria-label="Perfil: <%= u2.getPerfil() %>">
                                <%= u2.isAdmin() ? "Admin" : "Estudiante" %>
                            </span>
                        </td>
                        <td>
                            <span class="badge <%= u2.isActivo() ? "badge-activo" : "badge-bloqueado" %>"
                                  aria-label="Estado: <%= u2.isActivo() ? "Activo" : "Bloqueado" %>">
                                <%= u2.isActivo() ? "✅ Activo" : "🚫 Bloqueado" %>
                            </span>
                        </td>
                        <td class="small text-muted">
                            <%= u2.getFechaRegistro() != null ? u2.getFechaRegistro().toString().substring(0, 10) : "-" %>
                        </td>
                        <td>
                            <div class="d-flex gap-1 flex-wrap">
                                <!-- Editar -->
                                <button class="btn btn-outline-primary btn-sm"
                                        onclick="editarUsuario(<%= u2.getId() %>,'<%= u2.getNombre() %>','<%= u2.getApellido() %>','<%= u2.getPerfil() %>')"
                                        data-bs-toggle="modal" data-bs-target="#modalEditar"
                                        aria-label="Editar usuario <%= u2.getNombreCompleto() %>"
                                        style="border-radius:8px;">
                                    <i class="fas fa-edit" aria-hidden="true"></i>
                                </button>

                                <!-- Bloquear / Desbloquear -->
                                <% if (u2.getId() != admin.getId()) { // No bloquearse a sí mismo %>
                                <form method="POST" action="${pageContext.request.contextPath}/admin/accion" class="d-inline">
                                    <input type="hidden" name="id" value="<%= u2.getId() %>">
                                    <input type="hidden" name="action" value="<%= u2.isActivo() ? "bloquear" : "desbloquear" %>">
                                    <button type="submit"
                                            class="btn btn-sm <%= u2.isActivo() ? "btn-outline-danger" : "btn-outline-success" %>"
                                            style="border-radius:8px;"
                                            aria-label="<%= u2.isActivo() ? "Bloquear" : "Desbloquear" %> usuario <%= u2.getNombreCompleto() %>"
                                            onclick="return confirm('<%= u2.isActivo() ? "¿Bloquear" : "¿Desbloquear" %> a <%= u2.getNombreCompleto() %>?')">
                                        <i class="fas fa-<%= u2.isActivo() ? "ban" : "unlock" %>" aria-hidden="true"></i>
                                    </button>
                                </form>
                                <% } %>
                            </div>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>
    </main>
</div>

<!-- ── Modal Agregar Usuario ─────────────────────────────────────────────── -->
<div class="modal fade" id="modalAgregar" tabindex="-1"
     aria-labelledby="modalAgregar-label" aria-modal="true" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px;">
            <div class="modal-header" style="background:linear-gradient(135deg,#0288D1,#4FC3F7);border:none;border-radius:20px 20px 0 0;">
                <div class="modal-title h2" id="modalAgregar-label" style="font-family:'Fredoka One',cursive;color:#fff;font-size:1.35rem;">
                    ➕ Agregar Nuevo Usuario
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Cerrar modal"></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/admin/accion" novalidate>
                <div class="modal-body p-4">
                    <input type="hidden" name="action" value="agregar">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold" for="ag-nombre">Nombre</label>
                            <input type="text" id="ag-nombre" name="nombre" class="form-control"
                                   required aria-required="true" placeholder="Nombre">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold" for="ag-apellido">Apellido</label>
                            <input type="text" id="ag-apellido" name="apellido" class="form-control"
                                   required aria-required="true" placeholder="Apellido">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-bold" for="ag-correo">Correo</label>
                            <input type="email" id="ag-correo" name="correo" class="form-control"
                                   required aria-required="true" placeholder="correo@dominio.com">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-bold" for="ag-clave">Contraseña</label>
                            <input type="password" id="ag-clave" name="clave" class="form-control"
                                   required minlength="8" aria-required="true" placeholder="Mínimo 8 caracteres">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-bold" for="ag-perfil">Perfil</label>
                            <select id="ag-perfil" name="perfil" class="form-control"
                                    required aria-required="true">
                                <option value="estudiante">Estudiante</option>
                                <option value="admin">Administrador</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 px-4 pb-4">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"
                            style="border-radius:10px;" aria-label="Cancelar">
                        Cancelar
                    </button>
                    <button type="submit" class="btn btn-primary" style="border-radius:10px;"
                            aria-label="Guardar nuevo usuario">
                        <i class="fas fa-save me-1" aria-hidden="true"></i> Guardar
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- ── Modal Editar Usuario ──────────────────────────────────────────────── -->
<div class="modal fade" id="modalEditar" tabindex="-1"
     aria-labelledby="modalEditar-label" aria-modal="true" role="dialog">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content" style="border-radius:20px;">
            <div class="modal-header" style="background:linear-gradient(135deg,#7E57C2,#AB47BC);border:none;border-radius:20px 20px 0 0;">
                <div class="modal-title h2" id="modalEditar-label" style="font-family:'Fredoka One',cursive;color:#fff;font-size:1.35rem;">
                    ✏️ Editar Usuario
                </div>
                <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal"
                        aria-label="Cerrar modal"></button>
            </div>
            <form method="POST" action="${pageContext.request.contextPath}/admin/accion" novalidate>
                <div class="modal-body p-4">
                    <input type="hidden" name="action" value="actualizar">
                    <input type="hidden" id="ed-id" name="id" value="">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label fw-bold" for="ed-nombre">Nombre</label>
                            <input type="text" id="ed-nombre" name="nombre" class="form-control"
                                   required aria-required="true">
                        </div>
                        <div class="col-md-6">
                            <label class="form-label fw-bold" for="ed-apellido">Apellido</label>
                            <input type="text" id="ed-apellido" name="apellido" class="form-control"
                                   required aria-required="true">
                        </div>
                        <div class="col-12">
                            <label class="form-label fw-bold" for="ed-perfil">Perfil</label>
                            <select id="ed-perfil" name="perfil" class="form-control"
                                    required aria-required="true">
                                <option value="estudiante">Estudiante</option>
                                <option value="admin">Administrador</option>
                            </select>
                        </div>
                    </div>
                </div>
                <div class="modal-footer border-0 px-4 pb-4">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"
                            style="border-radius:10px;">Cancelar</button>
                    <button type="submit" class="btn btn-primary" style="border-radius:10px;"
                            aria-label="Actualizar información del usuario">
                        <i class="fas fa-save me-1" aria-hidden="true"></i> Actualizar
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/js/main.js"></script>
<script>
    function editarUsuario(id, nombre, apellido, perfil) {
        document.getElementById('ed-id').value      = id;
        document.getElementById('ed-nombre').value  = nombre;
        document.getElementById('ed-apellido').value = apellido;
        document.getElementById('ed-perfil').value  = perfil;
    }
</script>
</body>
</html>
