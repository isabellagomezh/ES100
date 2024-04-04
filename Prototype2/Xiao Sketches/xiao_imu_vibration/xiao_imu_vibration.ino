#include <LSM6DS3.h>
#include <Wire.h>

//Create a instance of class LSM6DS3
LSM6DS3 XIAOIMU(I2C_MODE, 0x6A);

// IMU definitions
#define CONVERT_G_TO_MS2 9.80665f
#define FREQUENCY_HZ 200
#define INTERVAL_MS (1000 / (FREQUENCY_HZ))

// Motor pins and duty cycle
const int motorPin = A1;
const int motorPin2 = A3;
// const int motorPin3 = A3;
const int dutyCycle = round(1.0*255); // refer to motor characterization curve for % to vib. frequency conversion

// Empty array to save IMU readings
float data1[6];

void setup() {
  Serial.begin(115200);
  // while (!Serial);

  // Initialize Xiao IMU sensor
  if (XIAOIMU.begin() != 0) {
    Serial.println("Device error");
  } else {
    Serial.println("Device OK!");
  }
}

void loop() {
  // Start motor vibration
  analogWrite(motorPin,dutyCycle);
  analogWrite(motorPin2,dutyCycle);
  // analogWrite(motorPin3,dutyCycle);

  // Collect data from Xiao IMU sensor
  printXIAOData(data1);

  Serial.print(data1[0] * CONVERT_G_TO_MS2); Serial.print(", ");
  Serial.print(data1[1] * CONVERT_G_TO_MS2); Serial.print(", ");
  Serial.print(data1[2] * CONVERT_G_TO_MS2); Serial.print(", ");
  Serial.print(data1[3]); Serial.print(", ");
  Serial.print(data1[4]); Serial.print(", ");
  Serial.println(data1[5]);

  delay(INTERVAL_MS);
}

void printXIAOData(float* result) {
  result[0] = XIAOIMU.readFloatAccelX();
  result[1] = XIAOIMU.readFloatAccelY();
  result[2] = XIAOIMU.readFloatAccelZ();
  result[3] = XIAOIMU.readFloatGyroX();
  result[4] = XIAOIMU.readFloatGyroY();
  result[5] = XIAOIMU.readFloatGyroZ();
}