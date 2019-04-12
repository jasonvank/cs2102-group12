const sql_query = require('../../sql');
var express = require('express');
var router = express.Router();
var isLoggedIn = require('../index.js');// import isLoggedIn from index.js
const bcrypt = require('bcrypt');
const {Pool} = require('pg')
const pool = new Pool({connectionString: process.env.DATABASE_URL});


var Client = require('pg').Client;
var client = new Client({connectionString: process.env.DATABASE_URL});
client.connect();


// var historyRouter = require('./history.js');
// router.use('/:userId/history', historyRouter);

// User Profile Page -----------------------------------------------------------------------------------
router.get('/', function (req, res, next) {
  res.render('user', {user: req.user});
});

router.get('/:userId', function (req, res, next) {
  if (!req.user) {
    res.status(500).send("<h3>Please <a href='/login'> login </a> first</h3>")
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  pool.query(sql_query.query.user_info, [req.user.username], (err, data) => {
    if (err) {
      res.status(500).send("Please login first")
      res.redirect('/login');
    } else {
      var user_uid = req.user.user_uid;
      // if user is customer
      if (req.user.isManager) {
        return new_bookings(user_uid, req, res)
      } else {
        return current_reservations(user_uid, req, res);
      }
    }
  });
});
// End user profile page -----------------------------------------------------------------------------------


// User information and password updates -------------------------------------------------------------------
router.get('/:userId/reset_password', function (req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  res.render('user/reset_password', {title: 'Express'});
});

router.post('/:userId/reset_password', function (req, res, next) {
  if (req.user.username != req.params.userId) {
    res.redirect('/login');
  }

  var password_hash = bcrypt.hashSync(req.body.password, 10);

  pool.query(sql_query.query.reset_password, [req.user.user_uid, password_hash], (err, data) => {
    if (err) {
      res.redirect('/login');
    } else {
      res.redirect('/user/' + req.user.username);
    }
  });
});

router.get('/:userId/update_info', function (req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  res.render('user/update_info', {data: req.user});
});

router.post('/:userId/update_info', function (req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  var first_name = req.body.first_name;
  var last_name = req.body.last_name;
  var contact_number = req.body.contact_number;

  pool.query(sql_query.query.update_info, [req.user.user_uid, first_name, last_name, contact_number], (err, data) => {
    if (err) {
      res.redirect('/login');
    } else {
      res.redirect('/user/' + req.user.username);
    }
  });
});
// End user information and passwords updates --------------------------------------------------------------


// Add Restaurant---------------------------------------------------------------------
router.get('/:userId/add_restaurant', function (req, res, next) {
  if (!req.user) res.redirect('/login');
  client.query(sql_query.query.userid_to_restaurant, [req.user.user_uid], function (err, data) {
    if (err) return next(err);
    if (data.rows[0]) {
      return res.render('user/restaurants/error_page/add_restaurant_error', {data: req.user.username});
    } else {
      res.render('user/restaurants/add_restaurant', {user: req.user});
    }
  });
});

router.post('/:userId/add_restaurant', function (req, res, next) {
  var name = req.body.name;
  var address = req.body.address;
  var location = req.body.location;
  var open_time = req.body.open_time;
  var close_time = req.body.close_time;
  var contacts = req.body.contacts;
  var uid = req.user.user_uid;
  var menu_name = req.body.menu_name;
  var cuisines = req.body.cuisines;

  var rollback = function (client, err) {
    client.query('ROLLBACK', client.end.bind(client), function () {
      var errorMessage = {
        message: err,
        user_name: req.user.username
      };
      return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    });
  };
  var rid;
  client.query('BEGIN', function (err, data) {
    if (err) return rollback(client, err);
    client.query(sql_query.query.add_restaurant, [name, address, location, open_time, close_time, contacts], function (err, data) {
      if (err) return rollback(client, err);
      rid = data.rows[0].rid;
      client.query(sql_query.query.register_restaurant, [uid, rid], function (err, data) {
        if (err) rollback(client, err);
        client.query(sql_query.query.add_menu, [rid, menu_name], function (err, data) {
          if (err) rollback(client, err);
          // To add Categories
          var cid;
          // if (typeof cuisines === 'string' || cuisines instanceof String) {
          client.query(sql_query.query.cat_name_to_cid, [cuisines], function (err, data) {
            if (err) rollback(client, err);
            cid = data.rows[0].cid;
            client.query(sql_query.query.add_category, [cid, rid], function (err, data) {
              if (err) {
                rollback(client, err);
              } else {
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
// End of Add Restaurant--------------------------------------------------------------------------

//Add Menu-------------------------------------------------------------------------------------------
router.get('/:userId/add_menu', function (req, res, next) {
  if (!req.user) res.redirect('/login');
  res.render('user/restaurants/add_menu');
});

router.post('/:userId/add_menu', function (req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  pool.query(sql_query.query.userid_to_restaurant, [req.user.user_uid], (err, data) => {
    if (err) return next(err);
    var errorMessage = {
      message: "Please register your restaurant first!",
      user_name: req.user.username
    };
    if (!data.rows[0]) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    var rid = data.rows[0].rid;
    pool.query(sql_query.query.add_menu, [rid, req.body.name], (err, data) => {
      errorMessage.message = err;
      if (err) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
      res.redirect('/user/' + req.user.username);
    })
  });
});
// End of Add Menu--------------------------------------------------------------------------

//Edit Restaurant------------------------------------------------------------------------------------
var uid;
var rid;
// GET
router.get('/:userId/edit_restaurant', function (req, res, next) {
  if (!req.user) res.redirect('/login');
  uid = req.user.user_uid;
  pool.query(sql_query.query.userid_to_restaurant, [req.user.user_uid], (err, data) => {
    if (err) return next(err);
    var errorMessage = {
      message: "Please register your restaurant first!",
      user_name: req.user.username
    };
    if (!data.rows[0]) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    rid = data.rows[0].rid;
    res.render('user/restaurants/edit_restaurant', {data: data.rows[0]});
  });
});

// post
router.post('/:userId/edit_restaurant', function (req, res, next) {
  // Retrieve Information
  var name = req.body.name;
  var address = req.body.address;
  var open_time = req.body.open_time;
  var close_time = req.body.close_time;
  var contacts = req.body.contacts;
  var location = req.body.location;
  var cuisines = req.body.cuisines;

  pool.query(sql_query.query.update_restaurant, [rid, name, address, location, open_time, close_time, contacts], (err, data) => {
    var errorMessage = {
      message: err,
      user_name: req.user.username
    };
    if (err) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    // Edit categories of restaurant
    client.query('BEGIN', function(err, data) {
      if (err) rollback(client, err);
      client.query(sql_query.query.delete_rest_belongs, [rid], function(err, data) {
        if (err) rollback(client, err);
        var cid;
        // if (typeof cuisines === 'string' || cuisines instanceof String) {
          client.query(sql_query.query.cat_name_to_cid, [cuisines], function (err, data) {
            if (err) rollback(client, err);
            cid = data.rows[0].cid;
            client.query(sql_query.query.add_category, [cid, rid], function (err, data) {
              if (err) {
                rollback(client, err);
              } else {
                client.query('COMMIT');
                return res.redirect('/user/' + req.user.username);
              }
            });
          });
        // }
      });
      // return res.redirect('/user/' + req.user.username);
    });
  });
});
//End of Edit Restaurant------------------------------------------------------------------------------------


//Delete Restaurant------------------------------------------------------------------------------------------
var rid;
router.get('/:userId/delete_restaurant', function (req, res, next) {
  if (!req.user) res.redirect('/login');
  uid = req.user.user_uid;
  pool.query(sql_query.query.userid_to_restaurant, [req.user.user_uid], (err, data) => {
    if (err) return next(err);
    var errorMessage = {
      message: "You have no restaurant to be deleted!",
      user_name: req.user.username
    };
    if (!data.rows[0]) return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    rid = data.rows[0].rid;
    res.render('user/restaurants/delete_restaurant', {data: data.rows[0]});
  });
});

router.post('/:userId/delete_restaurant', function(req, res, next) {
  var result = typeof req.body.Yes == 'undefined' ? "No" : "Yes";
  if (result == "No") return res.redirect('/user/' + req.user.username);
  var rollback = function(client, err) {
    client.query('ROLLBACK', client.end.bind(client), function() {
      var errorMessage = {
        message: err,
        user_name: req.user.username
      };
      return res.render('user/restaurants/error_page/operation_error', {data: errorMessage});
    });
  };
  client.query('BEGIN', function(err, data) {
    if(err) return rollback(client, err);
    client.query(sql_query.query.delete_register, [rid], function(err, data) {
      if (err) return rollback(client, err);
      client.query(sql_query.query.delete_restaurant, [rid], function(err, data) {
        if (err) rollback(client, err);
        client.query(sql_query.query.delete_rest_belongs, [rid], function(err, data) {
          if (err) rollback(client, err);
          client.query('COMMIT', client.end.bind(client), (err, res2) => {
              return res.redirect('/user/' + req.user.username);
          });
        });
      });
    });
  });
});
//End of Delete restaurant-----------------------------------------------------------------------------------

// Router to user past reservations or bookings page -------------------------------------------------------
router.get('/:userId/history', function (req, res, next) {
  if (!req.user) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  var user_uid = req.user.user_uid;
  if (req.user.isManager) {
    return manager_history(user_uid, req, res);
  } else {
    return customer_history(user_uid, req, res)
  }
});


router.get('/:userId/reset_password', function (req, res, next) {
  if (!req.user.username) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/user/' + req.user.username);
  }
  res.render('user/reset_password', {title: 'Express'});
});

router.post('/:userId/reset_password', function (req, res, next) {
  if (req.user.username != req.params.userId) {
    res.redirect('/login');
  }

  var password_hash = bcrypt.hashSync(req.body.password, 10);

  pool.query(sql_query.query.reset_password, [req.user.user_uid, password_hash], (err, data) => {
    if (err) {
      res.redirect('/login');
    } else {
      res.redirect('/user/' + req.user.username);
    }
  });
});


//manager reject reservation
router.get('/:userId/:resId/reject', function (req, res, next) {
  if (!req.user.isManager) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/login');
  }
  res.render('user/reject');
});


router.post('/:userId/:resId/reject', function (req, res, next) {
  var resid = req.params.resId;
  client.query('BEGIN', (err, data) => {
    if (err) return rollback(client);
    client.query(sql_query.query.remove_processes, [resid], (err, data) => {
      if (err) return rollback(client);
      client.query(sql_query.query.remove_books, [resid], (err, data) => {
        if (err) return rollback(client);
        client.query(sql_query.query.remove_reservation, [resid], (err, data) => {
          if (err) return rollback(client);
          client.query('COMMIT');
          return res.redirect('/user/' + req.user.username);
        });
      });
    });
  });
});


//customer cancel reservation
router.get('/:userId/:resId/cancel', function (req, res, next) {
  if (req.user.isManager) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/login');
  }
  res.render('user/cancel');
});

router.post('/:userId/:resId/cancel', function (req, res, next) {
  var resid = req.params.resId;
  client.query('BEGIN', (err, data) => {
    if (err) return rollback(client);
    client.query(sql_query.query.remove_processes, [resid], (err, data) => {
      if (err) return rollback(client);
      client.query(sql_query.query.remove_books, [resid], (err, data) => {
        if (err) return rollback(client);
        client.query(sql_query.query.remove_reservation, [resid], (err, data) => {
          if (err) return rollback(client);
          client.query('COMMIT');
          return res.redirect('/user/' + req.user.username);
        });
      });
    });
  });
});

//customer edit reservation
router.get('/:userId/:resId/edit', function (req, res, next) {
  if (req.user.isManager) {
    res.redirect('/login');
  }
  if (req.user.username != req.params.userId) {
    res.redirect('/login');
  }
  pool.query(sql_query.query.get_reservation, [req.params.resId], (err, data) => {
    if (err) return res.status(500).send("Cannot find reservation");
    var reserv = data.rows[0];
    res.render('user/edit_reserv', {data: reserv});
  });
});

router.post('/:userId/:resId/edit', function (req, res, next) {
  var resid = req.params.resId;
  var resdate = req.body.book_date;
  var restime = req.body.book_time;
  var numpeople = req.body.numpeople;
  pool.query(sql_query.query.update_reservation, [resdate, restime, numpeople, resid], (err, data) => {
    if (err) return res.status(500).send("Cannot update reservation");
    res.redirect('/user/' + req.user.username);
  });
});


router.post('/:userId/history/:reservationId/rate', function (req, res, next) {

  if (!req.user.username) {
    res.redirect('/login');
  }

  var rating_value = Object.keys(req.body)[0];
  var reservation_id = req.params.reservationId;
  var URL = '/user/' + req.user.username;
  var hotText = 'Go Back';
  pool.query(sql_query.query.rate_reservation_restaurant, [reservation_id, rating_value], (err, data) => {
    if (err) {
      res.status(404).send("You have rate already! "  + hotText.link(URL));
    }
    // var history

    res.status(200).send("Rate Successfully! "  + hotText.link(URL));
  });
});


router.post('/:userId/:resId/cancel', function (req, res, next) {
  var resid = req.params.resId;
  client.query('BEGIN', (err, data) => {
    if (err) return rollback(client);
    client.query(sql_query.query.remove_processes, [resid], (err, data) => {
      if (err) return rollback(client);
      client.query(sql_query.query.remove_books, [resid], (err, data) => {
        if (err) return rollback(client);
        client.query(sql_query.query.remove_reservation, [resid], (err, data) => {
          if (err) return rollback(client);
          client.query('COMMIT');
          return res.redirect('/user/' + req.user.username);
        });
      });
    });
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

function new_bookings(user_uid, req, res) {
  // TODO:
  pool.query(sql_query.query.display_new_bookings, [user_uid], (err, data) => {
    if (err) {
      return res.redirect('/user/' + req.user.username);
    } else {
      return res.render('user/user', {
        // data: data[0],
        new_bookings: data.rows,
        user: req.user,
      });
    }
  });
}

function current_reservations(user_uid, req, res) {
  pool.query(sql_query.query.display_current_reservations, [user_uid], (err, data) => {
    if (err) {
      return res.redirect('/user/' + req.user.username);
    }
    return res.render('user/user', {
      current_reservations: data.rows,
      user: req.user,
    });
    // }
  });
}

// End supplementary functions for user queries -------------------------------------------------------

module.exports = router;
