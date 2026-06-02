package com.englishkids.db;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection - Gestion de conexion JDBC a PostgreSQL.
 * Usa la base del datacenter por defecto para la entrega final.
 */
public class DBConnection {

    private static final String URL      = config("ENGLISHKIDS_DB_URL", "jdbc:postgresql://172.17.42.121:5432/BD_english");
    private static final String USER     = config("ENGLISHKIDS_DB_USER", "alumno");
    private static final String PASSWORD = config("ENGLISHKIDS_DB_PASSWORD", "1234");

    static {
        try {
            Class.forName("org.postgresql.Driver");
        } catch (ClassNotFoundException e) {
            throw new RuntimeException("Driver PostgreSQL no encontrado", e);
        }
    }

    /**
     * Obtiene una nueva conexion a la base de datos.
     * Cada Servlet debe cerrar la conexion en un bloque finally.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    private static String config(String key, String defaultValue) {
        String value = System.getProperty(key);
        if (value == null || value.trim().isEmpty()) {
            value = System.getenv(key);
        }
        return (value == null || value.trim().isEmpty()) ? defaultValue : value.trim();
    }
}
