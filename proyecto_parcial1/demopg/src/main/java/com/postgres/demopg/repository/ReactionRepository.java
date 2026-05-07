package com.postgres.demopg.repository;

import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.postgres.demopg.models.EReaction;
import com.postgres.demopg.models.Reaction;

@Repository
public interface ReactionRepository extends JpaRepository<Reaction, Long> {
  Optional<Reaction> findByDescription(EReaction description);
}
