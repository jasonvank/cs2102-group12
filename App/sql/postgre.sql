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

CREATE TABLE managers (
	uid     uuid primary key references users on delete cascade
);

-- CREATE TABLE restaurants (
--     rid     uuid DEFAULT uuid_generate_v4 (),
--     uid     uuid NOT NULL,
--     name    varchar(50) UNIQUE NOT NULL,
--     primary key (rid),
--     foreign key (uid) references restaurant_managers (uid)
-- );

CREATE TABLE restaurants (
    rid          uuid UNIQUE DEFAULT uuid_generate_v4 (),
    name         varchar(50) UNIQUE NOT NULL,
    uid          uuid UNIQUE NOT NULL,
    address      varchar(50) NOT NULL,
    open_time    TIME NOT NULL,
    close_time   TIME NOT NULL,
    contacts     NUMERIC(10,0) NOT NULL,
    primary key (rid),
    foreign key (uid) references managers (uid)
    -- foreign key (name) references restaurants (name) on delete cascade on update cascade
);



CREATE TABLE customers (
	uid         uuid primary key references users on delete cascade
);

-- CREATE TABLE assigns (
--     brid   uuid,
--     rmid   uuid,
--     bid    uuid,
--     primary key (brid, rmid, bid),
--     foreign key (bid) references branches (bid),
--     foreign key (brid) references branch_managers (uid),
--     foreign key (rmid) references restaurant_managers (uid)
-- );

-- CREATE TABLE manages (
--     uid     uuid NOT NULL,
--     bid     uuid NOT NULL,
--     primary key (uid, bid),
--     foreign key (uid) references branch_managers (uid),
--     foreign key (bid) references branches (bid)
-- );

-- CREATE TABLE opens (
--     rid     uuid NOT NULL,
--     bid     uuid NOT NULL,
--     primary key (rid, bid),
--     foreign key (rid) references restaurants (rid) on delete cascade,
--     foreign key (bid) references branches (bid)
-- );

CREATE TABLE registers (
    uid     uuid NOT NULL,
    rid     uuid NOT NULL,
    primary key (uid, rid),
    foreign key (uid) references managers (uid),
    foreign key (rid) references restaurants (rid)
);

CREATE TABLE categories (
    cid     integer,
    name    varchar(50) NOT NULL,
    primary key (cid)
);

CREATE TABLE belongs (
    cid     integer NOT NULL,
    rid     uuid NOT NULL,
    primary key (cid, rid),
    foreign key (cid) references categories (cid),
    foreign key (rid) references restaurants (rid)
);

CREATE TABLE menus (
    mid     uuid UNIQUE DEFAULT uuid_generate_v4 (),
    rid     uuid NOT NULL,
    name    varchar(50),
    primary key (mid, rid, name),
    foreign key (rid) references restaurants (rid) on delete cascade
);

-- CREATE TABLE provides (
--     rid     uuid NOT NULL,
--     mid     uuid NOT NULL,
--     primary key (rid, mid),
--     foreign key (rid) references restaurants (rid) on delete cascade,
--     foreign key (mid) references menus (mid)
-- );

CREATE TABLE items (
    iid         uuid UNIQUE NOT NULL DEFAULT uuid_generate_v4 (),
    name        varchar(50) NOT NULL,
    price       decimal(8,2) NOT NULL,
    description text,
    mid         uuid NOT NULL,
    primary key (iid, mid, name),
    foreign key (mid) references menus (mid) on delete cascade
);

-- CREATE TABLE contains (
--     iid         uuid NOT NULL,
--     mid         uuid NOT NULL,
--     primary key (iid, mid),
--     foreign key (iid) references items (iid),
--     foreign key (mid) references menus (mid) on delete cascade
-- );

CREATE TABLE reservations (
  resid       uuid DEFAULT uuid_generate_v4 (),
  restime     time NOT NULL,
  resdate     date NOT NULL,
  numpeople   integer NOT NULL,
  --rid     char(36) NOT NULL,
  primary key (resid)
  --, foreign key (rid) references restaurants.rid
);

CREATE TABLE processes (
    resid     uuid NOT NULL,
    rid       uuid NOT NULL,
    primary key (resid, rid),
    foreign key (resid) references reservations (resid),
    foreign key (rid) references restaurants (rid)
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
    value   NUMERIC(5,2) NOT NULL,
    primary key (rewid)
);

CREATE TABLE earns (
    rewid     uuid NOT NULL,
    uid       uuid NOT NULL,
    primary key (rewid, uid),
    foreign key (rewid) references rewards (rewid),
    foreign key (uid) references customers (uid)
);

CREATE TABLE ratings (
    rid     uuid NOT NULL,
    ave_Rating   NUMERIC(2,1) NOT NULL DEFAULT 5.0,
    CHECK (ave_Rating >= 0.0 and ave_Rating <= 5.0),
    primary key (rid),
    foreign key (rid) references restaurants (rid) on delete cascade
);

CREATE TABLE rate (
  resid uuid NOT NULL references reservations(resid),
  uid uuid NOT NULL references customers(uid) on delete cascade,
  rid uuid NOT NULL references restaurants(rid),
  primary key (resid, uid, rid)
);


