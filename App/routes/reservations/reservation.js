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
        return res.redirect('/login');
	} else {
		return next();
	}
}, function(req, res, next) {
    //get user_id of current user
    uid = req.user.user_uid;
    console.log("uid:" + uid);

    var checkCustQuery = 'select case when not exists(select * from customers where uid = ' + "'" + uid + "'" + ') then 1 else 0 end as result';
    pool.query(checkCustQuery, (err, data) => {
    	var isNotCustomer = data.rows[0].result;
    	var error = err;
    	if (err) {
	    	return next();
	    } else if (isNotCustomer == 1) {
			console.log("Only customers can make reservations");
			return res.redirect('/');
	    } else {
	    	return next();
    	}
 	});

    /*
    //get bid of branch. (get redirect parameter value)
    var params = req.query;
		//if no bid in params
		if (!params.bid) {
			//alert("please find a restaurant branch first");
		} else {
			bid = params.bid;
		}
	*/
}, function(req, res, next) {
    res.render('reservations/reservation', {user: req.user, /*points: req.user.points*/}); //the user is for navbar, points for displaying use points button
});	    

// POST reservation
router.post('/', function(req, res, next) {
	var resdate = req.body.book_date;
	var restime = req.body.book_time;
	var numpeople = req.body.numpeople;
	var usereward = req.body.usereward;

	console.log("form: " + resdate + ", " + restime + "," + numpeople);
	var resid;
	pool.query('select uuid_generate_v4 ()', (err, data) => {
		resid = data.rows[0].uuid_generate_v4;
		console.log(resid);
	});

	var reserve_query = 'insert into reservations (resid, restime, resdate, numpeople) values (' + resid + ',' + restime + ',' + resdate + ',' + numpeople + ')';
	var book_query = 'insert into books (resid, uid) values (' + resid + ', ' + uid + ')';
	var process_query = 'insert into processes (resid, bid) values(' + resid + ', ' + bid + ')';
	var get_rewid = 'select rewid from rewards where uid = ' + uid;
	var rewid;
	pool.query(get_rewid, (err, data) => {
		rewid = data.rows[0].rewid;
		console.log("rewid:" + rewid);
	});
	var usereward_query = 'insert into uses (rewid, resid) values (' + rewid + ',' + resid + ')';
	var update_reward_pt = 'update rewards set value = value - 100 where uid = ' + uid;
	
	if (usereward == 'on') {
		pool.query(usereward_query, (err, data) => {
			if (err) {return "ERROR";}
			pool.query(update_reward_pt, (err,data) => {
				if (err) {return "ERROR";}
			});
		});
	}
	
	var callback = res.redirect('/profile'); 
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
