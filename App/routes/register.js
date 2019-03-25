var express = require('express');
const bcrypt = require('bcrypt');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});


/* SQL Query */
var sql_query = 'INSERT INTO users (username, password_hash, last_name, first_name) VALUES';

// GET
router.get('/', function(req, res, next) {
	res.render('register', { title: 'Logging System' });
});

// POST
router.post('/', function(req, res, next) {
	console.log(req.body);
	// Retrieve Information
	var username   = req.body.username;
	var password_hash   = bcrypt.hashSync(req.body.password, 10);
	var last_name  = req.body.last_name;
	var first_name = req.body.first_name;
	
	// Construct Specific SQL Query
	var insert_query = sql_query + "('" + username + "','" + password_hash + "','" + last_name + "','" + first_name + "')";
	console.log(insert_query);
	
	pool.query(insert_query, (err, data) => {
		console.log("Registration sucessful "  + data);
		res.redirect('/select')
	});
});

module.exports = router;