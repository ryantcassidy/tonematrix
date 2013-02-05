//// TONE MATRIX
//// 2d Project
//// Colin Stanton & Ryan Cassidy
//// Computer Graphics

//// imports
import arb.soundcipher.*;
import java.awt.Point;

//// constants, sound libs
int FRAME_RATE = 120;
int BOARD_SIZE = 20;
int TILE_WIDTH = 20;
int BORDER = 0;
int window = (BOARD_SIZE * (TILE_WIDTH + BORDER)) + 250;
SoundCipher sc = new SoundCipher(this);

//A cached out calculation of a sine wave with BOARD_SIZE slices.
float[] m_sine;

// append two sine waves to make a big array with 2 peaks
float[] generateDoublePeakSine(int len){
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
////Bezier Ellipse by Ira Greenberg
//// http://processing.org/learning/basics/bezierellipse.html

// arrays to hold ellipse coordinate data
float[] px, py, cx, cy, cx2, cy2;

// global variable-points in ellipse
int pts = 4;

color controlPtCol = #222222;
color anchorPtCol = #BBBBBB;
setEllipse(pts, 65, 65);


// Draw ellipse with anchor/control points
void drawEllipse(){
  strokeWeight(1.125);
  stroke(255);
  noFill();
  // Create ellipse
  for (int i=0; i<pts; i++){
    if (i==pts-1) {
      bezier(px[i], py[i], cx[i], cy[i], cx2[i], cy2[i],  px[0], py[0]);
    }
    else{
      bezier(px[i], py[i], cx[i], cy[i], cx2[i], cy2[i],  px[i+1], py[i+1]);
    }
  }
  strokeWeight(.75);
  stroke(0);
  rectMode(CENTER);
}

// Fill arrays with ellipse coordinate data
void setEllipse(int points, float radius, float controlRadius){
  pts = points;
  px = new float[points];
  py = new float[points];
  cx = new float[points];
  cy = new float[points];
  cx2 = new float[points];
  cy2 = new float[points];
  float angle = 360.0/points;
  float controlAngle1 = angle/3.0;
  float controlAngle2 = controlAngle1*2.0;
  for ( int i=0; i<points; i++){
    px[i] = ctrlX+cos(radians(angle))*radius;
    py[i] = ctrlY+sin(radians(angle))*radius;
    cx[i] = ctrlX+cos(radians(angle+controlAngle1))* 
      controlRadius/cos(radians(controlAngle1));
    cy[i] = ctrlY+sin(radians(angle+controlAngle1))* 
      controlRadius/cos(radians(controlAngle1));
    cx2[i] = ctrlX+cos(radians(angle+controlAngle2))* 
      controlRadius/cos(radians(controlAngle1));
    cy2[i] = ctrlY+sin(radians(angle+controlAngle2))* 
      controlRadius/cos(radians(controlAngle1));

    // Increment angle so trig functions keep chugging along
    angle+=360.0/points;
  }
}
  //Draw wave controller
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

    //fill(255, 5, 5);
    //ellipse(ctrlX, ctrlY, 10, 10);
    drawEllipse();
    setEllipse(6, 10, 10);
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
    return floor((ctrlX)/(rectX + half));
  }

  public int getY() {
    int half = cWidth/2;
    return floor((ctrlY)/(rectY + half));
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
    if(x_sin <= 0){
      x_sin = BOARD_SIZE - 1;
    } else {
      x_sin--;
    }
  }
  
  void incrementY(){
    if(y_sin <= 0){
      y_sin = BOARD_SIZE - 1;
    } else {
      y_sin--;
    }
  }
  
  void checkSinAndPlayOnce(){
    double wave_val = (m_sine[x_sin] + m_sine[y_sin]);
    if (active && wave_val > 1) {
      if (!isPlaying) { playMe(); }
      isPlaying = true;
    } else {
      isPlaying = false;
    }
  }
  
  void drawMe() {
    checkSinAndPlayOnce();
    float wave_avg = (m_sine[x_sin] + m_sine[y_sin])/2;

    float combo = (m_sine[x_sin] + m_sine[y_sin])*5;
    float something = (float)combo;
    fill(gridX*10, gridY*10, 255/something);
    if (!active) {
      stroke(0);
    } else {
      stroke(gridX*15, gridY*15, 255/something);
    }

    strokeWeight(BORDER);

    rectMode(CENTER);
    if(active){
      rect(tileX, tileY, tWidth*wave_avg, tWidth*wave_avg, 6);
    } else {
      rect(tileX, tileY, tWidth, tWidth, 6);
    }
  }

  void playMe() {
    sc.playNote(60+(sc.MAJOR[(gridY % 7)]), 100, 1);
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

class Toggle {
  int toggleX;
  int toggleY;
  final int w = 200;
  final int h = 24;
  boolean toggledOn;
  
  Toggle(int tx, int ty, boolean to){
    this.toggleX = tx;
    this.toggleY = ty;
    this.toggledOn = to;
  }
  void drawMe(){
    rectMode(CENTER);
    textAlign(CENTER);
    if(toggledOn){
      text("Toggle All Tiles", toggleX, toggleY);
      fill(255);
      rect(toggleX, toggleY, w, h, 4);
    } else {
      text("Toggle All Tiles", toggleX, toggleY);
      fill(0);
      rect(toggleX, toggleY, w, h, 4);
    }
  }
  
  void clickCheck(int mx, int my){
    int halfH = h/2;
    int halfW = w/2; 
    
    if(mx < toggleX + halfW && mx > toggleX - halfW &&
       my < toggleY + halfH && my > toggleY - halfH){
         toggledOn = !toggledOn;
         for(TTile[] row : board){
            for(TTile t : row) {
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
  background(0);
  sc.instrument= sc.CLARINET;
}

void draw() {
  fill(0);
  rectMode(CORNER);
  rect(0, 0, window, window);

  ctrl.drawMe();
  
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
    x_tick_counter = x_ticks_max * ctrl.getX();
  } else {
    x_tick_counter++;
  }
  
  if (y_tick_counter == y_ticks_max) {
    for(TTile[] row : board){
      for(TTile t : row) {
        t.incrementY();
      }
    }
    y_tick_counter = y_ticks_max * ctrl.getY();
  } else {
    y_tick_counter++;
  }
  
  toggleAll.drawMe();
}

void mousePressed() {
  for (TTile[] row : board) {
    for (TTile t : row) {
      t.clickCheck(mouseX, mouseY);
    }
  }

  ctrl.clickCheck(mouseX, mouseY);
  toggleAll.clickCheck(mouseX, mouseY);
  
}




