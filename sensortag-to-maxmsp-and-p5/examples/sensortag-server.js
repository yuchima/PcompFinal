// var fs = require('fs');
// var csvWriter = require('csv-write-stream');
// var writer = csvWriter({ headers: ['x','y','z'], sendHeaders: false });
var SensorTag = require('sensortag');
// https://itp.nyu.edu/physcomp/labs/labs-serial-communication/lab-serial-communication-with-node-js/#Connecting_from_the_Browser_to_the_Node_Program
// https://github.com/ITPNYU/physcomp/blob/master/labs2014/Node%20Serial%20Lab/wsServer.js
var WebSocketServer = require('ws').Server;
var SERVER_PORT = 8081;
var wss = new WebSocketServer({port: SERVER_PORT});
var connections = new Array;
var accData = { x : 0, y : 0, z : 0 };

wss.on('connection', function(client) {
  console.log('New Connection');
  connections.push(client);
  client.on('close', function() {
    console.log('connection closed');
    var position = connections.indexOf(client);
    connections.splice(position, 1);
  });
});

function broadcast(accelerometerData) {
  for (var i = 0; i < connections.length; i++) {
    connections[i].send(JSON.stringify(accelerometerData));
  }
}

// listen for tags:
SensorTag.discover(function(tag) {
	// when you disconnect from a tag, exit the program:
	tag.on('disconnect', function() {
		console.log('disconnected!');
    // close csv stream
    // writer.end();
		process.exit(0);
	});

	function connectAndSetUpMe() {			// attempt to connect to the
    console.log('connectAndSetUp');
    console.log('id: ' + tag.id + ' type: ' + tag.type);
    // open csv stream
    // TODO: append instead of overwrite
    // writer.pipe(fs.createWriteStream(tag.id+'-acc-data.csv'));
    tag.connectAndSetUp(setAccelPeriod);		// when you connect and device is setup, call enableAccelMe
  }

	function setAccelPeriod() {	// set period/SR of accelerometer
    console.log('setAccelerometerPeriod');
    tag.setAccelerometerPeriod(100, enableAccelMe); // minimum period 100ms
	}

  function enableAccelMe() {		// attempt to enable the accelerometer
    console.log('enableAccelerometer');
    // when you enable the accelerometer, start accelerometer notifications:
    tag.enableAccelerometer(notifyMe);
  }

  function notifyMe() {
    tag.notifyAccelerometer(listenForAcc);   	// start the accelerometer listener
		tag.notifySimpleKey(listenForButton);		// start the button listener
  }

  // When you get an accelermeter change, print it out:
  function listenForAcc() {
    tag.on('accelerometerChange', function(x, y, z) {
      // store accelerometer data
      accData.x = x.toFixed(3);
      accData.y = y.toFixed(3);
      accData.z = z.toFixed(3);
      // console.log('\tx: '+accData.x+' G \ty: '+accData.y+'G \tz: '+accData.z+' G');
      // write csv data to the stream
      // writer.write([accData.x, accData.y, accData.z]);
      // broadcast data (https://github.com/ITPNYU/physcomp/blob/master/labs2014/Node%20Serial%20Lab/wsServer.js)
      if (connections.length > 0) { broadcast(accData); }
    });
  }

	// when you get a button change, print it out:
	function listenForButton() {
		tag.on('simpleKeyChange', function(left, right) {
			if (left) {
				console.log('left: ' + left);
			}
			if (right) {
				console.log('right: ' + right);
			}
			// if both buttons are pressed, disconnect:
			if (left && right) {
				tag.disconnect();
			}
    });
  }

	// Now that you've defined all the functions, start the process:
	connectAndSetUpMe();
});
