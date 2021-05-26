 //<>// //<>// //<>//
graphing g;
int number_of_emgs = 1;
int emg_number = 10000;
float [] [] emg_values =  new float[number_of_emgs][emg_number];
void setup() {
  size(800, 800);
  g =  new graphing (200, 300, 400, 200);
  for (int i = 0; i<number_of_emgs; i++) {
    for (int y = 0; y<emg_number; y++) {
      emg_values[i][y] = random(-50,50);
    }
  }
}

void draw() {
  background(0);
  g.draw_graph();
}

public class graphing {

  int xpos;
  int ypos;
  int xrange;
  int yrange;

  graphing(int x, int y, int x_range, int y_range ) {
    xpos = x;
    ypos = y;
    xrange = x_range;
    yrange = y_range;
  }
  void draw_graph() {
    push();
    fill(0);
    strokeWeight(5);
    stroke(255);
    rect( xpos, ypos, xrange, yrange);
    pop();
      noFill();
      strokeWeight(1);
      stroke(255);
      for (int i = 0; i<number_of_emgs; i++) { //<>//
        beginShape();
        int posun = 10;
        for (int y = 0; y<emg_number;y++) {
          if(y+xpos + posun*y<xpos+xrange){
          vertex(y+xpos + posun*y, ypos + yrange/2 - emg_values[i][y]);
          }else{
            break;
          }
        }
        endShape();
      }
    if(frameCount%5 == 0 ){
      for (int i = 0; i<number_of_emgs; i++) { //<>//
        for (int y = emg_number-1; y>0; y--) {
          emg_values[i][y] = emg_values[i][y-1];
        }
      }
      for (int i = 0; i<number_of_emgs; i++) {
        emg_values[i][0] = random(-50,50);
      }
    } //<>//
  }
}
