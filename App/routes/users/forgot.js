var express = require('express');
var router = express.Router();

/* GET forgot page. */
router.get('/', function(req, res, next) {
  res.render('user/forgot', { title: 'Express' });
});

module.exports = router;
