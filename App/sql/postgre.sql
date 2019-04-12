CREATE EXTENSION IF NOT EXISTS 'uuid-ossp';

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
    name         varchar(50) NOT NULL,
    address      varchar(250) NOT NULL,
    location     varchar(50) NOT NULL,
    open_time    TIME NOT NULL,
    close_time   TIME NOT NULL,
    contacts     NUMERIC(10,0) NOT NULL,
    primary key (rid)
);

CREATE TABLE customers (
	uid         uuid primary key references users on delete cascade
);

CREATE TABLE registers (
    uid     uuid NOT NULL,
    rid     uuid NOT NULL,
    primary key (rid),
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
    rid     uuid NOT NULL UNIQUE,
    primary key (rid),
    foreign key (cid) references categories (cid),
    foreign key (rid) references restaurants (rid) on delete cascade
);

CREATE TABLE menus (
    mid     uuid UNIQUE DEFAULT uuid_generate_v4 (),
    rid     uuid NOT NULL,
    name    varchar(50),
    primary key (mid),
    foreign key (rid) references restaurants (rid) on delete cascade
);

CREATE TABLE items (
    iid         uuid UNIQUE NOT NULL DEFAULT uuid_generate_v4 (),
    name        varchar(50) NOT NULL,
    price       decimal(8,2) NOT NULL,
    description text,
    mid         uuid NOT NULL,
    primary key (iid),
    foreign key (mid) references menus (mid) on delete cascade
);

CREATE TABLE reservations (
  resid       uuid DEFAULT uuid_generate_v4 (),
  restime     time NOT NULL,
  resdate     date NOT NULL,
  numpeople   integer NOT NULL,
  discount    integer DEFAULT 0,
  primary key (resid)
);

CREATE TABLE processes (
    resid     uuid NOT NULL,
    rid       uuid NOT NULL,
    primary key (resid),
    foreign key (resid) references reservations (resid) on delete cascade,
    foreign key (rid) references restaurants (rid) on delete cascade
);

CREATE TABLE books (
    resid     uuid NOT NULL,
    uid       uuid NOT NULL,
    primary key (resid),
    foreign key (resid) references reservations (resid) on delete cascade,
    foreign key (uid) references customers (uid) on delete cascade
);

CREATE TABLE rewards (
    rewid   uuid DEFAULT uuid_generate_v4 (),
    value   integer NOT NULL,
    primary key (rewid)
);

CREATE TABLE earns (
    rewid     uuid NOT NULL,
    uid       uuid NOT NULL,
    primary key (rewid),
    foreign key (rewid) references rewards (rewid) on delete cascade,
    foreign key (uid) references customers (uid) on delete cascade
);

