package com.postgres.demopg.payload;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

public class ComentarioRequest {
  @NotBlank
  private String contenido;

  @NotNull
  private Long personajeId;

  public ComentarioRequest() {
  }

  public ComentarioRequest(String contenido, Long personajeId) {
    this.contenido = contenido;
    this.personajeId = personajeId;
  }

  public String getContenido() {
    return contenido;
  }

  public void setContenido(String contenido) {
    this.contenido = contenido;
  }

  public Long getPersonajeId() {
    return personajeId;
  }

  public void setPersonajeId(Long personajeId) {
    this.personajeId = personajeId;
  }
}
