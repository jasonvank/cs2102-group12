-- drop table assigns;
drop trigger if_menu_name_existed ON menus;
drop function trig_addMenu();

drop trigger validate_reservation_date ON reservations;
drop function validate_reservation_date();

drop trigger validate_reservation_time ON processes;
drop function validate_reservation_time();

drop table belongs cascade;
drop table books cascade;
--drop table rate cascade;
-- drop table contains;
drop table items cascade;
drop table earns cascade;
-- drop table opens;
-- drop table provides;
-- drop table manages;
drop table ratings cascade;
drop table processes cascade;
drop table registers cascade;
drop table menus cascade;
-- drop table branch_managers;
-- drop table branches;
drop table restaurants cascade;
drop table categories cascade;
drop table customers cascade;
drop table reservations cascade;
drop table managers cascade;
drop table rewards cascade;
drop table users cascade;
