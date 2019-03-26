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
    rmid   char(36),
    primary key (brid, rmid),
    foreign key (brid) references branch_managers.uid,
    foreign key (rmid) references restaurant_managers.uid,
);

CREATE TABLE restaurants (
    rid     uuid DEFAULT uuid_generate_v4 (),
    name    varchar(50) NOT NULL, 
    primary key (rid)
);

CREATE TABLE branches (
    bid     uuid DEFAULT uuid_generate_v4 (),
    name    varchar(50),
    location varchar(50) NOT NULL,
    opentime TIME NOT NULL,
    closetime TIME NOT NULL,
    aveRating NUMERIC(2,1) NOT NULL DEFAULT 5.0,
    contacts  NUMERIC(10,0) NOT NULL,
    CHECK (aveRating >= 0.0 and <= 5.0),
    primary key (bid),
    foreign key (name) references restaurants.name on delete cascade on update cascade
);

CREATE TABLE manages (
    uid     char(36) NOT NULL,
    bid     char(36) NOT NULL,
    primary key (uid, bid),
    foreign key (uid) references branch_managers.uid,
    foreign key (bid) references branches.bid
);

CREATE TABLE opens (
    rid   char(36) NOT NULL,
    bid     char(36) NOT NULL,
    primary key (rid, bid),
    foreign key (rid) references restaurants.rid,
    foreign key (bid) references branches.bid
);

CREATE TABLE registers (
    uid     char(36) NOT NULL,
    rid   char(36) NOT NULL,
    primary key (uid, rid),
    foreign key (uid) references restaurant_managers.uid,
    foreign key (rid) references restaurants.rid
);

CREATE TABLE categories (
    cid    uuid DEFAULT uuid_generate_v4 (),
    name   varchar(50) NOT NULL,
    primary key (cid)
);

CREATE TABLE belongs (
    cid     char(36) NOT NULL,
    rid     char(36) NOT NULL,
    primary key (cid, rid),
    foreign key (cid) references categories.cid,
    foreign key (rid) references restaurants.rid
);

CREATE TABLE menus (
    name  varchar(50),
    mid   uuid DEFAULT uuid_generate_v4 (),
    bid   varchar(50) NOT NULL,
    primary key (mid),
    foreign key (bid) references branches.bid on delete cascade
);

CREATE TABLE provides (
    bid     char(36) NOT NULL,
    mid     char(36) NOT NULL,
    primary key (bid, mid),
    foreign key (bid) references branches.bid,
    foreign key (mid) references menus.mid
);

CREATE TABLE items (
    iid     uuid DEFAULT uuid_generate_v4 (),
    name    varchar(50) NOT NULL,
    price   NUMERIC(3,2) NOT NULL,
    description text,
    mid     char(36), NOT NULL,
    primary key (iid),
    foreign key (mid) references menus.mid on delete cascade
);

CREATE TABLE contains (
    iid     char(36) NOT NULL,
    mid     char(36) NOT NULL,
    primary key (iid, mid),
    foreign key (iid) references items.iid,
    foreign key (mid) references menus.mid
);

CREATE TABLE reservations (
    resid   uuid DEFAULT uuid_generate_v4 (),
    restime timestamp NOT NULL,
    numpeople integer NOT NULL,
    --bid     char(36) NOT NULL,
    primary key (resid)
    --, foreign key (bid) references branches.bid
);

CREATE TABLE processes (
    resid     char(36) NOT NULL,
    bid       char(36) NOT NULL,
    primary key (resid, bid),
    foreign key (resid) references reservations.resid,
    foreign key (bid) references branches.bid
);

CREATE TABLE books (
    resid     char(36) NOT NULL,
    uid       char(36) NOT NULL,
    primary key (resid, uid),
    foreign key (resid) references reservations.resid,
    foreign key (uid) references customers.uid
);

CREATE TABLE rewards (
    rewid   uuid DEFAULT uuid_generate_v4 (),
    value   NUMERIC(3,2) NOT NULL,
    primary key (rewid)
);

CREATE TABLE earns (
    rewid     char(36) NOT NULL,
    uid       char(36) NOT NULL,
    primary key (rewid, uid),
    foreign key (rewid) references rewards.rewid,
    foreign key (uid) references customers.uid
);

INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('meeple', '$2b$10$13BWk/6YJ4JYlxPvkNTnqeT6J8zsPTe592QIen.Le7apc921uebUW', 'Adi', 'Prabawa');
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('adi'   , '$2b$10$Pdcb3BDaN1wATBHyZ0Fymurw1Js01F9nv6xgff42NfOmTrdXT1A.i', 'Mikal', 'Lim');
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('cs2102', '$2b$10$vS4KkX8uenTCNooir9vyUuAuX5gUhSGVql8yQdsDDD4TG8bSUjkt.', 'Kueider', 'Ho');

-- INSERT INTO contacts (first_name, last_name, email, phone)
-- VALUES ('John', 'Smith', 'john.smith@example.com', '408-237-2345');

 

