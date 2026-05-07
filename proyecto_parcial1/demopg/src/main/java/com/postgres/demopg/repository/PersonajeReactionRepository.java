package com.postgres.demopg.repository;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.postgres.demopg.models.EReaction;
import com.postgres.demopg.models.PersonajeReaction;

@Repository
public interface PersonajeReactionRepository extends JpaRepository<PersonajeReaction, Long> {
  Optional<PersonajeReaction> findByUserIdAndPersonajeIdAndReactionDescription(Long userId, Long personajeId, EReaction description);
  
  List<PersonajeReaction> findByPersonajeId(Long personajeId);
  
  List<PersonajeReaction> findByPersonajeIdAndReactionDescription(Long personajeId, EReaction description);
  
  Optional<PersonajeReaction> findByUserIdAndPersonajeId(Long userId, Long personajeId);
  
  void deleteByUserIdAndPersonajeIdAndReactionDescription(Long userId, Long personajeId, EReaction description);
}
