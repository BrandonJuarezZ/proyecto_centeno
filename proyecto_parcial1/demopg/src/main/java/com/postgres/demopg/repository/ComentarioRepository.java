package com.postgres.demopg.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.postgres.demopg.models.Comentario;

@Repository
public interface ComentarioRepository extends JpaRepository<Comentario, Long> {
  List<Comentario> findByPersonajeId(Long personajeId);
  
  List<Comentario> findByUsuarioId(Long usuarioId);
  
  void deleteByIdAndUsuarioId(Long comentarioId, Long usuarioId);
}
