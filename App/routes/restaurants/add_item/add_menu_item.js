var express = require('express');
var router = express.Router();
const sql_query = require('../../../sql');

const Yes = "Yes";
const No = "No";

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

var passedName;

router.get('/', processPassedVariable);
router.post('/', enterItem);

function processPassedVariable(req, res, next) {
  var passedVariable = req.query.valid;
  if (passedVariable == No) return res.redirect('/profile');
  if (passedVariable != Yes) passedName = passedVariable;
  res.render('restaurants/add_item/add_menu_item');
}

function enterItem(req, res, next) {
  var name = req.body.item_name;
  var price = req.body.item_price;
  var description = req.body.item_description;
  price = parseFloat(price.replace('$', ''));
  pool.query(sql_query.query.menu_name_to_mid, [req.user.user_uid, passedName], (err, data) => {
    if(err) return next(err);
    var mid;
    mid = data.rows[0].mid;
    pool.query(sql_query.query.add_menu_item, [name, price, description, mid], (err, data) => {
      if (err) return res.render('restaurants/error_page/operation_error', {data: err.message});
      res.redirect('/add_item/re_enter_form');
    });
  });
}

module.exports = router;
