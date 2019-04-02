const sql_query = require('../../sql');

var express = require('express');
var router = express.Router();

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

// GET
router.get('/', function(req, res, next) {
  res.render('restaurants/add_restaurant', {user: req.user});
});

// post
router.post('/', function(req, res, next) {
	// Retrieve Information
	var name = req.body.name;
  var username = req.user.username;
  var uid = req.user.user_uid;
  console.log("name is " + name);
  console.log("uid is " + uid);
  pool.query(sql_query.query.add_restaurant, [uid, name], (err, data) => {
    if(err) {
      return next(err);
    } else {
      res.redirect('/profile');
    }
  });
});

module.exports = router;
