package com.englishkids.model;

import java.sql.Timestamp;

/** Modelo de Usuario del sistema */
public class Usuario {

    private int       id;
    private String    nombre;
    private String    apellido;
    private String    correo;
    private String    clave;          // SHA-256 hex
    private String    perfil;         // 'admin' | 'estudiante'
    private boolean   activo;
    private Timestamp fechaRegistro;

    public Usuario() {}

    public Usuario(int id, String nombre, String apellido, String correo,
                   String clave, String perfil, boolean activo, Timestamp fechaRegistro) {
        this.id            = id;
        this.nombre        = nombre;
        this.apellido      = apellido;
        this.correo        = correo;
        this.clave         = clave;
        this.perfil        = perfil;
        this.activo        = activo;
        this.fechaRegistro = fechaRegistro;
    }

    // ── Getters & Setters ────────────────────────────────────────
    public int       getId()            { return id; }
    public void      setId(int id)      { this.id = id; }

    public String    getNombre()        { return nombre; }
    public void      setNombre(String n){ this.nombre = n; }

    public String    getApellido()         { return apellido; }
    public void      setApellido(String a) { this.apellido = a; }

    public String    getNombreCompleto()   { return nombre + " " + apellido; }

    public String    getCorreo()          { return correo; }
    public void      setCorreo(String c)  { this.correo = c; }

    public String    getClave()           { return clave; }
    public void      setClave(String c)   { this.clave = c; }

    public String    getPerfil()          { return perfil; }
    public void      setPerfil(String p)  { this.perfil = p; }

    public boolean   isActivo()           { return activo; }
    public void      setActivo(boolean a) { this.activo = a; }

    public Timestamp getFechaRegistro()            { return fechaRegistro; }
    public void      setFechaRegistro(Timestamp t) { this.fechaRegistro = t; }

    public boolean isAdmin()      { return "admin".equals(perfil); }
    public boolean isEstudiante() { return "estudiante".equals(perfil); }

    @Override
    public String toString() {
        return "Usuario{id=" + id + ", correo=" + correo + ", perfil=" + perfil + "}";
    }
}
