package com.postgres.demopg.controllers;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
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

import com.postgres.demopg.models.Comentario;
import com.postgres.demopg.models.Personaje;
import com.postgres.demopg.models.User;
import com.postgres.demopg.payload.ComentarioRequest;
import com.postgres.demopg.repository.ComentarioRepository;
import com.postgres.demopg.repository.PersonajeRepository;
import com.postgres.demopg.repository.UserRepository;
import com.postgres.demopg.security.UserDetailsImpl;

import jakarta.validation.Valid;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/comentarios")
public class ComentarioController {

  @Autowired
  private ComentarioRepository comentarioRepository;

  @Autowired
  private PersonajeRepository personajeRepository;

  @Autowired
  private UserRepository userRepository;

  @GetMapping("/{personajeId}")
  public ResponseEntity<?> getComentariosByPersonaje(@PathVariable Long personajeId) {
    try {
      Personaje personaje = personajeRepository.findById(personajeId)
          .orElseThrow(() -> new RuntimeException("Character not found"));

      List<Comentario> comentarios = comentarioRepository.findByPersonajeId(personajeId);
      return new ResponseEntity<>(comentarios, HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.NOT_FOUND);
    }
  }

  @PostMapping()
  @PreAuthorize("hasRole('USER') or hasRole('MODERATOR') or hasRole('ADMIN')")
  public ResponseEntity<?> createComentario(@Valid @RequestBody ComentarioRequest comentarioRequest) {
    try {
      Authentication auth = SecurityContextHolder.getContext().getAuthentication();
      UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();

      User user = userRepository.findById(userPrincipal.getId())
          .orElseThrow(() -> new RuntimeException("User not found"));
      Personaje personaje = personajeRepository.findById(comentarioRequest.getPersonajeId())
          .orElseThrow(() -> new RuntimeException("Character not found"));

      Comentario comentario = new Comentario(comentarioRequest.getContenido(), user, personaje);
      Comentario savedComentario = comentarioRepository.save(comentario);

      return new ResponseEntity<>(savedComentario, HttpStatus.CREATED);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }

  @DeleteMapping("/{comentarioId}")
  @PreAuthorize("hasRole('USER') or hasRole('MODERATOR') or hasRole('ADMIN')")
  public ResponseEntity<?> deleteComentario(@PathVariable Long comentarioId) {
    try {
      Authentication auth = SecurityContextHolder.getContext().getAuthentication();
      UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();

      Comentario comentario = comentarioRepository.findById(comentarioId)
          .orElseThrow(() -> new RuntimeException("Comment not found"));

      // Solo el dueño o admin puede eliminar
      if (!comentario.getUsuario().getId().equals(userPrincipal.getId())
          && !userPrincipal.getAuthorities().stream()
              .anyMatch(authority -> authority.getAuthority().equals("ROLE_ADMIN"))) {
        return new ResponseEntity<>("No permission to delete this comment", HttpStatus.FORBIDDEN);
      }

      comentarioRepository.delete(comentario);
      return new ResponseEntity<>("Comment deleted successfully", HttpStatus.OK);
    } catch (Exception e) {
      return new ResponseEntity<>(e.getMessage(), HttpStatus.BAD_REQUEST);
    }
  }
}
