import ddf.minim.*; //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.signals.*;
import ddf.minim.spi.*;
import ddf.minim.ugens.*;

Minim minim;
AudioPlayer crash_player;
AudioPlayer munch_player;

import processing.serial.*;
Serial BT;



String[] fontList = PFont.list();


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxx GLOBAL OF ALL xxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

PFont font; 

boolean keypressed = false;
boolean BT_CONNECTED = false;
boolean animate_switch = false;
boolean dirUsed = false;
boolean BLE = false;
float [] EMG_values;

float screen_x;
color button_color = #F2B7B7;

long last_pressed = 0;
String [] Coms_inputed;
boolean COMStxt = true;
static final int FADE = 2500;
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////

int screen = 1;
int next_screen = screen;
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////
int dir; // direction from keyboard
int scl = 20;
int rows;
int cols;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxx    GRAPH    xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
int emg_number = 5000;
float emgMax = 10;
float  emg_value;
float [] emg_values = new float [5000];
graphing emg_graph, emg_graph1;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxx CALIBRATION xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
boolean calibration_in_process = true;  


color red = color (255, 0, 0);
color green = color (0, 255, 0);
color blue = color (0, 0, 255);
color []arrow_colors = {red, red, red, red};

String [] labels = {"FORWARD", "LEFT", "DOWN", "RIGHT", "DONE"};
int [] correct_row = {1, 3, 2, 4};
int index_here = 0;

int time_calib_finished;

long displayed;
boolean calib_check_need = false;
boolean wrong_st = false;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxx CHOOSE GAME xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

String [] game_names = new String[2];

int chosen_index = 0;
int part_animation = 1;

boolean [] game_chosen = new boolean[2];
boolean animation_start = false;


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxx SNAKE xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
snake main_snake, s1, color_snake;

float [] historyx = new float[200];
float [] historyy = new float [200];
float x_food, y_food;
float blinked = 0;

int StartingSnakeSize = 3;

