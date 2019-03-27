const sql = {}

sql.query = {
	// Login System
	user_login: 'SELECT * FROM users WHERE username=$1',
	user_register: 'INSERT INTO users (username, password_hash, last_name, first_name) VALUES ($1,$2,$3,$4)',
	
	// Update
	update_info: 'UPDATE users SET first_name=$2, last_name=$3 WHERE username=$1',
	update_pass: 'UPDATE users SET password=$2 WHERE username=$1',
	
}

module.exports = sql