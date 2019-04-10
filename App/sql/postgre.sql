CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

CREATE TABLE users (
    user_uid        uuid DEFAULT uuid_generate_v4 (),
	username        varchar(255) NOT NULL,
	password_hash   varchar(64) NOT NULL,
    first_name      varchar(64) NOT NULL,
	last_name       varchar(64) NOT NULL,
	contact_number  NUMERIC(10, 0) NOT NULL,
    primary key (user_uid),
    unique(username)
);

CREATE TABLE managers (
	uid     uuid primary key references users on delete cascade
);

CREATE TABLE restaurants (
    rid          uuid UNIQUE DEFAULT uuid_generate_v4 (),
    name         varchar(50) UNIQUE NOT NULL,
    uid          uuid UNIQUE NOT NULL,
    address      varchar(50) NOT NULL,
    location     varchar(50) NOT NULL,
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

CREATE TABLE registers (
    uid     uuid NOT NULL,
    rid     uuid NOT NULL,
    primary key (uid, rid),
    foreign key (uid) references managers (uid),
    foreign key (rid) references restaurants (rid)
);

CREATE TABLE categories (
    cid     uuid NOT NULL,
    name    varchar(50) NOT NULL,
    primary key (cid)
);

CREATE TABLE belongs (
    cid     uuid NOT NULL,
    rid     uuid NOT NULL,
    primary key (cid, rid),
    foreign key (cid) references categories (cid),
    foreign key (rid) references restaurants (rid) on delete cascade
);

CREATE TABLE menus (
    mid     uuid UNIQUE DEFAULT uuid_generate_v4 (),
    rid     uuid NOT NULL,
    name    varchar(50),
    primary key (mid, rid, name),
    foreign key (rid) references restaurants (rid) on delete cascade
);

CREATE TABLE items (
    iid         uuid UNIQUE NOT NULL DEFAULT uuid_generate_v4 (),
    name        varchar(50) NOT NULL,
    price       decimal(8,2) NOT NULL,
    description text,
    mid         uuid NOT NULL,
    primary key (iid, mid, name),
    foreign key (mid) references menus (mid) on delete cascade
);

CREATE TABLE reservations (
  resid       uuid DEFAULT uuid_generate_v4 (),
  restime     time NOT NULL,
  resdate     date NOT NULL,
  numpeople   integer NOT NULL,
  discount    integer DEFAULT 0,
  --rid     char(36) NOT NULL,
  primary key (resid)
  --, foreign key (rid) references restaurants.rid
);

CREATE TABLE processes (
    resid     uuid NOT NULL,
    rid       uuid NOT NULL,
    primary key (resid, rid),
    foreign key (resid) references reservations (resid) on delete cascade,
    foreign key (rid) references restaurants (rid) on delete cascade
);

CREATE TABLE books (
    resid     uuid NOT NULL,
    uid       uuid NOT NULL,
    primary key (resid, uid),
    foreign key (resid) references reservations (resid) on delete cascade,
    foreign key (uid) references customers (uid) on delete cascade
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
    foreign key (rewid) references rewards (rewid) on delete cascade,
    foreign key (uid) references customers (uid) on delete cascade
);

CREATE TABLE ratings (
    resid     uuid NOT NULL,
    rating   NUMERIC(2,1) NOT NULL DEFAULT 5.0,
    CHECK (rating >= 0.0 and rating <= 5.0),
    primary key (resid),
    foreign key (resid) references reservations (resid) on delete cascade
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

--Users
INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('d0a7f883-36fc-4094-9330-7c932381662a', 'customer', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'customer', 'customer', '84508450');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('fa9d34a8-78e5-4e3e-a800-e5b56554668e', 'summer', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Summer', 'Season', '77554433');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('cc659a63-df54-4922-80e0-950105c98d29', 'autumn', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Autumn', 'Season', '33445566');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('f58a8552-cfe6-4669-a098-8d6fd533c157', 'manager', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'manager', 'Lee', '84508450');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('aca97eca-337d-4b0e-b1bc-789f5acdff87', 'manager1', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'manager', 'Zhang', '84508450');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('0b6a7521-788a-4430-9614-9cd379ba9fde', 'manager2', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'manager', 'Chen', '84508450');

--customers
INSERT INTO customers (uid)
VALUES ('fa9d34a8-78e5-4e3e-a800-e5b56554668e');

--customer reward
INSERT INTO rewards (rewid, value)
VALUES ('fe6400b3-1e84-405e-a340-dbc539b5f41a', 50);

INSERT INTO earns (rewid, uid)
VALUES ('fe6400b3-1e84-405e-a340-dbc539b5f41a', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO rewards (rewid, value)
VALUES ('abcd00b3-1e84-405e-a340-dbc539b5f41a', 30);

INSERT INTO earns (rewid, uid)
VALUES ('abcd00b3-1e84-405e-a340-dbc539b5f41a', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

--managers
INSERT INTO managers (uid)
VALUES ('d0a7f883-36fc-4094-9330-7c932381662a');

INSERT INTO managers (uid)
VALUES ('f58a8552-cfe6-4669-a098-8d6fd533c157');

INSERT INTO managers (uid)
VALUES ('aca97eca-337d-4b0e-b1bc-789f5acdff87');

INSERT INTO managers (uid)
VALUES ('cc659a63-df54-4922-80e0-950105c98d29');

INSERT INTO managers (uid)
VALUES ('0b6a7521-788a-4430-9614-9cd379ba9fde');

--restaurants
INSERT INTO restaurants (rid, name, uid, address, location, open_time, close_time, contacts)
VALUES ('7b49a151-dacd-49c5-b49e-116d3889ed38', 'Parks Chicken Rice', 'd0a7f883-36fc-4094-9330-7c932381662a', 'Prince Georges Park', 'West', '13:30', '04:00', 98765432);

INSERT INTO restaurants (rid, name, uid, address, location, open_time, close_time, contacts)
VALUES ('31aa07d3-a0ab-4fb2-ab52-f58070acf393', 'KFC', 'f58a8552-cfe6-4669-a098-8d6fd533c157', 'Toa Payoh', 'Central', '07:30', '01:00', 88505532);

INSERT INTO restaurants (rid, name, uid, address, location, open_time, close_time, contacts)
VALUES ('22459a9b-80d6-429d-a65a-af0b883160b0', 'Mc Donalds', '0b6a7521-788a-4430-9614-9cd379ba9fde', 'Toa Payoh', 'Central', '07:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, uid, address, location, open_time, close_time, contacts)
VALUES ('609cace1-6b36-45b1-868d-f4fa463f358a', 'Burger King', 'aca97eca-337d-4b0e-b1bc-789f5acdff87', 'Orchard', 'Central', '07:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, uid, address, location, open_time, close_time, contacts)
VALUES ('e2b4cfea-8358-4f8b-bae8-cfaab688376f', 'Jumbo', 'cc659a63-df54-4922-80e0-950105c98d29', 'East Coast', 'East', '07:30', '23:00', 88505532);

--registers
INSERT INTO registers (uid, rid)
VALUES ('d0a7f883-36fc-4094-9330-7c932381662a', '7b49a151-dacd-49c5-b49e-116d3889ed38');

INSERT INTO registers (uid, rid)
VALUES ('cc659a63-df54-4922-80e0-950105c98d29', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');

INSERT INTO registers (uid, rid)
VALUES ('f58a8552-cfe6-4669-a098-8d6fd533c157', '22459a9b-80d6-429d-a65a-af0b883160b0');

INSERT INTO registers (uid, rid)
VALUES ('aca97eca-337d-4b0e-b1bc-789f5acdff87', '609cace1-6b36-45b1-868d-f4fa463f358a');

INSERT INTO registers (uid, rid)
VALUES ('0b6a7521-788a-4430-9614-9cd379ba9fde', 'e2b4cfea-8358-4f8b-bae8-cfaab688376f');

--menus
INSERT INTO menus (mid, rid, name)
VALUES ('9215008a-bcb3-4f54-a2a0-627bb149a77e', '7b49a151-dacd-49c5-b49e-116d3889ed38', 'dinner');

INSERT INTO menus (mid, rid, name)
VALUES ('4c79a7f5-b9d9-4f17-a07a-d25967ef6745', '7b49a151-dacd-49c5-b49e-116d3889ed38', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('2c52eec4-3dae-431d-98e1-258418f1e264', '31aa07d3-a0ab-4fb2-ab52-f58070acf393', 'dinner');

INSERT INTO menus (mid, rid, name)
VALUES ('0829f390-66f8-42e3-8d38-de30fd26b358', '31aa07d3-a0ab-4fb2-ab52-f58070acf393', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('854b1727-8e04-4af8-8482-371c54c44c1f', '22459a9b-80d6-429d-a65a-af0b883160b0', 'dinner');

INSERT INTO menus (mid, rid, name)
VALUES ('229df288-13e2-445e-8462-71327d62e0c7', '22459a9b-80d6-429d-a65a-af0b883160b0', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('57e36364-2769-469d-8ba0-3d2183fc8a56', '609cace1-6b36-45b1-868d-f4fa463f358a', 'dinner');

INSERT INTO menus (mid, rid, name)
VALUES ('5f4d0157-c22e-41ae-8106-a07fb00678fb', '609cace1-6b36-45b1-868d-f4fa463f358a', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('d997f068-ec56-45d9-8e67-eb2257eee703', 'e2b4cfea-8358-4f8b-bae8-cfaab688376f', 'dinner');

INSERT INTO menus (mid, rid, name)
VALUES ('5a68c459-8023-407b-9312-6573159ce0f0', 'e2b4cfea-8358-4f8b-bae8-cfaab688376f', 'breakfast');

--items
--dinner--------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('steak', '80', 'wagyu beef', '9215008a-bcb3-4f54-a2a0-627bb149a77e');

INSERT INTO items (name, price, description, mid)
VALUES ('lamb', '60', 'best lamb', '9215008a-bcb3-4f54-a2a0-627bb149a77e');

INSERT INTO items (name, price, description, mid)
VALUES ('spaghetti', '20', 'italian spaghetti', '9215008a-bcb3-4f54-a2a0-627bb149a77e');

INSERT INTO items (name, price, description, mid)
VALUES ('Hawaiian Pizza', '20', 'italian pizza', '9215008a-bcb3-4f54-a2a0-627bb149a77e');

INSERT INTO items (name, price, description, mid)
VALUES ('mushroom soup', '15', 'cream soup', '9215008a-bcb3-4f54-a2a0-627bb149a77e');

INSERT INTO items (name, price, description, mid)
VALUES ('chicken chop', '20', 'chicken', '9215008a-bcb3-4f54-a2a0-627bb149a77e');
------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('steak', '80', 'wagyu beef', '2c52eec4-3dae-431d-98e1-258418f1e264');

INSERT INTO items (name, price, description, mid)
VALUES ('lamb', '60', 'best lamb', '2c52eec4-3dae-431d-98e1-258418f1e264');

INSERT INTO items (name, price, description, mid)
VALUES ('spaghetti', '20', 'italian spaghetti', '2c52eec4-3dae-431d-98e1-258418f1e264');

INSERT INTO items (name, price, description, mid)
VALUES ('Hawaiian Pizza', '20', 'italian pizza', '2c52eec4-3dae-431d-98e1-258418f1e264');

INSERT INTO items (name, price, description, mid)
VALUES ('mushroom soup', '15', 'cream soup', '2c52eec4-3dae-431d-98e1-258418f1e264');

INSERT INTO items (name, price, description, mid)
VALUES ('chicken chop', '20', 'chicken', '2c52eec4-3dae-431d-98e1-258418f1e264');
---------------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('steak', '80', 'wagyu beef', '854b1727-8e04-4af8-8482-371c54c44c1f');

INSERT INTO items (name, price, description, mid)
VALUES ('lamb', '60', 'best lamb', '854b1727-8e04-4af8-8482-371c54c44c1f');

INSERT INTO items (name, price, description, mid)
VALUES ('spaghetti', '20', 'italian spaghetti', '854b1727-8e04-4af8-8482-371c54c44c1f');

INSERT INTO items (name, price, description, mid)
VALUES ('Hawaiian Pizza', '20', 'italian pizza', '854b1727-8e04-4af8-8482-371c54c44c1f');

INSERT INTO items (name, price, description, mid)
VALUES ('mushroom soup', '15', 'cream soup', '854b1727-8e04-4af8-8482-371c54c44c1f');

INSERT INTO items (name, price, description, mid)
VALUES ('chicken chop', '20', 'chicken', '854b1727-8e04-4af8-8482-371c54c44c1f');
--------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('steak', '80', 'wagyu beef', '57e36364-2769-469d-8ba0-3d2183fc8a56');

INSERT INTO items (name, price, description, mid)
VALUES ('lamb', '60', 'best lamb', '57e36364-2769-469d-8ba0-3d2183fc8a56');

INSERT INTO items (name, price, description, mid)
VALUES ('spaghetti', '20', 'italian spaghetti', '57e36364-2769-469d-8ba0-3d2183fc8a56');

INSERT INTO items (name, price, description, mid)
VALUES ('Hawaiian Pizza', '20', 'italian pizza', '57e36364-2769-469d-8ba0-3d2183fc8a56');

INSERT INTO items (name, price, description, mid)
VALUES ('mushroom soup', '15', 'cream soup', '57e36364-2769-469d-8ba0-3d2183fc8a56');

INSERT INTO items (name, price, description, mid)
VALUES ('chicken chop', '20', 'chicken', '57e36364-2769-469d-8ba0-3d2183fc8a56');
-----------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('steak', '80', 'wagyu beef', 'd997f068-ec56-45d9-8e67-eb2257eee703');

INSERT INTO items (name, price, description, mid)
VALUES ('lamb', '60', 'best lamb', 'd997f068-ec56-45d9-8e67-eb2257eee703');

INSERT INTO items (name, price, description, mid)
VALUES ('spaghetti', '20', 'italian spaghetti', 'd997f068-ec56-45d9-8e67-eb2257eee703');

INSERT INTO items (name, price, description, mid)
VALUES ('Hawaiian Pizza', '20', 'italian pizza', 'd997f068-ec56-45d9-8e67-eb2257eee703');

INSERT INTO items (name, price, description, mid)
VALUES ('mushroom soup', '15', 'cream soup', 'd997f068-ec56-45d9-8e67-eb2257eee703');

INSERT INTO items (name, price, description, mid)
VALUES ('chicken chop', '20', 'chicken', 'd997f068-ec56-45d9-8e67-eb2257eee703');

--breakfast-----------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('hash brown', '5', 'potato hash brown', '4c79a7f5-b9d9-4f17-a07a-d25967ef6745');

INSERT INTO items (name, price, description, mid)
VALUES ('fried egg', '5', 'egg', '4c79a7f5-b9d9-4f17-a07a-d25967ef6745');

INSERT INTO items (name, price, description, mid)
VALUES ('croissant', '5', 'nice croissant', '4c79a7f5-b9d9-4f17-a07a-d25967ef6745');

INSERT INTO items (name, price, description, mid)
VALUES ('pan cake', '6', 'nice pan cake', '4c79a7f5-b9d9-4f17-a07a-d25967ef6745');

INSERT INTO items (name, price, description, mid)
VALUES ('milk', '5', 'fresh milk', '4c79a7f5-b9d9-4f17-a07a-d25967ef6745');

INSERT INTO items (name, price, description, mid)
VALUES ('orange juice', '8', 'fresh squeezed orange juice', '4c79a7f5-b9d9-4f17-a07a-d25967ef6745');
---------------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('hash brown', '5', 'potato hash brown', '0829f390-66f8-42e3-8d38-de30fd26b358');

INSERT INTO items (name, price, description, mid)
VALUES ('fried egg', '5', 'egg', '0829f390-66f8-42e3-8d38-de30fd26b358');

INSERT INTO items (name, price, description, mid)
VALUES ('croissant', '5', 'nice croissant', '0829f390-66f8-42e3-8d38-de30fd26b358');

INSERT INTO items (name, price, description, mid)
VALUES ('pan cake', '6', 'nice pan cake', '0829f390-66f8-42e3-8d38-de30fd26b358');

INSERT INTO items (name, price, description, mid)
VALUES ('milk', '5', 'fresh milk', '0829f390-66f8-42e3-8d38-de30fd26b358');

INSERT INTO items (name, price, description, mid)
VALUES ('orange juice', '8', 'fresh squeezed orange juice', '0829f390-66f8-42e3-8d38-de30fd26b358');
--------------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('hash brown', '5', 'potato hash brown', '229df288-13e2-445e-8462-71327d62e0c7');

INSERT INTO items (name, price, description, mid)
VALUES ('fried egg', '5', 'egg', '229df288-13e2-445e-8462-71327d62e0c7');

INSERT INTO items (name, price, description, mid)
VALUES ('croissant', '5', 'nice croissant', '229df288-13e2-445e-8462-71327d62e0c7');

INSERT INTO items (name, price, description, mid)
VALUES ('pan cake', '6', 'nice pan cake', '229df288-13e2-445e-8462-71327d62e0c7');

INSERT INTO items (name, price, description, mid)
VALUES ('milk', '5', 'fresh milk', '229df288-13e2-445e-8462-71327d62e0c7');

INSERT INTO items (name, price, description, mid)
VALUES ('orange juice', '8', 'fresh squeezed orange juice', '229df288-13e2-445e-8462-71327d62e0c7');
-----------------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('hash brown', '5', 'potato hash brown', '5f4d0157-c22e-41ae-8106-a07fb00678fb');

INSERT INTO items (name, price, description, mid)
VALUES ('fried egg', '5', 'egg', '5f4d0157-c22e-41ae-8106-a07fb00678fb');

INSERT INTO items (name, price, description, mid)
VALUES ('croissant', '5', 'nice croissant', '5f4d0157-c22e-41ae-8106-a07fb00678fb');

INSERT INTO items (name, price, description, mid)
VALUES ('pan cake', '6', 'nice pan cake', '5f4d0157-c22e-41ae-8106-a07fb00678fb');

INSERT INTO items (name, price, description, mid)
VALUES ('milk', '5', 'fresh milk', '5f4d0157-c22e-41ae-8106-a07fb00678fb');

INSERT INTO items (name, price, description, mid)
VALUES ('orange juice', '8', 'fresh squeezed orange juice', '5f4d0157-c22e-41ae-8106-a07fb00678fb');
----------------------------------------------------------------------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('hash brown', '5', 'potato hash brown', '5a68c459-8023-407b-9312-6573159ce0f0');

INSERT INTO items (name, price, description, mid)
VALUES ('fried egg', '5', 'egg', '5a68c459-8023-407b-9312-6573159ce0f0');

INSERT INTO items (name, price, description, mid)
VALUES ('croissant', '5', 'nice croissant', '5a68c459-8023-407b-9312-6573159ce0f0');

INSERT INTO items (name, price, description, mid)
VALUES ('pan cake', '6', 'nice pan cake', '5a68c459-8023-407b-9312-6573159ce0f0');

INSERT INTO items (name, price, description, mid)
VALUES ('milk', '5', 'fresh milk', '5a68c459-8023-407b-9312-6573159ce0f0');

INSERT INTO items (name, price, description, mid)
VALUES ('orange juice', '8', 'fresh squeezed orange juice', '5a68c459-8023-407b-9312-6573159ce0f0');

--reservations
INSERT INTO reservations (resid, restime, resdate, numpeople)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', '01:00', '2019-03-02', 3);

INSERT INTO reservations (resid, restime, resdate, numpeople)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', '07:00', '2019-04-05', 2);

INSERT INTO reservations (resid, restime, resdate, numpeople)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', '02:00', '2019-04-15', 5);

INSERT INTO reservations (resid, restime, resdate, numpeople)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', '08:00', '2019-03-15', 15);


--books
INSERT INTO books (resid, uid)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO books (resid, uid)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO books (resid, uid)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO books (resid, uid)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');


--processes
INSERT INTO processes (resid, rid)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', '7b49a151-dacd-49c5-b49e-116d3889ed38');

INSERT INTO processes (resid, rid)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');

INSERT INTO processes (resid, rid)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');

INSERT INTO processes (resid, rid)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');

---categories
INSERT INTO categories (cid, name)
VALUES ('54321535-9cc0-457f-94b8-39edb9eb891b', 'Western');

INSERT INTO categories (cid, name)
VALUES ('3b688933-e5ae-483a-87b1-3c3c99be8749', 'Chinese');

INSERT INTO categories (cid, name)
VALUES ('8f87cee1-d078-429d-807a-e4e4db2e3a36', 'Japanese');

INSERT INTO categories (cid, name)
VALUES ('74367fad-d083-4898-aa93-6c214870c460', 'Korean');

INSERT INTO categories (cid, name)
VALUES ('958407cf-8ef0-40ca-a537-801d7f92e684', 'Indian');

--belongs
INSERT INTO belongs (rid, cid)
VALUES ('7b49a151-dacd-49c5-b49e-116d3889ed38', '8f87cee1-d078-429d-807a-e4e4db2e3a36');

INSERT INTO belongs (rid, cid)
VALUES ('31aa07d3-a0ab-4fb2-ab52-f58070acf393', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('22459a9b-80d6-429d-a65a-af0b883160b0', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('609cace1-6b36-45b1-868d-f4fa463f358a', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('e2b4cfea-8358-4f8b-bae8-cfaab688376f', '3b688933-e5ae-483a-87b1-3c3c99be8749');

--ratings
INSERT INTO ratings (resid, rating)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', 3.0);

INSERT INTO ratings (resid, rating)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', 4.0);

INSERT INTO ratings (resid, rating)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', 4.0);


----rates
--INSERT INTO rates (resid, uid, rid)
--VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e', '7b49a151-dacd-49c5-b49e-116d3889ed38');
--
--INSERT INTO rates (resid, uid, rid)
--VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');
--
