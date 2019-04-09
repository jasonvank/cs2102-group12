const sql_query = require('../sql');



var express = require('express');
var router = express.Router();


const passport = require('passport');
const bcrypt = require('bcrypt');
const { Pool } = require('pg');
const pool = new Pool({
  connectionString: process.env.DATABASE_URL
});

router.get('/', function(req, res, next) {
  var searchInfo = req.query;
  var rest_name = searchInfo.name;
  var location = searchInfo.location;
  var category = searchInfo.category;
  var time = searchInfo.time;

})

module.exports = router;
