var express = require('express');
var router = express.Router();
const sql_query = require('../../../sql');

// const Yes = "Yes";
// const No = "No";

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

var passedIid;

router.get('/', processPassedVariable);
router.post('/', editItem);

function processPassedVariable(req, res, next) {
  passedIid = req.query.valid;
  // if (passedVariable == No) return res.redirect('/profile');
  // if (passedVariable != Yes) passedIid = passedVariable;
  // console.log("Passed iid is " + passedIid);
  pool.query(sql_query.query.user_item_by_iid, [passedIid], (err, data) => {
    res.render('user/restaurants/edit_item/edit_fields', {data: data.rows[0]});
  });
}

function editItem(req, res, next) {
  var name = req.body.item_name;
  var price = req.body.item_price;
  var description = req.body.item_description;
  price = parseFloat(price.replace('$', ''));
  pool.query(sql_query.query.update_item, [passedIid, name, price, description], (err, data) => {
    var errorMessage = {
    message: err,
    user_name: req.user.username
  };
    if (err) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    res.redirect('/user/edit_item/re_edit_form');
  });
}

module.exports = router;
