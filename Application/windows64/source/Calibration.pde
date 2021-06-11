//calibration check
void calibration() {
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
void calib_check_v2() {
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

void arrow(int direction, int tx, int ty, color c) {
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
void wrong() {
  // hard coded, change it in future
  fill(red);
  textAlign (CENTER);
  textFont(font, 35);
  textSize(1.5*scl);
  text("WRONG", width/2+200, height/2-100);
}
