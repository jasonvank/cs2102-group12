var express = require('express');
var router = express.Router();

/* GET menu page. */
router.post('/', function(req, res, next) {
    req.session.destroy()
	req.logout()
	res.redirect('/')
});

module.exports = router;
