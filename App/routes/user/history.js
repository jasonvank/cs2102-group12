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
    console.log('hehre');
  res.render('user/history', { title: 'Express' });
});

router.get('/:userId/history', function(req, res, next) {
    console.log('hehre history');

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

module.exports = router;