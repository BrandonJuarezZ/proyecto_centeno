package com.postgres.demopg.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.postgres.demopg.models.Personaje;

@Repository
public interface PersonajeRepository extends JpaRepository<Personaje, Long> {

}
