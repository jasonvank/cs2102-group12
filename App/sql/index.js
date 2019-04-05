const sql = {}

sql.query = {
	// Users
	user_info: 'SELECT * FROM users WHERE username=$1',
	user_register: 'INSERT INTO users (username, password_hash, last_name, first_name) VALUES ($1,$2,$3,$4) returning user_uid',
	branch_manager_register: 'INSERT INTO branch_managers (uid) VALUES ($1)',
	restaurant_manager_register: 'INSERT INTO restaurant_managers (uid) VALUES ($1)',
	customer_register: 'INSERT INTO customers (uid) VALUES ($1)',

	// Update
	update_info: 'UPDATE users SET first_name=$2, last_name=$3 WHERE username=$1',
	update_pass: 'UPDATE users SET password=$2 WHERE username=$1',

  // Restaurants
  user_restaurant: 'SELECT * FROM restaurants WHERE uid=$1',
  add_restaurant: 'INSERT INTO restaurants (uid, name, address, open_time, close_time, contacts) VALUES ($1, $2, $3, $4, $5, $6) RETURNING rid',
  register_restaurant: 'INSERT INTO registers (uid, rid) VALUES ($1, $2)',
  add_menu: 'INSERT INTO menus (rid, name) VALUES ($1, $2)',
  user_menu: 'SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.uid=($1))',
  menu_name_to_mid: 'SELECT mid from (SELECT * FROM menus M1 WHERE M1.rid = (SELECT R1.rid FROM restaurants R1 WHERE R1.uid=$1)) as Temp WHERE name=$2',
  add_menu_item: 'INSERT INTO items (name, price, description, mid) VALUES ($1, $2, $3, $4)'
}

module.exports = sql
