package com.englishkids.model;

/** Modelo de Categoría de palabras en inglés */
public class Categoria {

    private int    id;
    private String nombre;
    private String nombreEs;
    private String descripcion;
    private String icono;
    private String colorHex;

    public Categoria() {}

    public Categoria(int id, String nombre, String nombreEs,
                     String descripcion, String icono, String colorHex) {
        this.id          = id;
        this.nombre      = nombre;
        this.nombreEs    = nombreEs;
        this.descripcion = descripcion;
        this.icono       = icono;
        this.colorHex    = colorHex;
    }

    public int    getId()              { return id; }
    public void   setId(int id)        { this.id = id; }

    public String getNombre()          { return nombre; }
    public void   setNombre(String n)  { this.nombre = n; }

    public String getNombreEs()           { return nombreEs; }
    public void   setNombreEs(String n)   { this.nombreEs = n; }

    public String getDescripcion()        { return descripcion; }
    public void   setDescripcion(String d){ this.descripcion = d; }

    public String getIcono()             { return icono; }
    public void   setIcono(String i)     { this.icono = i; }

    public String getColorHex()          { return colorHex; }
    public void   setColorHex(String c)  { this.colorHex = c; }
}
