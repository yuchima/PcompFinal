// Nov 18, 9:37 AM
// import necessary evils
var osc = require('node-osc');
var SensorTag = require('sensortag');
// SuperCollider as OSC server; the default port of SuperCollider is 57120
var client = new osc.Client('127.0.0.1', 57120);
// store accelerometer data in an object
var acc_data = { x : 0, y : 0, z : 0 };

// listen for sensortags:
SensorTag.discover(function(tag) {
	// when disconnect from a tag, exit the program:
	tag.on('disconnect', function() { console.log('disconnected!'); process.exit(0); });
  // the function to call after discovery
	function connectAndSetUpMe() { console.log('connect and setup...'); tag.connectAndSetUp(setAccelPeriod); }
  // set period/sample rate of the accelerometer (minimum period 100ms)
	function setAccelPeriod() { console.log('set accelerometer period...'); tag.setAccelerometerPeriod(100, enableAccel); }
  // enable the accelerometer, then start accelerometer notifications:
  function enableAccel() { console.log('enableAccelerometer'); tag.enableAccelerometer(notifyMe); }
	// start the accelerometer listener and the button listener
  function notifyMe() { tag.notifyAccelerometer(listenForAccel); tag.notifySimpleKey(listenForButton); }
  // When you get an accelermeter change, print it out:
  function listenForAccel() {
    tag.on('accelerometerChange', function(x, y, z) {
      // store accelerometer data (in G)
      acc_data["x"] = x.toFixed(3);
      acc_data["y"] = y.toFixed(3);
      acc_data["z"] = z.toFixed(3);
      // send osc msgs
      client.send('/sensortag', [acc_data]);
      console.log("messege send");
    });
  }
	// when you get a button change, print it out:
	function listenForButton() {
		tag.on('simpleKeyChange', function(left, right) {
			if (left) console.log('left: ' + left);
			if (right) console.log('right: ' + right);
			// if both buttons are pressed, disconnect:
			if (left && right) tag.disconnect();
    });
  }
  // Now that you've defined all the functions, start the process:
	connectAndSetUpMe();
});
