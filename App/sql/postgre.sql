CREATE TABLE users (
	uid        varchar(9) PRIMARY KEY,
	username   varchar(255),
	password   varchar(64) NOT NULL,
    first_name varchar(64) NOT NULL,
	last_name  varchar(64) NOT NULL
);

CREATE TABLE restaurant_managers (
	uid     varchar(9),
    foreign key (uid) references users (uid)
);

CREATE TABLE branch_managers (
	uid     varchar(9),
    foreign key (uid) references users (uid),
    primary key (uid)
);

CREATE TABLE administrators (
	uid     varchar(9),
    foreign key (uid) references users (uid),
    primary key (uid)
);

CREATE TABLE customers (
	uid     varchar(9),
    foreign key (uid) references users (uid),
    primary key (uid)
);

CREATE TABLE assigns (
    brid    varchar(9),
    resid   varchar(9),
    primary key (brid, resid)
);

INSERT INTO users (uid, username, password, first_name, last_name)
VALUES ('1', 'meeple', '$2b$10$13BWk/6YJ4JYlxPvkNTnqeT6J8zsPTe592QIen.Le7apc921uebUW', 'Adi', 'Prabawa');
INSERT INTO users (uid, username, password, first_name, last_name)
VALUES ('2', 'adi'   , '$2b$10$Pdcb3BDaN1wATBHyZ0Fymurw1Js01F9nv6xgff42NfOmTrdXT1A.i', 'Mikal', 'Lim');
INSERT INTO users (uid, username, password, first_name, last_name)
VALUES ('3', 'cs2102', '$2b$10$vS4KkX8uenTCNooir9vyUuAuX5gUhSGVql8yQdsDDD4TG8bSUjkt.', 'Kueider', 'Ho');

