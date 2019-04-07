var express = require('express');
var router = express.Router();

var passedVariable;

router.get('/', checkBox);
router.post('/', checkResult);
//
function checkBox(req, res, next) {
  res.render('user/restaurants/edit_item/re_edit_form');
}

function checkResult(req, res, next) {
  var result = typeof req.body.Check1 == 'undefined' ? "No" : "Yes";
  var string = encodeURIComponent(result);
  res.redirect('/user/edit_item/select_items?valid=' + result);
}

module.exports = router;
