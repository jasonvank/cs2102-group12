const sql_query = require('../sql');
var express = require('express');
var router = express.Router();

const url = require('url');

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

/* SEARCH */
router.post('/', function (req, res, next) {
  var res_name = req.body.rest_name;
  var location = req.body.location;
  var category = req.body.cuisines;
  var book_time = req.body.book_time;

  console.log(res_name == 0);
  console.log(location);
  console.log(category);
  console.log(book_time == 0);

  var searchInfo = {
    name : res_name,
    location : location,
    category : category,
    time : book_time
  }
console.log(url.format({
  pathname: "/results",
  query: searchInfo
}));
  res.redirect(url.format({
    pathname: "/results",
    query: searchInfo
  }));
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


  function user_login() {
    console.log("going to login")
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
  }

  client.query('BEGIN', function (err, data) {
    console.log("start to register")
    if (err) return rollback(client);
    client.query(sql_query.query.user_register, [username, password_hash, last_name, first_name, contact_number], (err2, data2) => {
      var user_uid;
      console.log("-1");
      if (err2) {
        // show message duplicate user name
        res.status(400).send("This user name has been registered, please change!");
        return rollback(client);
      }
      console.log("-2");
      console.log("complete registration");
      user_uid = data2.rows[0].user_uid;
      var inial_point = 100;
      if (user_type == "customer") {
        console.log("customer");
        client.query(sql_query.query.customer_register, [user_uid], (err3, data3) => {
          if (err3) {
            return rollback(client);
          }
          client.query(sql_query.query.register_rewards, [inial_point], (err4, data4) => {
            if (err4 || !data4.rows || data4.rows.length == 0) {
              return rollback(client);
            }
            var rewid = data4.rows[0].rewid;
            client.query(sql_query.query.customer_register_rewards, [user_uid, rewid], (err5, data5) => {
              if (err5) {
                return rollback(client);
              }
              user_login();



            })
          })
        });
      } else {
        console.log("manager");
        console.log("-3");
        client.query(sql_query.query.manager_register, [user_uid], (err6, data6) => {
          if (err6) {
            console.log("has problem");
            return rollback(client);
          }
          user_login();
        });
      }
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
        return res.status(500).send(err);
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
