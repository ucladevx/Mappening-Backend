CREATE DATABASE mapdb;
\c mapdb;

-- List all tables and types

-- \dt
-- \dT+

-- -- Drop all tables and types

-- -- DROP TABLE table_name;
-- -- DROP TYPE type_name;
-- DROP TABLE IF EXISTS test;

-- DROP TABLE IF EXISTS user_account;
-- DROP TABLE IF EXISTS address;
-- DROP TABLE IF EXISTS location;
-- DROP TABLE IF EXISTS event;
-- DROP TABLE IF EXISTS category;
-- DROP TABLE IF EXISTS event_interest;
-- DROP TABLE IF EXISTS event_category;

-- DROP TYPE IF EXISTS source;
-- DROP TYPE IF EXISTS academic_quarter;

-- Test data

CREATE TABLE test (id INT PRIMARY KEY, name VARCHAR (100) NOT NULL);
\copy test FROM '/docker-entrypoint-initdb.d/data/test.csv' DELIMITER ',' CSV HEADER;

-- Create all tables and types

CREATE TABLE user_account (
    id SERIAL PRIMARY KEY,
    g_id VARCHAR (100) NOT NULL,
    name VARCHAR (100) NOT NULL,
    email VARCHAR (255) UNIQUE NOT NULL,
    picture_url text,
    is_organizer BOOL DEFAULT FALSE,
    last_login_at TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE address (
    id SERIAL PRIMARY KEY,
    name VARCHAR (255) UNIQUE NOT NULL,
    street VARCHAR (255),
    latitude DECIMAL NOT NULL,
    longitude DECIMAL NOT NULL,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE location (
    id SERIAL PRIMARY KEY,
    name VARCHAR (255),
    address_id INT REFERENCES address(id),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TYPE source AS ENUM ('Eventbrite', 'Facebook', 'Manual');
CREATE TYPE academic_quarter AS ENUM ('Fall', 'Winter', 'Spring', 'Summer');
CREATE TABLE event (
    id SERIAL PRIMARY KEY,
    external_id VARCHAR (100) NOT NULL,
    external_source source NOT NULL,
    external_url VARCHAR (255),
    name VARCHAR (100) NOT NULL,
    starts_at TIMESTAMP NOT NULL,
    ends_at TIMESTAMP NOT NULL,
    quarter academic_quarter NOT NULL,
    organizer_id INT REFERENCES user_account(id),
    venue_id INT REFERENCES location(id),
    description text,
    picture_url text,
    free_food BOOL DEFAULT false,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE category (
    id SERIAL PRIMARY KEY,
    name VARCHAR (100) UNIQUE,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE event_interest (
    event_id INT REFERENCES event(id),
    user_id INT REFERENCES user_account(id),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, user_id)
);

CREATE TABLE event_category (
    event_id INT REFERENCES event(id),
    category_id INT REFERENCES category(id),
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, category_id)
);

-- Create update timestamp triggers

CREATE OR REPLACE FUNCTION update_timestamp_column() RETURNS TRIGGER AS 
$$
BEGIN
   NEW.updated_at = CURRENT_TIMESTAMP; 
   RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_timestamp BEFORE UPDATE
    ON user_account FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_timestamp BEFORE UPDATE
    ON event FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_timestamp BEFORE UPDATE
    ON category FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_timestamp BEFORE UPDATE
    ON location FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_timestamp BEFORE UPDATE
    ON event_interest FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_timestamp BEFORE UPDATE
    ON event_category FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

CREATE TRIGGER update_timestamp BEFORE UPDATE
    ON address FOR EACH ROW EXECUTE PROCEDURE update_timestamp_column();

-- Populate all tables

\copy user_account (g_id,name,email,picture_url,is_organizer,last_login_at) FROM '/docker-entrypoint-initdb.d/data/user_account.csv' DELIMITER ',' CSV HEADER;

-- SELECT location.name, address.name FROM location, address WHERE location.address_id = address.id;
\copy address (name,street,latitude,longitude) FROM '/docker-entrypoint-initdb.d/data/address.csv' DELIMITER ',' CSV HEADER;
\copy location (name,address_id) FROM '/docker-entrypoint-initdb.d/data/location.csv' DELIMITER ',' CSV HEADER;

\copy event (external_id,external_source,external_url,name,starts_at,ends_at,quarter,organizer_id,venue_id,description,picture_url,free_food) FROM '/docker-entrypoint-initdb.d/data/event.csv' DELIMITER ',' CSV HEADER;
\copy category (name) FROM '/docker-entrypoint-initdb.d/data/category.csv' DELIMITER ',' CSV HEADER;
\copy event_interest (event_id,user_id) FROM '/docker-entrypoint-initdb.d/data/event_interest.csv' DELIMITER ',' CSV HEADER;
\copy event_category (event_id,category_id) FROM '/docker-entrypoint-initdb.d/data/event_category.csv' DELIMITER ',' CSV HEADER;

-- Modify starting value for serial sequences

-- SELECT c.relname FROM pg_class c WHERE c.relkind = 'S';
-- SELECT last_value FROM *_id_seq;

SELECT setval('user_account_id_seq', (SELECT MAX(id) FROM user_account));
SELECT setval('event_id_seq', (SELECT MAX(id) FROM event));
SELECT setval('category_id_seq', (SELECT MAX(id) FROM category));
SELECT setval('location_id_seq', (SELECT MAX(id) FROM location));
SELECT setval('address_id_seq', (SELECT MAX(id) FROM address));
