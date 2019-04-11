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
    rest_name = '%%';
  } else {
    rest_name = '%' + rest_name + '%';
  }

  console.log(rest_name);

  var location = searchInfo.location;
  if (location == 'Anywhere') {
    location = '%%';
  } else {
    location = '%' + location + '%';
  }

  console.log(location);

  var category = searchInfo.category;
  if (category == 'Anything') {
    category = '%%';
  } else {
    category = '%' + category + '%';
  }

  console.log(category);

  var rating = searchInfo.rating;
  if (rating == "Any Rating") {
    rating = 0;
  }

  console.log("rating: " + rating);

  var time = searchInfo.time;
  if (time == 0) {
    pool.query(sql_query.query.restaurant_ratings, (err, data) => {
      if (err) console.log("cannot create restaurant_ratings view");
      pool.query(sql_query.query.search_no_time, [rest_name, location, category, rating], (err, data) => {
        if (err)
          res.render('/restaurants/empty_selections', {user : req.user});
          if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
          var passedData = {
            user: req.user,
            passedData: data
          };
          res.render('restaurants/search', {
          data : passedData
          });
      });
    });
  } else {
    pool.query(sql_query.query.restaurant_ratings, (err, data) => {
      if (err) console.log("cannot create restaurant_ratings view");
      pool.query(sql_query.query.search, [rest_name, location, category, rating, time], (err, data) => {
        if (err)
          res.render('/restaurants/empty_selections', {user : req.user});
          if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
          var passedData = {
            user: req.user,
            passedData: data
          };
          res.render('restaurants/search', {
          data : passedData
          });
      });
    });
  }

  var search_query =
  "SELECT * FROM restaurants LEFT JOIN belongs ON restaurants.rid = belongs.rid LEFT JOIN categories on belongs.cid = categories.cid WHERE " +
  rest_name + " AND " + location + " AND " + category + " AND " + time;

  // pool.query(sql_query.query.search, [rest_name, location, category, time], (err, data) => {
  //   if (err)
  //     res.render('/restaurants/empty_selections', {user : req.user});
  //     if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
  //     var passedData = {
  //       user: req.user,
  //       passedData: data
  //     };
  //     res.render('restaurants/search', {
  //     data : passedData
  //     });
  // });
  // pool.query(search_query, (err, data) => {
  //   if (err) {
  //     //cant find any Restaurants
  //       res.render('/restaurants/empty_selections', {user : req.user});
  //   }
  //   if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
  //   var passedData = {
  //     user: req.user,
  //     passedData: data
  //   };
  //   res.render('restaurants/search', {
  //       data : passedData
  //     });
  //
  // });

});

module.exports = router;
