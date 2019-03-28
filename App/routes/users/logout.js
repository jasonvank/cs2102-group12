var express = require('express');
var router = express.Router();

/* GET menu page. */
router.get('/', function(req, res, next) {
	if (req.session) {
	  // delete session object
	  req.session.destroy(function(err) {
		if(err) {
		  return next(err);
		} else {
		  return res.redirect('/');
		}
	  });
	}
});

module.exports = router;
