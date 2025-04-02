#include <ESP8266WiFi.h>
#include <WebSocketsClient.h>
#include <ArduinoJson.h>
#include <SoftwareSerial.h>
#include <TinyGPS++.h>
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// WiFi Credentials
const char* ssid = "your wifi ssid"; // Replace with your WiFi SSID
const char* password = "your wifi password"; // Replace with your WiFi password

// WebSocket Server Info
const char* websocketHost = "34.66.190.241";
const int websocketPort = 8080;
const char* websocketPath = "/ws?driverId=Lahiru121";

// WebSocket Client
WebSocketsClient webSocket;
bool isConnected = false;

// GPS Module Pins (Use GPIO 0 & 2 for SoftwareSerial)
#define RXPin 2  // GPS TX ---- ESP8266 GPIO2 D4
#define TXPin 0  // GPS RX ---- ESP8266 GPIO0 D3
#define BUZZER_PIN 16
#define GPSBaud 9600

// OLED display configuration
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// Create SoftwareSerial for GPS
SoftwareSerial gpsSerial(RXPin, TXPin);
TinyGPSPlus gps;

void webSocketEvent(WStype_t type, uint8_t * payload, size_t length) {
  switch (type) {
    case WStype_CONNECTED:
      Serial.println("Connected to WebSocket server");
      isConnected = true;
      break;

    case WStype_TEXT: {
      String message = String((char*)payload);
      if (message.indexOf("warning") != -1) {
        ringBuzzerAndShowWarning();
      }
      break;
    }

    case WStype_DISCONNECTED:
      Serial.println("Disconnected from WebSocket!");
      isConnected = false;
      break;
  }
}

void sendGPSData() {
  if (isConnected) {
    StaticJsonDocument<200> doc;

    float latitude = gps.location.lat();
    float longitude = gps.location.lng();
    float speed = gps.speed.kmph();

    Serial.print("Latitude: ");
    Serial.println(latitude, 6);
    Serial.print("Longitude: ");
    Serial.println(longitude, 6);
    Serial.print("Speed: ");
    Serial.println(speed);

    unsigned long timestamp = millis();

    doc["latitude"] = latitude;
    doc["longitude"] = longitude;
    doc["speed"] = speed;
    doc["timestamp"] = timestamp;

    String jsonStr;
    serializeJson(doc, jsonStr);

    webSocket.sendTXT(jsonStr);
  } else {
    Serial.println("Waiting for valid GPS data...");
  }
}

void ringBuzzerAndShowWarning() {
  Serial.println("ringBuzzerAndShowWarning function is called");

  for (int i = 0; i < 3; i++) {
    // Turn on buzzer and show message
    digitalWrite(BUZZER_PIN, HIGH);

    display.clearDisplay();
    display.setTextSize(2);
    display.setTextColor(WHITE);
    display.setCursor(0, 20);
    display.println("Slow Down!");
    display.display();

    delay(500);

    // Turn off buzzer and clear display
    digitalWrite(BUZZER_PIN, LOW);

    display.clearDisplay();
    display.display();

    delay(500);
  }
}


void setup() {
  pinMode(BUZZER_PIN, OUTPUT);
  Serial.begin(9600);
  gpsSerial.begin(GPSBaud);

  // Start I2C with SDA=D2 (GPIO4), SCL=D1 (GPIO5)
  Wire.begin(D2, D1);

  if (!display.begin(SSD1306_SWITCHCAPVCC, 0x3C)) {
    Serial.println(F("SSD1306 allocation failed"));
    while (true);
  }

  display.clearDisplay();
  display.setTextSize(1.2);
  display.setTextColor(WHITE);
  display.setCursor(0, 0);
  display.println("Connecting...");
  display.display();

  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConnected to WiFi");

  display.clearDisplay();
  display.setCursor(0, 0);
  display.println("WiFi Connected!");
  display.display();

  // Setup WebSocket Client
  webSocket.begin(websocketHost, websocketPort, websocketPath);
  webSocket.onEvent(webSocketEvent);
}

void loop() {
  webSocket.loop();

  while (gpsSerial.available()) {
    char c = gpsSerial.read();
    Serial.write(c);

    if (gps.encode(c)) {
      Serial.print("Latitude: ");
      Serial.println(gps.location.lat(), 6);
      Serial.print("Longitude: ");
      Serial.println(gps.location.lng(), 6);
    }
  }

  // Send GPS Data every second
  static unsigned long lastSentTime = 0;
  if (millis() - lastSentTime >= 1000) {
    sendGPSData();
    lastSentTime = millis();
  }
}
