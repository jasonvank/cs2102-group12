const sql_query = require('../sql');


var express = require('express');
var router = express.Router();


const passport = require('passport');
const bcrypt = require('bcrypt');
const {Pool} = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

router.get('/', function (req, res, next) {
  var searchInfo = req.query;
  var rest_name = searchInfo.name;
  if (rest_name == 0) {
    rest_name = '%%';
  } else {
    rest_name = '%' + rest_name.toLowerCase() + '%';
  }

  var address = searchInfo.address;
  if (address == 0) {
    address = '%%';
  } else {
    address = '%' + address + '%';
  }


  var location = searchInfo.location;
  if (location == 'Anywhere') {
    location = '%%';
  } else {
    location = location;
  }

  var category = searchInfo.category;
  if (category == 'Anything') {
    category = '%%';
  } else {
    category = '%' + category + '%';
  }

  var rating = searchInfo.rating;
  if (rating == "Any Rating") {
    rating = 0;
  }

  var time = searchInfo.time;

  if (time == 0) {
    time = ' ';
  }

  pool.query(sql_query.query.restaurant_ratings, (err, data) => {
    if (err) {
      res.status(404).send(err);
    }
    pool.query(sql_query.query.search, [rest_name, address, location, category, rating, time], (err, data) => {
      if (err) {
        res.status(404).send(err);
      }
      // res.render('/restaurants/empty_selections', {user : req.user});
      // if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
      var passedData = {
        user: req.user,
        passedData: data
      };
      res.render('restaurants/search', {
        data: passedData
      });
      pool.query(sql_query.query.delete_restaurant_ratings, (err, data) => {
        if (err) {
          res.status(404).send(err);
        }
      });
    });
  });
});


router.post('/', function(req, res, next) {
  var restaurant_name = req.body.restaurant_name;
  pool.query(sql_query.query.restaurant_name_to_rid, [restaurant_name], (err, data) => {
    if(err) return(next);
    restaurantRid = data.rows[0].rid;
    var string = encodeURIComponent(restaurantRid);
    res.redirect('/menu?valid=' + string);
  });
});

module.exports = router;
