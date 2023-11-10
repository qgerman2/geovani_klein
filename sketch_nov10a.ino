#include <SoftwareSerial.h>

const byte rxPin = 2;
const byte txPin = 3;

// Set up a new SoftwareSerial object
SoftwareSerial mySerial (rxPin, txPin);

void setup() {
  // put your setup code here, to run once:
  Serial.begin(9800);
  mySerial.begin(115200);
  Serial.println("HOLAAAA");
}

void loop() {
  struct {
    float a = 1.0;
    float b = 2.0;
    float c = 3.0;
    float d = 4.0;
    float e = 5.0;
  } valores;
  uint8_t size = sizeof(valores);
  mySerial.print("init");
  mySerial.write(size);
  mySerial.write(reinterpret_cast<uint8_t*>(&valores), size);
  delay(10);
}
