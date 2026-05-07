-- Insert initial reactions if they don't exist
INSERT INTO reactions (description) VALUES ('REACTION_LIKE')
ON CONFLICT (description) DO NOTHING;

INSERT INTO reactions (description) VALUES ('REACTION_HATE')
ON CONFLICT (description) DO NOTHING;
