public class graphing {
  // class for drawing graph

  int xpos;
  int ypos;
  int xrange;
  int yrange;
  color [] graph_colors = {#FF0000, #0319FF, #03FF2E, #B203FF, #03ECFF, #D0FF03};
  graphing(int x, int y, int x_range, int y_range ) {
    xpos = x;
    ypos = y;
    xrange = x_range;
    yrange = y_range;
  }
  void draw_graph() {
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
