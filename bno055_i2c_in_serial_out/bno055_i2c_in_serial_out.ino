#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

/* Set the delay between fresh samples */
//#define BNO055_SAMPLERATE_DELAY_MS (20)
#define BNO055_SAMPLERATE_DELAY_MS (50)

Adafruit_BNO055 bno = Adafruit_BNO055(55); // 55 is arbitrary sensor ID
sensors_event_t event;
//imu::Vector<3> accel;
imu::Vector<3> orientation;
imu::Vector<3> linaccel;
imu::Vector<3> gyro;


unsigned long prev = 0;
unsigned long now;

void setup() {
  Serial.begin(115200);
  Serial.println("Orientation Sensor Test"); Serial.println("");

  /* initialize the sensor */
  if (!bno.begin()) {
    /* There was a problem detecting the BNO055 ... check your connections */
    Serial.print("Ooops, no BNO055 detectd ... Check your wiring or I2C ADDR!");
    while (1);
  }

  delay(1000);

  bno.setExtCrystalUse(true);

  Serial.println("Calibration status values: 0=uncalibrated, 3=fully calibrated");
}

void loop() {
  //  now = millis();

  /* Get a new sensor event */
  //  bno.getEvent(&event);

  /* Display the floating point data */
  //  Serial.print("X: ");
  //  Serial.print(event.orientation.x, 4);
  //  Serial.print("\tY: ");
  //  Serial.print(event.orientation.y, 4);
  //  Serial.print("\tZ: ");
  //  Serial.print(event.orientation.z, 4);

  /* Display some raw data */
  // Possible vector values can be:
  // - VECTOR_ACCELEROMETER - m/s^2
  // - VECTOR_MAGNETOMETER  - uT
  // - VECTOR_GYROSCOPE     - rad/s
  // - VECTOR_EULER         - degrees
  // - VECTOR_LINEARACCEL   - m/s^2
  // - VECTOR_GRAVITY       - m/s^2
  //  accel = bno.getVector(Adafruit_BNO055::VECTOR_ACCELEROMETER);
  linaccel = bno.getVector(Adafruit_BNO055::VECTOR_LINEARACCEL);
  gyro = bno.getVector(Adafruit_BNO055::VECTOR_GYROSCOPE);
  orientation = bno.getVector(Adafruit_BNO055::VECTOR_EULER);

  /* [ori_x, ori_y, ori_z, linacc_x, linacc_y, linacc_z, gyro_x, gyro_y, gyro_z] */
  Serial.print(orientation.x(), 2); Serial.print("\t");
  Serial.print(orientation.y(), 2); Serial.print("\t");
  Serial.print(orientation.z(), 2); Serial.print("\t");
  //  Serial.print(accel.x(), 2); Serial.print("\t");
  //  Serial.print(accel.y(), 2); Serial.print("\t");
  //  Serial.print(accel.z(), 2); Serial.print("\t");
  Serial.print(linaccel.x(), 2); Serial.print("\t");
  Serial.print(linaccel.y(), 2); Serial.print("\t");
  Serial.print(linaccel.z(), 2); Serial.print("\t");
  Serial.print(gyro.x(), 2); Serial.print("\t");
  Serial.print(gyro.y(), 2); Serial.print("\t");
  Serial.print(gyro.z(), 2);

  //  /* Display calibration status for each sensor. */
  //  uint8_t system, gyro, accel, mag = 0;
  //  bno.getCalibration(&system, &gyro, &accel, &mag);
  //  Serial.print("CALIBRATION: Sys=");
  //  Serial.print(system, DEC);
  //  Serial.print(" Gyro=");
  //  Serial.print(gyro, DEC);
  //  Serial.print(" Accel=");
  //  Serial.print(accel, DEC);
  //  Serial.print(" Mag=");
  //  Serial.println(mag, DEC);

  Serial.println("");

  //  if (now - prev >= 1000) {
  //    Serial.print("time elapsed: ");
  //    Serial.print(now - prev);
  //    Serial.println("");
  //    prev = now;
  //  }

  delay(BNO055_SAMPLERATE_DELAY_MS);
}
