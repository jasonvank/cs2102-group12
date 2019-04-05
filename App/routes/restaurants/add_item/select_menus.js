var express = require('express');
var router = express.Router();
const sql_query = require('../../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET menu page. */
router.get('/', function(req, res, next) {
  if (!req.user) res.redirect('/login');
  pool.query(sql_query.query.user_menu, [req.user.user_uid], (err, data) => {
    if(err) return(next);
    res.render('restaurants/add_item/select_menus', {
        data : data
      });
  });
});

var menu_name;
router.post('/', selectMenu);

function selectMenu(req, res, next) {
  var menu_name = req.body.menu_name;
  var string = encodeURIComponent(menu_name);
  res.redirect('/add_item/add_menu_item?valid=' + string);
}

module.exports = router;
