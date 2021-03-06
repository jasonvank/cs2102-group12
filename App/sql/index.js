const sql = {}

sql.query = {
  // Register
  user_info: 'SELECT * FROM users WHERE username = $1',
  user_register: 'INSERT INTO users (username, password_hash, last_name, first_name, contact_number) VALUES ($1,$2,$3,$4,$5) RETURNING user_uid',
  manager_register: 'INSERT INTO managers (uid) VALUES ($1)',
  customer_register: 'INSERT INTO customers (uid) VALUES ($1)',
  reset_password: 'UPDATE users SET password_hash = $2 WHERE user_uid = $1',
  update_info: 'UPDATE users SET first_name = $2, last_name=$3, contact_number=$4 where user_uid = $1',


  check_user_status: '' +
  'SELECT sum(value) AS total ' +
  'FROM rewards NATURAL JOIN earns NATURAL JOIN customers ' +
  'GROUP BY uid ' +
  'HAVING uid = $1',

  // User Profile Page
  display_current_reservations: "" +
  "WITH user_reservations AS ( " +
  "SELECT B.uid AS customer_uid, B.resid AS reservation_id, resdate AS date, restime AS time, numpeople, RE.name AS restaurant_name, RE.location AS location, address, C.name AS categories, RA.rating as rating, R.discount as discount, RE.rid as restaurant_id " +
  "FROM books B LEFT JOIN reservations R ON B.resid = R.resid LEFT JOIN processes P ON P.resid = R.resid LEFT JOIN restaurants RE ON RE.rid = P.rid LEFT JOIN belongs BE ON BE.rid = P.rid LEFT JOIN categories C ON C.cid = BE.cid LEFT JOIN ratings RA ON RA.resid = R.resid " +
  "), " +
  "restaurant_rating AS ( " +
  "SELECT P.rid as restaurant_id, COALESCE(ROUND(AVG(rating)::numeric,1), 5.0) as restaurant_rating " +
  "FROM reservations RE NATURAL JOIN processes P LEFT JOIN ratings RA ON RA.resid = RE.resid " +
  "GROUP BY P.rid " +
  ") " +
  "SELECT * " +
  "FROM restaurant_rating RR Left join user_reservations CR on RR.restaurant_id = CR.restaurant_id " +
  "WHERE customer_uid = $1 AND date >= (select now()) " +
  "ORDER BY date, time, numpeople ",

  display_customer_history: "" +
  "WITH user_reservations AS ( " +
  "SELECT B.uid AS customer_uid, B.resid AS reservation_id, resdate AS date, restime AS time, numpeople, RE.name AS restaurant_name, RE.location AS location, address, C.name AS categories, RA.rating as rating, R.discount as discount, RE.rid as restaurant_id " +
  "FROM books B LEFT JOIN reservations R ON B.resid = R.resid LEFT JOIN processes P ON P.resid = R.resid LEFT JOIN restaurants RE ON RE.rid = P.rid LEFT JOIN belongs BE ON BE.rid = P.rid LEFT JOIN categories C ON C.cid = BE.cid LEFT JOIN ratings RA ON RA.resid = R.resid " +
  "), " +
  "restaurant_rating AS ( " +
  "SELECT P.rid as restaurant_id, COALESCE(ROUND(AVG(rating)::numeric,1), 5.0) as restaurant_rating " +
  "FROM reservations RE NATURAL JOIN processes P LEFT JOIN ratings RA ON RA.resid = RE.resid " +
  "GROUP BY P.rid " +
  ") " +
  "SELECT * " +
  "FROM restaurant_rating RR Left join user_reservations CR on RR.restaurant_id = CR.restaurant_id " +
  "WHERE customer_uid = $1 AND date < (select now()) " +
  "ORDER BY date DESC, time, numpeople, rating, discount ",

  // User history Page
  display_new_bookings: "" +
  "WITH accepted_bookings AS (" +
  "SELECT RE.resid AS reservation_id, RE.restime AS time, RE.resdate AS date, R.uid AS manager_uid, B.uid AS customer_uid, numpeople, name AS restaurant_name, address, open_time, close_time, U.contact_number AS customer_contact, U.username AS username, U.last_name as last_name, U.first_name as first_name " +
  "FROM reservations RE NATURAL JOIN processes P NATURAL JOIN books B INNER JOIN users U ON U.user_uid = B.uid INNER JOIN registers R ON R.rid = P.rid INNER JOIN restaurants RES ON RES.rid = P.rid " +
  ") " +
  "SELECT * " +
  "FROM accepted_bookings " +
  "WHERE manager_uid = $1 AND date >= (select now()) " +
  "ORDER BY date, time, numpeople",

  display_manager_history: "" +
  "WITH accepted_bookings AS (" +
  "SELECT RE.resid AS reservation_id, RE.restime AS time, RE.resdate AS date, R.uid AS manager_uid, B.uid AS customer_uid, numpeople, name AS restaurant_name, address, open_time, close_time, U.contact_number AS customer_contact, U.username AS username, U.last_name as last_name, U.first_name as first_name " +
  "FROM reservations RE NATURAL JOIN processes P NATURAL JOIN books B INNER JOIN users U ON U.user_uid = B.uid INNER JOIN registers R ON R.rid = P.rid INNER JOIN restaurants RES ON RES.rid = P.rid " +
  ") " +
  "SELECT * " +
  "FROM accepted_bookings " +
  "WHERE manager_uid = $1 AND date < (select now()) " +
  "ORDER BY date DESC, time, numpeople",

  display_restaurant_attributes: "" +
  "SELECT r1.name AS rname, c1.name AS cname, address, location, open_time, close_time, contacts, COALESCE(rating, 5.0 ) AS rating " +
  "FROM restaurants r1 NATURAL JOIN belongs b1 INNER JOIN categories c1 on b1.cid = c1.cid LEFT JOIN (SELECT P.rid, ROUND(AVG(rating)::numeric,1) AS rating FROM processes P NATURAL JOIN ratings R GROUP BY rid) AS rating ON r1.rid = rating.rid",

  register_rewards: 'INSERT INTO rewards (value) VALUES ($1) RETURNING rewid',
  customer_register_rewards: 'INSERT INTO earns (uid, rewid) VALUES ($1, $2)',

  display_reservation_rate_value: 'SELECT * FROM ratings WHERE resid = $1',
  rate_reservation_restaurant: 'INSERT INTO ratings (resid, rating) VALUES ($1, $2)',

  // Update
  // update_info: 'UPDATE users SET first_name=$2, last_name=$3 WHERE username=$1',
  update_pass: 'UPDATE users SET password=$2 WHERE username=$1',

  // Restaurants
  restaurant_name_to_rid: 'SELECT rid FROM restaurants WHERE name=$1',
  restaurantid_to_menu: 'SELECT * FROM menus WHERE rid=$1',
  name_rid_to_mid: 'SELECT mid FROM menus WHERE rid=$1 and name=$2',
  menuid_to_item: 'SELECT * FROM items WHERE mid = $1',
  userid_to_restaurant: 'SELECT * FROM restaurants WHERE rid= (SELECT rid FROM registers WHERE uid=$1)',
  add_restaurant: 'INSERT INTO restaurants (name, address, location, open_time, close_time, contacts) VALUES ($1, $2, $3, $4, $5, $6) RETURNING rid',
  register_restaurant: 'INSERT INTO registers (uid, rid) VALUES ($1, $2)',
  add_menu: 'INSERT INTO menus (rid, name) VALUES ($1, $2)',
  userid_to_menu: 'SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.rid=(SELECT rid FROM registers WHERE uid=$1))',
  menu_name_to_mid: 'SELECT mid from menus M INNER JOIN restaurants R1 ON M.rid = R1.rid INNER JOIN registers R2 on r1.rid = r2.rid WHERE R2.uid=$1 AND M.name=$2',
  // (SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.rid=(SELECT rid FROM registers WHERE uid=$1)) AS Temp WHERE name=$2',
  add_menu_item: 'INSERT INTO items (name, price, description, mid) VALUES ($1, $2, $3, $4)',
  item_name_to_iid: 'SELECT iid FROM items WHERE mid = $1 AND name = $2',
  user_item_by_iid: 'SELECT * FROM items WHERE iid = $1',
	cat_name_to_cid: 'SELECT cid FROM categories WHERE name = $1',
	add_category: 'INSERT INTO belongs (cid, rid) VALUES ($1, $2)',

  //search Restaurants
  restaurant_ratings: ""  +
  "CREATE VIEW restaurant_ratings AS " +
  "SELECT r1.name AS rname, COALESCE(ROUND(AVG(rating)::numeric, 1), 5.0) AS rating " +
  "FROM restaurants r1 LEFT JOIN processes p1 on r1.rid = p1.rid " +
  "LEFT JOIN ratings on p1.resid = ratings.resid " +
  "GROUP BY rname",

  delete_restaurant_ratings: "DROP VIEW restaurant_ratings",

  search: "" +
  "SELECT restaurants.name as rname, restaurants.address AS address, categories.name as cname, address, location, open_time, close_time, contacts, rating " +
  "FROM restaurants LEFT JOIN restaurant_ratings ON restaurants.name = restaurant_ratings.rname " +
  "LEFT JOIN belongs on restaurants.rid = belongs.rid " +
  "LEFT JOIN categories on belongs.cid = categories.cid " +
  "WHERE lower(restaurants.name) LIKE $1 " +
  "AND address LIKE $2 " +
  "AND location LIKE $3 " +
  "AND categories.name LIKE $4 " +
  "AND rating >= $5 " +
  "AND REPLACE($6, ' ', open_time::VARCHAR(50))::TIME  between open_time and close_time " +
  "ORDER BY rname, rating, location, cname",


  //Reservations
  get_rewards: 'SELECT value FROM earns LEFT JOIN rewards ON earns.rewid = rewards.rewid WHERE uid = $1',
  select_reward: 'SELECT rewards.rewid FROM earns LEFT JOIN rewards ON earns.rewid = rewards.rewid WHERE uid = $1 AND value = $2',
  delete_reward: 'DELETE FROM rewards WHERE rewid = $1',
  add_reservation: 'INSERT INTO reservations (restime, resdate, numpeople, discount) VALUES ($1, $2, $3, $4) RETURNING resid',
  add_reward: 'INSERT INTO rewards (value) VALUES ($1) RETURNING rewid',
  add_earns: 'INSERT INTO earns (rewid, uid) VALUES ($1, $2)',
  add_books: 'INSERT INTO books (resid, uid) VALUES ($1, $2)',
  add_processes: 'INSERT INTO processes (resid, rid) VALUES ($1, $2)',

  //update Restaurant
  update_restaurant: 'UPDATE restaurants SET name=$2, address=$3, location=$4, open_time=$5, close_time=$6, contacts=$7 WHERE rid=$1',
  update_menu: 'UPDATE menus SET name=$2 WHERE mid=$1',
  update_item: 'UPDATE items SET name=$2, price=$3, description=$4 WHERE iid=$1',

  //delete Restaurant
  delete_restaurant: 'DELETE FROM restaurants WHERE rid=$1',
  delete_rest_belongs: 'DELETE FROM belongs WHERE rid=$1',
  delete_register: 'DELETE FROM registers WHERE rid=$1',
  delete_menu: 'DELETE FROM menus WHERE mid=$1',
  delete_item: 'DELETE FROM items WHERE iid=$1',


  //delete reservation
  remove_processes: 'DELETE FROM processes WHERE resid=$1',
  remove_books: 'DELETE FROM books WHERE resid=$1',
  remove_reservation: 'DELETE FROM reservations WHERE resid=$1',

  //edit reservation
  get_reservation: 'SELECT * FROM reservations WHERE resid=$1',
  update_reservation: 'UPDATE reservations SET resdate=$1, restime=$2, numpeople=$3 WHERE resid=$4',
}


module.exports = sql
