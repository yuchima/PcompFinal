// NetAddr.langPort;
// NetAddr.localAddr;
// thisProcess.openUDPPort(1121);
// thisProcess.openPorts;
// n = NetAddr.new("127.0.0.1", 7771);
// // create the OSCresponderNode
// o = OSCFunc.new({ arg msg, time, addr, recvPort; [msg, time, addr, recvPort].postln }, '/goodbye', n);
// o.free;
// OSCFunc.trace(true);
// OSCFunc.trace(false);
// Nov 18, 2:40 AM
// n = NetAddr("127.0.0.1", 57120); // 57120 is sclang default port
// r = OSCFunc({ arg msg, time; [time, msg].postln }, '/good/news', n);
//
// n.sendMsg("/good/news", "you", "not you");
// n.sendMsg("/good/news", 1, 1.3, 77);
//
//
// n.sendBundle(0.2, ["/good/news", 1, 1.3, 77]);
//
// r.free;
// n.disconnect;
//
// // note that different NetAddr objects with the same port and ip are independent.
//
// r = OSCFunc({ "message arrived".postln }, '/x');
//
// n = NetAddr("127.0.0.1", 57120);
// n.sendMsg("/x")
//
//
// u = NetAddr("127.0.0.1", 57120);
// u.sendMsg("/x");
//
// n.disconnect
//
// u.sendMsg("/x");
//
// r.free;
// u.disconnect;
// Nov 18, 3:11 AM
// (
// n = NetAddr.new("127.0.0.1", 3333);
// r = OSCFunc.newMatching({|msg, time, addr, recvPort| [msg, time, addr, recvPort].postln}, '/oscAddress', n); // path matching
// )
// (
// m = NetAddr.new("127.0.0.1", 3333);
// m.sendMsg("/oscAddress");
// )
// Nov 18, 3:40 AM
n = NetAddr("127.0.0.1", NetAddr.langPort); // local machine

OSCFunc.newMatching({|msg, time, addr, recvPort| \matching.postln}, '/chat', n); // path matching
OSCFunc({|msg, time, addr, recvPort| \oneShot.postln}, '/chat', n).oneShot; // once only
OSCdef(\test, {|msg, time, addr, recvPort| \unmatching.postln}, '/chat', n); // def style

m = NetAddr("127.0.0.1", NetAddr.langPort); // loopback

m.sendMsg("/chat", "Hello App 1");
m.sendMsg("/chat", "Hello App 1"); // oneshot gone
m.sendMsg("/ch?t", "Hello App 1");
m.sendMsg("/*", "Hello App 1");
m.sendMsg("/chit", "Hello App 1"); // nothing

// Introspection

AbstractResponderFunc.allFuncProxies
AbstractResponderFunc.allEnabled
OSCdef(\test).disable;
AbstractResponderFunc.allDisabled

// change funcs
OSCdef(\test).enable;
OSCdef(\test, {|msg, time, addr, recvPort| 'Changed Unmatching'.postln}, '/chat', n); // replace at key \test
m.sendMsg("/chat", "Hello App 1");
OSCdef(\test).add(f = {\foo.postln}); // add another func
m.sendMsg("/chat", "Hello App 1");
OSCdef(\test).clear; // remove all functions
m.sendMsg("/chat", "Hello App 1");

//////// Use an argTemplate for finer grained matching

s.boot;
x = Synth(\default);
OSCFunc({ 'ended!'.postln }, '/n_end', s.addr, nil, [x.nodeID]).oneShot;
x.release(3);
// Nov 18, 3:47 AM
(
o = OSCresponderNode(nil, "/test", { arg time, responder, msg;
    "message receive:".postln;
    msg.postln;
}).add;
)
(
m = NetAddr("127.0.0.1", 3000);
m.sendMsg("/test", "Hello Node.js!");
)
// Nov 18, 10:19 AM
(
n = NetAddr.new("localhost", NetAddr.langPort);
o = OSCresponderNode(n, "/sensortag", {|time, responder, msg, addr|

)