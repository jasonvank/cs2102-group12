const sql_query = require('../sql');
var express = require('express');
var router = express.Router();

const passport = require('passport');
const bcrypt = require('bcrypt');
const {Pool} = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

var Client = require('pg').Client;
var client = new Client({connectionString: process.env.DATABASE_URL});
client.connect();


var userRouter = require('./user/user');
router.use('/user', userRouter);

/* GET home page. */
router.get('/', function (req, res, next) {
  res.render('index', {user: req.user});
});


router.get('/login', function (req, res, next) {
  res.render('user/login', {message: req.flash('loginMessage')});
});


router.post('/register', function (req, res, next) {
  // Retrieve Information
  var username = req.body.username;
  var password_hash = bcrypt.hashSync(req.body.password, 10);
  var last_name = req.body.last_name;
  var first_name = req.body.first_name;
  var contact_number = req.body.contact_number;
  var user_type = req.body.usertype;

  client.query('BEGIN', function (err, data) {
    if (err) return rollback(client);
    client.query(sql_query.query.user_register, [username, password_hash, last_name, first_name, contact_number], (err, data) => {
      var user_uid;
      if (err || !data.rows || data.rows.length == 0) {
        // show message duplicate user name
        res.status(400).send("This user name has been registered, please change!");
        return rollback(client);
      }
      user_uid = data.rows[0].user_uid;
      if (user_type == "customer") {
        client.query(sql_query.query.customer_register, [user_uid], (err, data) => {
          if (err || !data.rows || data.rows.length == 0) {
            return rollback(client);
          }
        });
      } else {
        client.query(sql_query.query.manager_register, [user_uid], (err, data) => {
          if (err || !data.rows || data.rows.length == 0) {
            return rollback(client);
          }

        });
      }

      client.query('COMMIT', client.end.bind(client), (err, res2) => {
        req.login({
          username: username,
          passwordHash: bcrypt.hashSync(req.body.password, 10),
        }, function (err) {
          if (err) {
            return res.redirect('/login');
          } else {
            return res.redirect('/user/' + username);
          }
        });
      });
    });
  });
});

// GET
router.get('/register', function (req, res, next) {
  res.render('user/register');
});

router.post('/login', passport.authenticate('local'), function (req, res) {
  // If this function gets called, authentication was successful.
  // `req.user` contains the authenticated user.
  res.redirect('/user/' + req.user.username);
});


router.get('/logout', function (req, res, next) {
  if (req.session) {
    // delete session object
    req.session.destroy(function (err) {
      if (err) {
        return next(err);
      } else {
        return res.redirect('/');
      }
    });
  }
});


var rollback = function (client) {
  client.query('ROLLBACK', function () {
    client.end();
  });
};


module.exports = router;
