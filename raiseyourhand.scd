(
SynthDef(\boxing, {
  |out = 0, punchrate = 1|
  var punchforce = 65;
  punchrate = MouseY.kr(1, 4); // trigger
  punchforce = TExpRand.kr(punchforce, punchforce * MouseY.kr(1.25, 1.1), Impulse.kr(punchrate));
  punchforce = MouseY.kr(punchforce, punchforce * 1.75); // how fast; the faster, the higher pitch
  out =
  AllpassC.ar(
    in:PMOsc.ar(punchforce, 10, 3).tanh,
    decaytime:0.2
  ) *
  // Decay.ar(
  //   in:Impulse.ar(punchrate),
  //   decayTime:MouseX.kr(0.2, 1.2); // how heavy; the heavier, the more resonant
  // ) *
  EnvGen.ar(Env.perc(0, MouseX.kr(0.2, 1.2), 1, -6)) *
  MouseX.kr(0.2, 0.5); // how loud, the heavier, the louder
  Out.ar(0, out.dup);
}).play
)

(
~oscAccel = OSCFunc.newMatching(
  {|msg, time, addr, recvPort|
    [time, msg].postln; // msg[1] is accel_x, msg[2] is accel_y, msg[3] is accel_z

  },
  '/accel'
);

~oscGyro = OSCFunc.newMatching(
  {|msg, time, addr, recvPort| [time, msg].postln},
  '/gyro'
);
)

(
~oscAccel.free;
~oscGyro.free;
)

// (
// play{AllpassC.ar(
//   in:SinOsc.ar(55).tanh,
//   maxdelaytime:0.4,
//   delaytime:
//   TExpRand.ar(
//     lo:2e-4,
//     hi:0.4,
//     trig:Impulse.ar(8)
//   ).round([2e-3, 4e-3]),
//   decaytime:2
//   )
// };
// )



SynthDef(
  \test,
  {
    var
    trig =
    Demand.ar(trig, reset, demanUGens)
  },
  rates,
  prependArgs,
  variants,
  metadata
)