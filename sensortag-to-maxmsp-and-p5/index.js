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

var st = require('sensortag')
accel = [0, 0, 0]

/******************** node-osc */

var osc = require('node-osc')
osc_server = new osc.Server(3333, '127.0.0.1')
osc_client = new osc.Client('127.0.0.1', 3334)

// test
//var testSend = setInterval(function() {
//	osc_client.send('sensorTag_accelerometer ' + Math.random() * 8 + ' ' + Math.random() * 8 + ' ' + Math.random() * 8);
//}, 500);

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
		console.log('enableAccelerometer');
		tag.enableAccelerometer(setAccelPeriod);	// here we enable its range to be +-8G directly thru modifying common.js
	}

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
		console.log('set accelerometer period...');
		tag.setAccelerometerPeriod(100, notifyMe);
	}

	function notifyMe() {
		console.log('begin notification');
		tag.notifyAccelerometer(listenForAccel);
		tag.notifySimpleKey(listenForButton);
	}

	function listenForAccel() {
		tag.on('accelerometerChange', function(x, y, z) {
			// store accelerometer data (in -8.0 ~ 8.0 G)
			accel[0] = x.toFixed(3);
			accel[1] = y.toFixed(3);
			accel[2] = z.toFixed(3);
			// send osc msgs
			var osc_msg = 'sensorTag_accelerometer ' + accel[0] + ' ' + accel[1] + ' ' + accel[2]
			osc_client.send(osc_msg);
			// broadcast accel data
			if (connections.length > 0) {
				broadcast({ x:accel[0], y:accel[1], z:accel[2] });
			}
			//console.log("message sent");
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