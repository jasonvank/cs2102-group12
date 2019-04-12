const sql_query = require('../../sql');
var express = require('express');
var router = express.Router();
// const history = require('./history').Router();
var isLoggedIn = require('../index.js');// import isLoggedIn from index.js
const passport = require('passport');
const bcrypt = require('bcrypt');
const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

// GET route after registering
router.get('/', function(req, res, next) {
  if (!req.user) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  var user_uid = req.user.user_uid;
  if (req.user.isManager) {
    // return manager_history(user_uid, req, res);
  } else {
    // return customer_history(user_uid, req, res)
  }
});

router.post('/:reservationId/rate', function(req, res, next) {

  if (!req.user.username) {
    res.redirect('/login');
  }
  pool.query(sql_query.query.user_info, [req.user.username], (err, data) => {
    if(err) {
      res.redirect('/history');
    } else {
      res.render('user/user', {
        data : data.rows[0]
      });
    }
  });
});

// Supplementary functions for user queries ------------------------------------------------------------
function customer_history(user_uid, req, res) {
  pool.query(sql_query.query.display_customer_history, [user_uid], (err, data) => {
    if (err) {
      return res.redirect('/user/' + req.user.username);
    } else {

      return res.render('user/history', {
        history_reservations: data.rows,
        user: req.user,
      });
    }
  });
}

function manager_history(user_uid, req, res) {
  pool.query(sql_query.query.display_manager_history, [user_uid], (err, data) => {
    if (err) {
      return res.redirect('/user/' + req.user.username);
    } else {
      return res.render('user/history', {
        history_reservations: data.rows,
        user: req.user,
      });
    }
  });
}

module.exports = router;