package com.postgres.demopg.models;

import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;

@Entity
@Table(name = "comentarios")
public class Comentario {

  @Id
  @GeneratedValue(strategy = GenerationType.IDENTITY)
  private Long id;

  @NotBlank
  @Column(columnDefinition = "TEXT")
  private String contenido;

  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "usuario_id", referencedColumnName = "id")
  private User usuario;

  @JsonIgnore
  @ManyToOne(fetch = FetchType.LAZY)
  @JoinColumn(name = "personaje_id", referencedColumnName = "id")
  private Personaje personaje;

  @Column(name = "fecha_creacion", nullable = false, updatable = false)
  private LocalDateTime fechaCreacion;

  public Comentario() {
  }

  public Comentario(String contenido, User usuario, Personaje personaje) {
    this.contenido = contenido;
    this.usuario = usuario;
    this.personaje = personaje;
    this.fechaCreacion = LocalDateTime.now();
  }

  // Getters and Setters

  public Long getId() {
    return id;
  }

  public void setId(Long id) {
    this.id = id;
  }

  public String getContenido() {
    return contenido;
  }

  public void setContenido(String contenido) {
    this.contenido = contenido;
  }

  public User getUsuario() {
    return usuario;
  }

  public void setUsuario(User usuario) {
    this.usuario = usuario;
  }

  public Personaje getPersonaje() {
    return personaje;
  }

  public void setPersonaje(Personaje personaje) {
    this.personaje = personaje;
  }

  public LocalDateTime getFechaCreacion() {
    return fechaCreacion;
  }

  public void setFechaCreacion(LocalDateTime fechaCreacion) {
    this.fechaCreacion = fechaCreacion;
  }
}
