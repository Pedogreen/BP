import processing.serial.*;
Serial BT;
boolean BT_CONNECTED = false; 
boolean COMStxt = true;
boolean keypressed = false;
boolean clicked = false;
String [] Coms_inputed;
int COM_number;
boolean switched = true;
Num_input coms_input;
void settings() {
  fullScreen();
}

void setup() { 
  surface.setSize(500, 500);
  surface.setLocation(width/2, height/2);
  rectMode(CENTER);
  textAlign(CENTER, CENTER);
  coms_input = new Num_input(width/2+50, height/2, 100, 50);
  try {
    Coms_inputed =   loadStrings("COMS.txt");
    for (int i = 0; i<Coms_inputed.length; i++) {
      connect_to_DV(Coms_inputed[i]);
    }
  }
  catch(NullPointerException e) {
    COMStxt = false;
  }
  if(BT_CONNECTED){
    surface.setVisible(false);
  }
}

void draw() {
  background(125);
  fill(255);
  textSize(20);
  text("Input COM port", width/2 - 100, height/2);
  if (!COMStxt) {
    fill(255, 0, 0);
    textSize(20);
    text("Missing COMS.txt", width-200, height-20);
  }
  coms_input.Draw( COM_number);
  if (BT_CONNECTED) {     
    textSize(20);
    text("Switching to BLE...", width/2, 50);
    BT.write("<1>");
    delay(500);
    BT.write("<0>");
    delay(500);
    exit();
  }

  keypressed = false;
  clicked =false;
}

void connect_to_DV(String string) {
  boolean BT_connect = false;
  for (int i=0; i<Serial.list().length; i++) {
    if (Serial.list()[i].contains(string)) {
      BT_connect = true;
      break;
    }
  }
  if (BT_connect ) {
    try {
      BT = new Serial(this, string, 9600);
      BT.bufferUntil('\n');
      BT_CONNECTED = true;
      println("Connected");
    }
    catch(RuntimeException e) {
      print("BT is not ready to pair");
    }
  }
}
void keyPressed() {
  keypressed = true;
}
void mousePressed() {
  clicked = true;
}
