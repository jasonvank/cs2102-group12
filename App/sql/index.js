const sql = {}

// CREATE VIEW CustomerHistory as SELECT * from (customers C NATURAL JOIN reservations R1 NATURAL JOIN Processes P NATURAL JOIN books B) LEFT JOIN rate R2 on R1.resid = R2.resid and C.uid = R2.uid and R2.rid = P.rid

// const current_reservations = "" +
// 	"CREATE VIEW current_reservations AS" +
// 	"SELECT resdate as date, restime as time, numpeople, name as restaurant_name, address, C.name as categories, R.ave_rating as rating " +
//     "FROM reservations NATURAL JOIN processes NATURAL JOIN restaurants NATURAL JOIN belongs B INNER JOIN categories C on C.cid = B.cid inner join Ratings R on R.rid = B.rid" +
//     "WHERE uid = $1"

sql.query = {
  // Register
  user_info: 'SELECT * FROM users WHERE username = $1',
  user_register: 'INSERT INTO users (username, password_hash, last_name, first_name, contact_number) VALUES ($1,$2,$3,$4,$5) RETURNING user_uid',
  manager_register: 'INSERT INTO managers (uid) VALUES ($1)',
  customer_register: 'INSERT INTO customers (uid) VALUES ($1)',
  reset_password: 'UPDATE users SET password_hash = $2 WHERE user_uid = $1',
  update_info: 'UPDATE users SET first_name = $2, last_name=$3 where user_uid = $1',
  check_usertype: 'SELECT * FROM managers WHERE uid = $1',
  // User
  customer_history: 'CREATE VIEW CustomerHistory as SELECT * from (customers C NATURAL JOIN reservations R1 NATURAL JOIN Processes P NATURAL JOIN books B) LEFT JOIN rate R2 on R1.resid = R2.resid and C.uid = R2.uid and R2.rid = P.rid',
  manager_history: 'CREATE VIEW ManagerHistory as SELECT * from (customers C NATURAL JOIN reservations R1 NATURAL JOIN Processes P NATURAL JOIN books B)',

  current_reservations: "SELECT resid as reservation_id, resdate as date, restime as time, numpeople, RE.name as restaurant_name, address, C.name as categories, R.ave_rating as rating " +
  "FROM reservations NATURAL JOIN processes NATURAL JOIN restaurants RE NATURAL JOIN belongs B INNER JOIN categories C ON C.cid = B.cid inner join Ratings R on R.rid = B.rid " +
  "WHERE uid = $1",
  new_bookings: "SELECT R.resid as reservation_id, R.resdate as date, R.restime as time, numpeople, RE.name as restaurant_name, U.username as customer_username, U.contact_number as contact_number, U.last_name as last_name, U.first_name as first_name " +
  "FROM restaurants RE NATURAL JOIN books B NATURAL JOIN reservations R INNER JOIN users U ON U.user_uid = uid " +
  "WHERE RE.rid = $1",
  reward_points: "SELECT * FROM rewards NATURAL JOIN earns where uid = $1",


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
  add_restaurant: 'INSERT INTO restaurants (uid, name, address, open_time, close_time, contacts) VALUES ($1, $2, $3, $4, $5, $6) RETURNING rid',
  register_restaurant: 'INSERT INTO registers (uid, rid) VALUES ($1, $2)',
  add_menu: 'INSERT INTO menus (rid, name) VALUES ($1, $2)',
  user_menu: 'SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.uid=($1))',
  menu_name_to_mid: 'SELECT mid from (SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.uid=$1)) as Temp WHERE name=$2',
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
}


module.exports = sql
