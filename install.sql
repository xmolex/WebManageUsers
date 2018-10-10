CREATE TABLE users
(
  id serial,
  login character varying(100) NOT NULL,
  pass character varying(150),
  last_time timestamp without time zone DEFAULT now(),
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

CREATE TABLE users_salt
(
  id integer NOT NULL,
  salt character varying(10) NOT NULL,
  CONSTRAINT users_salt_pkey PRIMARY KEY (id)
);

CREATE TABLE users_sess
(
  sess character varying(50) NOT NULL,
  user_id integer NOT NULL,
  ctime timestamp without time zone DEFAULT now(),
  CONSTRAINT users_sess_pkey PRIMARY KEY (sess, user_id)
);