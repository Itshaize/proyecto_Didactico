package com.englishkids.model;

/** Modelo de Palabra en inglés con su traducción y recursos multimedia */
public class Palabra {

    private int    id;
    private int    idCategoria;
    private String palabraEn;
    private String palabraEs;
    private String imagenUrl;
    private String audioUrl;
    private String modelo3d;
    private String nivel;

    public Palabra() {}

    public Palabra(int id, int idCategoria, String palabraEn, String palabraEs,
                   String imagenUrl, String audioUrl, String modelo3d, String nivel) {
        this.id          = id;
        this.idCategoria = idCategoria;
        this.palabraEn   = palabraEn;
        this.palabraEs   = palabraEs;
        this.imagenUrl   = imagenUrl;
        this.audioUrl    = audioUrl;
        this.modelo3d    = modelo3d;
        this.nivel       = nivel;
    }

    public int    getId()               { return id; }
    public void   setId(int id)         { this.id = id; }

    public int    getIdCategoria()      { return idCategoria; }
    public void   setIdCategoria(int i) { this.idCategoria = i; }

    public String getPalabraEn()            { return palabraEn; }
    public void   setPalabraEn(String p)    { this.palabraEn = p; }

    public String getPalabraEs()            { return palabraEs; }
    public void   setPalabraEs(String p)    { this.palabraEs = p; }

    public String getImagenUrl()            { return imagenUrl; }
    public void   setImagenUrl(String u)    { this.imagenUrl = u; }

    public String getAudioUrl()             { return audioUrl; }
    public void   setAudioUrl(String u)     { this.audioUrl = u; }

    public String getModelo3d()             { return modelo3d; }
    public void   setModelo3d(String m)     { this.modelo3d = m; }

    public String getNivel()                { return nivel; }
    public void   setNivel(String n)        { this.nivel = n; }
}
