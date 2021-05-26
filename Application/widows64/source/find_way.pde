//unfinished game

void find_way_game() {
  user_interface_fw();
  game_interface_fw();
}

void game_interface_fw() {
  for (int i=0; i<places.length; i++) {
    places[i].show(0);
  }
  
  strokeWeight(4);
   int count = 0;
   color a = red;
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
void user_interface_fw() {
  color p_color;
  fill(red);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(scl*1.5);
  text("LEVEL: "+ str(level_number), width-200, scl*2.5);
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
    rect(scl*11, scl*2, scl*2.5, scl*2.5);
  } else {
    p_color = green;
  }
  fill(p_color);
  text("P", scl*3, scl*2+scl/2);
  noFill();
  stroke(p_color);
  rect(scl*3, scl*2, scl*2.5, scl*2.5);
  if (Mute) {
    p_color = red;
    stroke(red);
    line(scl*5, scl*3.5, scl*9, scl/2);
  } else {
    p_color = green;
  }
  fill(p_color);
  text("M", scl*7, scl*2+scl/2);
  noFill();
  stroke(p_color);
  rect(scl*7, scl*2, scl*2.5, scl*2.5);
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
  color pole_color;
  color original_pole_color;
  Pole( int ix, int iy, int iw, color cc) {

    x = ix;
    y = iy;
    w = iw;
    pole_color = cc;
    original_pole_color = cc;
  }

  void show(int statemant) {
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
void find_way_animation() {//animace pro find way
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
