var express = require('express');
var router = express.Router();
const sql_query = require('../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

// const { Pool } = require('pg')
// const pool = new Pool({connectionString: process.env.DATABASE_URL});

var uid;
var rid;
// GET
router.get('/', function(req, res, next) {
  if (!req.user) res.redirect('/login');
  uid=req.user.user_uid;
  // console.log(req.user.user_uid);
    pool.query(sql_query.query.user_restaurant, [req.user.user_uid], (err, data) => {
      if (err) return next(err);
      if(! data.rows[0]) return res.render('restaurants/error_page/operation_error', {data: "Plase register your restaurant first!"});
      rid=data.rows[0].rid;
      res.render('restaurants/edit_restaurant', {data: data.rows[0]});
    });
  });

// post
router.post('/', function(req, res, next) {
	// Retrieve Information
	var name = req.body.name;
  var address = req.body.address;
  var open_time = req.body.open_time;
  var close_time = req.body.close_time;
  var contacts = req.body.contacts;
  // var rid;
// console.log(uid);
  // client.query(sql_query.query.user_restaurant[uid], function(err, data) {
  //   console.log("HERE");
  //   if (err) return next(err);
  //   rid = data.rows[0].rid;
  //   console.log(rid);
  // });
console.log(rid);
pool.query(sql_query.query.update_restaurant, [rid, name, address, open_time, close_time, contacts], (err, data) => {
    if(err) return res.render('restaurants/error_page/operation_error', {data: err});
    return res.redirect('profile');
  });
});

module.exports = router;
