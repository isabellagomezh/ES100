/*
  BLE_Peripheral.ino

  This program uses the ArduinoBLE library to set-up an Arduino Nano 33 BLE 
  as a peripheral device and specifies a service and a characteristic. Depending 
  of the value of the specified characteristic, an on-board LED gets on. 

  The circuit:
  - Arduino Nano 33 BLE. 

  This example code is in the public domain.
*/

#include <ArduinoBLE.h>
#include <Arduino.h>
#include <Adafruit_BNO08x.h>

// Loop frequency
#define FREQUENCY_HZ 300
#define INTERVAL_MS (1000 / (FREQUENCY_HZ + 1))

static unsigned long last_interval_ms = 0;

// BLE setup
const char* deviceServiceUuid = "19b10000-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic1Uuid = "19b10001-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic2Uuid = "19b10002-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic3Uuid = "19b10003-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic4Uuid = "19b10004-e8f2-537e-4f6c-d104768a1214";

BLEService gestureService(deviceServiceUuid); 
BLEFloatCharacteristic yawCharacteristic(deviceServiceCharacteristic1Uuid, BLERead | BLEWrite);
BLEFloatCharacteristic pitchCharacteristic(deviceServiceCharacteristic2Uuid, BLERead | BLEWrite);
BLEFloatCharacteristic rollCharacteristic(deviceServiceCharacteristic3Uuid, BLERead | BLEWrite);
BLEFloatCharacteristic timeCharacteristic(deviceServiceCharacteristic4Uuid, BLERead | BLEWrite);

float p_time;
float p_yaw;
float p_pitch;
float p_roll;

// BNO08x sensor setup
struct euler_t {
  float yaw;
  float pitch;
  float roll;
} ypr;

Adafruit_BNO08x  bno08x;
sh2_SensorValue_t sensorValue;

// #define FAST_MODE
#ifdef FAST_MODE
  // Top frequency is reported to be 1000Hz (but freq is somewhat variable)
  sh2_SensorId_t reportType = SH2_GYRO_INTEGRATED_RV;
  long reportIntervalUs = 2000;
#else
  // Top frequency is about 250Hz but this report is more accurate
  sh2_SensorId_t reportType = SH2_ARVR_STABILIZED_RV;
  long reportIntervalUs = 5000;
#endif
void setReports(sh2_SensorId_t reportType, long report_interval) {
  Serial.println("Setting desired reports");
  if (! bno08x.enableReport(reportType, report_interval)) {
    Serial.println("Could not enable stabilized remote vector");
  }
}


void setup() {
  Serial.begin(115200);
  while(!Serial);   // comment out when not connected to computer!!

  // BLE
  if (!BLE.begin()) {
    Serial.println("- Starting Bluetooth® Low Energy module failed!");
    while (1);
  }

  BLE.setLocalName("Xiao (Peripheral)");
  BLE.setAdvertisedService(gestureService);
  gestureService.addCharacteristic(timeCharacteristic);
  gestureService.addCharacteristic(yawCharacteristic);
  gestureService.addCharacteristic(pitchCharacteristic);
  gestureService.addCharacteristic(rollCharacteristic);
  BLE.addService(gestureService);
  BLE.advertise();

  Serial.println("Xiao (Peripheral Device)");
  Serial.println(" ");

  // BNO08x
  if (!bno08x.begin_I2C()) {
    Serial.println("Failed to find BNO08x chip");
    while (1) { delay(10); }
  }
  Serial.println("BNO08x Found!");
  setReports(reportType, reportIntervalUs);
}

void loop() {
  // Connect to central Xiao
  BLEDevice central = BLE.central();
  Serial.println("- Discovering central device...");
  delay(500);

  if (central) {
    Serial.println("* Connected to central device!");
    Serial.print("* Device MAC address: ");
    Serial.println(central.address());
    Serial.println(" ");

    while (central.connected()) {
      if (millis() > last_interval_ms + INTERVAL_MS) {
        last_interval_ms = millis();
        readEuler(); 
      }
    }
    Serial.println("* Disconnected to central device!");
  }
}

void quaternionToEuler(float qr, float qi, float qj, float qk, euler_t* ypr, bool degrees = false) {

    float sqr = sq(qr);
    float sqi = sq(qi);
    float sqj = sq(qj);
    float sqk = sq(qk);

    ypr->yaw = atan2(2.0 * (qi * qj + qk * qr), (sqi - sqj - sqk + sqr));
    ypr->pitch = asin(-2.0 * (qi * qk - qj * qr) / (sqi + sqj + sqk + sqr));
    ypr->roll = atan2(2.0 * (qj * qk + qi * qr), (-sqi - sqj + sqk + sqr));

    if (degrees) {
      ypr->yaw *= RAD_TO_DEG;
      ypr->pitch *= RAD_TO_DEG;
      ypr->roll *= RAD_TO_DEG;
    }
}

void quaternionToEulerRV(sh2_RotationVectorWAcc_t* rotational_vector, euler_t* ypr, bool degrees = false) {
    quaternionToEuler(rotational_vector->real, rotational_vector->i, rotational_vector->j, rotational_vector->k, ypr, degrees);
}

void quaternionToEulerGI(sh2_GyroIntegratedRV_t* rotational_vector, euler_t* ypr, bool degrees = false) {
    quaternionToEuler(rotational_vector->real, rotational_vector->i, rotational_vector->j, rotational_vector->k, ypr, degrees);
}

void readEuler() {
  if (bno08x.wasReset()) {
    Serial.println("Sensor was reset");
    setReports(reportType, reportIntervalUs);
  }
  
  if (bno08x.getSensorEvent(&sensorValue)) {
    // in this demo only one report type will be received depending on FAST_MODE define (above)
    switch (sensorValue.sensorId) {
      case SH2_ARVR_STABILIZED_RV:
        quaternionToEulerRV(&sensorValue.un.arvrStabilizedRV, &ypr, true);
      case SH2_GYRO_INTEGRATED_RV:
        // faster (more noise?)
        quaternionToEulerGI(&sensorValue.un.gyroIntegratedRV, &ypr, true);
        break;
    }

    p_time = (float) millis() / 1000;
    p_yaw = ypr.yaw;
    p_pitch = ypr.pitch;
    p_roll = ypr.roll;

    // for debugging
    Serial.print(p_time); Serial.print(", ");
    Serial.print(p_yaw); Serial.print(", ");
    Serial.print(p_pitch); Serial.print(", ");
    Serial.println(p_roll);

    timeCharacteristic.writeValue(p_time);
    yawCharacteristic.writeValue(p_yaw);
    pitchCharacteristic.writeValue(p_pitch);
    rollCharacteristic.writeValue(p_roll);
  }
}