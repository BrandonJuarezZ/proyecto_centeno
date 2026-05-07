package com.postgres.demopg.controllers;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.postgres.demopg.models.EReaction;
import com.postgres.demopg.models.Personaje;
import com.postgres.demopg.models.PersonajeReaction;
import com.postgres.demopg.models.Reaction;
import com.postgres.demopg.models.User;
import com.postgres.demopg.payload.PersonajeReactionRequest;
import com.postgres.demopg.repository.PersonajeRepository;
import com.postgres.demopg.repository.PersonajeReactionRepository;
import com.postgres.demopg.repository.ReactionRepository;
import com.postgres.demopg.repository.UserRepository;
import com.postgres.demopg.security.UserDetailsImpl;

import jakarta.validation.Valid;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/character-reactions")
public class CharacterReactionController {

  @Autowired
  private PersonajeReactionRepository personajeReactionRepository;

  @Autowired
  private PersonajeRepository personajeRepository;

  @Autowired
  private ReactionRepository reactionRepository;

  @Autowired
  private UserRepository userRepository;

  @GetMapping("/all")
  public ResponseEntity<Page<PersonajeReaction>> getAllReactions(Pageable pageable) {
    return new ResponseEntity<>(personajeReactionRepository.findAll(pageable), HttpStatus.OK);
  }

