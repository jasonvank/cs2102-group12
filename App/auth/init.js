const sql_query = require('../sql');

const passport = require('passport');
const bcrypt = require('bcrypt');
const LocalStrategy = require('passport-local').Strategy;

const authMiddleware = require('./middleware');
const antiMiddleware = require('./antimiddle');

// Postgre SQL Connection
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

function findUser (username, callback) {
    pool.query(sql_query.query.user_info, [username], (err, data) => {
		if(err) {
			console.error("Cannot find user");
			return callback(null);
		}
		
		if(data.rows.length == 0) {
			console.error("User does not exists?");
			return callback(null)
		} else if(data.rows.length == 1) {
			return callback(null, {
        username      : data.rows[0].username,
        password_hash : data.rows[0].password_hash,
        user_uid      : data.rows[0].user_uid,
        last_name     : data.rows[0].last_name,
        first_name    : data.rows[0].first_name,
        contact_number: data.rows[0].contact_number,
      });
		} else {
			console.error("More than one user?");
			return callback(null);
		}
	});
}

passport.serializeUser(function (user, cb) {
    console.log("16")
  cb(null, user.username);
  console.log("17")
})

passport.deserializeUser(function (username, cb) {
    console.log("1");
  findUser(username, cb);
  console.log("2");
})

function initPassport () {
  passport.use(new LocalStrategy(
    (username, password, done) => {
      findUser(username, (err, user) => {
        if (err) {
          return done(err);
        }
          console.log("18")
        // User not found
        if (!user) {
          console.error('User not found');
          return done(null, false);
        }

        // Always use hashed passwords and fixed time comparison
        bcrypt.compare(password, user.password_hash, (err, isValid) => {
          if (err) {
            return done(err);
          }
          if (!isValid) {
            return done(null, false);
          }
          return done(null, user);
        })
      })
    }
  ));

  passport.authMiddleware = authMiddleware;
  passport.antiMiddleware = antiMiddleware;
	passport.findUser = findUser;
}

module.exports = initPassport;