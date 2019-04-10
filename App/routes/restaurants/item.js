var express = require('express');
var router = express.Router();
const sql_query = require('../../sql');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

var passedName;

router.get('/', processPassedVariable);

function processPassedVariable(req, res, next) {
  var passedVariable = req.query.valid;
  pool.query(sql_query.query.menuid_to_item, [passedVariable], (err, data) => {
    if(err) return(next);
    if (!data.rows[0]) return res.render('restaurants/empty_selections', {user : req.user});
    var passedData = {
      user: req.user,
      passedData: data
    };
    res.render('restaurants/item', {
      data : passedData
    });
    // console.log(data.rows[0].name);
  });
  // res.render('user/restaurants/add_item/add_menu_item');
}

module.exports = router;
