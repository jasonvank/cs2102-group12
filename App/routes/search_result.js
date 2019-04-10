const sql_query = require('../sql');



var express = require('express');
var router = express.Router();


const passport = require('passport');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

router.get('/', function(req, res, next) {
  var searchInfo = req.query;
  var rest_name = searchInfo.name;
  if (rest_name == 0) {
    rest_name = "1=1";
  } else {
    rest_name = "name = " + "'" + rest_name + "'";
  }

  var location = searchInfo.location;
  if (location == 'Anywhere') {
    location = "1=1";
  } else {
    location = "location = " + "'" + location + "'";
  }

  var category = searchInfo.category;
  if (category == 'Anything') {
    category = "1=1";
  } else {
    category = "cname = " + "'" + category + "'";
  }

  var time = searchInfo.time;
  if (time == 0) {
    time = "1=1";
  } else {
    time = "open_time <= " + "'" + time + "'" + "AND close_time >=" + "'" + time + "'";
  }

  var search_query =
  "SELECT restaurants.name as name, restaurants.rid, location, categories.name as cname, belongs.cid, open_time, close_time FROM restaurants LEFT JOIN belongs ON restaurants.rid = belongs.rid LEFT JOIN categories on belongs.cid = categories.cid WHERE " +
  rest_name + " AND " + location + " AND " + category + " AND " + time;

  pool.query(search_query, (err, data) => {
    if (err) {
      //cant find any Restaurants
        res.render('/restaurants/empty_selections', {user : req.user});
    }
    if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
    var passedData = {
      user: req.user,
      passedData: data
    };
    res.render('restaurants/restaurant', {
        data : passedData
      });

  });

});

module.exports = router;
