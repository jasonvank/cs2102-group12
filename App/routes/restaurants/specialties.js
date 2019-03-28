var express = require('express');
var router = express.Router();

/* GET specialties page. */
router.get('/', function(req, res, next) {
  res.render('restaurants/specialties', { title: 'Express' });
});

module.exports = router;
