package com.postgres.demopg.payload;

public class ReactionResponseDTO {
    private Long id;
    private String description;

    public ReactionResponseDTO() {}

    public ReactionResponseDTO(Long id, String description) {
        this.id = id;
        this.description = description;
    }

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
}
