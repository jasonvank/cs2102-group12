const sql = {}

sql.query = {
	// Insertion
	add_user: 'INSERT INTO users (uid, username, password, first_name, last_name) VALUES ($1,$2,$3,$4,$5)',
	
	// Login
	userpass: 'SELECT * FROM users WHERE username=$1',
	
	// Update
	update_info: 'UPDATE users SET first_name=$2, last_name=$3 WHERE username=$1',
	update_pass: 'UPDATE users SET password=$2 WHERE username=$1',
	
}

module.exports = sql