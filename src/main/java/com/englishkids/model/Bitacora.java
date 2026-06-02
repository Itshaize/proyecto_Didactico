package com.englishkids.model;

import java.sql.Timestamp;

/** Modelo de entrada de Bitácora del sistema */
public class Bitacora {

    private int       id;
    private int       idUsuario;
    private String    nombreUsuario;   // campo JOIN para vistas
    private String    correoUsuario;
    private String    accion;
    private String    detalle;
    private String    ip;
    private Timestamp fecha;

    public Bitacora() {}

    public int       getId()                 { return id; }
    public void      setId(int id)           { this.id = id; }

    public int       getIdUsuario()          { return idUsuario; }
    public void      setIdUsuario(int i)     { this.idUsuario = i; }

    public String    getNombreUsuario()          { return nombreUsuario; }
    public void      setNombreUsuario(String n)  { this.nombreUsuario = n; }

    public String    getCorreoUsuario()          { return correoUsuario; }
    public void      setCorreoUsuario(String c)  { this.correoUsuario = c; }

    public String    getAccion()             { return accion; }
    public void      setAccion(String a)     { this.accion = a; }

    public String    getDetalle()            { return detalle; }
    public void      setDetalle(String d)    { this.detalle = d; }

    public String    getIp()                 { return ip; }
    public void      setIp(String ip)        { this.ip = ip; }

    public Timestamp getFecha()              { return fecha; }
    public void      setFecha(Timestamp t)   { this.fecha = t; }
}
