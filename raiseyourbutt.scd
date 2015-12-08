/*(
// first collect some things to play with
SynthDef("moto-rev", { arg out=0;
	var x;
	x = RLPF.ar(LFPulse.ar(SinOsc.kr(0.2, 0, 10, 21), [0,0.1], 0.1),
		100, 0.1).clip2(0.4);
	Out.ar(out, x);
}).send(s);

SynthDef("bubbles", { arg out=0;
	var f, zout;
	f = LFSaw.kr(0.4, 0, 24, LFSaw.kr([8,7.23], 0, 3, 80)).midicps;
	zout = CombN.ar(SinOsc.ar(f, 0, 0.04), 0.2, 0.2, 4); // echoing sine wave
	Out.ar(out, zout);
}).send(s);


SynthDef("rlpf",{ arg out=0,ffreq=600,rq=0.1;
	ReplaceOut.ar( out, RLPF.ar( In.ar(out), ffreq,rq) )
}).send(s);


SynthDef("wah", { arg out, rate = 1.5, cfreq = 1400, mfreq = 1200, rq=0.1;
	var zin, zout;

	zin = In.ar(out, 2);
	cfreq = Lag3.kr(cfreq, 0.1);
	mfreq = Lag3.kr(mfreq, 0.1);
	rq   = Ramp.kr(rq, 0.1);
	zout = RLPF.ar(zin, LFNoise1.kr(rate, mfreq, cfreq), rq, 10).distort
					* 0.15;

	// replace the incoming bus with the effected version
	ReplaceOut.ar( out , zout );

}).send(s);

SynthDef("modulate",{ arg out = 0, freq = 1, center = 440, plusMinus = 110;
	Out.kr(out, SinOsc.kr(freq, 0, plusMinus, center));
}).send(s);
)

// execute these one at a time

// y is playing on bus 0
y = Synth("moto-rev",["out",0]);

// z is reading from bus 0 and replacing that; It must be *after* y
z = Synth.after(y,"wah",["out",0]);

// stop the wah-ing
z.run(false);

// resume the wah-ing
z.run(true);

// add a rlpf after that, reading and writing to the same buss
x = Synth.after(z,"rlpf",["out",0]);

// create another rlpf after x
t = Synth.after(x,"rlpf",["out",0]);

x.set("ffreq", 400);

x.set(\ffreq, 800); // Symbols work for control names too

// Now let's modulate x's ffreq arg
// First get a control Bus
b = Bus.control(s, 1);

// now the modulator, *before* x
m = Synth.before(x, "modulate", [\out, b.index]);

// now map x's ffreq to b
x.map("ffreq", b);

m.set("freq", 4, "plusMinus", 20);

x.free;
z.free;
m.free;

// now place another synth after y, on the same bus
// they both write to the buss, adding their outputs
r = Synth.after(y,"bubbles",["out",0]);

y.free;

r.free;

// look at the Server window
// still see 4 Ugens and 1 synth?
// you can't hear me, but don't forget to free me
t.free;*/

/* continued from raiseyourhead.scd */
(
s.options.memSize = 81920;
s.waitForBoot {
  b = Buffer.read(s, Platform.userHomeDir+/+'GitHub/PcompFinal/clip_01.wav');
  // b = Buffer.read(s, Platform.userHomeDir+/+'GitHub/PcompFinal/clip_01_01.wav');
}
)

// (
// SynthDef( \test1, { | out = 0, mix = 0.5, maxdelaytime = 0.05 |
//   var inA, inB, chainA, chainB, chain, outSig;
//
//   inA = PlayBuf.ar( 2, b, BufRateScale.kr( b ), loop: 1 );
//   // inB = SinOsc.ar( MouseX.kr( 65, 88 ).midicps, mul: 0.2 );
//   inB = WhiteNoise.ar;
//
//   chainA = FFT( LocalBuf( 2048, 2 ), inA );
//   chainB = FFT( LocalBuf( 2048, 2 ), inB );
//
//   // chain = PV_MagShift( chainA, MouseX.kr( 1, 10, 1 ) );
//   chain = PV_MagSmear( chainA, MouseX.kr( 1, 100, 0 ) );
//   chain = 0.5 * IFFT( chain ).dup;
//
//   /* recipe #1 - Delay */
//   // outSig = DelayC.ar(
//   //   chain,
//   //   maxdelaytime = MouseY.kr( 0.2, 2, 1 ),
//   //   LFDNoise3.ar( #[ 1, 1 ], maxdelaytime, maxdelaytime/2 ),
//   // ).softclip;
//
//   maxdelaytime = 0.2;
//   outSig = CombN.ar( chain, maxdelaytime, 0.2, MouseY.kr( 0.01, 10, 1 ).poll( 1, \decaytime ) ); // echoing sine wave
//
//   outSig = ( 1 - mix ) * outSig + ( chain * mix );
//
//   Out.ar( out, outSig );
//   // Out.ar( out, 0.5 * IFFT( chain ).dup );
//   }
// ).play;
// )

