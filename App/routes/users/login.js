var express = require('express');
var router = express.Router();
var session = require('express-session');
var bodyParser = require('body-parser');
var path = require('path');
const passport = require('passport');
const bcrypt = require('bcrypt');
var flash = require('connect-flash');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

router.get('/', function(req, res, next) {
  res.render('user/login', { message: req.flash('info') });
});

router.post('/', passport.authenticate('local', {
		successRedirect: '/',
		failureRedirect: '/login',
		failureFlash: 'Incorrect Password or username'
}));

router.get('/flash', function(req, res) {
	res.flash('info', 'Hi there!');
})

module.exports = router;
