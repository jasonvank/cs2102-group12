var express = require('express');
var router = express.Router();

// GET route after registering
router.get('/', function(req, res, next) {
  res.render('user/profile', { title: 'Express' });
});