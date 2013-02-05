//// TONE MATRIX
//// 2d Project
//// Colin Stanton & Ryan Cassidy
//// Computer Graphics

//// imports
import arb.soundcipher.*;
import java.awt.Point;

//// constants, sound libs
int FRAME_RATE = 500;
int BOARD_SIZE = 10;
int TILE_WIDTH = 50;
int BORDER = 5;
int window = (BOARD_SIZE * (TILE_WIDTH + BORDER)) + 250;
SoundCipher sc = new SoundCipher(this);

//A cached out calculation of a sine wave with BOARD_SIZE slices.
float[] m_sine;

// append two sine waves to make a big array with 2 peaks
float[] generateDoublePeakSine(int len) {
  float[] d_sine = new float[len];
  float[] one_sine = generateSine(len / 2);

  System.arraycopy(one_sine, 0, d_sine, 0, len / 2);
  System.arraycopy(one_sine, 0, d_sine, len / 2, len / 2);

  return d_sine;
}

// make a sine wave in an array, one peak
float[] generateSine(int len) {
  m_sine = new float[len];

  if (len % 2 == 0) {
    float value;
    m_sine[0] = 0;
    int turnaround = len/2;
    float increment = 1.0 / turnaround;
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
    float increment = 2.0 / len;
    m_sine[eachSide] = 1;
    for (int counter = 1; counter <= eachSide; counter++) {
      int offset = eachSide - counter;
      m_sine[eachSide - counter] = 1 - (counter * increment);
      m_sine[eachSide + counter] = 1 - (counter * increment);
    }
  }
  return m_sine;
}



