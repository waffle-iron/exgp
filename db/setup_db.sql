CREATE DATABASE exgpdb;

\c exgpdb;

CREATE TABLE account(
  id            BIGSERIAL    PRIMARY KEY   NOT NULL,
  email         VARCHAR(50)  UNIQUE        NOT NULL,
  gid           VARCHAR(20)  UNIQUE        NOT NULL,
  session_key   VARCHAR(36),
  pass_hash     VARCHAR(80)                NOT NULL
);
