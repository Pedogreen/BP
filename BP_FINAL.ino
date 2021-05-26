// including keyboard library
#include <BleKeyboard.h>
BleKeyboard bleKeyboard;  //     bleKeyboard.write(0xD7,0xD8,0xDA,0xD9);
// including MPU library
#include <MPU6050_tockn.h>
// including WIRE library
#include <Wire.h>
// including BTSerial library

//#define BLEKEYBOARD
// uncomment this if you want to have export as blekeyboard


#include "BluetoothSerial.h"
#if !defined(CONFIG_BT_ENABLED) || !defined(CONFIG_BLUEDROID_ENABLED)
#error Bluetooth is not enabled! Please run `make menuconfig` to and enable it
#endif
BluetoothSerial SerialBT;
// ================================================================
// ===                   MPU6050 variables                      ===
// ================================================================

int actual_X, actual_Y;
int zero_X, zero_Y;
int CalibCount = 2000;
int ThreshHold = 12;
int Move = 0;
String printDir = "";
boolean moved = false;
unsigned long last_pressed = 0;
unsigned long lastShowed = 0;

MPU6050 mpu6050(Wire);

// ================================================================
// ===                   BT variables                           ===
// ================================================================

int dataReaderead[5];
boolean newData = false;
const byte numChars = 32;
char receivedChars[numChars];
boolean BLE_export = false;
String pressed_button;
boolean wasConnected = false;

// ================================================================
// ===                   EMG variables                          ===
// ================================================================

int EMG_sensor_pin = 33;
float EMG_sensor_values;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XXX                         SETUP                            XXX
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
void setup() {
  SerialBT.begin("DV"); //Bluetooth device name
  Serial.begin(115200);
  Serial.println("Setting up");
  Wire.begin(4, 0);
  Wire.setClock(400000);
  #ifdef BLEKEYBOARD
  Serial.println("Bluetooth keyboard output is ON");
  bleKeyboard.begin();
  BLE_export = true;
  #endif
  mpu6050.begin();
  mpu6050.setGyroOffsets(-5.251 - 1.6, 1, 39);
  Serial.println("DO NOT MOVE!!!");
  Serial.println("Calibration has started");
  myCalibration(false);
  //input true, if you want to display variables during calibration
  Serial.println("Calibration has finished");
}
// ================================================================
// ===                    myCalibration                        ===
// ================================================================
void myCalibration(boolean bol) {
  for (int i = 0; i < CalibCount; i++) {
    mpu6050.update();
    zero_X += mpu6050.getAngleX();
    zero_Y += mpu6050.getAngleY();
    if(bol){
    Serial.print("angleX : ");
    Serial.print(mpu6050.getAngleX());
    Serial.print("\tangleY : ");
    Serial.println(mpu6050.getAngleY());
    }
  }
  zero_X = zero_X / CalibCount;
  zero_Y = zero_Y / CalibCount;
  Serial.print("zeroX : ");
  Serial.print(zero_X);
  Serial.print("\tzeroY : ");
  Serial.println(zero_Y);
  delay(1000);
}
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XXX                         LOOP                             XXX
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
void loop() {
  checkAngle();
  sendProperWay();
  checkIncome();
}

// ================================================================
// ===                    BT reciever                           ===
// ================================================================
void sendProperWay() {
  if (BLE_export) {
      if (millis() - last_pressed > 500) {
        switch (Move) {
          case 0:
            break;
          case 1:
            bleKeyboard.write(0xDA);
            break;
          case 2:
            bleKeyboard.write(0xD9);
            break;
          case 3:
            bleKeyboard.write(0xD8);
            break;
          case 4:
            bleKeyboard.write(0xD7);
            break;
        }
        last_pressed = millis();
      }
  } else {
    getEmgValues();
    arraySend();
  }
  Move = 0;
}
// ================================================================
// ===                    BT reciever                           ===
// ================================================================
void checkIncome() {
  if (Serial.available() > 0) {
    dataReader();
    if (newData) {
      switch (dataReaderead[0]) {
        case 0:
          SerialBT.end();
          //Serial.begin(115200);
          break;
        case 1:
          Serial.println("Switching BLE export");
          SerialBT.end();
           //bleKeyboard.begin();
          BLE_export = !BLE_export;
          break;
        case 2:
          ThreshHold = dataReaderead[1];
          break;
      }
      newData = false;
    }
  }
}
// ================================================================s
// ===                    Sending String                        ===
// ================================================================
void arraySend() {
  String sending_string = String(Move) + "," + String(EMG_sensor_values);
  //Serial.println(sending_string);
  //uncomment this if you want to display sending data
  SerialBT.print(sending_string);
}
// ================================================================
// ===                    BT function                           ===
// ================================================================
int writeTodataReader( int ndx, String string) {
  int myInt;
  receivedChars[ndx] = '\0'; // terminate the string
  for (int i = 0; i < ndx; i++) {
    string = string + receivedChars[i];
  }
  myInt = string.toInt();
  return (myInt);
}
void dataReader() {
  int index = 0;
  static boolean recvInProgress = false;
  static byte ndx = 0;
  char startMarker = '<';
  char endMarker = '>';
  char gapMarker = ',';
  char rc;
  String string;

  while (Serial.available() > 0 && newData == false) {
    rc = Serial.read();
    if (recvInProgress == true) {
      if (rc != endMarker) {
        if (rc == gapMarker) {
          dataReaderead[index] = writeTodataReader(ndx, string);
          index++;
          string = "";
          ndx = 0;
        } else {
          receivedChars[ndx] = rc;
          ndx++;
          if (ndx >= numChars) {
            ndx = numChars - 1;
          }
        }
      }
      else {
        dataReaderead[index] = writeTodataReader(ndx, string);
        recvInProgress = false;
        newData = true;
        ndx = 0;
      }
    }
    else if (rc == startMarker) {
      recvInProgress = true;
    }
  }
}
// ================================================================
// ===                    Getting EMG values                    ===
// ================================================================
void getEmgValues() {
  EMG_sensor_values = analogRead(EMG_sensor_pin) * (5000 / 1023);
}
// ================================================================
// ===                    checkAngle                            ===
// ================================================================
void checkAngle() {
  mpu6050.update();
  actual_X = mpu6050.getAngleX();
  actual_Y = mpu6050.getAngleY();
    if (actual_X < zero_X - ThreshHold) {
      printDir = "LEFT";
      Move = 3;
      moved = true;
    }
    if (actual_X > zero_X + ThreshHold) {
      printDir = "RIGHT";
      Move = 4;
      moved = true;
    }
    if (actual_Y < zero_Y - ThreshHold) {
      printDir = "BACKWARD";
      Move = 2;
      moved = true;
    }
    if (actual_Y > zero_Y + ThreshHold) {
      printDir = "FORWARD";
      Move = 1;
      moved = true;
  }
  if (moved && millis() - lastShowed > 1000) {
    Serial.println("W MOVED " + printDir);
    Serial.print("angleX : ");
    Serial.print(actual_X);
    Serial.print("\tangleY : ");
    Serial.println(actual_Y);
    moved = false;
    lastShowed = millis();
  }
}
