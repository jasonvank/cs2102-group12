var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');
var logger = require('morgan');
var flash = require('connect-flash');

var bodyParser = require('body-parser')
var session = require('express-session')
var passport = require('passport')

/* --- V7: Using dotenv     --- */
require('dotenv').config({path: __dirname + '/.env'})

/* --- sample ---*/
var tableRouter = require('./routes/table');
var loopsRouter = require('./routes/loops');
var formsRouter = require('./routes/forms');


var indexRouter = require('./routes/index');
var aboutRouter = require('./routes/about');

/* --- users management --- */
// var registerRouter = require('./routes/users/register');
// var loginRouter = require('./routes/users/login');
// var forgotRouter = require('./routes/users/forgot');
var adminRouter = require('./routes/users/admin');
// var profileRouter = require('./routes/users/profile');
var usersRouter = require('./routes/users/users');

/* --- restarants management --- */
var menuRouter = require('./routes/restaurants/menu');
var specialtiesRouter = require('./routes/restaurants/specialties');

/* --- reservations management --- */
var reservationRouter = require('./routes/reservations/reservation');
var servicesRouter = require('./routes/reservations/services');

var app = express();


// Authentication Setup
// require('dotenv').load();
require('./auth').init(app);
app.use(session({
  secret: process.env.SECRET,
  resave: true,
  saveUninitialized: true
}))
app.use(passport.initialize())
app.use(passport.session())
app.use(flash())


// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

/* --- sample --- */
app.use('/table', tableRouter);
app.use('/loops', loopsRouter);
app.use('/forms', formsRouter);


app.use('/', indexRouter);
app.use('/about', aboutRouter);

/* --- restaurants management --- */
app.use('/menu', menuRouter);
app.use('/specialties', specialtiesRouter);

/* --- users management --- */
// app.use('/register', registerRouter);
// app.use('/login', loginRouter);
// app.use('/profile', profileRouter);
app.use('/admin', adminRouter);
// app.use('/users', usersRouter);
// app.use('/forgot', forgotRouter);

/* --- reservation management --- */
app.use('/services', servicesRouter);
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
