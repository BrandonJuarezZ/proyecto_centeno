package com.postgres.demopg.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.postgres.demopg.models.Reaction;
import com.postgres.demopg.repository.ReactionRepository;
import com.postgres.demopg.repository.UserRepository;
import com.postgres.demopg.security.UserDetailsImpl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/debug")
public class DebugController {

  @Autowired
  private ReactionRepository reactionRepository;

  @Autowired
  private UserRepository userRepository;

  @GetMapping("/current-user")
  public Map<String, Object> getCurrentUser() {
    Authentication auth = SecurityContextHolder.getContext().getAuthentication();
    Map<String, Object> response = new HashMap<>();

    if (auth != null && auth.isAuthenticated()) {
      UserDetailsImpl userPrincipal = (UserDetailsImpl) auth.getPrincipal();
      response.put("id", userPrincipal.getId());
      response.put("username", userPrincipal.getUsername());
      response.put("email", userPrincipal.getEmail());
      response.put("authorities", auth.getAuthorities());
    }
    return response;
  }

  @GetMapping("/reactions")
  public List<Reaction> getAllReactions() {
    return reactionRepository.findAll();
  }

  @GetMapping("/users-count")
  public Map<String, Object> getUsersCount() {
    Map<String, Object> response = new HashMap<>();
    response.put("total_users", userRepository.count());
    return response;
  }
}
