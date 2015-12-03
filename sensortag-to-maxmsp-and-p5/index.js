// var http = require('http'),
// fs = require('fs'),
// port = 3000,
// html = fs.readFileSync(__dirname + '/html/page.html', {encoding: 'utf8'}),
// css = fs.readFileSync(__dirname + '/css/styles.css', {encoding: 'utf8'});
//
// var app = http.createServer(function (req, res) {
//   if(req.url === '/styles.css') {
//     res.writeHead(200, {'Content-Type': 'text/css'});
//     res.end(css);
//   } else {
//     res.writeHead(200, {'Content-Type': 'text/html'});
//     res.end(html);
//   }
// }).listen(port, '127.0.0.1');

/******************** Socket.io */

// var io = require('socket.io').listen(app);
// var port = 8081,
//     io = require('socket.io').listen(port);
//
// io.sockets.on('connection', function (socket) {
//   socket.on('send', function (data) {
//   });
// });
//
// console.log('Server running at http://127.0.0.1:' + port);

/******************** WebSocket */
var WebSocketServer = require('ws').Server,
		port = 8081,
		wss = new WebSocketServer({ port: port }),
		connections = [];

wss.on('connection', function(client) {
	console.log('New Connection');
	connections.push(client);
	client.on('close', function() {
		console.log('connection closed');
		var position = connections.indexOf(client);
		connections.splice(position, 1);
	});
});

function broadcast(accel) {
	connections.forEach(function (connection) {
		connection.send(JSON.stringify(accel));
	})
}

/******************** sensorTag */

var st = require('sensortag'),
	accel = [0, 0, 0],
	gyro = [0, 0, 0];

/******************** node-osc */
// local machine
// port 57120 my SuperCollider uses (NetAddr.langPort to ensure)
var osc = require('node-osc'),
osc_server = new osc.Server(3333, '127.0.0.1'),
osc_client = new osc.Client('127.0.0.1', 57120);

/******************** node-osc + sensorTag */
// commented out for the "test" above
st.discover(function (tag) {
	tag.on('disconnect', function () {
		console.log('disconnected!');
		process.exit(0);
	});

	//function connectAndSetUpMe() {
	//	console.log('connect and setup...');
	//	tag.connectAndSetUp(setAccelPeriod);
	//}

	function connectAndSetUpMe() {
		console.log('connect and setup...');
		tag.connectAndSetUp(enableAccel);
	}

	function enableAccel() {
		console.log('enabling Accelerometer...');
		tag.enableAccelerometer(setAccelPeriod);	// here we enable its range to be +-8G directly thru modifying common.js
	}

	///** enableAccel and setAccelRangeMax are experimental */
	//function enableAccel() {
	//	console.log('enableAccelerometer');
	//	tag.enableAccelerometer(setAccelRangeMax);
	//}

	//// set accelerometer of CC2540 to maximum range of -8 ~ 8G
	//function setAccelRangeMax() {
	//	console.log('set accelerometer range to max...');
	//	tag.setAccelerometerRangeToMax(setAccelPeriod);
	//}

	// set period/sample rate of the accelerometer (minimum period 100ms)
	function setAccelPeriod() {
		console.log('setting accelerometer period to 100ms...');
		tag.setAccelerometerPeriod(100, enableGyro);
	}

	function enableGyro() {
		console.log('enabling Gyroscope...');
		tag.enableGyroscope(setGyroPeriod)
	}

	/* useless */
	function setGyroPeriod() {
		console.log('setting Gyroscope period to 100ms...');
		tag.setGyroscopePeriod(100, notifyMe);
	}

	function notifyMe() {
		console.log('begin notification');
		tag.notifyAccelerometer(listenForAccel);
		tag.notifyGyroscope(listenForGyro);
		tag.notifySimpleKey(listenForButton);
	}

	function listenForAccel() {
		tag.on('accelerometerChange', function(x, y, z) {
			// store acceleration, unit g, range -2, +2
			accel[0] = x.toFixed(3);
			accel[1] = y.toFixed(3);
			accel[2] = z.toFixed(3);
			// send OSC msg
			var osc_msg = {
				address: '/accel',
				args: [
					accel[0],
					accel[1],
					accel[2]
				]
			};
			osc_client.send(osc_msg);
			// broadcast accel data
			if (connections.length > 0) {
				broadcast({ accel_x : accel[0], accel_y : accel[1], accel_z : accel[2] });
			}
			//console.log("message sent");
			console.log(osc_msg);
		});
	}

	function listenForGyro() {
		tag.on('gyroscopeChange', function(x, y, z) {
			// store rotation, unit deg/s, range -250, +250
			gyro[0] = x.toFixed(3);
			gyro[1] = y.toFixed(3);
			gyro[2] = z.toFixed(3);
			// send OSC msgs
			var osc_msg = {
				address: '/gyro',
				args: [
					gyro[0],
					gyro[1],
					gyro[2]
				]
			}
			osc_client.send(osc_msg);
			// broadcast gyro data
			if (connections.length > 0) {
				broadcast({ gyro_x : gyro[0], gyro_y : gyro[1], gyro_z : gyro[2] });
			}
			console.log(osc_msg);
		});
	}

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
})
