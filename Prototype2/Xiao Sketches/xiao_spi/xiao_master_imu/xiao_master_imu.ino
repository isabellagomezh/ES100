#include <SPI.h>

// SPI Pin
const int SS_PIN = 0;  // digital pin 7 (D7)

//  Display and Loop Frequency
#define FREQUENCY_HZ 20
#define INTERVAL_MS (1000 / (FREQUENCY_HZ + 1))
static unsigned long last_interval_ms = 0;

void setup() {
  Serial.begin(115200);

  // SPI setup
  SPI.begin();
  SPI.beginTransaction(SPISettings(1000000, MSBFIRST, SPI_MODE0));
  pinMode(SS_PIN, OUTPUT);
}

void loop() {
  if (millis() > last_interval_ms + INTERVAL_MS) {
    last_interval_ms = millis();
    
    // Send data to other Xiao
    digitalWrite(SS_PIN, LOW); // select

    float dataToSend[3] = {3.14f, 42.00f, -123.45f};
    // byte buffer[sizeof(dataToSend)];

    // memcpy(buffer, &dataToSend, sizeof(dataToSend)); // serialize

    SPI.transfer(dataToSend, sizeof(dataToSend)); // send

    digitalWrite(SS_PIN, HIGH); // deselect 
  }

}