(
SynthDef( \boxing, { | out = 0, punch_rate = 1, punch_force = 35, orientation = 0, mix = 0.5, maxdelaytime = 0.05,
  roomsize = 5, revtime = 0.6, damping = 0.62, inputbw = 0.48, spread = 15, drylevel = -6, earlylevel = -11, taillevel = -13 |
  var inA, inB, chainA, chainB, chain, outSig, outSigDelayed, env;

  inA = PlayBuf.ar( 2, b, BufRateScale.kr( b ), loop: 1 );
  // inB = WhiteNoise.ar;

  chainA = FFT( LocalBuf( 2**11, 2 ), inA );
  // chainB = FFT( LocalBuf( 2048, 2 ), inB );

  // chain = PV_MagShift( chainA, MouseX.kr( 1, 10, 1 ) );
  chain = PV_MagSmear( chainA, punch_force.linlin( inMin: 30, inMax: 60, outMin: 1, outMax: 88 ) );
  outSig = IFFT( chain ).dup;

  /* recipe #1 - Delay */
  // outSig = DelayC.ar(
  //   chain,
  //   maxdelaytime = 2,
  //   delaytime: punch_rate.linexp( 1, 5, 0.2, 2 ),
  // ).softclip;

  /* recipe #2 - CombN */
  maxdelaytime = 0.2;
  outSigDelayed = CombN.ar( outSig, maxdelaytime, maxdelaytime, decaytime: punch_rate.linexp( inMin: 1, inMax: 20, outMin: 0.1, outMax: 100 ), mul: 1, add: 0 ); // echoing sine wave

  outSig = ( 1 - mix ) * outSigDelayed + ( outSig * mix );

  env = EnvGen.ar( Env.perc( attackTime: 0.01, releaseTime: 0.65, level: 1, curve: -6 ), doneAction: 2 );

  outSig = outSig * env;

  // Out.ar( out, outSig * 3 );
  Out.ar( out, GVerb.ar(
        outSig,
        roomsize,
        revtime,
        damping,
        inputbw,
        spread,
        drylevel.dbamp,
        earlylevel.dbamp,
        taillevel.dbamp,
        roomsize, 0.3 ) + outSig )
}).add;
)

/* SETUP OSC COMMUNICATION */
(
var orientation, trigger_punch = 0, prev_punch = 0, freeze = 0, immediate_after = 0;

~timestamp_prev = 0;
~timestamp_now = 0;
~time_diff = 0;

~osc_msg_orientation = OSCFunc.newMatching( {

  | msg, time, addr, recvPort |

  var orientation_x, orientation_y, orientation_z;
  // orientation_x = msg[1].asFloat;
  orientation_y = msg[2].asFloat;
  orientation_z = msg[3].asFloat;
  if ( orientation_y < 0, { orientation = 0 }, { orientation = 1 } );
  // orientation.postln;
  },
  '/bno055/orientation'
);

~osc_msg_accel = OSCFunc.newMatching( {

  | msg, time, addr, recvPort |

  var punch_rate, accel_x, accel_y, accel_z, punch_force;
  msg.postln;
  ~timestamp_now = time;
  ~time_diff = ~timestamp_now - ~timestamp_prev;
  if ( ~time_diff > 1, { ~time_diff = 1 }, {} );
  punch_rate = ~time_diff.reciprocal;

  accel_x = msg[1].asFloat;
  accel_y = msg[2].asFloat;
  accel_z = msg[3].asFloat;
  punch_force = (accel_x.squared + accel_y.squared + accel_z.squared);
  punch_force = sqrt( punch_force ).postln;
  // if (
  //   (punch_force >= 40).postln,
  //   { Synth(\boxing, [punch_rate: punch_rate, punch_force: punch_force, orientation: orientation ]);
  //     ~timestamp_prev = ~timestamp_now;
  //   },
  //   {}
  // );
  // },

  if (
    // ( ( accel_x <= -0.5 ) && ( accel_y <= -0.5 ) ) || ( ( accel_y <= -0.5 ) && ( accel_z <= -0.5 ) ) || ( ( accel_x <= -0.5 ) && ( accel_z <= -0.5 ) ),
    ( ( ( accel_x <= -5 ) && ( accel_y <= -5 ) ) || ( ( accel_x <= -5 ) && ( accel_z <= -5 ) ) ),
    // ( prev_punch >= 20 ),
    {
      if ( immediate_after == 0,
        { trigger_punch = 1 },
        { immediate_after = 0 }
      )
    },
    {}
  );

  // punch_force = accel_x.max( accel_y.max( accel_z ) );

  if (
    trigger_punch == 1,
    {
      if (
        /*( punch_force >= 20 ) && */( punch_force <= prev_punch ), // if punch reaches peak at the prev. frame
        {
          freeze = 0;
          Synth(\boxing, [punch_rate: punch_rate, punch_force: prev_punch.postln, orientation: orientation, freeze: freeze ]);
          "triggered!".postcs;
          ~timestamp_prev = ~timestamp_now;                     // update effective punch time register
          trigger_punch = 0;                                    // reset trigger punch flag
          immediate_after = 1;
          freeze = 1;
          // prev_punch = punch_force                              // update prev. punch force
        },
        {}
        // { prev_punch = punch_force }                            // else update prev. punch force
      )
    },
    {}
  );

  prev_punch = punch_force;
  },

  '/bno055/linear_accel'
);
)

(
~osc_msg_orientation.free;
~osc_msg_accel.free;
)