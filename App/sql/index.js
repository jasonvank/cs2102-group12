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
  add_restaurant: 'INSERT INTO restaurants (uid, name) VALUES ($1, $2)',
}

module.exports = sql
