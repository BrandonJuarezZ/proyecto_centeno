package com.postgres.demopg.models;

import java.util.HashSet;
import java.util.Set;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

@Entity
@Table( name = "personajes")

public class Personaje {

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

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "creado_por", referencedColumnName = "id")
  private User creadoPor;

  public User getCreadoPor() {
    return creadoPor;
  }

  public void setCreadoPor(User creadoPor) {
    this.creadoPor = creadoPor;
  }

  public Personaje() {
  }

  public  Personaje (String nombre, String descripcion, String videojuego, String imagenUrl) {
    this.nombre = nombre;
    this.descripcion = descripcion;
    this.videojuego = videojuego;
    this.imagenUrl = imagenUrl;
  }

  // getters and setters

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
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

  @OneToMany(mappedBy = "personaje")
  Set<PersonajeReaction> reacciones;

  public Set<PersonajeReaction> getReacciones() {
    return reacciones;
  }

  public void setReacciones(Set<PersonajeReaction> reacciones) {
    this.reacciones = reacciones;
  }

  @OneToMany(mappedBy = "personaje", cascade = CascadeType.ALL, orphanRemoval = true)
  Set<Comentario> comentarios;

  public Set<Comentario> getComentarios() {
    return comentarios;
  }

  public void setComentarios(Set<Comentario> comentarios) {
    this.comentarios = comentarios;
  }
}
