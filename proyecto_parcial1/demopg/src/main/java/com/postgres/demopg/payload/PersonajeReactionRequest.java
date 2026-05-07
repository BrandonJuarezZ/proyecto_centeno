package com.postgres.demopg.payload;

import jakarta.validation.constraints.NotNull;

public class PersonajeReactionRequest {
  @NotNull
  private Long personajeId;

  @NotNull
  private Long reactionId;

  public Long getPersonajeId() {
    return personajeId;
  }

  public void setPersonajeId(Long personajeId) {
    this.personajeId = personajeId;
  }

  public Long getReactionId() {
    return reactionId;
  }

  public void setReactionId(Long reactionId) {
    this.reactionId = reactionId;
  }
}
