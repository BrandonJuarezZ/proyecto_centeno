package com.postgres.demopg.models;

import com.fasterxml.jackson.annotation.JsonIgnore;

import jakarta.persistence.*;

@Entity
@Table( name = "personaje_reactions",
          uniqueConstraints = { 
          @UniqueConstraint(columnNames = {"user_id", "personaje_id"}
          ),
      
        }
)

public class PersonajeReaction {

   @Id
   @GeneratedValue(strategy = GenerationType.IDENTITY)
   private Long id;
 
   @Column(name = "reaction_id")
   Long reactionId;

   public Long getReactionId() {
    return reactionId;
}

   public void setReactionId(Long reactionId) {
    this.reactionId = reactionId;
   }

   @Column(name = "user_id")
   Long userId;

    public Long getUserId() {
    return userId;
}

   public void setUserId(Long userId) {
    this.userId = userId;
   }

    @Column(name = "personaje_id")
    Long personajeId;

  public Long getPersonajeId() {
        return personajeId;
    }

    public void setPersonajeId(Long personajeId) {
        this.personajeId = personajeId;
    }

  public Long getId() {
    return id;
}

   public void setId(Long id) {
    this.id = id;
   }

  
    @JsonIgnore
    @ManyToOne
    @MapsId("userId")
    @JoinColumn(name = "user_id")
    User user;

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.userId = user.getId();
        this.user = user;
    }

    @JsonIgnore
    @ManyToOne
    @MapsId("personajeId")
    @JoinColumn(name = "personaje_id")
    Personaje personaje;

    public Personaje getPersonaje() {
        return personaje;
    }

    public void setPersonaje(Personaje personaje) {
        this.personajeId = personaje.getId();
        this.personaje = personaje;
    }

    @ManyToOne
    @MapsId("reactionId")
    @JoinColumn(name = "reaction_id")
    Reaction reaction;

    public Reaction getReaction() {
        return reaction;
    }

    public void setReaction(Reaction reaction) {
        this.reactionId = reaction.getId();
        this.reaction = reaction;
    }

}
