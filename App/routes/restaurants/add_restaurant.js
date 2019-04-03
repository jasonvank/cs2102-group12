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
  var address = req.body.address;
  var open_time = req.body.open_time;
  var close_time = req.body.close_time;
  var contacts = req.body.contacts;
  var uid = req.user.user_uid;
  // console.log(name + " " + address + " " + open_time + " " + close_time + " " + contacts);
  // console.log("uid is " + uid);
  pool.query(sql_query.query.add_restaurant, [uid, name, address, open_time, close_time, contacts], (err, data) => {
    if(err) {
      return next(err);
    } else {
      res.redirect('/profile');
    }
  });
});

module.exports = router;