CREATE TABLE ratings (
    resid     uuid NOT NULL,
    rating    NUMERIC(2,1) NOT NULL,
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

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('b5eacf40-8170-40b3-826b-5d9d00280e31', 'xinze', '$2b$10$UZjC3PNlK1IBwZQfeipMkeavQCwG9N53tLpA.OyzV0c591cCNpIKm', 'xinze', 'li', '87563745');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('a4ac8567-f9e8-4baf-957c-d508e674c8ea', 'lizhi', '$2b$10$ee8SHIdq6xo3e2F2uQe6Y.ysor1A63DtfMxv9Y502QM56.nw6UyKO', 'lizhi', 'zhang', '98789878');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('be00ba64-2752-4f1f-8d97-7ad6046ec361', 'jasonvank', '$2b$10$AZH.L8s3VcHFdlkhxmmk7OFShRPB/IiFAKm5su6d9IUFvenqF5K0q', 'jason', 'van', '12345678');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('428f1791-1217-47c1-aabe-b6d6acef9476', 'changrui', '$2b$10$qRNCRD3ILFYju1L8E2oX/e1/f1BwNcWKmuwDjLA089qo/xmYMkxjG', 'changrui', 'li', '87899878');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('986cf913-b9c7-4d4f-b0c4-66bd231e7f09', 'delong', '$2b$10$fAU5IRE.0PJr.ExA1H3vSO0rorCMe8nneLTYJvhtsoNTspCzk4/76', 'delong', 'xiao', '87895676');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('4b050675-9f76-4f04-95ca-5e34cc0399d7', 'zegang', '$2b$10$/DClXmkWt0RFk5/zfOYR..TOC./rTJcVW2aBjt4LmvVqdRgIuuOZ2', 'zegang', 'zhou', '98009878');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('e86b9b12-1e4a-4df7-9a42-3920b64c23f1', 'wangfei', '$2b$10$cRJcVUa6a0IXgOY5evd8w.yoRJ0tdnRowDdXSV31oUzdlVUIY6bPS', 'fei', 'wang', '98900097');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('21a05c46-96cd-40b2-b00a-f7e8960376b3', 'tingfeng', '$2b$10$F.QyKMrISjU.gpuktLXwouO6Ef9Ysdh0b4US77zpCL3oadadi7KG2', 'tingfeng', 'xie', '98767867');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('5c835253-03f5-476f-9121-17ff0d207119', 'chenglong', '$2b$10$wPV5q0eKswbTH5JUJaCim.ii4bN1iGoiBwuxgrNcIbjnJDT8Arrfi', 'long', 'cheng', '98098766');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('2b11c253-a5c3-4021-aec0-c5772cc8eb1a', 'zhangjie', '$2b$10$AwOE2Kjy9hOMQYnjSOaPpeu7XnsMpXb3NkY9lrGI3DR1fKC/i7eVC', 'jie', 'zhang', '88987898');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('c3705556-91c1-404f-a056-12de7c482e35', 'minyu', '$2b$10$6/uZwQ4bZsvblKztC8ODDurJioLkFVjPxLY/wDrD5jJir2dhXOiJC', 'minyu', 'gao', '98987656');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('49e5527b-5476-40ff-9d06-54de25ac9c7b', 'chengyu', '$2b$10$X75mSmA6qsNZ671eIxdP9uPMTPzweVdFNsphniDsJVWvtXvoaUVC2', 'chengyu', 'hua', '98876787');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('91e15db8-37d8-4771-b7aa-3bb1acb32784', 'shiyuan', '$2b$10$zRHxUDxdYotYmYJmCchHeOOyqBQRtJKVZRuRIpK26UEg1OpKoX8ve', 'shiyuan', 'shui', '98780090');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('9e4b5fbf-6029-479b-b743-0f7f428da2c2', 'linxu', '$2b$10$WOcUySMKc8Zr6bQDSLptRO.JAtqiUIYKTFYKHw7nUgOH4zE4BScpG', 'xu', 'lin', '98765445');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('66cbae09-1692-4ec2-bada-b919b3a54fc0', 'shuiyao', '$2b$10$Gnebd3uzFN7XuWSQcgtwKek.XELEeA.0avvPxLLN/uaJTH4EVxrim', 'yao', 'shui', '98979898');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('ca94b41e-8fdb-4b52-bcdd-3f82d8464d45', 'jinyao', '$2b$10$Q8cHgJQic53PTkQCGBOjNu.lP6KlZVMbVZWQM1tO/RAme7SZkXSgq', 'jinyao', 'lu', '89896754');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('410fd52f-d2c7-4ffe-820b-47d8e7763857', 'hotaru', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Xiong', 'Yiliao', '93698827');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('4c56583e-7266-4a5c-96e0-caf682be1865', 'ponkllama', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Pork', 'Song Jon', '93453455');

INSERT INTO users (user_uid, username, password_hash, first_name, last_name, contact_number)
VALUES ('0f352beb-bd3e-4653-b36d-00ef559fac42', 'foodie', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Love', 'Eating', '91234123');

insert into users(user_uid, username, password_hash, first_name, last_name, contact_number)
values ('517E32D8-10BF-A8B8-C7E5-5791E00E39E8', 'LEE', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','LEE', 'LEE', '84508450');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES ('A6065EAA-253F-312C-CBAB-481720D955EB','user1, Alex','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','90934647');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('B76366D7-08D8-E102-CA7B-7DECCE8CFB55','user2, Alex','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','98302246');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('3C8C082C-19D7-BCDF-35D3-5279D5F815B1','user3, Alex','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','82988144');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES ('7301D2B1-B70D-2847-D433-CA1FDBE1491C','user4, Alex','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','96940755');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES ('C7702DAC-5326-9197-DD17-45514964E470','Gray','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','86094246');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('0AA5DF54-FB38-8DE5-2B3F-BFCA693633EC','Best','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','88192319');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('1B31FA5E-6F85-4D52-CF74-C94D977FC564','Carpenter','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','83759414');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('11D7142F-4E7B-C046-81D2-08300269356F','Flynn','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','98918197');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('CA669A06-B499-0AB8-0785-B26CC6CA1D92','Ewing','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','82374174');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('A23DA39B-9607-4B52-2A88-75503EEB96B1','Kane','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','89313114');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('B47E665E-FFD2-41A2-C8D6-0E6CF96CF7F9','Hendrix','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','80614236');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('0AB16C4A-6B43-B9F0-D8FB-25EB9CB12EA0','Adams','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','82012958');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('BE6B047B-127D-05A9-67CF-6EA4C2B97D6F','Cain','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','90178462');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('2A49480B-15D8-B6F8-EFE8-E2EBF825B9F2','Calhoun','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','88192194');
----------------------------------------

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES ('1EE2BCCF-5F02-4D80-F51E-10BFD6F0D36F','Cole','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','83416677');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('222E4E78-98EB-19F0-3A1D-130DFB75922E','Mccoy','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','85871002');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('26D40867-8FAB-F75F-E42E-35A8FB234D79','Le','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','80193572');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('22ED6620-3661-5881-2146-B1A8B81F13F6','Sweet','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','83741374');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('08C5E762-174E-73AD-1CC5-DD222CA5DC99','Salazar','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','85470703');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('2B60DEF5-B57F-C5AE-1DD8-34F4918D351F','Murray','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','96771444');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('BE9457DF-8401-7DF3-6A0D-A5800FC79477','Dotson','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','85057891');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('A7DC90B7-3D37-2D30-DD05-C36428F314B5','Mathis','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','83417346');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('A84A6ED2-8711-7A9C-D8F0-C19FD97F4115','Gordon','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','91121359');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('7FB4A065-137F-50AC-A3A6-A18CC104CE45','Bass','$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC','Lao','Five','80428611');

----------
INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('7d0be3d8-b0eb-4ffc-ad50-ae1054deb036', 'chaosthingy', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Botang', 'Uno', '12345123');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('ab441c22-00a3-4234-859b-223e61a0b6bd', 'qwerty', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Bob', 'Donald', '23443533');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('ef31d445-aa7a-4f71-b2fb-fd20b5e4f8ad', 'shroom', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'John', 'Smith', '23257489');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('6208e397-e720-4b18-848c-46b8c83a9a36', 'okay', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Steve', 'Horvey', '98374828');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('90393790-d935-4234-8ed2-479b991ef377', 'hello123', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Peter', 'Green', '98762324');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('8a3f7081-7ed4-4996-9203-2c0deeda571b', 'gamergod88', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Jane', 'Popo', '98172342');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('ad1e0a90-9eab-4888-a77c-a80f3e91ea56', 'bobo', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Bobo', 'Tan', '98712364');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('0b8041db-2700-4695-821a-44ee977bad58', 'johnathan', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Johnathan', 'Joestar', '24657468');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('197c344c-10a7-45e1-a91d-56916ea9d279', 'jojo', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Joseph', 'Joestar', '58567364');

INSERT INTO users (user_uid,username,password_hash,first_name,last_name,contact_number)
VALUES('42496f99-b5d8-4b4d-b033-ed16b602399a', 'jotaro', '$2b$10$QU1IB9xEAKzCCmp7BMo9POH4rMXOyqbFzJigI/s5fqvfVLoBocPQC', 'Jotaro', 'Kujo', '46587865');

--customers
INSERT INTO customers (uid)
VALUES ('fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO customers (uid)
VALUES ('410fd52f-d2c7-4ffe-820b-47d8e7763857');

INSERT INTO customers (uid)
VALUES ('4c56583e-7266-4a5c-96e0-caf682be1865');

INSERT INTO customers (uid)
VALUES ('0f352beb-bd3e-4653-b36d-00ef559fac42');

--customer reward
INSERT INTO rewards (rewid, value)
VALUES ('fe6400b3-1e84-405e-a340-dbc539b5f41a', 50);

INSERT INTO earns (rewid, uid)
VALUES ('fe6400b3-1e84-405e-a340-dbc539b5f41a', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO rewards (rewid, value)
VALUES ('abcd00b3-1e84-405e-a340-dbc539b5f41a', 30);

INSERT INTO earns (rewid, uid)
VALUES ('abcd00b3-1e84-405e-a340-dbc539b5f41a', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO rewards (rewid, value)
VALUES ('817b92de-aea6-4730-998e-cce2ec28cd83', 20);

INSERT INTO earns (rewid, uid)
VALUES ('817b92de-aea6-4730-998e-cce2ec28cd83', '410fd52f-d2c7-4ffe-820b-47d8e7763857');


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

INSERT INTO managers (uid)
VALUES ('b5eacf40-8170-40b3-826b-5d9d00280e31');

INSERT INTO managers (uid)
VALUES ('a4ac8567-f9e8-4baf-957c-d508e674c8ea');

INSERT INTO managers (uid)
VALUES ('be00ba64-2752-4f1f-8d97-7ad6046ec361');

INSERT INTO managers (uid)
VALUES ('428f1791-1217-47c1-aabe-b6d6acef9476');

INSERT INTO managers (uid)
VALUES ('986cf913-b9c7-4d4f-b0c4-66bd231e7f09');

INSERT INTO managers (uid)
VALUES ('4b050675-9f76-4f04-95ca-5e34cc0399d7');

INSERT INTO managers (uid)
VALUES ('e86b9b12-1e4a-4df7-9a42-3920b64c23f1');

INSERT INTO managers (uid)
VALUES ('21a05c46-96cd-40b2-b00a-f7e8960376b3');

INSERT INTO managers (uid)
VALUES ('5c835253-03f5-476f-9121-17ff0d207119');

INSERT INTO managers (uid)
VALUES ('2b11c253-a5c3-4021-aec0-c5772cc8eb1a');

INSERT INTO managers (uid)
VALUES ('c3705556-91c1-404f-a056-12de7c482e35');

INSERT INTO managers (uid)
VALUES ('49e5527b-5476-40ff-9d06-54de25ac9c7b');

INSERT INTO managers (uid)
VALUES ('91e15db8-37d8-4771-b7aa-3bb1acb32784');

INSERT INTO managers (uid)
VALUES ('9e4b5fbf-6029-479b-b743-0f7f428da2c2');

INSERT INTO managers (uid)
VALUES ('66cbae09-1692-4ec2-bada-b919b3a54fc0');

INSERT INTO managers (uid)
VALUES ('ca94b41e-8fdb-4b52-bcdd-3f82d8464d45');

--------------------------------------------------------
INSERT INTO managers (uid)
VALUES ('1EE2BCCF-5F02-4D80-F51E-10BFD6F0D36F');

INSERT INTO managers (uid)
VALUES ('222E4E78-98EB-19F0-3A1D-130DFB75922E');

INSERT INTO managers (uid)
VALUES ('26D40867-8FAB-F75F-E42E-35A8FB234D79');

INSERT INTO managers (uid)
VALUES ('22ED6620-3661-5881-2146-B1A8B81F13F6');

INSERT INTO managers (uid)
VALUES ('08C5E762-174E-73AD-1CC5-DD222CA5DC99');

INSERT INTO managers (uid)
VALUES ('2B60DEF5-B57F-C5AE-1DD8-34F4918D351F');

INSERT INTO managers (uid)
VALUES ('BE9457DF-8401-7DF3-6A0D-A5800FC79477');

INSERT INTO managers (uid)
VALUES ('A7DC90B7-3D37-2D30-DD05-C36428F314B5');

INSERT INTO managers (uid)
VALUES ('A84A6ED2-8711-7A9C-D8F0-C19FD97F4115');

INSERT INTO managers (uid)
VALUES ('7FB4A065-137F-50AC-A3A6-A18CC104CE45');

INSERT INTO managers (uid)
VALUES ('7d0be3d8-b0eb-4ffc-ad50-ae1054deb036');

INSERT INTO managers (uid)
VALUES ('ab441c22-00a3-4234-859b-223e61a0b6bd');

INSERT INTO managers (uid)
VALUES ('ef31d445-aa7a-4f71-b2fb-fd20b5e4f8ad');

INSERT INTO managers (uid)
VALUES ('6208e397-e720-4b18-848c-46b8c83a9a36');

INSERT INTO managers (uid)
VALUES ('90393790-d935-4234-8ed2-479b991ef377');

INSERT INTO managers (uid)
VALUES ('8a3f7081-7ed4-4996-9203-2c0deeda571b');

INSERT INTO managers (uid)
VALUES ('ad1e0a90-9eab-4888-a77c-a80f3e91ea56');

INSERT INTO managers (uid)
VALUES ('0b8041db-2700-4695-821a-44ee977bad58');

INSERT INTO managers (uid)
VALUES ('197c344c-10a7-45e1-a91d-56916ea9d279');

INSERT INTO managers (uid)
VALUES ('42496f99-b5d8-4b4d-b033-ed16b602399a');


--restaurants
INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('7b49a151-dacd-49c5-b49e-116d3889ed38', 'Parks Chicken Rice', 'Prince Georges Park', 'West', '08:30', '14:00', 98765432);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('31aa07d3-a0ab-4fb2-ab52-f58070acf393', 'KFC', 'Toa Payoh', 'Central', '07:30', '19:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('22459a9b-80d6-429d-a65a-af0b883160b0', 'Mc Donalds', 'Toa Payoh', 'Central', '07:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('609cace1-6b36-45b1-868d-f4fa463f358a', 'Burger King', 'Orchard', 'Central', '07:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('e2b4cfea-8358-4f8b-bae8-cfaab688376f', 'Jumbo', 'East Coast', 'East', '07:30', '23:00', 88505532);

---------------------------------------------------------------------------------------------------------
INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('6423E498-6D68-2E93-9A4F-D3784056C9D7', 'KFC (Kent Ridge)', 'East Coast', 'East', '06:30', '23:50', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('A2D6F06B-D75F-07CB-8EAD-3CF8C5B16121', 'KFC (East Coast)', 'East Coast', 'East', '09:30', '22:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('92933D0B-E261-9BDE-9CC3-4E1F7A2D8883', 'Mc Donalds (South East)', 'East Coast', 'East', '08:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('1D7C5463-B494-4545-FC8C-05C8C7F62262', 'Subway (Kent Ridge)', 'East Coast', 'West', '07:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('CC610696-910A-724F-FAC9-281A5839D8B1', 'Subway (Bouna Vista)', 'East Coast', 'West', '04:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('162189E2-94FD-66E5-AF00-121B43D93508', 'Crystal Jade (Holland Village)', 'East Coast', 'South', '09:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('2914C6F4-EBE9-0C4E-FA8B-E027561710C9', 'Crystal Jade (Orchard)', 'East Coast', 'South', '12:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('470C0298-16A1-ADF0-3F6A-3F183D8A0950', 'Crystal Jade (Vivo City)', 'East Coast', 'West', '07:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('B75A9B18-7C5F-44D6-D6C9-A9A2B235DF41', 'XingWang (Kent Ridge)', 'East Coast', 'North', '07:30', '23:00', 88505532);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('4B0D5F3A-4538-19AF-3E7E-A7F80196F7D0', 'The Royal Bistro (Utown)', 'East Coast', 'East', '07:30', '23:00', 88505532);
---------------------------------------
INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('0782e093-7a43-4bca-b1a3-ad0febc789a1', 'Texas Chicken', 'Star Vista', 'West', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('0e085d21-0cc4-4ed3-9640-a458beabe5e6', 'Prata World', 'Clementi', 'West', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('f4e73d7c-0f8e-46fe-bdcf-542d5378b4e8', 'Sakae Sushi', 'East Coast', 'East', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('9096d2aa-4d88-47ef-ab2e-8aa9b00694bd', 'Sushi Tei', 'Orchard Road', 'Central', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('31827027-bf45-410b-9e08-6d48a06dbf4d', 'Seafood Galore', 'Commonwealth', 'Central', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('08c0ff8a-30ba-45dc-b321-e4dd6854b87f', 'Pizza Hut', 'Clementi', 'West', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('ceb714b6-d7d3-43aa-ab9a-f062e675186f', 'Chinese Takeout', 'Clementi', 'West', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('63211439-c828-4e8f-95cd-cb51d7ecedd0', 'Oppa BBQ', 'Jurong', 'West', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('cc568518-4cd5-4648-a986-96e2b6735ba5', 'Vegetarian Planet', 'Jurong', 'West', '08:00', '20:00', 91928472);

INSERT INTO restaurants (rid, name, address, location, open_time, close_time, contacts)
VALUES ('eaefbc91-86ea-4028-9a7d-348df2108d68', 'Canton Paradise', 'Star Vista', 'West', '08:00', '20:00', 91928472);


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

--------------------------------------------------------------------------------
INSERT INTO registers (uid, rid)
VALUES ('1EE2BCCF-5F02-4D80-F51E-10BFD6F0D36F', '6423E498-6D68-2E93-9A4F-D3784056C9D7');

INSERT INTO registers (uid, rid)
VALUES ('222E4E78-98EB-19F0-3A1D-130DFB75922E', 'A2D6F06B-D75F-07CB-8EAD-3CF8C5B16121');

INSERT INTO registers (uid, rid)
VALUES ('26D40867-8FAB-F75F-E42E-35A8FB234D79', '92933D0B-E261-9BDE-9CC3-4E1F7A2D8883');

INSERT INTO registers (uid, rid)
VALUES ('22ED6620-3661-5881-2146-B1A8B81F13F6', '1D7C5463-B494-4545-FC8C-05C8C7F62262');

INSERT INTO registers (uid, rid)
VALUES ('08C5E762-174E-73AD-1CC5-DD222CA5DC99', 'CC610696-910A-724F-FAC9-281A5839D8B1');

INSERT INTO registers (uid, rid)
VALUES ('2B60DEF5-B57F-C5AE-1DD8-34F4918D351F', '162189E2-94FD-66E5-AF00-121B43D93508');

INSERT INTO registers (uid, rid)
VALUES ('BE9457DF-8401-7DF3-6A0D-A5800FC79477', '2914C6F4-EBE9-0C4E-FA8B-E027561710C9');

INSERT INTO registers (uid, rid)
VALUES ('A7DC90B7-3D37-2D30-DD05-C36428F314B5', '470C0298-16A1-ADF0-3F6A-3F183D8A0950');

INSERT INTO registers (uid, rid)
VALUES ('A84A6ED2-8711-7A9C-D8F0-C19FD97F4115', 'B75A9B18-7C5F-44D6-D6C9-A9A2B235DF41');

INSERT INTO registers (uid, rid)
VALUES ('7FB4A065-137F-50AC-A3A6-A18CC104CE45', '4B0D5F3A-4538-19AF-3E7E-A7F80196F7D0');

INSERT INTO registers (rid, uid)
VALUES ('0782e093-7a43-4bca-b1a3-ad0febc789a1', '7d0be3d8-b0eb-4ffc-ad50-ae1054deb036');

INSERT INTO registers (rid, uid)
VALUES ('0e085d21-0cc4-4ed3-9640-a458beabe5e6', 'ab441c22-00a3-4234-859b-223e61a0b6bd');

INSERT INTO registers (rid, uid)
VALUES ('f4e73d7c-0f8e-46fe-bdcf-542d5378b4e8', 'ef31d445-aa7a-4f71-b2fb-fd20b5e4f8ad');

INSERT INTO registers (rid, uid)
VALUES ('9096d2aa-4d88-47ef-ab2e-8aa9b00694bd', '6208e397-e720-4b18-848c-46b8c83a9a36');

INSERT INTO registers (rid, uid)
VALUES ('31827027-bf45-410b-9e08-6d48a06dbf4d', '90393790-d935-4234-8ed2-479b991ef377');

INSERT INTO registers (rid, uid)
VALUES ('08c0ff8a-30ba-45dc-b321-e4dd6854b87f', '8a3f7081-7ed4-4996-9203-2c0deeda571b');

INSERT INTO registers (rid, uid)
VALUES ('ceb714b6-d7d3-43aa-ab9a-f062e675186f', 'ad1e0a90-9eab-4888-a77c-a80f3e91ea56');

INSERT INTO registers (rid, uid)
VALUES ('63211439-c828-4e8f-95cd-cb51d7ecedd0', '0b8041db-2700-4695-821a-44ee977bad58');

INSERT INTO registers (rid, uid)
VALUES ('cc568518-4cd5-4648-a986-96e2b6735ba5', '197c344c-10a7-45e1-a91d-56916ea9d279');

INSERT INTO registers (rid, uid)
VALUES ('eaefbc91-86ea-4028-9a7d-348df2108d68', '42496f99-b5d8-4b4d-b033-ed16b602399a');

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
--------------------------------

INSERT INTO menus (mid, rid, name)
VALUES ('C943C5E4-C65D-ABF4-959E-63B5F51B420A', '6423E498-6D68-2E93-9A4F-D3784056C9D7', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('FECC1C80-05E8-D9FD-1A6A-9E528AEADE7A', 'A2D6F06B-D75F-07CB-8EAD-3CF8C5B16121', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('9DD31637-9769-853A-849B-9C8508EBA100', '92933D0B-E261-9BDE-9CC3-4E1F7A2D8883', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('A7C11C18-BDF8-CE26-287E-6B50C0206069', '1D7C5463-B494-4545-FC8C-05C8C7F62262', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('200CC939-AE0F-5863-B6C9-A01103B6B303', 'CC610696-910A-724F-FAC9-281A5839D8B1', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('36661948-A1DF-C099-25B7-C3C08D70024C', '162189E2-94FD-66E5-AF00-121B43D93508', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('9BB6E0C4-318B-147B-3F71-280EE20439A4', '2914C6F4-EBE9-0C4E-FA8B-E027561710C9', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('A35340F5-1C6C-CBC2-1B22-F36985B42759', '470C0298-16A1-ADF0-3F6A-3F183D8A0950', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('BB46C94D-C14A-3706-7A3B-11A673970295', 'B75A9B18-7C5F-44D6-D6C9-A9A2B235DF41', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('C1CD8987-FA41-13EA-F9F6-81B14B6E62F8', '4B0D5F3A-4538-19AF-3E7E-A7F80196F7D0', 'breakfast');

INSERT INTO menus (mid, rid, name)
VALUES ('911e4dd0-f566-4209-84a5-3cf96bccc0a6', '0782e093-7a43-4bca-b1a3-ad0febc789a1', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('411df567-e677-4f00-af1d-b1cdc5b278a1', '0e085d21-0cc4-4ed3-9640-a458beabe5e6', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('218be75d-81aa-4ab7-add1-4176979cbc0f', 'f4e73d7c-0f8e-46fe-bdcf-542d5378b4e8', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('f19f118f-a2c3-4ccc-8a63-eb4c7da27cc4', '9096d2aa-4d88-47ef-ab2e-8aa9b00694bd', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('8328f829-a6b4-41df-b838-29541c1e34e4', '31827027-bf45-410b-9e08-6d48a06dbf4d', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('936e675d-ef4d-49cf-b3df-65eadd88e483', '08c0ff8a-30ba-45dc-b321-e4dd6854b87f', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('a8ddfcdf-f757-4d7d-8774-d83b2eec626a', 'ceb714b6-d7d3-43aa-ab9a-f062e675186f', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('5086accc-3c3d-43a1-ab77-92ce3cbdda7b', '63211439-c828-4e8f-95cd-cb51d7ecedd0', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('fb91b6b3-54ad-4ec2-af9e-d595a66525a3', 'cc568518-4cd5-4648-a986-96e2b6735ba5', 'All Day Menu');

INSERT INTO menus (mid, rid, name)
VALUES ('f916c8de-7bf4-4b8b-bdb1-97162fdec814', 'eaefbc91-86ea-4028-9a7d-348df2108d68', 'All Day Menu');



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

-----------------------All day menus--------------------------
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', '911e4dd0-f566-4209-84a5-3cf96bccc0a6');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', '911e4dd0-f566-4209-84a5-3cf96bccc0a6');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', '911e4dd0-f566-4209-84a5-3cf96bccc0a6');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', '911e4dd0-f566-4209-84a5-3cf96bccc0a6');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', '411df567-e677-4f00-af1d-b1cdc5b278a1');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', '411df567-e677-4f00-af1d-b1cdc5b278a1');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', '411df567-e677-4f00-af1d-b1cdc5b278a1');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', '411df567-e677-4f00-af1d-b1cdc5b278a1');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', '218be75d-81aa-4ab7-add1-4176979cbc0f');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', '218be75d-81aa-4ab7-add1-4176979cbc0f');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', '218be75d-81aa-4ab7-add1-4176979cbc0f');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', '218be75d-81aa-4ab7-add1-4176979cbc0f');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', 'f19f118f-a2c3-4ccc-8a63-eb4c7da27cc4');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', 'f19f118f-a2c3-4ccc-8a63-eb4c7da27cc4');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', 'f19f118f-a2c3-4ccc-8a63-eb4c7da27cc4');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', 'f19f118f-a2c3-4ccc-8a63-eb4c7da27cc4');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', '8328f829-a6b4-41df-b838-29541c1e34e4');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', '8328f829-a6b4-41df-b838-29541c1e34e4');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', '8328f829-a6b4-41df-b838-29541c1e34e4');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', '8328f829-a6b4-41df-b838-29541c1e34e4');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', '936e675d-ef4d-49cf-b3df-65eadd88e483');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', '936e675d-ef4d-49cf-b3df-65eadd88e483');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', '936e675d-ef4d-49cf-b3df-65eadd88e483');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', '936e675d-ef4d-49cf-b3df-65eadd88e483');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', 'a8ddfcdf-f757-4d7d-8774-d83b2eec626a');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', 'a8ddfcdf-f757-4d7d-8774-d83b2eec626a');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', 'a8ddfcdf-f757-4d7d-8774-d83b2eec626a');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', 'a8ddfcdf-f757-4d7d-8774-d83b2eec626a');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', '5086accc-3c3d-43a1-ab77-92ce3cbdda7b');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', '5086accc-3c3d-43a1-ab77-92ce3cbdda7b');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', '5086accc-3c3d-43a1-ab77-92ce3cbdda7b');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', '5086accc-3c3d-43a1-ab77-92ce3cbdda7b');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', 'fb91b6b3-54ad-4ec2-af9e-d595a66525a3');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', 'fb91b6b3-54ad-4ec2-af9e-d595a66525a3');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', 'fb91b6b3-54ad-4ec2-af9e-d595a66525a3');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', 'fb91b6b3-54ad-4ec2-af9e-d595a66525a3');
---
INSERT INTO items (name, price, description, mid)
VALUES ('chicken', '6', 'freshest grilled chicken', 'f916c8de-7bf4-4b8b-bdb1-97162fdec814');

INSERT INTO items (name, price, description, mid)
VALUES ('wow vegetables', '3', 'delicious cooked vegetables', 'f916c8de-7bf4-4b8b-bdb1-97162fdec814');

INSERT INTO items (name, price, description, mid)
VALUES ('assorted mushrooms', '5', 'mushrooms coated in delicious sauce', 'f916c8de-7bf4-4b8b-bdb1-97162fdec814');

INSERT INTO items (name, price, description, mid)
VALUES ('rice', '1', 'fluffy white rice, goes with anything', 'f916c8de-7bf4-4b8b-bdb1-97162fdec814');

--reservations
INSERT INTO reservations (resid, restime, resdate, numpeople, discount)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', '03:00', '2019-04-05', 3, 50);

INSERT INTO reservations (resid, restime, resdate, numpeople, discount)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', '07:00', '2019-04-05', 2, 30);

INSERT INTO reservations (resid, restime, resdate, numpeople, discount)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', '14:00', '2019-04-15', 5, 10);

INSERT INTO reservations (resid, restime, resdate, numpeople)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', '08:00', '2019-03-15', 15);

INSERT INTO reservations (resid, restime, resdate, numpeople, discount)
VALUES ('8fc486b4-8fcf-4f4e-bb41-9f6a09d3c632', '13:00', '2019-04-05', 3, 50);

INSERT INTO reservations (resid, restime, resdate, numpeople, discount)
VALUES ('114445ff-4662-4e26-aa41-c4b2d11e58f0', '13:30', '2019-04-06', 3, 20);

INSERT INTO reservations (resid, restime, resdate, numpeople, discount)
VALUES ('4eb96026-d2f4-4eaf-a9a3-1db592e890e7', '14:30', '2019-04-26', 2, 10);


--books
INSERT INTO books (resid, uid)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO books (resid, uid)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO books (resid, uid)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');

INSERT INTO books (resid, uid)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', 'fa9d34a8-78e5-4e3e-a800-e5b56554668e');


INSERT INTO books (resid, uid)
VALUES ('8fc486b4-8fcf-4f4e-bb41-9f6a09d3c632', '410fd52f-d2c7-4ffe-820b-47d8e7763857');

INSERT INTO books (resid, uid)
VALUES ('114445ff-4662-4e26-aa41-c4b2d11e58f0', '410fd52f-d2c7-4ffe-820b-47d8e7763857');

INSERT INTO books (resid, uid)
VALUES ('4eb96026-d2f4-4eaf-a9a3-1db592e890e7', '410fd52f-d2c7-4ffe-820b-47d8e7763857');


--processes
INSERT INTO processes (resid, rid)
VALUES ('a6b1a41c-a889-4d2a-bb9e-e07c8de05d6f', '7b49a151-dacd-49c5-b49e-116d3889ed38');

INSERT INTO processes (resid, rid)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');

INSERT INTO processes (resid, rid)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');

INSERT INTO processes (resid, rid)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', '31aa07d3-a0ab-4fb2-ab52-f58070acf393');

INSERT INTO processes (resid, rid)
VALUES ('8fc486b4-8fcf-4f4e-bb41-9f6a09d3c632', '7b49a151-dacd-49c5-b49e-116d3889ed38');

INSERT INTO processes (resid, rid)
VALUES ('114445ff-4662-4e26-aa41-c4b2d11e58f0', 'e2b4cfea-8358-4f8b-bae8-cfaab688376f');

INSERT INTO processes (resid, rid)
VALUES ('4eb96026-d2f4-4eaf-a9a3-1db592e890e7', '22459a9b-80d6-429d-a65a-af0b883160b0');

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
VALUES ('7b49a151-dacd-49c5-b49e-116d3889ed38', '74367fad-d083-4898-aa93-6c214870c460');

INSERT INTO belongs (rid, cid)
VALUES ('31aa07d3-a0ab-4fb2-ab52-f58070acf393', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('22459a9b-80d6-429d-a65a-af0b883160b0', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('609cace1-6b36-45b1-868d-f4fa463f358a', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('e2b4cfea-8358-4f8b-bae8-cfaab688376f', '3b688933-e5ae-483a-87b1-3c3c99be8749');

---------------------------------------------------------------------------
INSERT INTO belongs (rid, cid)
VALUES ('6423E498-6D68-2E93-9A4F-D3784056C9D7', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('A2D6F06B-D75F-07CB-8EAD-3CF8C5B16121', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('92933D0B-E261-9BDE-9CC3-4E1F7A2D8883', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('1D7C5463-B494-4545-FC8C-05C8C7F62262', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('CC610696-910A-724F-FAC9-281A5839D8B1', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('162189E2-94FD-66E5-AF00-121B43D93508', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('2914C6F4-EBE9-0C4E-FA8B-E027561710C9', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('470C0298-16A1-ADF0-3F6A-3F183D8A0950', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('B75A9B18-7C5F-44D6-D6C9-A9A2B235DF41', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('4B0D5F3A-4538-19AF-3E7E-A7F80196F7D0', '54321535-9cc0-457f-94b8-39edb9eb891b');

INSERT INTO belongs (rid, cid)
VALUES ('0782e093-7a43-4bca-b1a3-ad0febc789a1', '74367fad-d083-4898-aa93-6c214870c460');

INSERT INTO belongs (rid, cid)
VALUES ('0e085d21-0cc4-4ed3-9640-a458beabe5e6', '958407cf-8ef0-40ca-a537-801d7f92e684');

INSERT INTO belongs (rid, cid)
VALUES ('f4e73d7c-0f8e-46fe-bdcf-542d5378b4e8', '8f87cee1-d078-429d-807a-e4e4db2e3a36');

INSERT INTO belongs (rid, cid)
VALUES ('9096d2aa-4d88-47ef-ab2e-8aa9b00694bd', '8f87cee1-d078-429d-807a-e4e4db2e3a36');

INSERT INTO belongs (rid, cid)
VALUES ('31827027-bf45-410b-9e08-6d48a06dbf4d', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('08c0ff8a-30ba-45dc-b321-e4dd6854b87f', '74367fad-d083-4898-aa93-6c214870c460');

INSERT INTO belongs (rid, cid)
VALUES ('ceb714b6-d7d3-43aa-ab9a-f062e675186f', '3b688933-e5ae-483a-87b1-3c3c99be8749');

INSERT INTO belongs (rid, cid)
VALUES ('63211439-c828-4e8f-95cd-cb51d7ecedd0', '74367fad-d083-4898-aa93-6c214870c460');

INSERT INTO belongs (rid, cid)
VALUES ('cc568518-4cd5-4648-a986-96e2b6735ba5', '958407cf-8ef0-40ca-a537-801d7f92e684');

INSERT INTO belongs (rid, cid)
VALUES ('eaefbc91-86ea-4028-9a7d-348df2108d68', '3b688933-e5ae-483a-87b1-3c3c99be8749');

--ratings
INSERT INTO ratings (resid, rating)
VALUES ('b2a5078d-df7a-46f2-a4c1-d60b9a168394', 3.0);

INSERT INTO ratings (resid, rating)
VALUES ('235a555f-6c36-4b57-b34c-eb92db1276d2', 4.0);

INSERT INTO ratings (resid, rating)
VALUES ('d2d3fa97-bb8f-450a-9f2a-fe58df40133c', 4.0);

CREATE OR REPLACE FUNCTION validate_reservation_date()
RETURNS TRIGGER AS
$$
DECLARE current_date DATE;
BEGIN
 SELECT CURRENT_DATE INTO current_date;
 IF NEW.resdate < CURRENT_DATE THEN RAISE NOTICE 'Date is before today!';
 RAISE EXCEPTION 'Please enter a date that is today or later';
 RETURN NULL;
 ELSE RETURN NEW;
 END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER validate_reservation_date
BEFORE INSERT ON reservations
FOR EACH ROW
EXECUTE PROCEDURE validate_reservation_date();

CREATE OR REPLACE FUNCTION validate_reservation_time()
RETURNS TRIGGER AS
$$
DECLARE opentime TIME;
DECLARE closetime TIME;
DECLARE reservid uuid;
DECLARE restaurant uuid;
DECLARE reservtime TIME;
BEGIN
 SELECT NEW.resid INTO reservid;
 SELECT NEW.rid INTO restaurant;
 SELECT restime from reservations where resid = reservid INTO reservtime;
 SELECT open_time from restaurants where rid = restaurant INTO opentime;
 SELECT close_time from restaurants where rid = restaurant INTO closetime;
 IF closetime < opentime AND reservtime > closetime AND reservtime < opentime THEN RAISE NOTICE 'close<open!';
 RAISE EXCEPTION 'Please choose a time when the restaurant is open';
 RETURN NULL;
 ELSIF reservtime > closetime OR reservtime < opentime AND closetime > opentime THEN RAISE NOTICE 'close>open!';
 RAISE EXCEPTION 'Please choose a time when the restaurant is open';
 RETURN NULL;
 ELSE RETURN NEW;
 END IF;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER validate_reservation_time
BEFORE INSERT ON processes
FOR EACH ROW
EXECUTE PROCEDURE validate_reservation_time();
