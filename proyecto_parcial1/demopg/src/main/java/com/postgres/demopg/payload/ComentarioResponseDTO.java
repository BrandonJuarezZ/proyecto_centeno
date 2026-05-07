package com.postgres.demopg.payload;

import java.time.LocalDateTime;

public class ComentarioResponseDTO {
    private Long id;
    private String contenido;
    private String nombreUsuario;
    private LocalDateTime fechaCreacion;

    public ComentarioResponseDTO() {}

    public ComentarioResponseDTO(Long id, String contenido, String nombreUsuario, LocalDateTime fechaCreacion) {
        this.id = id;
        this.contenido = contenido;
        this.nombreUsuario = nombreUsuario;
        this.fechaCreacion = fechaCreacion;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getContenido() { return contenido; }
    public void setContenido(String contenido) { this.contenido = contenido; }

    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }

    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
}
