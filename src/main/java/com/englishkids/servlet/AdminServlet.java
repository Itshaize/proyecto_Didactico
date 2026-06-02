package com.englishkids.servlet;

import com.englishkids.db.DBConnection;
import com.englishkids.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/**
 * AdminServlet - Gestion de usuarios y revision de actividades.
 */
@WebServlet("/admin/accion")
public class AdminServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        if (!esAdmin(req, resp)) {
            return;
        }

        String action = req.getParameter("action");
        String ip = req.getRemoteAddr();
        Usuario admin = (Usuario) req.getSession().getAttribute("usuario");

        try (Connection conn = DBConnection.getConnection()) {
            switch (action != null ? action : "") {
                case "agregar":
                    agregarUsuario(req, resp, conn, admin, ip);
                    break;
                case "actualizar":
                    actualizarUsuario(req, resp, conn, admin, ip);
                    break;
                case "bloquear":
                    cambiarEstado(req, resp, conn, admin, ip, false);
                    break;
                case "desbloquear":
                    cambiarEstado(req, resp, conn, admin, ip, true);
                    break;
                case "revisar_actividad":
                    revisarActividad(req, resp, conn, admin, ip);
                    break;
                default:
                    resp.sendRedirect(req.getContextPath() + "/admin/usuarios.jsp");
                    break;
            }
        } catch (SQLException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/admin/usuarios.jsp?error=1");
        }
    }

    private void agregarUsuario(HttpServletRequest req, HttpServletResponse resp,
                                Connection conn, Usuario admin, String ip)
            throws SQLException, IOException {
        String nombre = req.getParameter("nombre");
        String apellido = req.getParameter("apellido");
        String correo = req.getParameter("correo");
        String clave = req.getParameter("clave");
        String perfil = req.getParameter("perfil");

        String hash = LoginServlet.sha256(clave);
        String sql = "INSERT INTO usuarios (nombre, apellido, correo, clave, perfil, activo) " +
                     "VALUES (?,?,?,?,?,TRUE)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, correo);
            ps.setString(4, hash);
            ps.setString(5, perfil);
            ps.executeUpdate();
        }

        LoginServlet.registrarBitacora(conn, admin.getId(), "ADMIN_AGREGAR_USUARIO",
                "Admin agrego usuario: " + correo, ip);
        resp.sendRedirect(req.getContextPath() + "/admin/usuarios.jsp?ok=agregado");
    }

    private void actualizarUsuario(HttpServletRequest req, HttpServletResponse resp,
                                   Connection conn, Usuario admin, String ip)
            throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String nombre = req.getParameter("nombre");
        String apellido = req.getParameter("apellido");
        String perfil = req.getParameter("perfil");

        String sql = "UPDATE usuarios SET nombre=?, apellido=?, perfil=? WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, nombre);
            ps.setString(2, apellido);
            ps.setString(3, perfil);
            ps.setInt(4, id);
            ps.executeUpdate();
        }

        LoginServlet.registrarBitacora(conn, admin.getId(), "ADMIN_ACTUALIZAR_USUARIO",
                "Admin actualizo usuario id=" + id, ip);
        resp.sendRedirect(req.getContextPath() + "/admin/usuarios.jsp?ok=actualizado");
    }

    private void cambiarEstado(HttpServletRequest req, HttpServletResponse resp,
                               Connection conn, Usuario admin, String ip, boolean nuevoEstado)
            throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        String sql = "UPDATE usuarios SET activo=? WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, nuevoEstado);
            ps.setInt(2, id);
            ps.executeUpdate();
        }

        String accion = nuevoEstado ? "ADMIN_DESBLOQUEAR_USUARIO" : "ADMIN_BLOQUEAR_USUARIO";
        String estado = nuevoEstado ? "desbloqueado" : "bloqueado";
        LoginServlet.registrarBitacora(conn, admin.getId(), accion,
                "Admin dejo usuario id=" + id + " como " + estado, ip);
        resp.sendRedirect(req.getContextPath() + "/admin/usuarios.jsp?ok=" + estado);
    }

    private void revisarActividad(HttpServletRequest req, HttpServletResponse resp,
                                  Connection conn, Usuario admin, String ip)
            throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        boolean aprobado = "aprobar".equals(req.getParameter("decision"));
        String observacion = req.getParameter("observacion");

        String sql = "UPDATE actividades SET revisado=TRUE, aprobado=?, observacion_revision=?, " +
                     "id_admin_revisor=?, fecha_revision=NOW() WHERE id=?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, aprobado);
            ps.setString(2, observacion != null ? observacion.trim() : "");
            ps.setInt(3, admin.getId());
            ps.setInt(4, id);
            ps.executeUpdate();
        }

        LoginServlet.registrarBitacora(conn, admin.getId(), "ADMIN_REVISAR_ACTIVIDAD",
                "Admin " + (aprobado ? "aprobo" : "marco para revisar") + " actividad id=" + id, ip);
        resp.sendRedirect(req.getContextPath() + "/admin/actividades.jsp?ok=revision");
    }

    public static boolean esAdmin(HttpServletRequest req, HttpServletResponse resp)
            throws IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }

        Usuario usuario = (Usuario) session.getAttribute("usuario");
        if (!usuario.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return false;
        }

        return true;
    }
}
