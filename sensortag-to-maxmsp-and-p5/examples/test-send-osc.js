var osc = require('node-osc');

var client = new osc.Client('127.0.0.1', 57120);

setInterval(function(){
  client.send('/test', "Hello SuperCollider!");
  console.log("messege sent");
}, 5000);