  @GetMapping("/character/{personajeId}")
  public ResponseEntity<?> getReactionsByCharacter(@PathVariable Long personajeId) {
    try {
      Personaje personaje = personajeRepository.findById(personajeId)
          .orElseThrow(() -> new RuntimeException("Character not found"));

      List<PersonajeReaction> reactions = personajeReactionRepository.findByPersonajeId(personajeId);

      // Contar likes y hates
      long likes = reactions.stream()
          .filter(r -> r.getReaction().getDescription() == EReaction.REACTION_LIKE)
          .count();
      long hates = reactions.stream()
          .filter(r -> r.getReaction().getDescription() == EReaction.REACTION_HATE)
          .count();

      Map<String, Object> response = new HashMap<>();
      response.put("personajeId", personajeId);
      response.put("likes", likes);
      response.put("hates", hates);
      response.put("reactions", reactions);

      return new ResponseEntity<>(response, HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
    }
  }

  @PostMapping("/create")
  @PreAuthorize("hasRole('USER') or hasRole('MODERATOR') or hasRole('ADMIN')")
  public ResponseEntity<?> createReaction(@Valid @RequestBody PersonajeReactionRequest reactionRequest) {
    try {
      Authentication auth = SecurityContextHolder.getContext().getAuthentication();
      UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();

      User user = userRepository.findById(userPrincipal.getId()).orElseThrow();
      Personaje personaje = personajeRepository.findById(reactionRequest.getPersonajeId())
          .orElseThrow(() -> new RuntimeException("Character not found"));
      Reaction reaction = reactionRepository.findById(reactionRequest.getReactionId())
          .orElseThrow(() -> new RuntimeException("Reaction not found"));

      PersonajeReaction personajeReaction = new PersonajeReaction();
      personajeReaction.setUser(user);
      personajeReaction.setPersonaje(personaje);
      personajeReaction.setReaction(reaction);

      PersonajeReaction savedReaction = personajeReactionRepository.save(personajeReaction);
      return new ResponseEntity<>(savedReaction, HttpStatus.CREATED);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  @PostMapping("/like/{personajeId}")
  @PreAuthorize("hasRole('USER') or hasRole('MODERATOR') or hasRole('ADMIN')")
  public ResponseEntity<?> likeCharacter(@PathVariable Long personajeId) {
    try {
      Authentication auth = SecurityContextHolder.getContext().getAuthentication();
      UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();

      User user = userRepository.findById(userPrincipal.getId()).orElseThrow();
      Personaje personaje = personajeRepository.findById(personajeId)
          .orElseThrow(() -> new RuntimeException("Character not found"));
      Reaction likeReaction = reactionRepository.findByDescription(EReaction.REACTION_LIKE)
          .orElseThrow(() -> new RuntimeException("Like reaction not found"));
      Reaction hateReaction = reactionRepository.findByDescription(EReaction.REACTION_HATE)
          .orElseThrow(() -> new RuntimeException("Hate reaction not found"));

      // Buscar si ya existe una reacción del usuario a este personaje
      var existingReaction = personajeReactionRepository.findByUserIdAndPersonajeId(user.getId(), personajeId);

      if (existingReaction.isPresent()) {
        PersonajeReaction reaction = existingReaction.get();
        if (reaction.getReaction().getDescription() == EReaction.REACTION_LIKE) {
          // Si ya dio like, removerlo
          personajeReactionRepository.delete(reaction);
          return new ResponseEntity<>("Like removed", HttpStatus.OK);
        } else {
          // Si tenía hate, cambiar a like
          reaction.setReaction(likeReaction);
          PersonajeReaction updated = personajeReactionRepository.save(reaction);
          return new ResponseEntity<>(updated, HttpStatus.OK);
        }
      } else {
        // Crear nuevo like
        PersonajeReaction newReaction = new PersonajeReaction();
        newReaction.setUser(user);
        newReaction.setPersonaje(personaje);
        newReaction.setReaction(likeReaction);
        PersonajeReaction saved = personajeReactionRepository.save(newReaction);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
      }
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  @PostMapping("/hate/{personajeId}")
  @PreAuthorize("hasRole('USER') or hasRole('MODERATOR') or hasRole('ADMIN')")
  public ResponseEntity<?> hateCharacter(@PathVariable Long personajeId) {
    try {
      Authentication auth = SecurityContextHolder.getContext().getAuthentication();
      UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();

      User user = userRepository.findById(userPrincipal.getId()).orElseThrow();
      Personaje personaje = personajeRepository.findById(personajeId)
          .orElseThrow(() -> new RuntimeException("Character not found"));
      Reaction hateReaction = reactionRepository.findByDescription(EReaction.REACTION_HATE)
          .orElseThrow(() -> new RuntimeException("Hate reaction not found"));
      Reaction likeReaction = reactionRepository.findByDescription(EReaction.REACTION_LIKE)
          .orElseThrow(() -> new RuntimeException("Like reaction not found"));

      // Buscar si ya existe una reacción del usuario a este personaje
      var existingReaction = personajeReactionRepository.findByUserIdAndPersonajeId(user.getId(), personajeId);

      if (existingReaction.isPresent()) {
        PersonajeReaction reaction = existingReaction.get();
        if (reaction.getReaction().getDescription() == EReaction.REACTION_HATE) {
          // Si ya dio hate, removerlo
          personajeReactionRepository.delete(reaction);
          return new ResponseEntity<>("Hate removed", HttpStatus.OK);
        } else {
          // Si tenía like, cambiar a hate
          reaction.setReaction(hateReaction);
          PersonajeReaction updated = personajeReactionRepository.save(reaction);
          return new ResponseEntity<>(updated, HttpStatus.OK);
        }
      } else {
        // Crear nuevo hate
        PersonajeReaction newReaction = new PersonajeReaction();
        newReaction.setUser(user);
        newReaction.setPersonaje(personaje);
        newReaction.setReaction(hateReaction);
        PersonajeReaction saved = personajeReactionRepository.save(newReaction);
        return new ResponseEntity<>(saved, HttpStatus.CREATED);
      }
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  @DeleteMapping("/{reactionId}")
  @PreAuthorize("hasRole('USER') or hasRole('MODERATOR') or hasRole('ADMIN')")
  public ResponseEntity<?> deleteReaction(@PathVariable Long reactionId) {
    try {
      PersonajeReaction reaction = personajeReactionRepository.findById(reactionId)
          .orElseThrow(() -> new RuntimeException("Reaction not found"));
      personajeReactionRepository.delete(reaction);
      return new ResponseEntity<>("Reaction deleted successfully", HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

}
