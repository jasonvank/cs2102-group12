var express = require('express');
var router = express.Router();

/* GET reservation page. */
router.get('/', function(req, res, next) {
  res.render('reservations/reservation', { title: 'Express' });
});

module.exports = router;
