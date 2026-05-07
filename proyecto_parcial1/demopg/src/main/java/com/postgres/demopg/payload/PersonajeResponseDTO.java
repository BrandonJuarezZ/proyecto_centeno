package com.postgres.demopg.payload;

import java.util.List;

public class PersonajeResponseDTO {
    private Long id;
    private String nombre;
    private String descripcion;
    private String videojuego;
    private String imagenUrl;
    private String creadoPorNombre;
    private int likes;
    private int dislikes;
    private boolean usuarioHizoPlike;
    private boolean usuarioHizoDislike;
    private List<ComentarioResponseDTO> comentarios;
    private List<ReactionResponseDTO> reacciones;

    public PersonajeResponseDTO() {
    }

    public PersonajeResponseDTO(Long id, String nombre, String descripcion, String videojuego, 
                               String imagenUrl, String creadoPorNombre, 
                               int likes, int dislikes, boolean usuarioHizoPlike, boolean usuarioHizoDislike,
                               List<ComentarioResponseDTO> comentarios, 
                               List<ReactionResponseDTO> reacciones) {
        this.id = id;
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.videojuego = videojuego;
        this.imagenUrl = imagenUrl;
        this.creadoPorNombre = creadoPorNombre;
        this.likes = likes;
        this.dislikes = dislikes;
        this.usuarioHizoPlike = usuarioHizoPlike;
        this.usuarioHizoDislike = usuarioHizoDislike;
        this.comentarios = comentarios;
        this.reacciones = reacciones;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }

    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }

    public String getVideojuego() { return videojuego; }
    public void setVideojuego(String videojuego) { this.videojuego = videojuego; }

    public String getImagenUrl() { return imagenUrl; }
    public void setImagenUrl(String imagenUrl) { this.imagenUrl = imagenUrl; }

    public String getCreadoPorNombre() { return creadoPorNombre; }
    public void setCreadoPorNombre(String creadoPorNombre) { this.creadoPorNombre = creadoPorNombre; }

    public int getLikes() { return likes; }
    public void setLikes(int likes) { this.likes = likes; }

    public int getDislikes() { return dislikes; }
    public void setDislikes(int dislikes) { this.dislikes = dislikes; }

    public boolean isUsuarioHizoPlike() { return usuarioHizoPlike; }
    public void setUsuarioHizoPlike(boolean usuarioHizoPlike) { this.usuarioHizoPlike = usuarioHizoPlike; }

    public boolean isUsuarioHizoDislike() { return usuarioHizoDislike; }
    public void setUsuarioHizoDislike(boolean usuarioHizoDislike) { this.usuarioHizoDislike = usuarioHizoDislike; }

    public List<ComentarioResponseDTO> getComentarios() { return comentarios; }
    public void setComentarios(List<ComentarioResponseDTO> comentarios) { this.comentarios = comentarios; }

    public List<ReactionResponseDTO> getReacciones() { return reacciones; }
    public void setReacciones(List<ReactionResponseDTO> reacciones) { this.reacciones = reacciones; }
}
