-- Ensure the script runs in a valid context
CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD 'postgres_pass';

-- Create user if not exists
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_catalog.pg_roles WHERE rolname = 'classkart_user'
   ) THEN
      CREATE ROLE classkart_user WITH LOGIN PASSWORD 'classkart_pass';
   END IF;
END
$do$;

-- Create dev database if not exists
DO
$do$
BEGIN
   IF NOT EXISTS (
      SELECT FROM pg_database WHERE datname = 'classkart_dev'
   ) THEN
      CREATE DATABASE classkart_dev OWNER classkart_user;
   END IF;
END
$do$;

-- Grant privileges to the user
GRANT ALL PRIVILEGES ON DATABASE classkart_dev TO classkart_user;

-- Connect to classkart_dev and create sample table
\connect classkart_dev

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    email VARCHAR(100)
);

INSERT INTO users (name, email) VALUES
('Eric Mathew', 'eric@example.com')
ON CONFLICT DO NOTHING;