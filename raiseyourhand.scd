(
SynthDef(\boxing, {
  |out = 0, punchrate = 1|
  var punchforce = 65;
  // punchrate = 0.max((punchrate - 0.6)/2.7).postln("punchrate"); // 0~1 0.6~2.5
  // punchrate = MouseY.kr(1, 4); // trigger
  // punchforce = TExpRand.kr(punchforce, punchforce * MouseY.kr(1.25, 1.1), Impulse.kr(punchrate));
  // punchforce = MouseY.kr(punchforce, punchforce * 1.75); // how fast; the faster, the higher pitch
  // punchforce = punchforce * punchrate;
  punchforce = punchforce + (punchrate.cubed * 5);
  // punchforce = 114.min(punchforce.max(65));
  punchforce = 300.min(punchforce);
  out =
  AllpassC.ar(
    in:PMOsc.ar(punchforce, 10, 3).tanh,
    decaytime:0.2
  ) *
  // Decay.ar(
  //   in:Impulse.ar(punchrate),
  //   decayTime:MouseX.kr(0.2, 1.2); // how heavy; the heavier, the more resonant
  // ) *
  // EnvGen.ar(Env.perc(0, MouseX.kr(0.2, 1.2), 1, -6), doneAction:2) *
  EnvGen.ar(Env.perc(0, 1.2.min((sqrt(punchrate)-0.5).max(0.2)), 1, -6), doneAction:2) *
  // MouseX.kr(0.2, 0.5); // how loud, the heavier, the louder
  ((punchrate / 2.5).min(1)).max(0.5); // how loud, the heavier, the louder
  Out.ar(0, out.dup);
}).add;
)
(
// ~globaltimeprev = 0;
a = 0;
// ~globaltimenow = 0;
b = 1;
// ~globaltimedif = ~globaltimenow - ~globaltimedif;
c = b - a;
~oscAccel = OSCFunc.newMatching(
  {|msg, time, addr, recvPort|
    // [time, msg[1]].postln; // msg[1] is accel_x, msg[2] is accel_y, msg[3] is accel_z
    if (
      ((sqrt(msg[1].asFloat.squared + msg[2].asFloat.squared + msg[3].asFloat.squared)-1)/2.464 > 0.4).postln,
      {b = time; c = b - a;
        if ( (c.postln > 0.3), {c.reciprocal.postln; Synth(\boxing, [punchrate: c.reciprocal]); a = time})}
    );
  },
  '/accel'
);
//
// ~oscGyro = OSCFunc.newMatching(
//   {|msg, time, addr, recvPort| [time, msg].postln},
//   '/gyro'
// );
)

~oscAccel.free;
~oscGyro.free;