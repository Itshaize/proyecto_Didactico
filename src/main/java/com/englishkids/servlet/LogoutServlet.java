package com.englishkids.servlet;

import com.englishkids.db.DBConnection;
import com.englishkids.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.sql.*;

/**
 * LogoutServlet – Invalida la sesión y redirige al login.
 * URL: /logout
 */
@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session != null) {
            Usuario u = (Usuario) session.getAttribute("usuario");
            if (u != null) {
                try (Connection conn = DBConnection.getConnection()) {
                    LoginServlet.registrarBitacora(conn, u.getId(), "LOGOUT",
                            "Cierre de sesión: " + u.getCorreo(), req.getRemoteAddr());
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            session.invalidate();
        }
        resp.sendRedirect(req.getContextPath() + "/index.jsp");
    }
}
