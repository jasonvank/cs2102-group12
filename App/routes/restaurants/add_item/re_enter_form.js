var express = require('express');
var router = express.Router();

var passedVariable;
/* GET menu name. */
router.get('/', checkBox);
router.post('/', checkResult);
//
function checkBox(req, res, next) {
  res.render('restaurants/add_item/re_enter_form');
}

function checkResult(req, res, next) {
  var result = typeof req.body.Check1 == 'undefined' ? "No" : "Yes";
  var string = encodeURIComponent(result);
  res.redirect('/add_item/add_menu_item?valid=' + result);
}

module.exports = router;
