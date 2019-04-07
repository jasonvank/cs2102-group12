const sql_query = require('../../sql');
var express = require('express');
var router = express.Router();
var isLoggedIn = require('../index.js');// import isLoggedIn from index.js
const bcrypt = require('bcrypt');
const { Pool } = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});

var historyRouter = require('./history.js');
router.use('/history', historyRouter);

// GET route after registering
router.get('/', function(req, res, next) {
  res.render('user', { title: 'Express' });
});

router.get('/:userId', function(req, res, next) {
  console.log("well!!!")

  if (!req.user.username) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  pool.query(sql_query.query.user_info, [req.user.username], (err, data) => {
    if(err) {
      res.redirect('/login');
    } else { 
      res.render('user/user', {
        data : data.rows[0]
      });
    }
  });
});

router.get('/:userId/history', function(req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  var user_uid = req.user.user_uid;
  pool.query(sql_query.query.check_usertype, [user_uid], (err, data) => {
    if(err) {
      return res.redirect('/login');
    } else {
      if (data.rows.length == 0) {
        return customer_history(user_uid, res) 
      } else {
        return manager_history(user_uid, res);
      }
    }
  })
});

router.get('/:userId/reset_password', function(req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  res.render('user/reset_password', { title: 'Express' });
});

router.post('/:userId/reset_password', function(req, res, next) {
  if (req.user.username != req.params.userId) {
    res.redirect('/login');
  }

	var password_hash   = bcrypt.hashSync(req.body.password, 10);

  pool.query(sql_query.query.reset_password, [req.user.user_uid, password_hash], (err, data) => {
    if(err) {
      res.redirect('/login');
    } else { 
      res.redirect('/user/' + req.user.username);
    }
  }); 
})

router.get('/:userId/update_info', function(req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  res.render('user/update_info', { title: 'Express' });
});

router.post('/:userId/update_info', function(req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
	var first_name = req.body.first_name;
	var last_name  = req.body.last_name;

  console.log("user uid " + req.user.user_uid);
  console.log("new first name " + first_name);
  console.log("new last name " + last_name);

  pool.query(sql_query.query.update_info, [req.user.user_uid, first_name, last_name], (err, data) => {
    if(err) {
      res.redirect('/login');
    } else { 
      res.redirect('/user/' + req.user.username);
    }
  }); 
})

function isManager (user_uid, res) {
  console.log(user_uid)
  pool.query(sql_query.query.check_usertype, [user_uid], (err, data) => {
    if(err) {
      return res.redirect('/login');
    } else {
      if (data.rows.length == 0) return false;
      else return true;
    }
  })
}

function customer_history (user_uid, res) {
  pool.query(sql_query.query.customer_history, [user_uid], (err, data) => {
    if(err) {
      res.redirect('/login');
    } else { 
      res.render('user/history', { data: data[0] });
    }
  });  
}

function manager_history (user_uid, res) {
  pool.query(sql_query.query.manager_history, [user_uid], (err, data) => {
    console.log(JSON.stringify(data));
    if(err) {
      res.redirect('/user/' + req.user.username);
    } else { 
      res.render('user/history', { data: data[0] });
    }
  });  
}

module.exports = router;