var sql_query = require('./sql');

var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');

const exphbs = require('express-handlebars')
const bodyParser = require('body-parser')
const session = require('express-session')
const passport = require('passport')

/* --- V7: Using dotenv     --- */
require('dotenv').config({path: __dirname + '/.env'})

var indexRouter = require('./routes/index');
var usersRouter = require('./routes/users');

/* --- V2: Adding Web Pages --- */
var aboutRouter = require('./routes/about');
/* ---------------------------- */

/* --- V3: Basic Template   --- */
var tableRouter = require('./routes/table');
var loopsRouter = require('./routes/loops');
/* ---------------------------- */

/* --- V4: Database Connect --- */
var selectRouter = require('./routes/select');
/* ---------------------------- */

/* --- V5: Adding Forms     --- */
var formsRouter = require('./routes/forms');
/* ---------------------------- */


var registerRouter = require('./routes/register');
var reservationRouter = require('./routes/reservation')
var servicesRouter = require('./routes/services')
var menuRouter = require('./routes/menu')
var specialtiesRouter = require('./routes/specialties')


var app = express();


// Authentication Setup
//require('dotenv').load();
require('./auth').init(app);
app.use(session({
  // secret: process.env.SECRET,
  secret: "reservation",
  resave: true,
  saveUninitialized: true
}))
app.use(passport.initialize())
app.use(passport.session())


// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use('/', indexRouter);
app.use('/users', usersRouter);

/* --- V2: Adding Web Pages --- */
app.use('/about', aboutRouter);
/* ---------------------------- */

/* --- V3: Basic Template   --- */
app.use('/table', tableRouter);
app.use('/loops', loopsRouter);
/* ---------------------------- */

/* --- V4: Database Connect --- */
app.use('/select', selectRouter);
/* ---------------------------- */

/* --- V5: Adding Forms     --- */
app.use('/forms', formsRouter);
/* ---------------------------- */

/* --- V6: Modify Database  --- */
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use('/register', registerRouter);
app.use('/services', servicesRouter);
app.use('/menu', menuRouter);
app.use('/specialties', specialtiesRouter);
app.use('/reservation', reservationRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
