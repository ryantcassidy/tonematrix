//// TONE MATRIX
//// 2d Project
//// Colin Stanton & Ryan Cassidy
//// Computer Graphics

//// imports
import arb.soundcipher.*;
import java.awt.Point;

//// constants, sound libs
int FRAME_RATE = 120;
int BOARD_SIZE = 8;
int TILE_WIDTH = 50;
int window = (BOARD_SIZE * (TILE_WIDTH + 4)) + 250;
SoundCipher sc = new SoundCipher(this);

double[] m_sine;

// append two sine waves to make a big array with 2 peaks
double[] generateDoublePeakSine(int len){
  double[] d_sine = new double[len];
  double[] one_sine = generateSine(len / 2);
  
  System.arraycopy(one_sine, 0, d_sine, 0, len / 2);
  System.arraycopy(one_sine, 0, d_sine, len / 2, len / 2);
  
  return d_sine;
}

// make a sine wave in an array, one peak
double[] generateSine(int len) {
  m_sine = new double[len];

  if (len % 2 == 0) {
    double value;
    m_sine[0] = 0;
    int turnaround = len/2;
    double increment = 1.0 / turnaround;
    for (int counter = 0; counter < len; counter++) {
      if (counter > turnaround) {
        m_sine[counter] = 1 - (increment * (counter - turnaround));
      } 
      else {
        m_sine[counter] = increment * counter;
      }
    }
  } 
  else {
    int eachSide = (len - 1) / 2;
    double increment = 2.0 / len;
    m_sine[eachSide] = 1;
    for (int counter = 1; counter <= eachSide; counter++) {
      int offset = eachSide - counter;
      m_sine[eachSide - counter] = 1 - (counter * increment);
      m_sine[eachSide + counter] = 1 - (counter * increment);
    }
  }
  return m_sine;
}

//// SPINNER CLASS
//// The spinners sit along the X and Y axes of the tone matrix
//// and provide a semblance of control for the mechanism
class Spinner {
  int sWidth;
  int spinX;
  int spinY;
  float rotation;
  boolean rowp;
  int gridIndex;

  // constructor
  Spinner(int sx, int sy, int sw, boolean rowp, int gi) {
    sWidth = sw;
    spinX = sx;
    spinY = sy;
    rotation = 0.0;
    rowp = rowp;
    gridIndex = gi;
  }

  // put me on the screen!
  void drawMe() {
    rectMode(CENTER);
    fill(255);
    rect(spinX, spinY, sWidth, sWidth);
    fill(0);
    textAlign(CENTER);
    text(rotation, spinX, spinY);

    int half = sWidth/4;
    if (rowp) {
      fill(255);
      rect(spinX - sWidth, spinY - half, sWidth/2, sWidth/2);
      fill(0);
      text("+", spinX - sWidth, spinY - half);
      fill(255);
      rect(spinX - sWidth, spinY + half, sWidth/2, sWidth/2);
      fill(0);
      text("-", spinX - sWidth, spinY + half);
    } 
    else {
      fill(255);
      rect(spinX - half, spinY - sWidth, sWidth/2, sWidth/2);
      fill(0);
      text("-", spinX - half, spinY - sWidth);
      fill(255);
      rect(spinX + half, spinY - sWidth, sWidth/2, sWidth/2);
      fill(0);
      text("+", spinX + half, spinY - sWidth);
    }
  }

  void clickCheck(int mx, int my) {
    if (rowp) {
      int xMin = spinX - (sWidth + sWidth/4);
      int xMax = spinX - (sWidth - sWidth/4);
      int yMin = spinY - (sWidth/2);
      int yMax = spinY + (sWidth/2);
      if (mx < xMax && mx > xMin && my < yMax) {
        if ( my > spinY) {
          rotation++;
        } 
        else {
          rotation--;
        }
      }
    } 
    else {
      int yMin = spinY - (sWidth + sWidth/4);
      int yMax = spinY - (sWidth - sWidth/4);
      int xMin = spinX - (sWidth/2);
      int xMax = spinX + (sWidth/2);
      if (my < yMax && my > yMin && mx < xMax) {
        if ( mx > spinX) {
          rotation++;
        } 
        else {
          rotation--;
        }
      }
    }
  }

  void update() {

    if (rowp) { 
      for (TTile t : board[gridIndex]) {
        //t.mod(mod);
      }
    } 
    else {
      for (TTile[] t : board) {
        //t[gridIndex].mod(mod);
      }
    }
  }
}

class WaveControl {
  int cWidth;
  int rectX;
  int rectY;
  int ctrlX;
  int ctrlY;

  WaveControl(int rx, int ry, int cx, int cy, int cw) {
    rectX = rx;
    rectY = ry;
    ctrlX = cx;
    ctrlY = cy;
    cWidth = cw;
  } 

  void drawMe() {
    fill(135);
    stroke(200);
    rectMode(CENTER);
    strokeWeight(7);
    rect(rectX, rectY, cWidth, cWidth, 6);
    strokeWeight(1);
    int half = cWidth/2;
    line((rectX - half), rectY, (rectX + half), rectY);
    line(rectX, (rectY - half), rectX, (rectY + half));

    fill(255, 5, 5);
    ellipse(ctrlX, ctrlY, 10, 10);
  } 
  
  void clickCheck(int mx, int my) {
    int half = cWidth/2;
    if (mx >= (rectX - half) && mx <= (rectX + half) &&
      my >= (rectY - half) && my <= (rectY + half)) {
      ctrlX = mx;
      ctrlY = my;
    }
  }

