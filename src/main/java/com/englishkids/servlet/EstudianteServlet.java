package com.englishkids.servlet;

import com.englishkids.db.DBConnection;
import com.englishkids.model.Usuario;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;

import java.io.IOException;
import java.sql.*;

/**
 * EstudianteServlet – Registra la interacción del estudiante (quiz / actividad).
 * URL: /estudiante/*
 */
@WebServlet("/estudiante/actividad")
public class EstudianteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Verificar sesión de estudiante
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"no session\"}");
            return;
        }
        Usuario u  = (Usuario) session.getAttribute("usuario");
        String ip  = req.getRemoteAddr();
        String action = req.getParameter("action");

        try (Connection conn = DBConnection.getConnection()) {
            switch (action != null ? action : "") {
                case "quiz":
                    registrarQuiz(req, resp, conn, u, ip);
                    break;
                case "ver_categoria":
                    String cat = req.getParameter("categoria");
                    LoginServlet.registrarBitacora(conn, u.getId(), "VER_CATEGORIA",
                            "Estudiante visitó categoría: " + cat, ip);
                    resp.sendRedirect(req.getContextPath() + "/categorias/" + cat + ".jsp");
                    break;
                default:
                    resp.setContentType("application/json;charset=UTF-8");
                    resp.getWriter().write("{\"error\":\"unknown action\"}");
            }
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
        }
    }

    /** GET – también acepta registros para mayor compatibilidad con fetch sin CORS */
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("usuario") == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"no session\"}");
            return;
        }

        String action = req.getParameter("action");
        if ("quiz".equals(action)) {
            Usuario u = (Usuario) session.getAttribute("usuario");
            String ip = req.getRemoteAddr();
            try (Connection conn = DBConnection.getConnection()) {
                registrarQuiz(req, resp, conn, u, ip);
            } catch (Exception e) {
                e.printStackTrace();
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"error\":\"" + e.getMessage().replace("\"","'") + "\"}");
            }
        } else {
            resp.sendRedirect(req.getContextPath() + "/estudiante/dashboard.jsp");
        }
    }

    private void registrarQuiz(HttpServletRequest req, HttpServletResponse resp,
                               Connection conn, Usuario u, String ip)
            throws SQLException, IOException {

        String idPalabraStr = req.getParameter("id_palabra");
        String resultado    = req.getParameter("resultado");

        if (idPalabraStr == null || resultado == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"error\":\"missing params\"}");
            return;
        }

        int idPalabra = Integer.parseInt(idPalabraStr);
        String tipo   = req.getParameter("tipo") != null ? req.getParameter("tipo") : "quiz";
        int puntos    = "correcto".equals(resultado) ? 10 : 0;

        String sql = "INSERT INTO actividades (id_usuario, id_palabra, tipo, resultado, puntos) " +
                     "VALUES (?,?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, u.getId());
            ps.setInt(2, idPalabra);
            ps.setString(3, tipo);
            ps.setString(4, resultado);
            ps.setInt(5, puntos);
            ps.executeUpdate();
        }

        LoginServlet.registrarBitacora(conn, u.getId(), "ACTIVIDAD_QUIZ",
                "Palabra id=" + idPalabra + " resultado=" + resultado, ip);

        resp.setContentType("application/json;charset=UTF-8");
        resp.getWriter().write("{\"resultado\":\"" + resultado + "\",\"puntos\":" + puntos + "}");
    }
}
