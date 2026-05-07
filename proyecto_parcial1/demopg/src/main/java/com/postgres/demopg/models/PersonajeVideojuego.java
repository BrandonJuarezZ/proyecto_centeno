package com.postgres.demopg.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table(name = "personajes_videojuego")
public class PersonajeVideojuego {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    @Size(max = 100)
    private String nombre;

    @NotBlank
    @Size(max = 300)
    private String descripcion;

    @NotBlank
    @Size(max = 100)
    private String videojuego;

    @NotBlank
    private String imagenUrl;

    public PersonajeVideojuego() {}

    public PersonajeVideojuego(String nombre, String descripcion, String videojuego, String imagenUrl) {
        this.nombre = nombre;
        this.descripcion = descripcion;
        this.videojuego = videojuego;
        this.imagenUrl = imagenUrl;
    }

    // Getters y Setters

    public Long getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String descripcion) {
        this.descripcion = descripcion;
    }

    public String getVideojuego() {
        return videojuego;
    }

    public void setVideojuego(String videojuego) {
        this.videojuego = videojuego;
    }

    public String getImagenUrl() {
        return imagenUrl;
    }

    public void setImagenUrl(String imagenUrl) {
        this.imagenUrl = imagenUrl;
    }
}