int growsize = 4;
int score = 0;
//times
int time_for_destroy = 0;
int pause = 400;
int selected_index = 0;
float settings_h = 0;
color []Snake_Colors = {blue, #F200FF, #8D55F0, #00EAF5, #F5002D, #F5A800, #00F553};

boolean GameOver = false;
boolean check = true;
boolean once_v2 = true;
boolean Pause = false;
boolean Mute = false;
boolean moved = true;
boolean snake_first_start = true;
boolean Settings_show = false;
//boolean [] selected_index = {true,false,false};
boolean swipe = false;
boolean settings_animation = false;


//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxx FIND WAY xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx


int gap = 150;
int spacey;
int level_number = 1;
//pole [] place = new pole[171];
Pole [] places;
int x_work;
boolean work_right = true;
boolean find_way_animation_start = true;
int y_anim;

//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxx SETUP xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
void setup() {
  //fullScreen();

  size(1920, 1080);

  try {
    Coms_inputed =   loadStrings("COMS.txt");
    for (int i = 0; i<Coms_inputed.length; i++) {
      connect_to_DV(Coms_inputed[i]);
    }
  }
  catch(NullPointerException e) {
    COMStxt = false;
  }
  screen_x = width/2;
  //connect_to_DV("COM12");
  rectMode(CENTER);
  emg_graph = new graphing(width/2 - 300, 0, 600, scl*8);
  emg_graph1 = new graphing(width/2 - 300, height-200, 600, scl*8);
  minim = new Minim(this);
  crash_player = minim.loadFile("crash.mp3");
  munch_player = minim.loadFile("munch_cut.mp3");

  //nastavovani choose menu
  game_names[0] = "Snake";
  game_chosen[0] = true;
  game_names[1] = "Find way";
  game_chosen[1] = false;

  //nastavovani snake hry
  font= createFont("Dominican Regular", 45);
  rows = floor(height/scl);
  cols = floor(width/scl);
  historyx[0] = scl*cols/2;
  historyx[1] = scl*cols/2-scl;
  historyx[2] =scl*cols/2-scl*2;
  historyy[0] = scl*rows/2;
  historyy[1] = scl*rows/2;
  historyy[2] = scl*rows/2;
  //for (int i = 0; i<history_dir.length; i++) {
  //  history_dir[i] = 4;
  //}

  main_snake = new snake(historyx, historyy, blue);

  //nastaveni hry find_way

  int index = 0;
  x_work = scl*cols/2;
  int counting_of_obj = (((rows)-8)/4)*(((cols-1)-3)/4);
  println(counting_of_obj);

  places = new Pole[171];
  for (int r = 8; r<rows-1; r=r+5) {
    for (int c = 3; c<cols-2; c=c+5) {
      color random_C = color (random(255), random(255), random(255), random(255));
      //pole current_pole = new pole(c*scl, r*scl, scl*4, random_C);  
      places[index++] = new Pole (c*scl, r*scl, scl*4, random_C);
    }
  }
}     
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx DRAW xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
void draw() {
  background(125);
  if (BT_CONNECTED) {
    if (BT.available()>0) {
      translate_BT(BT.readString());
    }
  }
  switch (screen) {
  case 1:
    calibration();
    break;
  case 2:
    choose_game();
    break;
  case 3:
    snake_game();
    break;
  case 4:
    find_way_game();
    break;
  }
  if (animate_switch) {
    animate_switch = animate_switch_screen();
  }
}
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

void draw_topic(int sized, float yy, String string) {
  fill(0);
  for (int o = -1; o < 4; o++) {
    textAlign (CENTER);
    textFont(font, 35);
    textSize(sized);
    text(string, width/2 +o, yy);
    textAlign (CENTER);
    textFont(font, 35);
    textSize(sized);
    text(string, width/2, yy +o);
  }
  fill(red);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(sized);
  text(string, width/2, yy);
} 
boolean animate_switch_screen() {
  push();
  rectMode(CORNER);
  fill(0);
  strokeWeight(5);
  stroke(255);
  rect(0- 200 - screen_x, 0, width/2 + 200, height);
  rect(width/2 + screen_x, 0, width/2 + 200, height);
  pop();
  if (screen_x > 0 && screen != next_screen) {
    screen_x = lerp(screen_x, -10, 0.05);
  } else {
    screen = next_screen;
  } //<>//
  if (screen_x < width/2 && screen == next_screen) {
    screen_x = lerp(screen_x, width/2+50, 0.05);
  } else if (screen_x>10 && screen == next_screen) {
    screen_x = width/2; 
    return false;
  }


  return true;
}
void pause_game() {
  fill(255);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(80);
  text("PAUSE", width/2, height/2-50);
  noStroke();
  fill(125, 125, 125, 100);
  rect(0, 0, width*2, height*2);
}
void back_screen_f() {
  switch (screen) {
  case 2:
    next_screen = 1;
    start_calibration();
    break;
  case 3:
    next_screen = 2;
    animation_start = true;
    break;
  case 4:
    next_screen = 2;
    animation_start = true;
    break;
  }
  animate_switch = true;
}
void start_calibration() {

  calibration_in_process = true;  
  for (int i = 0; i<4; i++) {
    arrow_colors[i] = red;
  }
  index_here = 0;
}

void keyPressed() {
  keypressed = true;
  trans_key();
}

void trans_key() {
  if (key == CODED) {
    switch(keyCode) {
    case UP:
      dir = 1;
      dir_rules();
      break;
    case DOWN:
      dir = 2;
      dir_rules();
      break;
    case LEFT:
      dir = 3;
      dir_rules();
      break;
    case RIGHT:
      dir = 4;
      dir_rules();
      break;
    }
  } else {
    switch(key) {
    case 'p':
      Pause = !Pause;
      Settings_show = false;
      break;
    case 'm':
      Mute = !Mute;
      break;
    case 'b':
      if (screen == 3) {
        if (Pause) {
          back_screen_f();
        }
      } else {
        back_screen_f();
      }
      break;
    case 's':
      if (Pause) {      
        Settings_show = !Settings_show;
        settings_animation = true;
      }
      break;
    case 'k':
      BT.write("<1>");
      break;
    case ESC:
      if (BT_CONNECTED) {
        BT.write("<0>");
      }
      exit();
      break;
    }
  }
  keypressed = false;
}
void dir_rules() {
  switch(screen) {
  case 1: // CALIBRATION
    calib_check_need = true;
    break;
  case 2: // CHOOSE GAME
    switch(dir) {
    case 1:
      chosen_index--;
      if (chosen_index < 0 ) {
        chosen_index = game_names.length-1;
      }
      chose_dif();
      break;
    case 2:
      chosen_index++;
      if (chosen_index > game_names.length-1) {
        chosen_index = 0;
      }
      chose_dif();
      break;
    case 3:
      back_screen_f();
      break;
    case 4:
      play_game();
      break;
    }
    break;
  case 3: // SNAKE GAME
    if (moved && !Pause) {
      switch(dir) {
      case 1:
        if (main_snake.snake_dir != 2) {
          main_snake.snake_dir = 1;
        }
        break;
      case 2:
        if (main_snake.snake_dir != 1) {
          main_snake.snake_dir = 2;
        }
        break;
      case 3:
        if (main_snake.snake_dir != 4) {
          main_snake.snake_dir = 3;
        }
        break;
      case 4:
        if (main_snake.snake_dir != 3) {
          main_snake.snake_dir = 4;
        }
        break;
      }
      moved = false;
    }
    if (Pause && Settings_show) {
      switch (dir) {
      case 1:
        selected_index--;
        if (selected_index<0) {
          selected_index = 2;
        }
        break;
      case 2:
        selected_index++;
        if (selected_index>2) {
          selected_index = 0;
        }
        break;
      default:
        swipe =true;
        break;
      }
    }
    break;
  }
}


void translate_BT(String string) {
  String [] transInt = split(string, ',');

  if (transInt.length > 2) {
    //if(int(transInt[0]) !=0 ){
    dir = int(transInt[0]);
    if (dir !=0 && millis() - last_pressed > 500) {
      last_pressed = millis();
      //print(dir);
      dir_rules();
    }
    //}

    emg_value = int(transInt[1]);
    if (emgMax<emg_value) {
      emgMax = emg_value + 1000;
    }
    println(emg_value);
    emg_value = map(emg_value, 0, emgMax, 0, scl*8);
    // println(transInt[1]);
  }
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
