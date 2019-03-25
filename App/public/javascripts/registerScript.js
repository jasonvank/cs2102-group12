function check(event) {
	// Get Values
	var username  = document.getElementById('username' ).value;
	var first_name    = document.getElementById('first_name'   ).value;
	var last_name = document.getElementById('last_name').value;
	var password = document.getElementById('password').value;
	
	// Simple Check
	if(username.length != 9) {
		alert("Invalid username number");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(first_name.length == 0) {
		alert("Invalid first_name");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(last_name.length == 0) {
		alert("Invalid last_name");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	if(password.length <= 6) {
		alert("Invalid password code");
		event.preventDefault();
		event.stopPropagation();
		return false;
	}
	console.log("check");
}