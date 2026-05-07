package com.postgres.demopg.startup;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import com.postgres.demopg.models.EReaction;
import com.postgres.demopg.models.Reaction;
import com.postgres.demopg.repository.ReactionRepository;

@Component
public class DataLoader implements ApplicationRunner {

  @Autowired
  private ReactionRepository reactionRepository;

  @Override
  public void run(ApplicationArguments args) throws Exception {
    initializeReactions();
  }

  private void initializeReactions() {
    // Check if reactions already exist
    var likeReaction = reactionRepository.findByDescription(EReaction.REACTION_LIKE);
    var hateReaction = reactionRepository.findByDescription(EReaction.REACTION_HATE);

    if (likeReaction.isEmpty()) {
      reactionRepository.save(new Reaction(EReaction.REACTION_LIKE));
      System.out.println("✅ Created REACTION_LIKE");
    } else {
      System.out.println("✅ REACTION_LIKE already exists");
    }

    if (hateReaction.isEmpty()) {
      reactionRepository.save(new Reaction(EReaction.REACTION_HATE));
      System.out.println("✅ Created REACTION_HATE");
    } else {
      System.out.println("✅ REACTION_HATE already exists");
    }
  }
}