//WaveControl class
//Represents the waveheads' speed
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

  //Draw wave controller
  void drawMe() {
    fill(135);
    stroke(200);
    rectMode(CENTER);
    strokeWeight(7);
    rect(rectX, rectY, cWidth, cWidth, 16);
    strokeWeight(1);
    int half = cWidth/2;
    noFill();
    strokeWeight(7);
    bezier((rectX - half), rectY, ctrlX, ctrlY, ctrlX, ctrlY, (rectX + half), rectY);
    bezier(rectX, (rectY - half), ctrlX, ctrlY, ctrlX, ctrlY, rectX, (rectY + half));
    fill(0);
    strokeWeight(0);
    rect(ctrlX, ctrlY, 7, 7);
  } 

  void clickCheck(int mx, int my) {
    int half = cWidth/2;
    if (mx >= (rectX - half) && mx <= (rectX + half) &&
      my >= (rectY - half) && my <= (rectY + half)) {
      ctrlX = mx;
      ctrlY = my;
    }
  }

  //Public getter and setter for 
  //the x and y value of the wave controller
  // returns a fraction representing how close
  // the controller is to its max x and y value.
  public int getX() {
    int half = cWidth/2;
    return x_ticks_max * (ctrlX)/(rectX + half);
  }

  public int getY() {
    int half = cWidth/2;
    return y_ticks_max * (ctrlY)/(rectY + half);
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


  void incrementX() {
    if (x_sin <= 0) {
      x_sin = BOARD_SIZE - 1;
    } 
    else {
      x_sin--;
    }
  }

  void incrementY() {
    if (y_sin <= 0) {
      y_sin = BOARD_SIZE - 1;
    } 
    else {
      y_sin--;
    }
  }

  void checkSinAndPlayOnce() {
    double wave_val = (m_sine[x_sin] + m_sine[y_sin]);
    if (active && wave_val > 1.8) {
      if (!isPlaying) { 
        playMe();
      }
      isPlaying = true;
    } 
    else {
      isPlaying = false;
    }
  }

  void drawMe() {
    checkSinAndPlayOnce();
    float wave_avg = (m_sine[x_sin] + m_sine[y_sin])/2;

    float combo = (m_sine[x_sin] + m_sine[y_sin])*2;
    fill(gridX*15, gridY*15, 255/combo);
    if (!active) {
      stroke(0);
    } 
    else {
      stroke(255);
    }

    strokeWeight(BORDER);

    rectMode(CENTER);
    if (active) {
      rect(tileX, tileY, tWidth*wave_avg, tWidth*wave_avg, BORDER);
    } 
    else {
      fill(100*wave_avg);
      rect(tileX, tileY, tWidth, tWidth, BORDER);
    }
  }

  void playMe() {
    sc.playNote(60+(sc.MAJOR[(gridY % 7)]), 100, 1);
  }

  void clickCheck(int mX, int mY) {
    int half = (tWidth+BORDER)/2;
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

class Toggle {
  int toggleX;
  int toggleY;
  final int w = 200;
  final int h = 24;
  boolean toggledOn;

  Toggle(int tx, int ty, boolean to) {
    this.toggleX = tx;
    this.toggleY = ty;
    this.toggledOn = to;
  }
  void drawMe() {
    rectMode(CENTER);
    textAlign(CENTER);
    strokeWeight(2);
    if (toggledOn) {
      text("Toggle All Tiles", toggleX, toggleY);
      noFill();
      rect(toggleX, toggleY, w, h, 4);
    } 
    else {
      text("Toggle All Tiles", toggleX, toggleY);
      noFill();
      rect(toggleX, toggleY, w, h, 4);
    }
  }

  void clickCheck(int mx, int my) {
    int halfH = h/2;
    int halfW = w/2; 

    if (mx < toggleX + halfW && mx > toggleX - halfW &&
      my < toggleY + halfH && my > toggleY - halfH) {
      toggledOn = !toggledOn;
      for (TTile[] row : board) {
        for (TTile t : row) {
          t.active = toggledOn;
        }
      }
    }
  }
}

TTile[][] board;
WaveControl ctrl = new WaveControl(125, 125, 125, 125, 200);
Toggle toggleAll = new Toggle(window/2, 12, false);
int x_playhead=0;
int y_playhead=0;
int board_size;
int tick_counter;
int x_tick_counter=0;
int y_tick_counter=0;
int x_ticks_max = 20;
int y_ticks_max = 50;


void generateBoard(int bsize) {
  board_size = bsize;
  board = new TTile[bsize][bsize];
  for (int a = 0; a < bsize; a++) {
    for (int b = 0; b < bsize; b++) {
      board[a][b] = new TTile(250 + ((TILE_WIDTH + BORDER) * a), 250 + ((TILE_WIDTH + BORDER) * b), TILE_WIDTH, a, b);
    }
  }
}


void setup() {
  size(window, window);
  m_sine = generateDoublePeakSine(BOARD_SIZE);
  generateBoard(BOARD_SIZE);
  frameRate(FRAME_RATE);
  background(145);
  sc.instrument= sc.PIANO;
}

void draw() {
  fill(145);
  rectMode(CORNER);
  rect(0, 0, window, window);

  ctrl.drawMe();

  for (TTile[] row : board) {
    for (TTile t : row) {
      t.drawMe();
    }
  }

  if (x_tick_counter == x_ticks_max) {
    for (TTile[] row : board) {
      for (TTile t : row) {
        t.incrementX();
      }
    }
    x_tick_counter = ctrl.getX();
  } 
  else {
    x_tick_counter++;
  }

  if (y_tick_counter == y_ticks_max) {
    for (TTile[] row : board) {
      for (TTile t : row) {
        t.incrementY();
      }
    }
    y_tick_counter = ctrl.getY();
  } 
  else {
    y_tick_counter++;
  }

  //toggleAll.drawMe();
}

void mousePressed() {
  for (TTile[] row : board) {
    for (TTile t : row) {
      t.clickCheck(mouseX, mouseY);
    }
  }

  toggleAll.clickCheck(mouseX, mouseY);
  ctrl.clickCheck(mouseX, mouseY);
}

void mouseDragged() {
  ctrl.clickCheck(mouseX, mouseY);
}

