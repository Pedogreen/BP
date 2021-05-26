//<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>// //<>//
//snake game
void snake_game() {
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
  void setColor() {
    this.color_index++;
    if (this.color_index >= Snake_Colors.length) {
      this.color_index = 0;
    }
  }
  color getColor() {
    return Snake_Colors[color_index];
  }
  void update() {
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

  void show() {
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
  void HitCheck() {
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
  void ate_food() {
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
void snake_UI() {
  int button_y = scl*4;
  int letter_y = button_y + scl/2;
  int local_line_alfa = 0;
  emg_graph.draw_graph();
  color p_color;
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
    rect(scl*11, button_y, scl*2.5, scl*2.5);
    fill(blue);
    text("S", scl*11, letter_y);

    fill(button_color);
    stroke(blue);
    rect(scl*15, button_y, scl*2.5, scl*2.5);
    fill(blue);
    text("B", scl*15, letter_y);

  } else {
    p_color = blue;
  }

  fill(button_color);
  stroke(p_color);
  rect(scl*3, button_y, scl*2.5, scl*2.5);
  fill(p_color);
  text("P", scl*3, letter_y);
  if (Mute) {
    p_color = red;
    local_line_alfa = 255;
  } else {
    p_color = #099029;
    local_line_alfa = 0;
  }

  fill(button_color);
  stroke(p_color);
  rect(scl*7, button_y, scl*2.5, scl*2.5);
  fill(p_color);
  text("M", scl*7, letter_y);
  stroke(red, local_line_alfa);
  line(scl*5, button_y+1.5*scl, scl*9, button_y - 1.5*scl);


  pop();
}
void draw_box() {

  strokeWeight(1);
  for (int i = 0; i<scl; i++) {
    stroke(0);
    line(0+i, 8*scl, 0+i, rows*scl); 
    line(0, 8*scl+i, cols*scl, 8*scl+i); 
    line(0, rows*scl-i+5, cols*scl, rows*scl-i+5); 
    line(cols*scl-i+5, 8*scl, cols*scl-i+5, rows*scl);
  }
}


void draw_food() {
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
void Destroy() {
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

void snake_animation() {
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
void Settings() {
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
      color fill_C = #FFFFFF;
      if (i == selected_index) {
        fill_C = #FF0000;
      }
      stroke(fill_C);
      fill(#099029);
      rect(scl*7.5, buttons_y + i*scl*6, scl*10, scl*4, 20);
      fill(0);
      text(settings_array[i], scl*12.5, buttons_y + i*scl*6 + 2.5*scl);
    }
    pop();
    color_snake.show();
  }
  if ((settings_animation) &&(settings_h<main_h - 10) ) {
    settings_h = lerp(settings_h, main_h, 0.1);
  } else {
    settings_animation = false;
  }

  if (settings_h>10 && !settings_animation) {
    settings_h = lerp(settings_h, 0, 0.1);
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