CREATE OR REPLACE FUNCTION trig_addMenu()
RETURNS TRIGGER AS
$$
DECLARE check_name uuid;
BEGIN
SELECT mid INTO check_name FROM menus WHERE name = NEW.name AND rid = NEW.rid;
IF check_name IS NOT NULL THEN
IF TG_OP = 'UPDATE' AND NEW.mid = check_name THEN
RETURN NEW;
END IF;
RAISE NOTICE 'MENU NAME EXISTED !';
RAISE EXCEPTION 'Menu name entered is already existed: %', NEW.name
      USING HINT = 'Please check your entered name';
RETURN NULL;
ELSE
RETURN NEW;
END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER if_menu_name_existed
BEFORE INSERT OR UPDATE ON menus
FOR EACH ROW
EXECUTE PROCEDURE trig_addMenu();


CREATE OR REPLACE FUNCTION trig_addRestaurant()
RETURNS TRIGGER AS
$$
DECLARE check_name uuid;
BEGIN
SELECT rid INTO check_name FROM restaurants WHERE name = NEW.name;
IF check_name IS NOT NULL THEN
IF TG_OP = 'UPDATE' AND NEW.rid = check_name THEN
RETURN NEW;
END IF;
RAISE NOTICE 'RESTAURANT NAME EXISTED !';
RAISE EXCEPTION 'Restaurant name entered is already existed: %', NEW.name
      USING HINT = 'Please check your entered name';
RETURN NULL;
ELSE
RETURN NEW;
END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER if_restaurant_name_existed
BEFORE INSERT OR UPDATE ON restaurants
FOR EACH ROW
EXECUTE PROCEDURE trig_addRestaurant();

CREATE OR REPLACE FUNCTION trig_addItem()
RETURNS TRIGGER AS
$$
DECLARE check_name uuid;
BEGIN
SELECT iid INTO check_name FROM items WHERE name = NEW.name and mid = NEW.mid;
IF check_name IS NOT NULL THEN
IF TG_OP = 'UPDATE' AND NEW.iid = check_name THEN
RETURN NEW;
END IF;
RAISE NOTICE 'ITEM NAME EXISTED !';
RAISE EXCEPTION 'Item name entered is already existed: %', NEW.name
      USING HINT = 'Please check your entered name';
RETURN NULL;
ELSE
RETURN NEW;
END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER if_item_name_existed
BEFORE INSERT OR UPDATE ON items
FOR EACH ROW
EXECUTE PROCEDURE trig_addItem();

-- Categories
INSERT INTO categories (cid, name)
VALUES (1, 'chinese');
INSERT INTO categories (cid, name)
VALUES (2, 'korean');
INSERT INTO categories (cid, name)
VALUES (3, 'indian');
INSERT INTO categories (cid, name)
VALUES (4, 'western');
INSERT INTO categories (cid, name)
VALUES (5, 'japanese');

--Users
INSERT INTO users (user_uid, username, password_hash, first_name, last_name)
VALUES ('d0a7f883-36fc-4094-9330-7c932381662a', 'spring', '$2b$10$13BWk/6YJ4JYlxPvkNTnqeT6J8zsPTe592QIen.Le7apc921uebUW', 'Sprint', 'Season');
INSERT INTO users (user_uid, username, password_hash, first_name, last_name)
VALUES ('fa9d34a8-78e5-4e3e-a800-e5b56554668e', 'summer', '$2b$10$Pdcb3BDaN1wATBHyZ0Fymurw1Js01F9nv6xgff42NfOmTrdXT1A.i', 'Summer', 'Season');
INSERT INTO users (username, password_hash, first_name, last_name)
VALUES ('autumn', '$2b$10$vS4KkX8uenTCNooir9vyUuAuX5gUhSGVql8yQdsDDD4TG8bSUjkt.', 'Autumn', 'Season');
--customers
INSERT INTO customers (uid)
VALUES ('fa9d34a8-78e5-4e3e-a800-e5b56554668e');

--customer reward
INSERT INTO rewards (rewid, value)
VALUES ('fe6400b3-1e84-405e-a340-dbc539b5f41a', 100);

INSERT INTO earns (rewid, uid)
VALUES ('fe6400b3-1e84-405e-a340-dbc539b5f41a', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

--managers
INSERT INTO managers (uid)
VALUES ('d0a7f883-36fc-4094-9330-7c932381662a');

--restaurants
INSERT INTO restaurants (rid, name, uid, address, open_time, close_time, contacts)
VALUES ('7b49a151-dacd-49c5-b49e-116d3889ed38', 'Parks Chicken Rice', 'd0a7f883-36fc-4094-9330-7c932381662a', 'Prince Georges Park', '01:30', '04:00', 98765432);

--reservations
INSERT INTO reservations (resid, restime, resdate, numpeople)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', '01:00', '2019-06-02', 3);

INSERT INTO books (resid, uid)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO processes (resid, rid)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', '7b49a151-dacd-49c5-b49e-116d3889ed38');
