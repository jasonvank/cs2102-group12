var express = require('express');
var router = express.Router();
const sql_query = require('../../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET menu page. */
router.get('/', function(req, res, next) {
  // console.log("HEREER!!!!");
  if (!req.user) res.redirect('/login');
  pool.query(sql_query.query.userid_to_menu, [req.user.user_uid], (err, data) => {
    if(err) return(next);

    var errorMessage = {
    message: "You dont't have any menus to add!",
    user_name: req.user.username
  };
    if(! data.rows[0]) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    res.render('user/restaurants/add_item/select_menus', {
        data : data
      });
  });
});

var menu_name;
router.post('/', selectMenu);

function selectMenu(req, res, next) {
  var menu_name = req.body.menu_name;

  var string = encodeURIComponent(menu_name);
  res.redirect('/user/add_item/add_menu_item?valid=' + string);
}

module.exports = router;
