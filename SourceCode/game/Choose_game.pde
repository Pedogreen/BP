//mid screen, where is user choosing game to play
void choose_game() {
  for (int i = 0; i<game_names.length; i++) {
    if (game_chosen[i]) {
      animate(i);
    }
    draw_game_menu(game_names[i], width/2, 200 + i*400, game_chosen[i]);
  }

  user_interface_cg();
}
void user_interface_cg() {
  push();
  strokeWeight(4);
  fill(button_color);
  stroke(blue);
  rect(scl*6, height-6*scl, scl*2.5, scl*2.5);
  fill(blue);
  //textSize(scl*2);
  text("B", scl*6, height-6*scl + scl);
  pop();
}
void draw_game_menu(String name, float x, float y, boolean chosen) {
  float h_g = 100;
  float w_g = 300;
  color c;
  if (chosen) {
    c = color(0, 255, 0);
  } else { 
    c = color(0);
  }
  pushMatrix();
  strokeWeight(4);
  stroke(c);
  fill(#9A98F2);
  rectMode(CENTER);
  rect(x, y, w_g, h_g, 20);
  fill(0);
  textAlign (CENTER);
  textFont(font, scl*2.5);
  textSize(scl*2.5);
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
void animate(int animation_index) {
  switch (animation_index) {
  case 0:
    snake_animation();
    break;
  case 1:
    find_way_animation();
    break;
  }
}
void chose_dif() {
  for (int i = 0; i<game_names.length; i++) {
    game_chosen[i] = false;
  }
  animation_start = true;

  game_chosen[chosen_index] = true;
}
void play_game() {
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
