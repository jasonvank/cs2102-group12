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
	var get_rewards = 'select value from earns left join rewards on earns.rewid = rewards.rewid where uid = ' + "'" + uid + "'";
	var rewardvalues;
	pool.query(get_rewards, (err, data) => {
		rewardvalues = data.rows;
		console.log(rewardvalues);
    	res.render('reservations/reservation', {user: req.user, rewardsList: rewardvalues}); //the user is for navbar, rewards list for displaying rewards
	});
});	    

// POST reservation
router.post('/:rid', function(req, res, next) {
	var resdate = req.body.book_date;
	var restime = req.body.book_time;
	var numpeople = req.body.numpeople;
	var usereward = req.body.usereward;

	console.log("use reward: " + usereward);
	var find_reward = 'select rewards.rewid from earns left join rewards on earns.rewid = rewards.rewid where uid = ' + "'" + uid + "'" + " and value = " + parseInt(usereward);
	console.log("form: " + resdate + ", " + restime + "," + numpeople);
	var resid;
	var reserve_query = 'insert into reservations (restime, resdate, numpeople, discount) values (' + "'" + restime + "'" + ',' + "'" + resdate + "'" + ',' + numpeople + ',' + usereward + ') returning resid';
	client.query('BEGIN', (err, data) => {
		if (err) return rollback(client);
		if (usereward != 0) {
			console.log(find_reward);
			client.query(find_reward, (err, data) => {
			if (err) {
				console.log("find reward ERROR");
				return rollback(client);
			} else {
				rewid = data.rows[0].rewid;
				var remove_reward = "delete from rewards where rewid = " + "'" + rewid + "'";
				console.log("rewid:" + rewid);
				client.query(remove_reward, (err, data) => {
					if (err) {
						console.log("delete reward ERROR");
						return rollback(client);
					}
				});
			}	
			});
		}
		var earnedpoints = Math.min(numpeople * 10, 50);
		console.log("earned points: " + earnedpoints)
		var add_reward = "insert into rewards (value) values (" + earnedpoints + ") returning rewid";
		client.query(add_reward, (err, data) => {
			if (err) {
				console.log("add reward ERROR");
				return rollback(client);
			}
			var newrewid = data.rows[0].rewid;
			var add_earns = "insert into earns (rewid, uid) values (" + "'" + newrewid + "'" + ',' + "'" + uid + "'" + ")";
			console.log(add_earns);
			client.query(add_earns, (err, data) => {
				if (err) {
					console.log("add earns ERROR");
					return rollback(client);
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
                client.query('COMMIT', client.end.bind(client), (err, res2) => {
                  return res.redirect('/user/' + req.user.username);
                });
							}
					});
				});
			});
		});
	});
});

  var rollback = function (client) {
  client.query('ROLLBACK', function () {
    client.end();
  });
}});

module.exports = router;
