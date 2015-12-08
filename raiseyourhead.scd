/* continued from raiseyourhand.scd */
(
SynthDef( \boxing, {

  | out = 0, punch_rate = 1, punch_force = 35, orientation = 0, freeze = 0 |

  var input, decay, env, chain;

  input =
  // GlitchRHPF.ar(
    AllpassC.ar(
      in: PMOsc.ar(
        // carfreq: MouseX.kr( 65, 88, warp: \exponential ).poll( 1, \car_freq ),
        carfreq: punch_force.linexp( inMin: 35, inMax: 70, outMin: 65, outMax: 88 ),
        modfreq: punch_rate.linlin( inMin: 1, inMax: 4, outMin: 10, outMax: 100 ),
        // pmindex: MouseY.kr( 2, 12 ).poll( 1, \pmindex )
        pmindex: if ( orientation == 0, { 2 }, { 4 } )
      ).tanh,
      decaytime: 0.2
  // ),
    // freq: if ( orientation == 0, { 1/0.5 }, { 1/0.05 } ),
    // rq:0.75
  );

  // decay = Decay2.ar(
  //   in: Impulse.ar( TIRand.ar( 1, 4, Impulse.ar( 1 ) ) ),
  //   // in: Impulse.ar( punch_rate
  //   attackTime: 0.01,
  //   decayTime: 0.65
  // );

  env = EnvGen.ar( Env.perc( attackTime: 0.01, releaseTime: 0.65, level: 1, curve: -6 ), doneAction: 2 );

  input = input * env;
  // input = input * decay;

  // input = input * decay + BPF.ar( input * 5, MouseY.kr( 40, 100 ).poll( 1, \center_freq ), 0.1 );

  chain = FFT( LocalBuf( 2048 ), input );

  chain = PV_Freeze( chain, freeze );

  out = 0.5 * IFFT( chain ).dup;

  Out.ar( 0, out );
}).add;
)

~timestamp_prev = 0;
~timestamp_now = 0;
~time_diff = 0;

/* SETUP OSC COMMUNICATION */
(
var orientation, trigger_punch = 0, prev_punch = 0, freeze = 0;

~osc_msg_orientation = OSCFunc.newMatching( {

  | msg, time, addr, recvPort |

  var orientation_x, orientation_y, orientation_z;
  orientation_x = msg[1].asFloat;
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

  accel_x = msg[1].asFloat.postln;
  accel_y = msg[2].asFloat.postln;
  accel_z = msg[3].asFloat.postln;
  punch_force = (accel_x.squared + accel_y.squared + accel_z.squared).postln;
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
    // ( ( ( accel_x <= -2 ) && ( accel_y <= -2 ) ) || ( ( accel_x <= -2 ) && ( accel_z <= -2 ) ) ),
    ( punch_force >= 35 ),
    { trigger_punch = 1 },
    {}
  );

  punch_force = accel_x.max( accel_y.max( accel_z ) );

  if (
    trigger_punch == 1,
    {
      if (
        /*( punch_force >= 20 ) && */( punch_force <= prev_punch ), // if punch reaches peak at the prev. frame
        {
          freeze = 0;
          Synth(\boxing, [punch_rate: punch_rate, punch_force: prev_punch.postln, orientation: orientation, freeze: freeze ]);
          ~timestamp_prev = ~timestamp_now;                     // update effective punch time register
          trigger_punch = 0;                                    // reset trigger punch flag
          freeze = 1;
          prev_punch = punch_force                              // update prev. punch force
        },
        { prev_punch = punch_force }                            // else update prev. punch force
      )
    },
    {}
  );
  },

  '/bno055/linear_accel'
);
)

(
~osc_msg_orientation.free;
~osc_msg_accel.free;
)