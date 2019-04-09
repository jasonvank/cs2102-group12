var express = require('express');
var router = express.Router();
const sql_query = require('../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

var restaurantRid;

router.get('/', processPassedVariable);
router.post('/', selectMenu);

function processPassedVariable(req, res, next) {
  var passedVariable = req.query.valid;
  pool.query(sql_query.query.restaurant_rid, [passedVariable], (err, data) => {
    if(err) return(next);
    restaurantRid = data.rows[0].rid;
    // console.log(restaurantRid);
    // console.log(data.rows[0].name);
    pool.query(sql_query.query.restaurant_menu, [data.rows[0].rid], (err, data) => {
      if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
      // console.log(data.rows[0].name);
      var passedData = {
        user: req.user,
        // user_name: req.user.username
        passedData: data
      };
      res.render('restaurants/menu', {
          data : passedData
        });
    })
  });
  // res.render('user/restaurants/add_item/add_menu_item');
}

function selectMenu(req, res, next) {
  var menu_name = req.body.menu_name;

  pool.query(sql_query.query.menu_mid, [restaurantRid, menu_name], (err, data) => {
    if (err) return next(err);
    // console.log(restaurantRid);
    // console.log(data.rows[0].mid);
      var string = encodeURIComponent(data.rows[0].mid);
      res.redirect('/item?valid=' + string);
  })
}

module.exports = router;
