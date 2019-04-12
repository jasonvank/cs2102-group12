var express = require('express');
var router = express.Router();
const sql_query = require('../../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET menu page. */

router.get('/', processPassedVariable);
router.post('/', enterName);

var passedName;

function processPassedVariable(req, res, next) {
  passedName = req.query.valid;
  res.render('user/restaurants/edit_menu/edit_name');
}

function enterName(req, res, next) {
  var name = req.body.name;
  pool.query(sql_query.query.menu_name_to_mid, [req.user.user_uid, passedName], (err, data) => {
    if(err) return next(err);
    var mid = data.rows[0].mid;
    pool.query(sql_query.query.update_menu, [mid, name], (err, data) => {

      var errorMessage = {
      message: err,
      user_name: req.user.username
    };
      if (err) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
      res.redirect('/user/' + req.user.username);
    });
  });
}

module.exports = router;
