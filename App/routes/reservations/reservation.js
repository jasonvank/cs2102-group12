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

var Client = require('pg').Client;
var client = new Client({connectionString: process.env.DATABASE_URL});
client.connect();

var uid;
var rid;

/* GET reservation page. */

router.get('/:rid', function(req, res, next) {
	if (!req.isAuthenticated()){ // if not logged in, redirect to login page
        return res.redirect('/login');
	} else {
		return next();
	}
}, function(req, res, next) {
    //get user_id of current user
    uid = req.user.user_uid;
    console.log("uid:" + uid);
    rid = req.params.rid;
    console.log("rid:" + rid);
	var isNotCustomer = req.user.isManager;
	if (isNotCustomer == true) {
		console.log("Only customers can make reservations");
		return res.render('reservations/notcustomererror');
    } else {
    	return next();
	}
}, function(req, res, next) {
    res.render('reservations/reservation', {user: req.user, /*points: req.user.points*/}); //the user is for navbar, points for displaying use points button
});	    

// POST reservation
router.post('/:rid', function(req, res, next) {
	var resdate = req.body.book_date;
	var restime = req.body.book_time;
	var numpeople = req.body.numpeople;
	var usereward = req.body.usereward;

	console.log("form: " + resdate + ", " + restime + "," + numpeople);
	var resid;
	var reserve_query = 'insert into reservations (restime, resdate, numpeople) values (' + "'" + restime + "'" + ',' + "'" + resdate + "'" + ',' + numpeople + ') returning resid';
	var get_rewid = 'select rewid from earns where uid = ' + "'" + uid + "'";
	var rewid;
	client.query('BEGIN', (err, data) => {
		if (err) return rollback(client);
		client.query(get_rewid, (err, data) => {
			if (err) {
				console.log("each customer should be mapped to a reward in the rewards and earns tables");
				return rollback(client);
			} else {
				rewid = data.rows[0].rewid;
				console.log("rewid:" + rewid);
				var usereward_query = 'insert into uses (rewid, resid) values (' + "'" + rewid + "'" + ',' + "'" + resid + "'" + ')';
				var update_reward_pt = 'update rewards set value = value - 100 where uid = ' + "'" + uid + "'";
				
				if (usereward == 'on') {
					client.query(usereward_query, (err, data) => {
						if (err) {return rollback(client);}
						client.query(update_reward_pt, (err,data) => {
							if (err) {return rollback(client);}
						});
					});
				}
				//insert into Reservations table
				client.query(reserve_query, function(err, data) {
					if (err) {
					    console.log("reserve ERROR");
					    return rollback(client);
					}
					resid = data.rows[0].resid;
					console.log("resid: " + resid);
					var book_query = 'insert into books (resid, uid) values (' + "'" + resid + "'" + ', ' + "'" + uid + "'" + ')';
					var process_query = 'insert into processes (resid, rid) values(' + "'" + resid + "'" + ', ' + "'" + rid + "'" + ')';
					//insert into Books table
					client.query(book_query, function(err, data) {
						if (err) {
							console.log("book ERROR");
							return rollback(client);
						}
						// insert into processes table
						console.log(process_query);
						client.query(process_query, function(err, data) {
							if (err) {
								console.log("process ERROR");
								return rollback(client);
							}
							else {
								client.query('COMMIT');
								return res.redirect('/user/' + req.user.username); }
						});
					});
				});
			}
		});
	});
});

var rollback = function (client) {
  client.query('ROLLBACK', function () {
    client.end();
  });
};

module.exports = router;
