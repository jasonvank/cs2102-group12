var express = require('express');
var router = express.Router();
const sql_query = require('../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET menu page. */
router.get('/', function(req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  pool.query(sql_query.query.user_restaurant, [req.user.user_uid], (err, data) => {
    if(err) {
      res.redirect('/login');
    } else {
      console.log(data.rows.length);
      res.render('restaurants/add_menu', {
        data : data
      });
    }
  });
  // res.render('restaurants/add_menu', {user: req.user});
});

router.post('/', function(req, res, next) {
  var name = req.body.name;
  console.log(req.body.name);
  });

module.exports = router;
