CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    user_name varchar UNIQUE NOT NULL
);

CREATE TABLE plans (
    id BIGSERIAL PRIMARY KEY,
    user_id integer NOT NULL,
    name varchar NOT NULL,
    text varchar NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'todo' CHECK (status IN ('todo', 'progress', 'complete')),
    UNIQUE (user_id, name),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

CREATE INDEX idx_name_plans ON plans (user_id, name);
CREATE INDEX idx_status_plans ON plans (user_id, status);
