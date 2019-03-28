var express = require('express');
var router = express.Router();

/* GET services page. */
router.get('/', function(req, res, next) {
  res.render('reservations/services', { title: 'Express' });
});

module.exports = router;
