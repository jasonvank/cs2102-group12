var express = require('express');
var router = express.Router();
var session = require('express-session');
var bodyParser = require('body-parser');
var path = require('path');
var flash = require('connect-flash');
const passport = require('passport');
const bcrypt = require('bcrypt');

const sql_query = require('../../sql');

const {Pool} = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

var Client = require('pg').Client;
var client = new Client({connectionString: process.env.DATABASE_URL});
client.connect();

var uid;
var rid;

/* GET reservation page. */

router.get('/:rid', function (req, res, next) {
  if (!req.isAuthenticated()) { // if not logged in, redirect to login page
    return res.redirect('/login');
  } else {
    return next();
  }
}, function (req, res, next) {
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
}, function (req, res, next) {
  //var get_rewards = 'select value from earns left join rewards on earns.rewid = rewards.rewid where uid = ' + "'" + uid + "'";
  var rewardvalues;
  pool.query(sql_query.query.get_rewards, [uid], (err, data) => {
    rewardvalues = data.rows;
    console.log(rewardvalues);
    res.render('reservations/reservation', {user: req.user, rewardsList: rewardvalues}); //the user is for navbar, rewards list for displaying rewards
  });
});

// POST reservation
router.post('/:rid', function (req, res, next) {
  var resdate = req.body.book_date;
  var restime = req.body.book_time;
  var numpeople = req.body.numpeople;
  var usereward = req.body.usereward;

  console.log("use reward: " + usereward);
  console.log("form: " + resdate + ", " + restime + "," + numpeople);
  var resid;

  var rollback = function (client, err) {
    client.query('ROLLBACK', client.end.bind(client), function () {
      return res.render('reservations/errorpage', {message: err});
    });
  };

  client.query('BEGIN', (err, data) => {
    if (err) return rollback(client, err);
    if (usereward != 0) {
      client.query(sql_query.query.select_reward, [uid, usereward], (err, data) => {
        if (err) {
          console.log("find reward ERROR");
          return rollback(client, err);
        } else {
          rewid = data.rows[0].rewid;
          console.log("rewid:" + rewid);
          client.query(sql_query.query.delete_reward, [rewid], (err, data) => {
            if (err) {
              console.log("delete reward ERROR");
              return rollback(client, err);
            }
          });
        }
      });
    }
    var earnedpoints = Math.min(numpeople * 10, 50);
    console.log("earned points: " + earnedpoints)
    client.query(sql_query.query.add_reward, [earnedpoints], (err, data) => {
      if (err) {
        console.log("add reward ERROR");
        return rollback(client, err);
      }
      var newrewid = data.rows[0].rewid;

      client.query(sql_query.query.add_earns, [newrewid, uid], (err, data) => {
        if (err) {
          console.log("add earns ERROR");
          return rollback(client, err);
        }
        //insert into Reservations table

        console.log(restime);
        console.log(resdate);
        console.log(numpeople);
        console.log(usereward);

        client.query(sql_query.query.add_reservation, [restime, resdate, numpeople, usereward], function (err, data) {
          if (err) {
            console.log("reserve ERROR");
            return rollback(client, err);
          }
          resid = data.rows[0].resid;
          console.log("resid: " + resid);
          //insert into Books table
          client.query(sql_query.query.add_books, [resid, uid], function (err, data) {
            if (err) {
              console.log("book ERROR");
              return rollback(client, err);
            }
            // insert into processes table
            client.query(sql_query.query.add_processes, [resid, rid], function (err, data) {
              if (err) {
                console.log("process ERROR");
                return rollback(client, err);
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

});


module.exports = router;
