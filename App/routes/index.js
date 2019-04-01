const sql_query = require('../sql');
var express = require('express');
var router = express.Router();
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

/* GET home page. */
router.get('/', function(req, res, next) {
  res.render('index', {user: req.user});
});


router.get('/login', function(req, res, next) {
  res.render('users/login', { message: req.flash('loginMessage') });
});

router.get('/flash', function(req, res) {
	res.flash('info', 'Hi there!');
})

// GET
router.get('/register', function(req, res, next) {
	res.render('users/register', { title: 'Logging System' });
});

// GET route after registering
router.get('/profile', isLoggedIn, function (req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  pool.query(sql_query.query.user_info, [req.user.username], (err, data) => {
    if(err) {
      res.redirect('/login');
    } else { 
      res.render('users/profile', {
        data : data.rows[0]
      });
    }
  });
});	

router.post('/login', passport.authenticate('local', {
		successRedirect: '/profile',
		failureRedirect: '/login',
		failureFlash: 'Incorrect Password or username'
}));


router.post('/register', function (req, res, next) {
	// Retrieve Information
	var username        = req.body.username;
	var password_hash   = bcrypt.hashSync(req.body.password, 10);
	var last_name       = req.body.last_name;
	var first_name      = req.body.first_name;
  var user_type       = req.body.usertype;

  pool.query(sql_query.query.user_register, [username, password_hash, last_name, first_name],  (err, data) => {
    var user_uid;
    if(err || !data.rows || data.rows.length == 0) {
      return next();
    } else {
      user_uid = data.rows[0].user_uid;
    }
    if (user_type == "customer") {
      pool.query(sql_query.query.customer_register, [user_uid], (err2, data2) => {
        if(err || !data.rows || data.rows.length == 0) {
          return next();
        }
      });
    } else if (user_type == "branch_manager") {
      pool.query(sql_query.query.branch_manager_register, [user_uid], (err2, data2) => {
        if(err || !data.rows || data.rows.length == 0) {
          return next();
        }
      });
    } else if (user_type == "restaurant_manager") {
      pool.query(sql_query.query.restaurant_manager_register, [user_uid], (err2, data2) => {
        if(err || !data.rows || data.rows.length == 0) {
          return next();
        }
      });
    }

    req.login({
      username    : username,
      passwordHash: bcrypt.hashSync(req.body.password, 10),
    }, function(err) {
      if(err) {
        return res.redirect('/login');
      } else {
        return res.redirect('/profile');
      }
    });
  });
});


router.get('/logout', function(req, res, next) {
	if (req.session) {
	  // delete session object
	  req.session.destroy(function(err) {
      if(err) {
        return next(err);
      } else {
        return res.redirect('/');
      }
    });
  }
});


function isLoggedIn(req, res, next) {
    if (req.isAuthenticated())
        return next();
    res.redirect('/login');
}

module.exports = router;
