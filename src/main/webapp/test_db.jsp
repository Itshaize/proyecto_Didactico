<%@ page import="com.englishkids.db.DBConnection, java.sql.*, java.io.*" %>
<%
try (Connection conn = DBConnection.getConnection();
     Statement st = conn.createStatement();
     ResultSet rs = st.executeQuery("SELECT * FROM palabras WHERE id_categoria = 1 ORDER BY id")) {
    while (rs.next()) {
        out.println(rs.getInt("id") + " - " + rs.getString("palabra_en") + " - " + rs.getString("palabra_es") + " - img: " + rs.getString("imagen_url"));
    }
} catch (Exception e) { out.println(e.getMessage()); }
%>
