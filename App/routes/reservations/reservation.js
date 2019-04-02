var express = require('express');
var router = express.Router();
var session = require('express-session');
var bodyParser = require('body-parser');
var path = require('path');
var flash = require('connect-flash');
const passport = require('passport');
const bcrypt = require('bcrypt');

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

/* GET reservation page. */
router.get('/', function(req, res, next) {
	if (!req.isAuthenticated()){
        res.redirect('/login');
        console.log("not logged in");
	}
    res.render('reservations/reservation', { title: 'Express' });

});

router.get('/', function(req, res, next) {
  res.render('reservation', {user: req.user});
});


module.exports = router;