  public int getX() {
    int half = cWidth/2;
    return 20 * (ctrlX)/(rectX + half);
  }

  public int getY() {
    int half = cWidth/2;
    return 20 * (ctrlY)/(rectY + half);
  }
}

//// TONE TILE Class
//// Represents a square in the main grid of the application
//// Triggers a sound to play, toggleable
class TTile {
  int tWidth;
  int tileX;
  int tileY;
  int gridX;
  int gridY;
  boolean active = false;
  int x_sin = 0;
  int y_sin = 0;
  
  boolean isPlaying = false;
  
  void incrementX(){
    if(x_sin == 0){
      x_sin = BOARD_SIZE - 1;
    } else {
      x_sin--;
    }
   // this.x_sin = (x_sin + 1) % BOARD_SIZE;
  }
  
  void incrementY(){
    if(y_sin == 0){
      y_sin = BOARD_SIZE - 1;
    } else {
      y_sin--;
    }
   // this.y_sin = (y_sin + 1) % BOARD_SIZE;
  }
  
  void checkSinAndPlayOnce(){
    double wave_val = (m_sine[x_sin] + m_sine[y_sin]);
    if (active && wave_val > 1.8) {
      if (!isPlaying) { playMe(); }
      isPlaying = true;
    } else {
      isPlaying = false;
    }
  }
  
  void drawMe() {
    checkSinAndPlayOnce();

    if (!active) {
      stroke(0);
    } else {
      stroke(255);
    }

    double combo = (m_sine[x_sin] + m_sine[y_sin])*5;
    float something = (float)combo;
    fill(gridX*10, gridY*10, 255/something);
    strokeWeight(3);

    rectMode(CENTER);
    rect(tileX, tileY, tWidth, tWidth, 6);
  }

  void playMe() {
    sc.playNote(60+(sc.TURKISH[(gridY % 7)]), 100, 1);
  }

  void clickCheck(int mX, int mY) {
    int half = tWidth/2;
    if ((tileX - half) < mX &&
      mX < (tileX + half) &&
      (tileY - half) < mY &&
      mY < (tileY + half)) {
      this.active = !this.active;
    }
  }

  TTile(int tlx, int tly, int w, int x, int y) {
    tWidth = w;
    tileX = tlx;
    tileY = tly;
    gridX = x;
    gridY = y;
    x_sin = x;
    y_sin = y;
  }
}

TTile[][] board;
Spinner[][] spinners;
WaveControl ctrl = new WaveControl(125, 125, 125, 125, 200);
int x_playhead=0;
int y_playhead=0;
int board_size;
int tick_counter;
int x_tick_counter=0;
int y_tick_counter=0;
int x_ticks_max = 20;
int y_ticks_max = 50;

void generateSpinners(int bsize) {
  spinners = new Spinner[2][bsize];
  for (int a = 0; a < 2; a++) {
    boolean rowp = a % 2 == 0 ? true : false;
    for (int b = 0; b < bsize; b++) {
      if (rowp) {
        spinners[a][b] = new Spinner(200, 250 + (54 * b), 50, rowp, b);
      } 
      else {
        spinners[a][b] = new Spinner(250 + (54 * b), 200, 50, rowp, b);
      }
    }
  }
  print("\n");
  for (int a = 0; a < 2; a++) {
    for (int b = 0; b < board_size; b++) {
      spinners[a][b].rowp = a == 0 ? true : false;
      print(spinners[a][b].rowp);
    }
  }
}

void generateBoard(int bsize) {
  board_size = bsize;
  board = new TTile[bsize][bsize];
  for (int a = 0; a < bsize; a++) {
    for (int b = 0; b < bsize; b++) {
      board[a][b] = new TTile(250 + (54 * a), 250 + (54 * b), 50, a, b);
    }
  }
}


void setup() {
  size(window, window);
  m_sine = generateDoublePeakSine(BOARD_SIZE);
  generateBoard(BOARD_SIZE);
  generateSpinners(BOARD_SIZE);
  frameRate(FRAME_RATE);
  background(0);
  sc.instrument= sc.CLARINET;
}

void draw() {
  fill(0);
  rectMode(CORNER);
  rect(0, 0, window, window);

  ctrl.drawMe();
  
  for (int a = 0; a < 2; a++) {
    for (int b = 0; b < board_size; b++) {
      spinners[a][b].drawMe();
    }
  }
  for (TTile[] row : board) {
    for (TTile t : row) {
      t.drawMe();
    }
  }
  
  if (x_tick_counter == x_ticks_max) {
    for(TTile[] row : board){
      for(TTile t : row) {
        t.incrementX();
      }
    }
    x_tick_counter = 0;
  } else {
    x_tick_counter++;
  }
  
  if (y_tick_counter == y_ticks_max) {
    for(TTile[] row : board){
      for(TTile t : row) {
        t.incrementY();
      }
    }
    y_tick_counter = 0;
  } else {
    y_tick_counter++;
  }
}

void mousePressed() {
  for (TTile[] row : board) {
    for (TTile t : row) {
      t.clickCheck(mouseX, mouseY);
    }
  }

  ctrl.clickCheck(mouseX, mouseY);
  
  for (Spinner[] sArray : spinners) {
    for (Spinner s : sArray) {
      s.clickCheck(mouseX, mouseY);
    }
  }
}




