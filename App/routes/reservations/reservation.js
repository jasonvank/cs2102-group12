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

var uuid;
var bid;

/* GET reservation page. */

router.get('/', function(req, res, next) {
	if (!req.isAuthenticated()){ // if not logged in, redirect to login page
        res.redirect('/login');
	}
    res.render('reservations/reservation', {user: req.user}); //the user:req.user is for navbar
    //get user_id of current user
    var user = req.user;
    pool.query('select user_uid from users where username = ' + "'" + user.username + "'", (err, data) => {
    	uuid = data.rows[0].user_uid;
    	console.log('user id is ' + uuid);
    });
    /*
    //check if user is customer, if not, redirect to login
    pool.query('select user_uid from customers where uid = ' + uuid, (err, data) => {
    	if 
    });

    //get bid of branch. (get redirect parameter value)

	*/
});
/*
// POST reservation
router.post('/', function(req, res, next) {
	var resdate = req.body.book_date;
	var restime = req.body.book_time;
	var numpeople = req.body.;
	var reserve_query = 'insert into reservations value (restime, resdate, numpeople) values (' + restime + ',' + resdate + ',' + numpeople + ')';
	var resid;
	var book_query;
	var callback = res.redirect('/confirm');
	//insert into Reservations table
	pool.query(reserve_query, function(err, data) {
		if (err) {return "ERROR";}
		resid = data.rows[0].resid;
		//get resid 
		pool.query()
		//insert into Books table
		pool.query(book_query, callback);
	});
});
*/

module.exports = router;
