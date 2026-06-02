package com.englishkids.servlet;

import com.englishkids.db.DBConnection;
import com.englishkids.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.security.MessageDigest;
import java.sql.*;

/**
 * LoginServlet – Gestiona el inicio de sesión y establece la sesión HTTP.
 * URL: /login
 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Si ya tiene sesión, redirigir al dashboard correspondiente
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("usuario") != null) {
            redirectByProfile(req, resp, (Usuario) session.getAttribute("usuario"));
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String correo = req.getParameter("correo");
        String clave  = req.getParameter("clave");

        if (correo == null || correo.isBlank() || clave == null || clave.isBlank()) {
            req.setAttribute("error", "Por favor ingresa correo y contraseña.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
            return;
        }

        String claveHash = sha256(clave);
        String ip        = req.getRemoteAddr();

        try (Connection conn = DBConnection.getConnection()) {
            // Buscar usuario activo con las credenciales
            String sql = "SELECT id, nombre, apellido, correo, clave, perfil, activo, fecha_registro " +
                         "FROM usuarios WHERE correo = ? AND clave = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, correo);
                ps.setString(2, claveHash);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        Usuario u = mapUsuario(rs);
                        if (!u.isActivo()) {
                            registrarBitacora(conn, u.getId(), "LOGIN_BLOQUEADO",
                                    "Intento de login con cuenta bloqueada", ip);
                            req.setAttribute("error", "Tu cuenta está bloqueada. Contacta al administrador.");
                            req.getRequestDispatcher("/login.jsp").forward(req, resp);
                            return;
                        }
                        // Crear sesión
                        HttpSession session = req.getSession(true);
                        session.setAttribute("usuario", u);
                        session.setMaxInactiveInterval(30 * 60); // 30 minutos

                        registrarBitacora(conn, u.getId(), "LOGIN_EXITOSO",
                                "Inicio de sesión: " + u.getCorreo(), ip);
                        redirectByProfile(req, resp, u);
                    } else {
                        // Registrar intento fallido (sin id_usuario)
                        registrarBitacora(conn, 0, "LOGIN_FALLIDO",
                                "Credenciales incorrectas para: " + correo, ip);
                        req.setAttribute("error", "Correo o contraseña incorrectos.");
                        req.getRequestDispatcher("/login.jsp").forward(req, resp);
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Error del servidor. Intenta más tarde.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }

    // ── Helpers ─────────────────────────────────────────────────────
    private void redirectByProfile(HttpServletRequest req, HttpServletResponse resp, Usuario u)
            throws IOException {
        if (u.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/estudiante/dashboard.jsp");
        }
    }

    public static String sha256(String input) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(input.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Error calculando SHA-256", e);
        }
    }

    public static void registrarBitacora(Connection conn, int idUsuario, String accion,
                                          String detalle, String ip) {
        String sql = "INSERT INTO bitacora (id_usuario, accion, detalle, ip) VALUES (?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            if (idUsuario > 0) ps.setInt(1, idUsuario);
            else               ps.setNull(1, java.sql.Types.INTEGER);
            ps.setString(2, accion);
            ps.setString(3, detalle);
            ps.setString(4, ip);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    public static Usuario mapUsuario(ResultSet rs) throws SQLException {
        Usuario u = new Usuario();
        u.setId(rs.getInt("id"));
        u.setNombre(rs.getString("nombre"));
        u.setApellido(rs.getString("apellido"));
        u.setCorreo(rs.getString("correo"));
        u.setClave(rs.getString("clave"));
        u.setPerfil(rs.getString("perfil"));
        u.setActivo(rs.getBoolean("activo"));
        u.setFechaRegistro(rs.getTimestamp("fecha_registro"));
        return u;
    }
}
