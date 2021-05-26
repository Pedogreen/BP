//BT conection test //<>// //<>//
import processing.serial.*;
long  l = 0;
Serial BT, send;
int[] BT_array = {-1, -1};

void setup() {
  size(400, 400);
  BT = new Serial(this, "COM7", 11500);
  BT.bufferUntil('\n');
  //send = new Serial(this, "COM12", 115200);
  //send.bufferUntil('\n');
}

void draw() {
  background(125);
  if (millis() - l>1000) {
    //print("loop");
    l = millis();
  }
  if (BT.available()>0) {
    while (BT.available()>0) {
      print(BT.readString());
    }
  }
}
void keyPressed() {
  print("here\t");
  if (key == '1') { 
    print("pisu jedna\t");
    BT.write("<1>");
  }
  if (key == '2') { 
    BT.write("2");
    print("pisu dva\t");
  }
  if (key == '3') { 
    BT.write("3");
    print("pisu tri\t");
  }
  print("konec");
}

void translate_BT(String string) {
  char startMarker = '<';
  char endMarker = '>';
  char gapMarker = ',';
  int index = 0;

  String str = "";
  if (string.charAt(0) == startMarker) {
    for (int i = 1; i<string.length(); i++) {
      char one_char = string.charAt(i);
      if (one_char != endMarker) {
        if (one_char == gapMarker) {
          BT_array[index] = int(str);
          index++;
          str = "";
        } else {
          str = str+one_char;
        }
      } else {
        BT_array[index] = int(str);

        break;
      }
    }
  }
}
/*
void (){
 int index = 0;
 final boolean recvInProgress = false;
 final byte ndx = 0;
 char startMarker = '<';
 char endMarker = '>';
 char gapMarker = ',';
 char rc;
 String string;
 ///////////////
 //            no local variables
 boolean newData = false;
 /////////////
 
 
 while (BT.available() > 0 && newData == false) {
 rc = BT.read();
 
 if (recvInProgress == true) {
 if (rc != endMarker) {
 if (rc == gapMarker) {
 write_to_dataread(index, ndx, string);
 index++;
 string = "";
 ndx = 0;
 
 } else {
 receivedChars[ndx] = rc;
 //string = string + receivedChars[ndx];
 //Serial.println(string);
 
 ndx++;
 if (ndx >= numChars) {
 ndx = numChars - 1;
 }
 }
 }
 else {
 write_to_dataread(index, ndx, string);
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
 */
