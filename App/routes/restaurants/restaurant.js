var express = require('express');
var router = express.Router();
const sql_query = require('../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET menu page. */
router.get('/', function(req, res, next) {
  // console.log("HEREER!!!!");
  pool.query(sql_query.query.display_restaurant_attributes, [], (err, data) => {
    if (err) return next(err);
    // console.log(data.rows[0].name);
    if (!data.rows) return res.render('restaurants/empty_selections', {user : req.user});
    return res.render('restaurants/restaurant', {
        attributes: data.rows,
        user: req.user,
      });
  });
});

var menu_name;
router.post('/', selectRestaurant);

function selectRestaurant(req, res, next) {
  var restaurant_name = req.body.restaurant_name;
  pool.query(sql_query.query.restaurant_name_to_rid, [restaurant_name], (err, data) => {
    if(err) return(next);
    restaurantRid = data.rows[0].rid;
    var string = encodeURIComponent(restaurantRid);
    res.redirect('/menu?valid=' + string);
  });
}

module.exports = router;
