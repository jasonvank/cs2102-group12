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

var userRouter = require('./routes/user/user');


/* --- restarants management --- */
var menuRouter = require('./routes/restaurants/menu');
var restaurantRouter = require('./routes/restaurants/restaurant');
var specialtiesRouter = require('./routes/restaurants/specialties');

var itemRouter = require('./routes/restaurants/item');
// var addRestaurantRouter = require('./routes/user/restaurants/add_restaurant');
var selectMenuRouter = require('./routes/user/add_item/select_menus');
// var addMenuRouter = require('./routes/restaurants/add_menu');
var addMenuItemRouter = require('./routes/user/add_item/add_menu_item');
var reEnterRouter = require('./routes/user/add_item/re_enter_form');
// var updateRestaurantRouter = require('./routes/restaurants/edit_restaurant');
var updateMenuRouter = require('./routes/user/edit_menu/select_menus');
var updateMenuNameRouter = require('./routes/user/edit_menu/edit_name');
var updateItem_SelectMenusRouter = require('./routes/user/edit_item/select_menus');
var updateItem_SelectItemsRouter = require('./routes/user/edit_item/select_items');
var updateItem_UpdateFieldsRouter = require('./routes/user/edit_item/edit_fields');
var reEditRouter = require('./routes/user/edit_item/re_edit_form');
// var addRestaurantErrorRouter = require('./routes/restaurants/add_restaurant');
// var addMenuErrorRouter = require('./routes/restaurants/add_menu');
var deleteMenuRouter = require('./routes/user/delete_menu/select_menus');
var deleteItem_SelectMenusRouter = require('./routes/user/delete_item/select_menus');
var deleteItem_DeleteItemRouter = require('./routes/user/delete_item/select_items');
var reDeleteRouter = require('./routes/user/delete_item/re_delete_form');

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
app.use(express.urlencoded({extended: false}));
app.use(cookieParser());
app.use(express.static(path.join(__dirname, 'public')));

app.use(bodyParser.json());
app.use(bodyParser.urlencoded({extended: true}));

/* --- sample --- */
app.use('/table', tableRouter);
app.use('/loops', loopsRouter);
app.use('/forms', formsRouter);


app.use('/', indexRouter);

app.use('/about', aboutRouter);

/* --- restaurants management --- */
app.use('/menu', menuRouter);
app.use('/restaurant', restaurantRouter);
app.use('/specialties', specialtiesRouter);
app.use('/item', itemRouter);

// app.use('/add_restaurant', addRestaurantRouter);
// app.use('/add_menu', addMenuRouter);
app.use('/user/add_item/add_menu_item', addMenuItemRouter);
app.use('/user/add_item/select_menus', selectMenuRouter)
app.use('/user/add_item/re_enter_form', reEnterRouter);
// app.use('/edit_restaurant', updateRestaurantRouter);
app.use('/user/edit_menu/select_menus', updateMenuRouter);
app.use('/user/edit_menu/edit_name', updateMenuNameRouter);
app.use('/user/edit_item/select_menus', updateItem_SelectMenusRouter);
app.use('/user/edit_item/select_items', updateItem_SelectItemsRouter);
app.use('/user/edit_item/edit_fields', updateItem_UpdateFieldsRouter);
app.use('/user/edit_item/re_edit_form', reEditRouter);

app.use('/user/delete_menu/select_menus', deleteMenuRouter);
app.use('/user/delete_item/select_menus', deleteItem_SelectMenusRouter);
app.use('/user/delete_item/select_items', deleteItem_DeleteItemRouter);
app.use('/user/delete_item/re_delete_form', reDeleteRouter);
// app.use('/add_restaurant_error',addRestaurantErrorRouter);
// app.use('/add_menu_error',addMenuErrorRouter);

/* --- users management --- */
// app.use('/error', errorRouter);
app.use('/user', userRouter);

/* --- reservation management --- */
app.use('/services', servicesRouter);
app.use('/reservation', reservationRouter);


// catch 404 and forward to error handler
app.use(function (req, res, next) {
  next(createError(404));
});

// catch 500 and forward to error handler
app.use(function (req, res, next) {
  next(createError(500));
});

// error handler
app.use(function (err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
