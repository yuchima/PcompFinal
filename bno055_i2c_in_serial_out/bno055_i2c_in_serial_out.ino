#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_BNO055.h>
#include <utility/imumaths.h>

/* Set the delay between fresh samples */
#define BNO055_SAMPLERATE_DELAY_MS (20)

Adafruit_BNO055 bno = Adafruit_BNO055(55); // 55 is arbitrary sensor ID
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
}

void loop() {
//  now = millis();

  /* Get a new sensor event */
  sensors_event_t event;
  bno.getEvent(&event);

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
  imu::Vector<3> accel = bno.getVector(Adafruit_BNO055::VECTOR_ACCELEROMETER);

  Serial.print("\tAccel_X: ");
  Serial.print(accel.x(), 4);
  Serial.print("\tAccel_Y: ");
  Serial.print(accel.y(), 4);
  Serial.print("\tAccel_Z: ");
  Serial.print(accel.z(), 4);

  Serial.println("");

//  if (now - prev >= 1000) {
//    Serial.print("time elapsed: ");
//    Serial.print(now - prev);
//    Serial.println("");
//    prev = now;
//  }

  delay(BNO055_SAMPLERATE_DELAY_MS);
}
