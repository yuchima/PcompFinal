// https://itp.nyu.edu/physcomp/labs/labs-serial-communication/lab-serial-communication-with-node-js/
// #Including_P5js
// https://github.com/ITPNYU/physcomp/blob/master/labs2014/Node%20Serial%20Lab/public/index.html
var text;
var socket = new WebSocket('ws://localhost:8081');
var circle = {};

function setup() {
	// The socket connection needs two event listeners:
	socket.onopen = openSocket;
	socket.onmessage = showData;
	
	// make a new div and position it at 10, 10:
	text = createDiv("Sensor reading:");
	text.position(10,10);
}

function openSocket() {
	text.html("Socket open");
}

function showData(result) {
	// when the server returns, show the result in the div:
	var accData = JSON.parse(result.data);
	// console.log(accData);
	text.html('Sensor reading x:' + accData.x + ' y:' + accData.y + ' z:' + accData.z);
	xPos = int(map(accData.x, -2, 2, 0, 100));
	text.position(xPos, 10);
}
