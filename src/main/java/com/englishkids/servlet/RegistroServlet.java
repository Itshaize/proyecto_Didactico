package com.englishkids.servlet;

import com.englishkids.db.DBConnection;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.sql.*;
import java.util.regex.Pattern;

/**
 * RegistroServlet – Registro de nuevos usuarios con validación de correo y clave.
 * URL: /registro
 */
@WebServlet("/registro")
public class RegistroServlet extends HttpServlet {

    private static final Pattern EMAIL_PATTERN =
            Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$");

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/registro.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String nombre   = req.getParameter("nombre");
        String apellido = req.getParameter("apellido");
        String correo   = req.getParameter("correo");
        String clave    = req.getParameter("clave");
        String confirma = req.getParameter("confirma");
        String ip       = req.getRemoteAddr();

        // ── Validaciones ────────────────────────────────────────────
        if (esVacio(nombre) || esVacio(apellido) || esVacio(correo) ||
                esVacio(clave) || esVacio(confirma)) {
            req.setAttribute("error", "Todos los campos son obligatorios.");
            req.getRequestDispatcher("/registro.jsp").forward(req, resp); return;
        }
        if (!EMAIL_PATTERN.matcher(correo).matches()) {
            req.setAttribute("error", "El correo electrónico no es válido.");
            req.getRequestDispatcher("/registro.jsp").forward(req, resp); return;
        }
        if (clave.length() < 8) {
            req.setAttribute("error", "La contraseña debe tener mínimo 8 caracteres.");
            req.getRequestDispatcher("/registro.jsp").forward(req, resp); return;
        }
        if (!clave.equals(confirma)) {
            req.setAttribute("error", "Las contraseñas no coinciden.");
            req.getRequestDispatcher("/registro.jsp").forward(req, resp); return;
        }

        String claveHash = LoginServlet.sha256(clave);

        try (Connection conn = DBConnection.getConnection()) {
            // Verificar si el correo ya está registrado
            try (PreparedStatement ps = conn.prepareStatement(
                    "SELECT id FROM usuarios WHERE correo = ?")) {
                ps.setString(1, correo);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        req.setAttribute("error", "El correo ya está registrado. Intenta iniciar sesión.");
                        req.getRequestDispatcher("/registro.jsp").forward(req, resp); return;
                    }
                }
            }

            // Insertar nuevo usuario con perfil 'estudiante'
            String sql = "INSERT INTO usuarios (nombre, apellido, correo, clave, perfil, activo) " +
                         "VALUES (?,?,?,?,'estudiante',TRUE)";
            int nuevoId;
            try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setString(1, nombre.trim());
                ps.setString(2, apellido.trim());
                ps.setString(3, correo.trim().toLowerCase());
                ps.setString(4, claveHash);
                ps.executeUpdate();
                try (ResultSet gk = ps.getGeneratedKeys()) {
                    nuevoId = gk.next() ? gk.getInt(1) : 0;
                }
            }

            LoginServlet.registrarBitacora(conn, nuevoId, "REGISTRO",
                    "Nuevo usuario registrado: " + correo, ip);

            req.setAttribute("exito", "¡Registro exitoso! Ahora puedes iniciar sesión.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Error al registrar usuario. Intenta más tarde.");
            req.getRequestDispatcher("/registro.jsp").forward(req, resp);
        }
    }

    private boolean esVacio(String s) {
        return s == null || s.isBlank();
    }
}
