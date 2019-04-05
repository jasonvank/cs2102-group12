const sql_query = require('../../sql');

var express = require('express');
var router = express.Router();

// const { Pool } = require('pg')
// const pool = new Pool({connectionString: process.env.DATABASE_URL});

var Client = require('pg').Client;
var client = new Client({connectionString: process.env.DATABASE_URL});
client.connect();

// GET
router.get('/', function(req, res, next) {
  if (!req.user) res.redirect('/login');
  res.render('restaurants/add_restaurant', {user: req.user});
});

// post
router.post('/', function(req, res, next) {
	// Retrieve Information
	var name = req.body.name;
  var address = req.body.address;
  var open_time = req.body.open_time;
  var close_time = req.body.close_time;
  var contacts = req.body.contacts;
  var uid = req.user.user_uid;
  var menu_name = req.body.menu_name;

  var rollback = function(client) {
    //terminating a client connection will
    //automatically rollback any uncommitted transactions
    //so while it's not technically mandatory to call
    //ROLLBACK it is cleaner and more correct
    client.query('ROLLBACK', function() {
      client.end();
    });
  };

  client.query('BEGIN', function(err, data) {
    if(err) return rollback(client);
    client.query(sql_query.query.add_restaurant, [uid, name, address, open_time, close_time, contacts], function(err, data) {
          if (err) return rollback(client);
          var rid = data.rows[0].rid;
          client.query(sql_query.query.register_restaurant, [uid, rid], function(err, data) {
            if (err) rollback(client);
            client.query(sql_query.query.add_menu, [rid, menu_name], function(err, data) {
              if (err) rollback(client);
              client.query('COMMIT', client.end.bind(client));
              res.redirect('/profile');
            })
          })
        })
      });
});

module.exports = router;
