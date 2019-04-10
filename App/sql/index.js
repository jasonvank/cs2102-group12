const sql = {}

// CREATE VIEW CustomerHistory AS SELECT * from (customers C NATURAL JOIN reservations R1 NATURAL JOIN Processes P NATURAL JOIN books B) LEFT JOIN rate R2 ON R1.resid = R2.resid and C.uid = R2.uid and R2.rid = P.rid

// const current_reservations = "" +
// 	"CREATE VIEW current_reservations AS" +
// 	"SELECT resdate AS date, restime AS time, numpeople, name AS restaurant_name, address, C.name AS categories, R.ave_rating AS rating " +
//     "FROM reservations NATURAL JOIN processes NATURAL JOIN restaurants NATURAL JOIN belongs B INNER JOIN categories C ON C.cid = B.cid inner join Ratings R ON R.rid = B.rid" +
//     "WHERE uid = $1"

sql.query = {
  // Register
  user_info: 'SELECT * FROM users WHERE username = $1',
  user_register: 'INSERT INTO users (username, password_hash, last_name, first_name, contact_number) VALUES ($1,$2,$3,$4,$5) RETURNING user_uid',
  manager_register: 'INSERT INTO managers (uid) VALUES ($1)',
  customer_register: 'INSERT INTO customers (uid) VALUES ($1)',
  reset_password: 'UPDATE users SET password_hash = $2 WHERE user_uid = $1',
  update_info: 'UPDATE users SET first_name = $2, last_name=$3 where user_uid = $1',
  check_user_status: 'SELECT sum(value) AS total FROM rewards NATURAL JOIN earns NATURAL JOIN customers GROUP BY uid HAVING uid = $1',
  rate_reservation_restaurant: 'INSERT INTO ratings (resid, rating) VALUES ($1, $2)',
  display_reservation_rate_value: 'SELECT * FROM ratings WHERE resid = $1',
  // User
  display_customer_history:  "" +
  "WITH current_reservations AS ( " +
  "SELECT B.uid AS customer_uid, B.resid AS reservation_id, resdate AS date, restime AS time, numpeople, RE.name AS restaurant_name, address, C.name AS categories, RA.rating as rating " +
  "FROM books B LEFT JOIN reservations R ON B.resid = R.resid LEFT JOIN  processes P ON P.resid = R.resid LEFT JOIN restaurants RE ON RE.rid = P.rid LEFT JOIN belongs BE ON BE.rid = P.rid LEFT JOIN categories C ON C.cid = BE.cid LEFT JOIN ratings RA on RA.resid = R.resid " +
  ") " +
  "SELECT * " +
  "FROM current_reservations " +
  "WHERE customer_uid = $1 AND date < (select now()) " +
  "ORDER BY date, time, numpeople ",

  display_manager_history: "" +
  "WITH current_reservations AS ( " +
  "SELECT B.uid AS customer_uid, B.resid AS reservation_id, resdate AS date, restime AS time, numpeople, RE.name AS restaurant_name, address, C.name AS categories " +
  "FROM books B LEFT JOIN reservations R ON B.resid = R.resid LEFT JOIN  processes P ON P.resid = R.resid LEFT JOIN restaurants RE ON RE.rid = P.rid LEFT JOIN belongs BE ON BE.rid = P.rid LEFT JOIN categories C ON C.cid = BE.cid " +
  ") " +
  "SELECT * " +
  "FROM current_reservations " +
  "WHERE customer_uid = $1 AND date < (select now()) " +
  "ORDER BY date, time, numpeople ",

  display_current_reservations: "" +
  "WITH current_reservations AS ( " +
  "SELECT B.uid AS customer_uid, B.resid AS reservation_id, resdate AS date, restime AS time, numpeople, RE.name AS restaurant_name, address, C.name AS categories " +
  "FROM books B LEFT JOIN reservations R ON B.resid = R.resid LEFT JOIN  processes P ON P.resid = R.resid LEFT JOIN restaurants RE ON RE.rid = P.rid LEFT JOIN belongs BE ON BE.rid = P.rid LEFT JOIN categories C ON C.cid = BE.cid " +
  ") " +
  "SELECT * " +
  "FROM current_reservations " +
  "WHERE customer_uid = $1 AND date >= (select now()) " +
  "ORDER BY date, time, numpeople ",


  display_new_bookings: "" +
  "WITH new_bookings AS (" +
  "SELECT resid AS reservation_id, RE.restime AS time, RE.resdate AS data, M.uid AS manager_uid, C.uid AS customer_uid, numpeople, name AS restaurant_name, address, open_time, close_time, U.contact_number AS customer_contact " +
  "FROM reservations RE NATURAL JOIN books B NATURAL JOIN customers C NATURAL JOIN processes P inner join (restaurants R natural join managers M) ON R.rid = P.rid inner join users U ON C.uid = U.user_uid" +
  ") " +
  "SELECT * " +
  "FROM new_bookings " +
  "WHERE manager_uid = $1",

  register_rewards: 'INSERT INTO rewards (value) VALUES ($1) RETURNING rewid',
  customer_register_rewards: 'INSERT INTO earns (uid, rewid) VALUES ($1, $2)',


  // Update
  // update_info: 'UPDATE users SET first_name=$2, last_name=$3 WHERE username=$1',
  update_pass: 'UPDATE users SET password=$2 WHERE username=$1',

  // Restaurants
  all_restaurants: 'SELECT * FROM restaurants',
  restaurant_rid: 'SELECT rid FROM restaurants WHERE name=$1',
  restaurant_menu: 'SELECT * FROM menus WHERE rid=$1',
  menu_mid: 'SELECT mid FROM menus WHERE rid=$1 and name=$2',
  menu_item: 'SELECT * FROM items WHERE mid = $1',
  user_restaurant: 'SELECT * FROM restaurants WHERE uid=$1',
  add_restaurant: 'INSERT INTO restaurants (uid, name, address, location, open_time, close_time, contacts) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING rid',
  register_restaurant: 'INSERT INTO registers (uid, rid) VALUES ($1, $2)',
  add_menu: 'INSERT INTO menus (rid, name) VALUES ($1, $2)',
  user_menu: 'SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.uid=($1))',
  menu_name_to_mid: 'SELECT mid from (SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.uid=$1)) AS Temp WHERE name=$2',
  add_menu_item: 'INSERT INTO items (name, price, description, mid) VALUES ($1, $2, $3, $4)',
  user_item: 'SELECT * FROM items WHERE mid =$1',
  item_name_to_iid: 'SELECT iid FROM items WHERE mid = $1 AND name = $2',
  user_item_by_iid: 'SELECT * FROM items WHERE iid = $1',
	cat_name_to_cid: 'SELECT cid FROM categories WHERE name = $1',
	add_category: 'INSERT INTO belongs (cid, rid) VALUES ($1, $2)',

  //update Restaurant
  update_restaurant: 'UPDATE restaurants SET name=$2, address=$3, open_time=$4, close_time=$5, contacts=$6 WHERE rid=$1',
  update_menu: 'UPDATE menus SET name=$2 WHERE mid=$1',
  update_item: 'UPDATE items SET name=$2, price=$3, description=$4 WHERE iid=$1',

  //delete Restaurant
  delete_restaurant: 'DELETE FROM restaurants WHERE rid=$1',
  delete_register: 'DELETE FROM registers WHERE rid=$1',
  delete_menu: 'DELETE FROM menus WHERE mid=$1',
  delete_item: 'DELETE FROM items WHERE iid=$1',

  //reject reservation
  remove_processes: 'DELETE FROM processes WHERE resid=$1',
  remove_books: 'DELETE FROM books WHERE resid=$1',
  remove_reservation: 'DELETE FROM reservations WHERE resid=$1',
}


module.exports = sql
