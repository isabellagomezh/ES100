// XIAO BLE Sense LSM6DS3 Accelerometer + LSM9DS1 Raw Data 

#include "LSM6DS3.h"
#include "Wire.h"
#include <Adafruit_LSM9DS1.h>

//Create instance of class LSM6DS3
LSM6DS3 XIAOIMU(I2C_MODE, 0x6A);  //I2C device address 0x6A

// Create instance of LSM9DS1
Adafruit_LSM9DS1 lsm = Adafruit_LSM9DS1(0x6B);  //I2C device address 0x6B

#define CONVERT_G_TO_MS2 9.80665f
#define FREQUENCY_HZ 200
#define INTERVAL_MS (1000 / (FREQUENCY_HZ + 1))

static unsigned long last_interval_ms = 0;

float data1[6];
float data2[6];

void setup() {
  Serial.begin(115200);
  while (!Serial);

  // Initialize xiao sensor
  if (XIAOIMU.begin() != 0) {
    Serial.println("Device error");
  } else {
    Serial.println("Device OK!");
    // XIAOIMU.setAccelDataRate(LSM6DS_RATE_3_33K_HZ);
  }


  // Initialize LSM9DS1 sensor
  if (!lsm.begin()) {
    Serial.println("LSM9DS1 not detected!");
    while (1);
  } 
}



void loop() {
  if (millis() > last_interval_ms + INTERVAL_MS) {
    last_interval_ms = millis();
    
    // Read and print data from each IMU
    printXIAOData(data1);
    printLSM9DS1Data(data2);

    Serial.print(data1[0] * CONVERT_G_TO_MS2); Serial.print(", ");
    Serial.print(data1[1] * CONVERT_G_TO_MS2); Serial.print(", ");
    Serial.print(data1[2] * CONVERT_G_TO_MS2); Serial.print(", ");
    Serial.print(data1[3]); Serial.print(", ");
    Serial.print(data1[4]); Serial.print(", ");
    Serial.print(data1[5]); Serial.print(", ");
    Serial.print(data2[0]); Serial.print(", ");
    Serial.print(data2[1]); Serial.print(", ");
    Serial.print(data2[2]); Serial.print(", ");
    Serial.print(data2[3]); Serial.print(", ");
    Serial.print(data2[4]); Serial.print(", ");
    Serial.println(data2[5]);
  }
}

void printLSM9DS1Data(float* result) {
  lsm.read();
  sensors_event_t a, m, g, temp;
  lsm.getEvent(&a, &m, &g, &temp);

  result[0] = a.acceleration.x;
  result[1] = a.acceleration.y;
  result[2] = a.acceleration.z;
  result[3] = g.gyro.x;
  result[4] = g.gyro.y;
  result[5] = g.gyro.z;
}

void printXIAOData(float* result) {
  result[0] = XIAOIMU.readFloatAccelX();
  result[1] = XIAOIMU.readFloatAccelY();
  result[2] = XIAOIMU.readFloatAccelZ();
  result[3] = XIAOIMU.readFloatGyroX();
  result[4] = XIAOIMU.readFloatGyroY();
  result[5] = XIAOIMU.readFloatGyroZ();
}
