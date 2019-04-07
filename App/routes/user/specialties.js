var express = require('express');
var router = express.Router();

/* GET specialties page. */
router.get('/', function(req, res, next) {
  res.render('restaurants/specialties', {user: req.user});
});

module.exports = router;
