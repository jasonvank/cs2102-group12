var express = require('express');
var router = express.Router();

const { Pool } = require('pg')

const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* SQL Query */
var sql_query = 'SELECT * FROM users';


router.get('/', function(req, res, next) {
	pool.query(sql_query, (err, data) => {
		res.render('user/admin', { title: 'User Info', data: data.rows });
	});
});

module.exports = router;
