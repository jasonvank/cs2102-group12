const sql_query = require('../sql');

const passport = require('passport');
const bcrypt = require('bcrypt');
const LocalStrategy = require('passport-local').Strategy;

const authMiddleware = require('./middleware');
const antiMiddleware = require('./antimiddle');

// Postgre SQL Connection
const { Pool } = require('pg');
const pool = new Pool({ connectionString: process.env.DATABASE_URL });

function findOne (username, done) {
	pool.query(sql_query.query.user_login, [username], (err, data) => {
    if (err) {
      return done(err, false);
    }
    if (data.rows.length == 0) {
      var err = new Error('User not found.');
      err.status = 401;
      return done(err, false);
    } else if(data.rows.length == 1) {
			return done(null, {
				username     : data.rows[0].username,
				password_hash: data.rows[0].password_hash,
      });
		} else {
			return done(null);
		}
  })
}

passport.serializeUser(function (user, cb) {
  cb(null, user.username);
})

passport.deserializeUser(function (username, cb) {
  findOne(username, cb);
})

function initPassport () {
  passport.use(new LocalStrategy(
    (username, password, done) => {
      findOne(username, (err, user) => {
        if (err) {
          return done(err);
        } else if (!user) {
          var err = new Error('User not found.');
          err.status = 401;
          return done(err);
        }

        // Always use hashed passwords and fixed time comparison
        bcrypt.compare(password, user.password_hash, (err, isValid) => {
          if (isValid) {
            return done(null, user);
          } else {
            return done(null, false, {message: 'Incorrect password.'});
          }
        })
      })
    }
  ));

  passport.authMiddleware = authMiddleware;
  passport.antiMiddleware = antiMiddleware;
	passport.findOne = findOne;
}

module.exports = initPassport;