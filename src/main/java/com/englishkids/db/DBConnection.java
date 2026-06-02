package com.englishkids.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection – Gestión de conexión JDBC a PostgreSQL.
 * Ajustar URL, usuario y contraseña según el entorno.
 */
public class DBConnection {

    // ── Configuración de conexión ──────────────────────────────────
    private static final String URL      = "jdbc:postgresql://localhost:5432/englishkids";
    private static final String USER     = "postgres";
    private static final String PASSWORD = "1234";
    // Para el servidor del datacenter cambiar a:
    // private static final String URL = "jdbc:postgresql://172.17.42.121:5432/englishkids";
    // private static final String USER = "alumno";
    // private static final String PASSWORD = "1234";

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver PostgreSQL no encontrado", e);
        }
    }

    /**
     * Obtiene una nueva conexión a la base de datos.
     * Cada Servlet debe cerrar la conexión en un bloque finally.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }
}
