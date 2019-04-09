var express = require('express');
var router = express.Router();
const sql_query = require('../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET menu page. */
router.get('/', function(req, res, next) {
  // console.log("HEREER!!!!");
  pool.query(sql_query.query.all_restaurants, [], (err, data) => {
    if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
    if(err) return(next);
    var passedData = {
      user: req.user,
      // user_name: req.user.username
      passedData: data
    };
    // if(! data.rows[0]) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    res.render('restaurants/restaurant', {
        data : passedData
      });
  });
});

var menu_name;
router.post('/', selectRestaurant);

function selectRestaurant(req, res, next) {
  var restaurant_name = req.body.restaurant_name;
  console.log(restaurant_name);
  pool.query(sql_query.query.restaurant_rid, [restaurant_name], (err, data) => {
    if(err) return(next);
    restaurantRid = data.rows[0].rid;
    var string = encodeURIComponent(restaurantRid);
    res.redirect('/menu?valid=' + string);
  });
}

module.exports = router;
