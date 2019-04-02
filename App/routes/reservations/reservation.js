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

var uid;
var bid;

/* GET reservation page. */

router.get('/', function(req, res, next) {
	if (!req.isAuthenticated()){ // if not logged in, redirect to login page
        res.redirect('/login');
	}
    res.render('reservations/reservation', {user: req.user}); //the user:req.user is for navbar
    //get user_id of current user
    uid = req.user.user_uid;
    console.log("uid:" + uid);
    /*
    //check if user is customer, if not, alert("Only customers can make reservations"); redirect to home page
    pool.query('select user_type from users where user_uid = ' + uid, (err, data) => {
    	var type = data.rows[0].user_type;

    });

    //get bid of branch. (get redirect parameter value)
    var params = req.query;
		//if no bid in params
		if (!params.bid) {
			alert("please find a restaurant branch first");
		} else {
			bid = params.bid;
		}
	*/
});

// POST reservation
router.post('/', function(req, res, next) {
	var resdate = req.body.book_date;
	var restime = req.body.book_time;
	var numpeople = req.body.numpeople;
	console.log("form: " + resdate + ", " + restime + "," + numpeople);
	var resid;
	pool.query('select uuid_generate_v4 ()', (err, data) => {
		resid = data.rows[0].uuid_generate_v4;
		console.log(resid);
	});

	var reserve_query = 'insert into reservations (resid, restime, resdate, numpeople) values (' + resid + ',' + restime + ',' + resdate + ',' + numpeople + ')';
	var book_query = 'insert into books (resid, uid) values (' + resid + ', ' + uid + ')';
	var process_query = 'insert into processes (resid, bid) values(' + resid + ', ' + bid + ')';
	
	var callback = res.redirect('/'); //change to confirm booking page later
	//insert into Reservations table
	pool.query(reserve_query, function(err, data) {
		if (err) {return "ERROR";}
		//insert into Books table
		pool.query(book_query, function(err, data) {
			if (err) {return "ERROR";}
			// insert into processes table
			pool.query(process_query, callback);
		});
	});
});


module.exports = router;
