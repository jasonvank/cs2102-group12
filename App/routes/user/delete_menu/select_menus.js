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
    var errorMessage = {
    message: "You dont't have any menus to delete!",
    user_name: req.user.username
  };
    if(! data.rows[0]) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    res.render('user/restaurants/delete_menu/select_menus', {
        data : data
      });
  });
});

var menu_name;
router.post('/', selectMenu);

function selectMenu(req, res, next) {
  if (typeof req.body.Yes == 'undefined' && typeof req.body.No == 'undefined') {
      menu_name = req.body.menu_name;
      res.render('user/restaurants/delete_menu/delete_menu', {data: menu_name});
  } else {
      var result = typeof req.body.Yes == 'undefined' ? "No" : "Yes";
      if (result == "No") return res.redirect('/user/' + req.user.username);
      pool.query(sql_query.query.menu_name_to_mid, [req.user.user_uid, menu_name], (err, data) => {
        if (err) return next(err);
        var mid = data.rows[0].mid;
        console.log(mid);
        pool.query(sql_query.query.delete_menu, [mid], (err, data) => {
          if (err) return next(err);
          return res.redirect('/user/' + req.user.username);
        });
      });
    }
  }

module.exports = router;
