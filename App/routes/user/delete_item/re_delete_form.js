var express = require('express');
var router = express.Router();

var passedVariable;

router.get('/', checkBox);
router.post('/', checkResult);
//
function checkBox(req, res, next) {
  res.render('user/restaurants/delete_item/re_delete_form');
}

function checkResult(req, res, next) {
  var result = typeof req.body.Check1 == 'undefined' ? "No" : "Yes";
  var string = encodeURIComponent(result);
  res.redirect('/user/delete_item/select_items?valid=' + result);
}

module.exports = router;
