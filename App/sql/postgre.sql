CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    user_uid   uuid DEFAULT uuid_generate_v4 (),
	username   varchar(255) NOT NULL,
	password_hash   varchar(64) NOT NULL,
    first_name varchar(64) NOT NULL,
	last_name  varchar(64) NOT NULL,
    primary key (user_uid)
);

CREATE TABLE restaurant_managers (
	uid     char(36),
    foreign key (uid) references users (user_uid)
);

CREATE TABLE branch_managers (
	uid     char(36),
    foreign key (uid) references users (user_uid),
    primary key (uid)
);

CREATE TABLE administrators (
	uid     char(36),
    foreign key (uid) references users (user_uid),
    primary key (uid)
);

CREATE TABLE customers (
	uid     char(36),
    foreign key (uid) references users (user_uid),
    primary key (uid)
);

CREATE TABLE assigns (
    brid    char(36),
    resid   char(36),
    primary key (brid, resid)
);

INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('meeple', '$2b$10$13BWk/6YJ4JYlxPvkNTnqeT6J8zsPTe592QIen.Le7apc921uebUW', 'Adi', 'Prabawa');
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('adi'   , '$2b$10$Pdcb3BDaN1wATBHyZ0Fymurw1Js01F9nv6xgff42NfOmTrdXT1A.i', 'Mikal', 'Lim');
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('cs2102', '$2b$10$vS4KkX8uenTCNooir9vyUuAuX5gUhSGVql8yQdsDDD4TG8bSUjkt.', 'Kueider', 'Ho');

-- INSERT INTO contacts (first_name, last_name, email, phone)
-- VALUES ('John', 'Smith', 'john.smith@example.com', '408-237-2345');

 

