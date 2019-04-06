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
  if (passedVariable == No) return res.redirect('/profile');
  if (passedVariable != Yes) passedName = passedVariable;
  // console.log(passedName);
  pool.query(sql_query.query.menu_name_to_mid, [req.user.user_uid, passedName], (err, data) => {
    if (err) res.render('restaurants/error_page/operation_error', {data: err.message});
    mid = data.rows[0].mid;
    pool.query(sql_query.query.user_item, [mid], (err, data) => {
      if(err) return(next);
      if(! data.rows[0]) return res.render('restaurants/error_page/operation_error', {data: "You dont't have any items to edit!"});
      res.render('restaurants/edit_item/select_items', {
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
    var string = encodeURIComponent(iid);
    res.redirect('/edit_item/edit_fields?valid=' + string);
  });
}

module.exports = router;












/* GET menu page. */
// router.get('/', function(req, res, next) {
//   if (!req.user) res.redirect('/login');
//   pool.query(sql_query.query.user_menu, [req.user.user_uid], (err, data) => {
//     if(err) return(next);
//     if(! data.rows[0]) return res.render('restaurants/error_page/operation_error', {data: "You dont't have any menus to edit!"});
//     res.render('restaurants/edit_item/select_menus', {
//         data : data
//       });
//   });
// });

var menu_name;
// router.post('/', selectMenu);

function selectMenu(req, res, next) {
  var menu_name = req.body.menu_name;
  var string = encodeURIComponent(menu_name);
 res.redirect('/edit_item/edit_fields?valid=' + string);
}

module.exports = router;
