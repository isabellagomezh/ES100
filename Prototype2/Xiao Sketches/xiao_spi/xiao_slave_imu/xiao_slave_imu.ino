/******************************************************************
  @file       xiao_slave_imu.ino
  @brief      Print roll, pitch, yaw and heading angles using the
              LSM9DS1 IMU on the Seeed XIAO BLE Sense. Receives 
              Euler angle data from another XIAO/IMU through SPI.

  Adapted from nano33BLErev1.ino from Reefwing AHRS Arduino Library:
  @author     David Such
  @copyright  Please see the accompanying LICENSE file.

  Code:        David Such
  Version:     2.2.0
  Date:        10/02/23

  1.0.0 Original Release.                         22/02/22
  1.1.0 Added NONE fusion option.                 25/05/22
  2.0.0 Changed Repo & Branding                   15/12/22
  2.0.1 Invert Gyro Values PR                     24/12/22
  2.1.0 Updated Fusion Library                    30/12/22
  2.2.0 Add support for Nano 33 BLE Sense Rev. 2  10/02/23

  This sketch is configured to work with the MADGWICK, MAHONY,
  CLASSIC, COMPLEMENTARY, KALMAN & NONE Sensor Fusion options. Set the 
  algorithm that you wish to use with:

  ahrs.setFusionAlgorithm(SensorFusion::MADGWICK);

  Adapted by: Isabella Gomez
  Date: 2/22/2024
******************************************************************/

#include <ReefwingAHRS.h>
#include <ReefwingLSM9DS1.h>
#include <SPI.h>

// SPI Pin
const int SS_PIN = 0;  // digital pin 0 (D0)

// Fusion Setup
ReefwingLSM9DS1 imu;
ReefwingAHRS ahrs;

//  Display and Loop Frequency
// #define FREQUENCY_HZ 20
// #define INTERVAL_MS (1000 / (FREQUENCY_HZ + 1))
// static unsigned long last_interval_ms = 0;

void setup() {
  //  Initialise the LSM9DS1 IMU & AHRS
  //  Use default fusion algo and parameters
  imu.begin();
  ahrs.begin();
  
  //  If your IMU isn't autodetected and has a mag you need
  //  to add: ahrs.setDOF(DOF::DOF_9);
  ahrs.setFusionAlgorithm(SensorFusion::MADGWICK);
  ahrs.setDeclination(-14.13);                      //  Boston, MA, USA

  //  Start Serial and wait for connection
  Serial.begin(115200);
  while (!Serial);

  Serial.print("Detected Board - ");
  Serial.println(ahrs.getBoardTypeString());

  if (imu.connected()) {
    Serial.println("LSM9DS1 IMU Connected."); 
    Serial.println("Calibrating IMU...\n"); 
    imu.start();
    imu.calibrateGyro();
    imu.calibrateAccel();
    imu.calibrateMag();

    delay(20);
    //  Flush the first reading - this is important!
    //  Particularly after changing the configuration.
    imu.readGyro();
    imu.readAccel();
    imu.readMag();
  } 
  else {
    Serial.println("LSM9DS1 IMU Not Detected.");
    while(1);
  }

  // SPI setup
  Serial.print("SPI Pin: "); Serial.println(SS_PIN);
  SPI.begin();
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
  pinMode(SS_PIN, INPUT);
}

void loop() {

  // If master Xiao has sensor readings, read this Xiao and combine data
  if (digitalRead(SS_PIN) == LOW) {
    Serial.println("here");
    imu.updateSensorData();
    ahrs.setData(imu.data);
    ahrs.update();

    // byte buffer[12];
    float r_data[3];

    SPI.transfer(r_data, sizeof(r_data)); // receive

    // memcpy(&r_data, buffer, sizeof(r_data)); // deserialize

    //  Display sensor data
    Serial.print(ahrs.angles.roll, 2); Serial.print(", ");
    Serial.print(ahrs.angles.pitch, 2); Serial.print(", ");
    Serial.print(ahrs.angles.yaw, 2); Serial.print(", ");
    Serial.print(r_data[0], 2); Serial.print(", ");
    Serial.print(r_data[1], 2); Serial.print(", ");
    Serial.println(r_data[2], 2);
  }
  delay(10);
}