var express = require('express');
var router = express.Router();
var session = require('express-session');
var bodyParser = require('body-parser');
var path = require('path');
const passport = require('passport');
const bcrypt = require('bcrypt')

const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

router.use(session({
	secret: 'secret',
	resave: true,
	saveUninitialized: true
}));


router.get('/', function(req, res, next) {
  res.render('login', { title: 'Logging System' });
});

router.post('/', passport.authenticate('local', {
		successRedirect: '/menu',
		failureRedirect: '/specialties'
}));
//   console.log(req.body);
// 	var username = req.body.username;
//   var password = req.body.password;
//   console.log("--" + username);
//   console.log("--" + password);
// 	if (username && password) {
// 		pool.query('SELECT * FROM users WHERE username = ', [username], function(error, results, fields) {
//       console.log(results);
//       // if (results.length > 0) {
// 			// 	req.session.loggedin = true;
// 			// 	req.session.username = username;
// 			// 	res.redirect('/home');
// 			// } else {
// 			// 	res.send('Incorrect Username and/or Password!');
// 			// }			
// 			// res.end();
// 		});
// 	} else {
// 		res.send('Please enter Username and Password!');
// 		res.end();
// 	}
// });

// router.get('/home', function(request, response) {
// 	if (request.session.loggedin) {
// 		response.send('Welcome back, ' + request.session.username + '!');
// 	} else {
// 		response.send('Please login to view this page!');
// 	}
// 	response.end();
// });

// var sql_query_userpass = 'SELECT * FROM username_password WHERE username=$1'

// function findUser (username, callback) {
// 	pool.query(sql_query_userpass, [username], (err, data) => {
// 		if(err) {
// 			console.error("Cannot find user");
// 			return callback(null);
// 		}
		
// 		if(data.rows.length == 0) {
// 			console.error("User does not exists?");
// 			return callback(null)
// 		} else if(data.rows.length == 1) {
// 			return callback(null, {
// 				username    : data.rows[0].username,
// 				passwordHash: data.rows[0].passwordHash
// 			});
// 		} else {
// 			console.error("More than one user?");
// 			return callback(null);
// 		}
// 	});
// }


// passport.serializeUser(function (user, cb) {
//   cb(null, user.username);
// })

// passport.deserializeUser(function (username, cb) {
//   findUser(username, cb);
// })

// function initPassport () {
//   passport.use(new LocalStrategy(
//     (username, password, done) => {
//       findUser(username, (err, user) => {
//         if (err) {
//           return done(err);
//         }

//         // User not found
//         if (!user) {
//           console.error('User not found');
//           return done(null, false);
//         }

//         // Always use hashed passwords and fixed time comparison
//         bcrypt.compare(password, user.passwordHash, (err, isValid) => {
//           if (err) {
//             return done(err);
//           }
//           if (!isValid) {
//             return done(null, false);
//           }
//           return done(null, user);
//         })
//       })
//     }
//   ));

module.exports = router;