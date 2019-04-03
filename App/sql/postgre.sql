CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    user_uid        uuid DEFAULT uuid_generate_v4 (),
	username        varchar(255) NOT NULL,
	password_hash   varchar(64) NOT NULL,
    first_name      varchar(64) NOT NULL,
	last_name       varchar(64) NOT NULL,
    primary key (user_uid),
    unique(username)
);

CREATE TABLE branch_managers (
	uid     uuid primary key references users on delete cascade
);

CREATE TABLE restaurant_managers (
	uid     uuid primary key references users on delete cascade
);

CREATE TABLE restaurants (
    rid     uuid DEFAULT uuid_generate_v4 (),
    uid     uuid NOT NULL,
    name    varchar(50) UNIQUE NOT NULL,
    primary key (rid),
    foreign key (uid) references restaurant_managers (uid)
);

CREATE TABLE branches (
    bid          uuid UNIQUE DEFAULT uuid_generate_v4 (),
    name         varchar(50) UNIQUE NOT NULL,
    uid          uuid NOT NULL,
    address      varchar(50) NOT NULL,
    open_time    TIME NOT NULL,
    close_time   TIME NOT NULL,
    ave_Rating   NUMERIC(2,1) NOT NULL DEFAULT 5.0,
    contacts     NUMERIC(10,0) NOT NULL,
    CHECK (ave_Rating >= 0.0 and ave_Rating <= 5.0),
    primary key (bid),
    foreign key (uid) references restaurant_managers (uid)
    -- foreign key (name) references restaurants (name) on delete cascade on update cascade
);



CREATE TABLE customers (
	uid         uuid primary key references users on delete cascade
);

CREATE TABLE assigns (
    brid   uuid,
    rmid   uuid,
    bid    uuid,
    primary key (brid, rmid, bid),
    foreign key (bid) references branches (bid),
    foreign key (brid) references branch_managers (uid),
    foreign key (rmid) references restaurant_managers (uid)
);

CREATE TABLE manages (
    uid     uuid NOT NULL,
    bid     uuid NOT NULL,
    primary key (uid, bid),
    foreign key (uid) references branch_managers (uid),
    foreign key (bid) references branches (bid)
);

CREATE TABLE opens (
    rid     uuid NOT NULL,
    bid     uuid NOT NULL,
    primary key (rid, bid),
    foreign key (rid) references restaurants (rid) on delete cascade,
    foreign key (bid) references branches (bid)
);

CREATE TABLE registers (
    uid     uuid NOT NULL,
    rid     uuid NOT NULL,
    primary key (uid, rid),
    foreign key (uid) references restaurant_managers (uid),
    foreign key (rid) references restaurants (rid)
);

CREATE TABLE categories (
    cid     uuid DEFAULT uuid_generate_v4 (),
    name    varchar(50) NOT NULL,
    primary key (cid)
);

CREATE TABLE belongs (
    cid     uuid NOT NULL,
    rid     uuid NOT NULL,
    primary key (cid, rid),
    foreign key (cid) references categories (cid),
    foreign key (rid) references restaurants (rid)
);

CREATE TABLE menus (
    mid     uuid UNIQUE DEFAULT uuid_generate_v4 (),
    bid     uuid NOT NULL,
    name    varchar(50),
    primary key (mid, bid),
    foreign key (bid) references branches (bid) on delete cascade
);

CREATE TABLE provides (
    bid     uuid NOT NULL,
    mid     uuid NOT NULL,
    primary key (bid, mid),
    foreign key (bid) references branches (bid) on delete cascade,
    foreign key (mid) references menus (mid)
);

CREATE TABLE items (
    iid         uuid UNIQUE NOT NULL DEFAULT uuid_generate_v4 (),
    name        varchar(50) NOT NULL,
    price       NUMERIC(3,2) NOT NULL,
    description text,
    mid         uuid NOT NULL,
    primary key (iid, mid),
    foreign key (mid) references menus (mid) on delete cascade
);

CREATE TABLE contains (
    iid         uuid NOT NULL,
    mid         uuid NOT NULL,
    primary key (iid, mid),
    foreign key (iid) references items (iid),
    foreign key (mid) references menus (mid) on delete cascade
);

CREATE TABLE reservations (
    resid       uuid DEFAULT uuid_generate_v4 (),
    restime     timestamp NOT NULL,
    numpeople   integer NOT NULL,
    --bid     char(36) NOT NULL,
    primary key (resid)
    --, foreign key (bid) references branches.bid
);

CREATE TABLE processes (
    resid     uuid NOT NULL,
    bid       uuid NOT NULL,
    primary key (resid, bid),
    foreign key (resid) references reservations (resid),
    foreign key (bid) references branches (bid)
);

CREATE TABLE books (
    resid     uuid NOT NULL,
    uid       uuid NOT NULL,
    primary key (resid, uid),
    foreign key (resid) references reservations (resid),
    foreign key (uid) references customers (uid)
);

CREATE TABLE rewards (
    rewid   uuid DEFAULT uuid_generate_v4 (),
    value   NUMERIC(3,2) NOT NULL,
    primary key (rewid)
);

CREATE TABLE earns (
    rewid     uuid NOT NULL,
    uid       uuid NOT NULL,
    primary key (rewid, uid),
    foreign key (rewid) references rewards (rewid),
    foreign key (uid) references customers (uid)
);

INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('spring', '$2b$10$13BWk/6YJ4JYlxPvkNTnqeT6J8zsPTe592QIen.Le7apc921uebUW', 'Sprint', 'Season');
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('summer', '$2b$10$Pdcb3BDaN1wATBHyZ0Fymurw1Js01F9nv6xgff42NfOmTrdXT1A.i', 'Summer', 'Season');
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('autumn', '$2b$10$vS4KkX8uenTCNooir9vyUuAuX5gUhSGVql8yQdsDDD4TG8bSUjkt.', 'Autumn', 'Season');
