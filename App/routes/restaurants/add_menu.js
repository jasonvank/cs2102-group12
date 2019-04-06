var express = require('express');
var router = express.Router();
const sql_query = require('../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET menu page. */
router.get('/', function(req, res, next) {
  if (!req.user) res.redirect('/login');
  res.render('restaurants/add_menu');
});

router.post('/', function(req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  pool.query(sql_query.query.user_restaurant, [req.user.user_uid], (err, data) => {
    if(err) return next(err);
    if(! data.rows[0]) return res.render('restaurants/error_page/operation_error', {data: "Plase register your restaurant first!"});
    var rid = data.rows[0].rid;
    pool.query(sql_query.query.add_menu, [rid, req.body.name], (err, data) => {
      if (err) return res.render('restaurants/error_page/operation_error', {data: err.message});
      res.redirect('profile');
    })
  });
});

module.exports = router;
