package com.postgres.demopg.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
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
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.postgres.demopg.models.Personaje;
import com.postgres.demopg.models.PersonajeReaction;
import com.postgres.demopg.models.User;
import com.postgres.demopg.payload.ComentarioResponseDTO;
import com.postgres.demopg.payload.PersonajeResponseDTO;
import com.postgres.demopg.payload.ReactionResponseDTO;
import com.postgres.demopg.repository.PersonajeReactionRepository;
import com.postgres.demopg.repository.PersonajeRepository;
import com.postgres.demopg.repository.ReactionRepository;
import com.postgres.demopg.repository.UserRepository;
import com.postgres.demopg.security.UserDetailsImpl;

import jakarta.validation.Valid;
import java.util.stream.Collectors;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/characters")
public class CharacterController {

  @Autowired
  private PersonajeRepository personajeRepository;

  @Autowired
  private UserRepository userRepository;

  @Autowired
  private PersonajeReactionRepository personajeReactionRepository;

  @Autowired
  private ReactionRepository reactionRepository;

  private PersonajeResponseDTO convertToDTO(Personaje personaje, Long userId) {
    var comentariosDTO = personaje.getComentarios().stream()
        .map(c -> new ComentarioResponseDTO(
            c.getId(),
            c.getContenido(),
            c.getUsuario().getUsername(),
            c.getFechaCreacion()
        ))
        .collect(Collectors.toList());

    var reaccionesDTO = personaje.getReacciones().stream()
        .map(r -> new ReactionResponseDTO(
            r.getId(),
            r.getReaction().getDescription().name()
        ))
        .collect(Collectors.toList());

    // Contar likes y dislikes
    long likeCount = personaje.getReacciones().stream()
        .filter(r -> r.getReaction().getDescription().name().equals("REACTION_LIKE"))
        .count();

    long dislikeCount = personaje.getReacciones().stream()
        .filter(r -> r.getReaction().getDescription().name().equals("REACTION_HATE"))
        .count();

    // Verificar si el usuario actual votó
    boolean usuarioHizoPlike = false;
    boolean usuarioHizoDislike = false;

    if (userId != null) {
      usuarioHizoPlike = personaje.getReacciones().stream()
          .anyMatch(r -> r.getUser().getId().equals(userId) && 
                        r.getReaction().getDescription().name().equals("REACTION_LIKE"));

      usuarioHizoDislike = personaje.getReacciones().stream()
          .anyMatch(r -> r.getUser().getId().equals(userId) && 
                        r.getReaction().getDescription().name().equals("REACTION_HATE"));
    }

    return new PersonajeResponseDTO(
        personaje.getId(),
        personaje.getNombre(),
        personaje.getDescripcion(),
        personaje.getVideojuego(),
        personaje.getImagenUrl(),
        personaje.getCreadoPor().getUsername(),
        (int) likeCount,
        (int) dislikeCount,
        usuarioHizoPlike,
        usuarioHizoDislike,
        comentariosDTO,
        reaccionesDTO
    );
  }

  @GetMapping("/all")
  public ResponseEntity<Page<PersonajeResponseDTO>> getAllCharacters(Pageable pageable) {
    // Obtener userId del usuario actual si está autenticado
    final Long userId;
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    if (auth != null && auth.isAuthenticated() && auth.getPrincipal() instanceof UserDetailsImpl) {
      UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();
      userId = userPrincipal.getId();
    } else {
      userId = null;
    }

    Page<Personaje> personajesPage = personajeRepository.findAll(pageable);
    var personajesDTOList = personajesPage.getContent().stream()
        .map(p -> convertToDTO(p, userId))
        .collect(Collectors.toList());
    
    Page<PersonajeResponseDTO> dtoPage = new PageImpl<>(personajesDTOList, pageable, personajesPage.getTotalElements());
    return new ResponseEntity<>(dtoPage, HttpStatus.OK);
  }

  @GetMapping("/{id}")
  public ResponseEntity<?> getCharacterById(@PathVariable("id") long id) {
    Object personaje = personajeRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Character not found for id :: " + id));
    return new ResponseEntity<>(personaje, HttpStatus.OK);
  }

  @PostMapping("/create")
  @PreAuthorize("isAuthenticated()")
  public ResponseEntity<?> createCharacter(@Valid @RequestBody Personaje personaje) {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();

    User user = userRepository.findById(userPrincipal.getId()).orElseThrow();
    personaje.setCreadoPor(user);

    Personaje savedPersonaje = personajeRepository.save(personaje);
    return new ResponseEntity<>(savedPersonaje, HttpStatus.CREATED);
  }

  @PutMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public ResponseEntity<?> updateCharacter(@PathVariable("id") long id,
      @Valid @RequestBody Personaje personajeDetails) {
    Personaje personaje = personajeRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Character not found for id :: " + id));

    personaje.setNombre(personajeDetails.getNombre());

    Personaje updatedPersonaje = personajeRepository.save(personaje);
    return new ResponseEntity<>(updatedPersonaje, HttpStatus.OK);
  }

  @DeleteMapping("/{id}")
  @PreAuthorize("isAuthenticated()")
  public ResponseEntity<?> deleteCharacter(@PathVariable("id") long id) {
    Personaje personaje = personajeRepository.findById(id)
        .orElseThrow(() -> new RuntimeException("Character not found for id :: " + id));

    personajeRepository.delete(personaje);
    return new ResponseEntity<>(HttpStatus.NO_CONTENT);
  }

}
