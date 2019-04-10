var express = require('express');
var router = express.Router();
const sql_query = require('../../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

const Yes = "Yes";
const No = "No";

var passedName;
var mid;

router.get('/', processPassedVariable);
router.post('/', selectItem);

function processPassedVariable(req, res, next) {
  if (!req.user) res.redirect('/login');
  var passedVariable = req.query.valid;
  if (passedVariable == No) return res.redirect('/user/' + req.user.username);
  if (passedVariable != Yes) passedName = passedVariable;
  pool.query(sql_query.query.menu_name_to_mid, [req.user.user_uid, passedName], (err, data) => {
    var errorMessage = {
    message: err,
    user_name: req.user.username
  };
    if (err) res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    mid = data.rows[0].mid;
    pool.query(sql_query.query.user_item, [mid], (err, data) => {
      if(err) return(next);
      errorMessage.message="You dont't have any items to delete!"
      if(! data.rows[0]) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
      res.render('user/restaurants/delete_item/select_items', {
          data : data
        });
    });
  });
}

function selectItem(req, res, next) {
  var name = req.body.item_name;
  pool.query(sql_query.query.item_name_to_iid, [mid, name], (err, data) => {
    if(err) return next(err);
    var iid = data.rows[0].iid;
    // console.log(iid);
    pool.query(sql_query.query.delete_item, [iid], (err, data) => {
      if(err) return next(err);
      return res.redirect('/user/delete_item/re_delete_form');
    });
  });
}

module.exports = router;
