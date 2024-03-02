-- Create a user table
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  username VARCHAR(100) NOT NULL,
  email VARCHAR(100) UNIQUE NOT NULL UNIQUE
);

-- Insert the first sample entry
INSERT INTO users (username, email) VALUES ('admin', 'admin@localhost');

-- Insert the second sample entry
INSERT INTO users (username, email) VALUES ('contact', 'contact@localhost');
