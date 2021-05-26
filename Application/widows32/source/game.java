import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import ddf.minim.*; 
import ddf.minim.analysis.*; 
import ddf.minim.effects.*; 
import ddf.minim.signals.*; 
import ddf.minim.spi.*; 
import ddf.minim.ugens.*; 
import processing.serial.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class game extends PApplet {

 //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//






Minim minim;
AudioPlayer crash_player;
AudioPlayer munch_player;


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
int button_color = 0xffF2B7B7;

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


int red = color (255, 0, 0);
int green = color (0, 255, 0);
int blue = color (0, 0, 255);
int []arrow_colors = {red, red, red, red};

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
int []Snake_Colors = {blue, 0xffF200FF, 0xff8D55F0, 0xff00EAF5, 0xffF5002D, 0xffF5A800, 0xff00F553};

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
public void setup() {
  //fullScreen();

  

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
   int random_C = color (random(255), random(255), random(255), random(255));
   //pole current_pole = new pole(c*scl, r*scl, scl*4, random_C);  
   places[index++] = new Pole (c*scl, r*scl, scl*4, random_C);
   }
   } 
   
}     
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxx DRAW xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
//xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
public void draw() {
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

public void draw_topic(int sized, float yy, String string) {
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
public boolean animate_switch_screen() {
  push();
  rectMode(CORNER);
  fill(0);
  strokeWeight(5);
  stroke(255);
  rect(0- 200 - screen_x, 0, width/2 + 200, height);
  rect(width/2 + screen_x, 0, width/2 + 200, height);
  pop();
  if (screen_x > 0 && screen != next_screen) {
    screen_x = lerp(screen_x, -10, 0.05f);
  } else {
    screen = next_screen;
  }
  if (screen_x < width/2 && screen == next_screen) {
    screen_x = lerp(screen_x, width/2+50, 0.05f);
  } else if (screen_x>10 && screen == next_screen) {
    screen_x = width/2; 
    return false;
  }


  return true;
}
public void pause_game() {
  fill(255);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(80);
  text("PAUSE", width/2, height/2-50);
  noStroke();
  fill(125, 125, 125, 100);
  rect(0, 0, width*2, height*2);
}
public void back_screen_f() {
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
public void start_calibration() {

  calibration_in_process = true;  
  for (int i = 0; i<4; i++) {
    arrow_colors[i] = red;
  }
  index_here = 0;
}

public void keyPressed() {
  keypressed = true;
  trans_key();
}

public void trans_key() {
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
public void dir_rules() {
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


public void translate_BT(String string) {
  String [] transInt = split(string, ',');

  if (transInt.length > 2) {
    //if(int(transInt[0]) !=0 ){
    dir = PApplet.parseInt(transInt[0]);
    if(dir !=0 && millis() - last_pressed > 500){
      last_pressed = millis();
    //print(dir);
    dir_rules();
    }
    //}

    emg_value = PApplet.parseInt(transInt[1]);
    if(emgMax<emg_value){
      emgMax = emg_value + 1000;
    }
     println(emg_value);
    emg_value = map(emg_value, 0, emgMax, 0, scl*8);
    // println(transInt[1]);
  }
}

public void connect_to_DV(String string) {
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
//calibration check
public void calibration() {
  //nadpis
  draw_topic(150, 200, "CALIBRATION");
  emg_graph1.draw_graph();
  fill(0);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(30);
  text(labels[index_here], width/2, height/2-200);
  arrow(1, width/2, height/2-120, arrow_colors[0]);
  arrow(2, (width/2), (height/2), arrow_colors[2]);
  arrow(4, (width/2)-120, height/2, arrow_colors[1]);
  arrow(3, (width/2)+120, height/2, arrow_colors[3]);
    if (!COMStxt) {
    fill(255, 0, 0);
    textSize(20);
    text("Missing COMS.txt", width-200, height-10);
  }
  calib_check_v2();
  if (wrong_st && millis() < displayed + 2000) {
    wrong();
  } else { 
    wrong_st = false;
  }
  if (index_here == 4) {
    next_screen = 2;
    if (millis()>time_calib_finished+2000) {
      calibration_in_process = false;
      dir = 4;
      animate_switch = true;
      animation_start = true;
    }
  }
}
public void calib_check_v2() {
  if (calib_check_need && index_here<4) {
    if (dir == correct_row[index_here]) {
      arrow_colors[index_here] = green;
      if (index_here == 3) {
        time_calib_finished = millis();
      }
      index_here++;
    } else {
      wrong_st = true;
      displayed = millis();
    }
    calib_check_need = false;
  }
}

public void arrow(int direction, int tx, int ty, int c) {
  // vykresluje sipky
  float rot=0;
  int x = 0;
  int y = 0;

  switch(direction) {
  case 1:
    rot = 0;
    break;
  case 2:
    rot = PI;
    break;
  case 3:
    rot = PI/2;
    break;
  case 4:
    rot = -PI/2;
    break;
  }
  //strokeWeight(5);
  pushMatrix();
  rectMode(CORNER);
  translate(tx, ty);
  rotate(rot);
  strokeWeight(5);
  stroke(0);
  fill(c);
  rect(x-100/2, y-100/2, 100, 100, 20);
  fill(0);
  noStroke();
  beginShape();
  vertex(x, y - 30);
  vertex(x - 40, y+20);
  vertex(x + 40, y+20);
  endShape(CLOSE);
  popMatrix();

  //strokeWeight(1);
}
public void wrong() {
  // hard coded, change it in future
  fill(red);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(1.5f*scl);
  text("WRONG", width/2+200, height/2-100);
}
//mid screen, where is user choosing game to play
public void choose_game() {
  for (int i = 0; i<game_names.length; i++) {
    if (game_chosen[i]) {
      animate(i);
    }
    draw_game_menu(game_names[i], width/2, 200 + i*400, game_chosen[i]);
  }

  user_interface_cg();
}
public void user_interface_cg() {
  push();
  strokeWeight(4);
  fill(button_color);
  stroke(blue);
  rect(scl*6, height-6*scl, scl*2.5f, scl*2.5f);
  fill(blue);
  //textSize(scl*2);
  text("B", scl*6, height-6*scl + scl);
  pop();
}
public void draw_game_menu(String name, float x, float y, boolean chosen) {
  float h_g = 100;
  float w_g = 300;
  int c;
  if (chosen) {
    c = color(0, 255, 0);
  } else { 
    c = color(0);
  }
  pushMatrix();
  strokeWeight(4);
  stroke(c);
  fill(0xff9A98F2);
  rectMode(CENTER);
  rect(x, y, w_g, h_g, 20);
  fill(0);
  textAlign (CENTER);
  textFont(font, scl*2.5f);
  textSize(scl*2.5f);
  text(name, x - 10, y+10);
  popMatrix();
  pushMatrix();
  strokeWeight(6);
  stroke(c);
  noFill();
  beginShape();
  vertex(x + w_g/2 - 50, y - h_g/4);
  vertex(x + w_g/2 - 20, y);
  vertex(x + w_g/2 - 50, y + h_g/4);
  endShape();
  strokeWeight(1);
  popMatrix();
}
public void animate(int animation_index) {
  switch (animation_index) {
  case 0:
    snake_animation();
    break;
  case 1:
    find_way_animation();
    break;
  }
}
public void chose_dif() {
  for (int i = 0; i<game_names.length; i++) {
    game_chosen[i] = false;
  }
  animation_start = true;

  game_chosen[chosen_index] = true;
}
public void play_game() {
  switch (chosen_index) { 
  case 0:
    next_screen = 3;

    snake_first_start = true;
    dir = 4;
    break;
  case 1:
    next_screen = 4;
    break;
  }
  animate_switch = true;
}
public class graphing {
  // class for drawing graph

  int xpos;
  int ypos;
  int xrange;
  int yrange;
  int [] graph_colors = {0xffFF0000, 0xff0319FF, 0xff03FF2E, 0xffB203FF, 0xff03ECFF, 0xffD0FF03};
  graphing(int x, int y, int x_range, int y_range ) {
    xpos = x;
    ypos = y;
    xrange = x_range;
    yrange = y_range;
  }
  public void draw_graph() {
    push();
    rectMode(CORNER);
    noFill();
    noStroke();
    rect( xpos, ypos, xrange, yrange);
    strokeWeight(5);


    stroke(graph_colors[0]);
    beginShape();
    int posun = 10;
    for (int y = 0; y<emg_number; y++) {
      if (y+xpos + posun*y<xpos+xrange) {
        vertex(y+xpos + posun*y, ypos + yrange - 10 - emg_values[y]);
      } else {
        break;
      }
    }
    endShape();
    stroke(0);
    rect( xpos, ypos, xrange, yrange);
    pop();
    if (frameCount%1 == 0 ) {
      for (int y = emg_number-1; y>0; y--) {
        emg_values[y] = emg_values[y-1];
      }      
      emg_values[0] = emg_value;
    }
  }
}
//unfinished game

public void find_way_game() {
  user_interface_fw();
  game_interface_fw();
}

public void game_interface_fw() {
  for (int i=0; i<places.length; i++) {
    places[i].show(0);
  }
  
  strokeWeight(4);
   int count = 0;
   int a = red;
   for (int r = 8; r<rows-1; r=r+5) {
   for (int c = 3; c<cols-2; c=c+5) {
   //if(r%2 == 0 && c%2 == 0){
   if (a == red) {
   a = blue;
   } else {
   a = red;
   }     
   fill(random(255), random(255), random(255));
   stroke(255);
   rect(c*scl, r*scl, scl*4, scl*4);
   count++;
   }
   }
   println(count);
   
}
public void user_interface_fw() {
  int p_color;
  fill(red);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(scl*1.5f);
  text("LEVEL: "+ str(level_number), width-200, scl*2.5f);
  fill(255);
  rect(width/2, 5*scl, width, scl);
  push();
  textSize(scl*2);
  strokeWeight(4);
  if (Pause) {
    p_color = red;
    fill(blue);
    text("B", scl*11, scl*2+scl/2);
    noFill();
    stroke(blue);
    rect(scl*11, scl*2, scl*2.5f, scl*2.5f);
  } else {
    p_color = green;
  }
  fill(p_color);
  text("P", scl*3, scl*2+scl/2);
  noFill();
  stroke(p_color);
  rect(scl*3, scl*2, scl*2.5f, scl*2.5f);
  if (Mute) {
    p_color = red;
    stroke(red);
    line(scl*5, scl*3.5f, scl*9, scl/2);
  } else {
    p_color = green;
  }
  fill(p_color);
  text("M", scl*7, scl*2+scl/2);
  noFill();
  stroke(p_color);
  rect(scl*7, scl*2, scl*2.5f, scl*2.5f);
  pop();
  textSize(scl*2);

  if (x_work< cols*scl/2+scl && work_right) {
    x_work= x_work + 5;
  } else {
    work_right = false;
  }
  if (x_work > cols*scl/2 - scl && !work_right) {
    x_work =x_work - 5;
  } else {
    work_right = true;
  }

  text("We are working on it", x_work, scl*3);
}
class Pole {
  int x, y, w;
  int pole_color;
  int original_pole_color;
  Pole( int ix, int iy, int iw, int cc) {

    x = ix;
    y = iy;
    w = iw;
    pole_color = cc;
    original_pole_color = cc;
  }

  public void show(int statemant) {
    if (statemant == 1) {
      pole_color = green;
    } else if (statemant == 2) {
      pole_color = red;
    } else {
      pole_color = original_pole_color;
    }
    push();
    strokeWeight(4);
    fill(original_pole_color);
    stroke(255);
    rect(x, y, w, w);
    pop();
  }
}
public void find_way_animation() {//animace pro find way
   if (animation_start) {
    y_anim = 600;
    animation_start = false;
  }
  if (y_anim<700) {
    y_anim = y_anim + 5;
  }

  push();
  strokeWeight(5);
  stroke(0);
  line(width/2 - 50, y_anim - 50, width/2 - 50, y_anim );
  line(width/2 + 50, y_anim- 50, width/2 + 50, y_anim );

  strokeWeight(1);
  fill(green);
  rect(  width/2, y_anim, 250, 50, 20);
  fill(0);
  textSize(scl);
  text("SORRY WE HAVE TO FIX THAT", width/2, y_anim + 10);

  pop();
}
//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
//snake game
public void snake_game() {
  if (snake_first_start) {
    historyx[0] = scl*cols/2;
    historyx[1] = scl*cols/2-scl;
    historyx[2] =scl*cols/2-scl*2;
    historyy[0] = scl*rows/2;
    historyy[1] = scl*rows/2;
    historyy[2] = scl*rows/2;
    Pause = false;
    GameOver = false;
    time_for_destroy = 0;
    pause = 400;
    once_v2 = true;
    blinked = 0;
    crash_player.pause();
    crash_player.rewind();
    score = 0;
    once_v2 = true;

    //
    snake_first_start = false;
    //
    main_snake = new snake(historyx, historyy, 0);
  }
  draw_box();
  if (!GameOver  && !Pause) {
    if (frameCount%main_snake.frame == 0) {
      main_snake.update();
    }
    main_snake.show();
    main_snake.ate_food();
    draw_food();
    main_snake.HitCheck();
  } else if (GameOver) {
    if (blinked <10) {
      Destroy();
    } else {
      animation_start = true;
      animate_switch = true;
      next_screen = 2;
    }
  } else {
    pause_game();   
    main_snake.show();
    draw_food();
    if (Settings_show) {
      Settings();
    }
  }
  snake_UI();
}

class snake {
  float [] hx;
  float [] hy;
  float move = scl;
  float w;
  float [] history_dir = new float [200];
  int Snakesize = StartingSnakeSize;
  int last_Snakesize = Snakesize;
  int snake_dir = 4;
  int frame = 5;
  int color_index = 0;

  snake(float[] hhx, float[] hhy, int c) {

    Snakesize = StartingSnakeSize;
    last_Snakesize = Snakesize;
    color_index = c;
    hx = hhx;
    hy = hhy;
    w = scl;
    for (int i = 0; i<this.history_dir.length; i++) {
      this.history_dir[i] = 4;
    }
  }
  public void setColor() {
    this.color_index++;
    if (this.color_index >= Snake_Colors.length) {
      this.color_index = 0;
    }
  }
  public int getColor() {
    return Snake_Colors[color_index];
  }
  public void update() {
    float new_x = hx[0];
    float new_y = hy[0];
    float new_dir = this.history_dir[0];
    switch (this.snake_dir) {
    case 1 :
      new_y = hy[0] - move;
      new_dir = 3*PI/2;
      break;
    case 2 :
      new_y = hy[0] + move;
      new_dir = PI/2;
      break;
    case 3 :
      new_x = hx[0] - move;
      new_dir = PI;
      break;
    case 4 :
      new_x = hx[0] + move;
      new_dir = 0;
      break;
    }
    for (int i = 0; i<Snakesize-1; i++) {
      float ix = hx[Snakesize-i-2];
      float iy = hy[Snakesize-i-2];
      float idir = this.history_dir[Snakesize-i-2];
      hx[Snakesize-i-1] = ix;
      hy[Snakesize-i-1] = iy;
      this.history_dir[Snakesize - i - 1] = idir;
    }
    hx[0] = new_x;
    hy[0] = new_y;
    this.history_dir[0] = new_dir;
    moved = true;
  }

  public void show() {
    for (int i = 1; i<last_Snakesize; i++) {
      noStroke();
      fill(Snake_Colors[color_index]);
      rect(hx[i], hy[i], w, w, 5);
    }
    if (last_Snakesize != Snakesize) {
      rect(hx[last_Snakesize], hy[last_Snakesize], w, w, 5);
      last_Snakesize++;
    }
    //hlava
    pushMatrix();
    translate(hx[0], hy[0]);
    rotate(this.history_dir[0]);
    stroke(255);
    beginShape();
    vertex(-scl/2, -scl/2);
    vertex(scl/2, -scl/2);
    vertex(scl/2, -scl*3/8);
    vertex(scl*3/4, -scl/4);
    vertex(scl*3/4, scl/4);
    vertex(scl/2, scl*3/8);
    vertex(scl/2, scl/2);
    vertex(-scl/2, scl/2);
    endShape(CLOSE);
    //rect(0, 0,w,w,5);
    fill(255);
    rect(0, 0 - scl/4, scl/4, scl/4);
    rect(0, 0 + scl/4, scl/4, scl/4);
    popMatrix();
    //ocas
  }
  public void HitCheck() {
    for (int i = 1; i < Snakesize; i++) { // checkuje pokud se had srazil, srovnava vsechny vlastni hodnoty (krome prvni = hlava) s hlavou
      if (hx[0] == main_snake.hx[i] && hy[0]== main_snake.hy[i]) {
        time_for_destroy = millis();
        GameOver = true;
      }
      if ( hx[0] < scl*2 || hy[0] < scl*10 || hx[0] > (cols-2)*scl || hy[0] > (rows-2)*scl) {  
        time_for_destroy = millis();
        GameOver = true;
      }
    }
  }
  public void ate_food() {
    float tol = scl/4;
    if (x_food+tol > hx[0] && x_food-tol < hx[0] && y_food+tol> hy[0] && y_food-tol < hy[0]) {
      check = true;
      if (Mute == false) {
        munch_player.rewind();
        munch_player.play();
      }
      last_Snakesize = Snakesize;
      for (int i = 1; i<growsize; i++) {
        main_snake.hx[Snakesize] = main_snake.hx[1];
        main_snake.hy[Snakesize] = main_snake.hy[1];
        Snakesize++;
      }
      score++;
    }
  }
}
public void snake_UI() {
  int button_y = scl*4;
  int letter_y = button_y + scl/2;
  int local_line_alfa = 0;
  emg_graph.draw_graph();
  int p_color;
  fill(0);
  textAlign (CENTER);
  textFont(font);
  textSize(scl*3);
  text("SCORE: "+ str(score), width-8*scl, scl*4);


  push();
  textSize(scl*2);
  strokeWeight(4);
  if (Pause) {
    p_color = red;

    fill(button_color);
    stroke(blue);
    rect(scl*11, button_y, scl*2.5f, scl*2.5f);
    fill(blue);
    text("S", scl*11, letter_y);

    fill(button_color);
    stroke(blue);
    rect(scl*15, button_y, scl*2.5f, scl*2.5f);
    fill(blue);
    text("B", scl*15, letter_y);

  } else {
    p_color = blue;
  }

  fill(button_color);
  stroke(p_color);
  rect(scl*3, button_y, scl*2.5f, scl*2.5f);
  fill(p_color);
  text("P", scl*3, letter_y);
  if (Mute) {
    p_color = red;
    local_line_alfa = 255;
  } else {
    p_color = 0xff099029;
    local_line_alfa = 0;
  }

  fill(button_color);
  stroke(p_color);
  rect(scl*7, button_y, scl*2.5f, scl*2.5f);
  fill(p_color);
  text("M", scl*7, letter_y);
  stroke(red, local_line_alfa);
  line(scl*5, button_y+1.5f*scl, scl*9, button_y - 1.5f*scl);


  pop();
}
public void draw_box() {

  strokeWeight(1);
  for (int i = 0; i<scl; i++) {
    stroke(0);
    line(0+i, 8*scl, 0+i, rows*scl); 
    line(0, 8*scl+i, cols*scl, 8*scl+i); 
    line(0, rows*scl-i+5, cols*scl, rows*scl-i+5); 
    line(cols*scl-i+5, 8*scl, cols*scl-i+5, rows*scl);
  }
}


public void draw_food() {
  while (check) {
    x_food = floor(random(3, cols-1))*scl;
    y_food = floor(random(11, rows-1))*scl;

    for (int i = 0; i < main_snake.hx.length; i++) {
      if (x_food == main_snake.hx[i] && y_food == main_snake.hy[i]) {
        check = true;
        i = main_snake.hx.length;
      } else {
        check = false;
      }
    }
  }

  stroke(red);
  fill(red);
  rect(x_food, y_food, scl, scl, 10);
}
public void Destroy() {
  if (once_v2) {
    once_v2 = false;
    if (Mute == false) {
      crash_player.rewind();
      crash_player.play();
      //crash_player.shiftGain(crash_player.getGain(),-80,FADE);
    }
  }
  if (millis()- time_for_destroy >pause) {
    if (millis() - time_for_destroy >pause + 100) {
      time_for_destroy = millis();
      pause = pause - pause*30/100;
      blinked ++;
    }
    main_snake.show();
  }
}

public void snake_animation() {
  if (animation_start) {
    animation_start = false; 

    float xxx = width/2;
    float [] s1x = {xxx+scl, xxx, xxx-scl, xxx-2*scl, xxx-3*scl};
    float [] s1y = {200, 200, 200, 200, 200};
    s1 = new snake(s1x, s1y, 2);
    s1.Snakesize = 5;
    part_animation = 1;
  }
  if (s1.hx[0]< width/2 + scl && s1.hy[0]<300 && s1.hx[0] > width/2 - scl ) {
    s1.setColor();
  }
  switch (part_animation) {
  case 1:
    if (s1.hx[0]< width/2 + 10*scl) {
      s1.snake_dir = 4;
    } else {
      part_animation = 2;
    }
    break;
  case 2:
    if (s1.hy[0]<400) {
      s1.snake_dir = 2;
    } else {
      part_animation = 3;
    }
    break;
  case 3:
    if (s1.hx[0] > width/2 - 20*scl) {
      s1.snake_dir  =  3;
    } else {
      part_animation = 4;
    }
    break;
  case 4:
    if (s1.hy[0]>200) {
      s1.snake_dir = 1;
    } else {
      part_animation = 1;
    }
    break;
  }
  if (frameCount%5 == 0) {
    s1.update();
  }
  s1.show();
}
public void Settings() {
  float main_x = scl*5;
  float main_y = scl*8;
  float main_w = scl*15;
  float main_h = scl*20;
  if (!settings_animation) {
    String [] settings_array = {"", "", "SPEED LEVEL: " + str(main_snake.frame)};
    int buttons_y = scl*10;
    int local_x =scl*16;
    int local_y = buttons_y + scl*8;

    float []local_histx = {local_x, local_x-scl, local_x-2*scl, local_x-3*scl, local_x-4*scl, local_x-5*scl, local_x-6*scl, local_x-7*scl};
    float []local_histy = {local_y, local_y, local_y, local_y, local_y, local_y, local_y, local_y      };
    color_snake = new snake (local_histx, local_histy, main_snake.color_index);
    color_snake.last_Snakesize = local_histx.length - 1;
    color_snake.history_dir[0] = 0;
    if (swipe) {
      if (selected_index == 0) {
        BLE= !BLE;
        if (BT_CONNECTED) {
          BT.write("<1>");
        }
      }
      if (selected_index == 1) {
        color_snake.setColor();
        main_snake.setColor();
      }
      if (selected_index == 2) {
        main_snake.frame = main_snake.frame + 5;
        if (main_snake.frame>=20) {
          main_snake.frame = 5;
        }
      }
      swipe = false;
    }

    if (BLE) {
      settings_array [0] = "BLE Keyboard ON" ;
    } else {
      settings_array [0] = "BLE Keyboard OFF" ;
    }
    push();
    textSize(30);
    strokeWeight(5); 
    rectMode(CORNER);
    stroke(255);
    fill(blue, 125);
    rect(main_x, main_y, main_w, main_h, 5);

    for (int i = 0; i<settings_array.length; i++) {
      int fill_C = 0xffFFFFFF;
      if (i == selected_index) {
        fill_C = 0xffFF0000;
      }
      stroke(fill_C);
      fill(0xff099029);
      rect(scl*7.5f, buttons_y + i*scl*6, scl*10, scl*4, 20);
      fill(0);
      text(settings_array[i], scl*12.5f, buttons_y + i*scl*6 + 2.5f*scl);
    }
    pop();
    color_snake.show();
  }
  if ((settings_animation) &&(settings_h<main_h - 10) ) {
    settings_h = lerp(settings_h, main_h, 0.1f);
  } else {
    settings_animation = false;
  }

  if (settings_h>10 && !settings_animation) {
    settings_h = lerp(settings_h, 0, 0.1f);
  }
  if ((settings_h>10 && !settings_animation) ||(settings_animation &&settings_h<scl*20) ) {
    push();
    rectMode(CORNER);
    strokeWeight(5); 
    stroke(255);
    fill(0);
    rect(main_x, main_y, main_w, settings_h, 5);
    pop();
  }
}
  public void settings() {  size(1920, 1080); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "game" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
