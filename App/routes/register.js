const sql_query = require('../sql');

var express = require('express');
var bcrypt = require('bcrypt');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

// GET
router.get('/', function(req, res, next) {
	res.render('register', { title: 'Logging System' });
});

// POST
router.post('/', function(req, res, next) {
	// Retrieve Information
	var username   = req.body.username;
	var password_hash   = bcrypt.hashSync(req.body.password, 10);
	var last_name  = req.body.last_name;
	var first_name = req.body.first_name;

	pool.query(sql_query.query.user_register, [username, password_hash, last_name, first_name], (err, data) => {
		res.redirect('/')
	});
});

module.exports = router;