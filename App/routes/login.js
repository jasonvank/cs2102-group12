var express = require('express');
const bcrypt = require('bcrypt');
var router = express.Router();
const passport = require('passport');
const LocalStrategy = require('passport-local').Strategy;


const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});






// GET
router.get('/', function(req, res, next) {
	res.render('login', { title: 'Logging System' });
});


// router.post('/', (req, res, next) => {
//   console.log('Inside POST /login callback')
//   passport.authenticate('local', (err, user, info) => {
//     console.log('Inside passport.authenticate() callback');
//     console.log(`req.session.passport: ${JSON.stringify(req.session.passport)}`)
//     console.log(`req.username: ${JSON.stringify(req.body.username)}`)
//     req.login(req.body.username, (err) => {
//       console.log('Inside req.login() callback')
//       console.log(`req.session.passport: ${JSON.stringify(req.session.passport)}`)
//       console.log(`req.username: ${JSON.stringify(req.body.username)}`)
//       return res.send('You were authenticated & logged in!\n');
//     })
//   })(req, res, next);
// })

// router.get('/authrequired', (req, res) => {
//   console.log('Inside GET /authrequired callback')
//   console.log(`User authenticated? ${req.isAuthenticated()}`)
//   if(req.isAuthenticated()) {
//     res.send('you hit the authentication endpoint\n')
//   } else {
//     res.redirect('/')
//   }
// })
/* LOGIN */
router.post('/', passport.authenticate('local', {
  successRedirect: '/select',
  failureRedirect: '/'
}));



// // POST
// router.post('/', function(req, res, next) {
//   console.log('Inside POST /login callback')
// 	console.log(req.body);
// 	// Retrieve Information
// 	var username   = req.body.username;
// 	var password_hash   = req.body.password;
  
//   insert_query = "'select * from users where username = '" + username;
	
// 	pool.query(insert_query, (err, data) => {
// 		console.log("Registration sucessful ");
// 		res.redirect('/select')
// 	});
// });

module.exports = router;