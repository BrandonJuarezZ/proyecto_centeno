package com.postgres.demopg;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

import com.postgres.demopg.models.ERole;
import com.postgres.demopg.models.Role;
import com.postgres.demopg.repository.RoleRepository;

@SpringBootApplication
public class DemopgApplication {

	public static void main(String[] args) {
		SpringApplication.run(DemopgApplication.class, args);
	}

	@Bean
	public CommandLineRunner demo(RoleRepository roleRepository) {
		return (args) -> {
			Role roleUser = roleRepository.findByName(ERole.ROLE_USER).orElse(null);
			Role roleModerator = roleRepository.findByName(ERole.ROLE_MODERATOR).orElse(null);
			Role roleAdmin = roleRepository.findByName(ERole.ROLE_ADMIN).orElse(null);

			if (roleUser == null) {
				roleRepository.save(new Role(ERole.ROLE_USER));
			}
			if (roleModerator == null) {
				roleRepository.save(new Role(ERole.ROLE_MODERATOR));
			}
			if (roleAdmin == null) {
				roleRepository.save(new Role(ERole.ROLE_ADMIN));
			}
		};
	}

}
