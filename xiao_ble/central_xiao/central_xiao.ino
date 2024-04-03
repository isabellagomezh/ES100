/*
  central_xiao.ino

  Connects to additional Seeed Studio XIAO nRF52840 Sense that is broadcasting Euler angle data from a BNO08x sensor.
  Reads Euler angles from local BNO08x sensor.
  Passes the combined data into a TFLite movement classifier model.
  ...
*/

#include <ArduinoBLE.h>
#include <Arduino.h>
#include <Adafruit_BNO08x.h>

// Loop frequency
#define FREQUENCY_HZ 250
#define INTERVAL_MS (1000 / (FREQUENCY_HZ + 1))

static unsigned long last_interval_ms = 0;

// BLE setup
const char* deviceServiceUuid = "19b10000-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic1Uuid = "19b10001-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic2Uuid = "19b10002-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic3Uuid = "19b10003-e8f2-537e-4f6c-d104768a1214";
const char* deviceServiceCharacteristic4Uuid = "19b10004-e8f2-537e-4f6c-d104768a1214";

float p_time;
float p_yaw;
float p_pitch;
float p_roll;

// BNO08x sensor setup
float curr_euler[3];

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
    Serial.println("* Starting Bluetooth® Low Energy module failed!");
    while (1);
  }
  
  BLE.setLocalName("Xiao (Central)"); 
  BLE.advertise();

  Serial.println("Xiao (Central Device)");
  Serial.println(" ");

  BLE.scanForUuid(deviceServiceUuid);   // start looking for peripheral

  // BNO08x
  if (!bno08x.begin_I2C()) {
    Serial.println("Failed to find BNO08x chip");
    while (1) { delay(10); }
  }
  Serial.println("BNO08x Found!");
  setReports(reportType, reportIntervalUs);
}


void loop() {
  // Connect to peripheral Xiao
  connectToPeripheral();
}

void connectToPeripheral(){
  BLEDevice peripheral;
  
  Serial.println("- Discovering peripheral device...");

  do
  {
    BLE.scanForUuid(deviceServiceUuid);
    peripheral = BLE.available();
  } while (!peripheral);
  
  if (peripheral) {
    Serial.println("* Peripheral device found!");
    Serial.print("* Device MAC address: ");
    Serial.println(peripheral.address());
    Serial.print("* Device name: ");
    Serial.println(peripheral.localName());
    Serial.print("* Advertised service UUID: ");
    Serial.println(peripheral.advertisedServiceUuid());
    Serial.println(" ");
    BLE.stopScan();
    controlPeripheral(peripheral);
  }
}

void controlPeripheral(BLEDevice peripheral) {
  Serial.println("- Connecting to peripheral device...");

  if (peripheral.connect()) {
    Serial.println("* Connected to peripheral device!");
    Serial.println(" ");
  } else {
    Serial.println("* Connection to peripheral device failed!");
    Serial.println(" ");
    return;
  }

  Serial.println("- Discovering peripheral device attributes...");
  if (peripheral.discoverAttributes()) {
    Serial.println("* Peripheral device attributes discovered!");
    Serial.println(" ");
  } else {
    Serial.println("* Peripheral device attributes discovery failed!");
    Serial.println(" ");
    peripheral.disconnect();
    return;
  }

  BLECharacteristic timeCharacteristic = peripheral.characteristic(deviceServiceCharacteristic4Uuid);
  BLECharacteristic yawCharacteristic = peripheral.characteristic(deviceServiceCharacteristic1Uuid);
  BLECharacteristic pitchCharacteristic = peripheral.characteristic(deviceServiceCharacteristic2Uuid);
  BLECharacteristic rollCharacteristic = peripheral.characteristic(deviceServiceCharacteristic3Uuid);
    
  // Check if other XIAO has characteristics
  if (!timeCharacteristic) {
    Serial.println("* Peripheral device does not have time characteristic!");
    peripheral.disconnect();
    return;
  } else if (!yawCharacteristic) {
    Serial.println("* Peripheral does not have a yaw characteristic!");
    peripheral.disconnect();
    return;
  } else if (!pitchCharacteristic) {
    Serial.println("* Peripheral does not have a pitch characteristic!");
    peripheral.disconnect();
    return;
  } else if (!rollCharacteristic) {
    Serial.println("* Peripheral does not have a roll characteristic!");
    peripheral.disconnect();
    return;
  }
  
  // While connected to peripheral XIAO, read local sensor and retrieve data from other XIAO
  while (peripheral.connected()) {
    if (millis() > last_interval_ms + INTERVAL_MS) {
      last_interval_ms = millis();

      // Read local sensor
      readEuler(curr_euler);

      // Read peripheral sensor
      timeCharacteristic.readValue(&p_time, 4);
      yawCharacteristic.readValue(&p_yaw, 4);
      pitchCharacteristic.readValue(&p_pitch, 4);
      rollCharacteristic.readValue(&p_roll, 4);

      // Print to serial monitor
      Serial.print(curr_euler[0]); Serial.print(", ");
      Serial.print(curr_euler[1]); Serial.print(", ");
      Serial.print(curr_euler[2]); Serial.print(", ");
      Serial.print(p_time); Serial.print(", ");
      Serial.print(p_yaw); Serial.print(", ");
      Serial.print(p_pitch); Serial.print(", ");
      Serial.println(p_roll);
    }
  
  }
  Serial.println("- Peripheral device disconnected!");
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

void readEuler(float* result) {
  if (bno08x.wasReset()) {
    Serial.print("sensor was reset ");
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

    // Add current sensor position
    result[0] = ypr.yaw;
    result[1] = ypr.pitch;
    result[2] = ypr.roll;
  }
}