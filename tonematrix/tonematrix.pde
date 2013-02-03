import arb.soundcipher.*;
import java.awt.Point;
int FRAME_RATE = 120;
int BOARD_SIZE = 8;
int TILE_WIDTH = 50;
int window = (BOARD_SIZE * (TILE_WIDTH + 4)) + 250;
SoundCipher sc = new SoundCipher(this);

class Spinner {

  int sWidth;
  int spinX;
  int spinY;
  float rotation;
  boolean rowp;
  Modifier mod;
  int gridIndex;
  
  Spinner(int sw, int sx, int sy, boolean rowp, int gi){
    sWidth = sw;
    spinX = sx;
    spinY = sy;
    rotation = 0;
    rowp = rowp;
    mod = new Modifier();
    gridIndex = gi;
  }
  
  void drawMe(){
    rectMode(CENTER);
    rect(spinX,spinY,sw,sw);
    if(rowp){ 
      for(Tile t : board[gridIndex]){
         t.mod(...);
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
  
  WaveControl(int rx,int ry,int cx,int cy,int cw){
    rectX = rx;
    rectY = ry;
    ctrlX = cx;
    ctrlY = cy;
    cWidth = cw;
  } 
 
 void drawMe(){
   fill(135);
   stroke(200);
   rectMode(CENTER);
   strokeWeight(7);
   rect(rectX,rectY,cWidth,cWidth,6);
   strokeWeight(1);
   int half = cWidth/2;
   line((rectX - half), rectY, (rectX + half), rectY);
   line(rectX, (rectY - half), rectX, (rectY + half));
   
   fill(255,5,5);
   ellipse(ctrlX,ctrlY,10,10);
 } 
 
 void clickCheck(int mx, int my){
   int half = cWidth/2;
   if(mx >= (rectX - half) && mx <= (rectX + half) &&
      my >= (rectY - half) && my <= (rectY + half)){
     ctrlX = mx;
     ctrlY = my;      
   }
 }
 
 public int getX(){
   int half = cWidth/2;
   return 20 * (ctrlX)/(rectX + half);
 }
 
 public int getY(){
   int half = cWidth/2;
   return 20 * (ctrlY)/(rectY + half);
 }
 
}

class TTile {
  int tWidth;
  int tileX;
  int tileY;
  int gridX;
  int gridY;
  //TONE
  boolean active = false;
  
  public float x_playhead_on = 0.0;
  public float y_playhead_on = 0.0;
  
  boolean isPlaying;

  void drawMe() {
    float combo = (x_playhead_on + y_playhead_on)*5;
    float threshold = (x_playhead_on + y_playhead_on)/2;
    
    
    if(active && threshold < .1){
      if(!isPlaying){
       playMe(); 
      }
      isPlaying = true;
    } else {
      isPlaying = false;
    }
       
    if (!active) {
      stroke(0);
    } else {
      stroke(255);
    }
    
    fill(gridX*10, gridY*10, 255/combo);
    
    //stroke(combo);
    strokeWeight(3);

    rectMode(CENTER);
    if (active){
      float t = 1-threshold;
      rect(tileX, tileY, tWidth*t, tWidth*t, 6); 
    } else {
      rect(tileX, tileY, tWidth, tWidth, 6);
    }
  }

  void playMe(){
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
  }
}

TTile[][] board;
WaveControl ctrl = new WaveControl(125,125,125,125,200);
int x_playhead=0;
int y_playhead=0;
int board_size;
int tick_counter;
int x_tick_counter=0;
int y_tick_counter=0;

void advanceXPlayhead() {
  x_playhead = (x_playhead + 1) % board_size;
  for (int a = 0; a < board_size; a++) {
    for (TTile t : board[a]) {
      t.x_playhead_on = float(abs(a-x_playhead))/board_size;
    }
  }
}


void advanceYPlayhead() {
  y_playhead = (y_playhead + 1) % board_size;
  for (TTile[] row : board) {
    for (int b = 0; b < board_size; b++) {
      row[b].y_playhead_on = float(abs(b-y_playhead))/board_size;
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
  generateBoard(BOARD_SIZE);
  frameRate(FRAME_RATE);
  background(0);
  sc.instrument= sc.CLARINET;
}

void draw() {
  fill(0);
  rectMode(CORNER);
  rect(0,0,window,window);
  //boolean play = false;
  //if (tick_counter == FRAME_RATE){
  //  play = true;
  //} else {
  //  tick_counter++;
  //}
  
  ctrl.drawMe();
  
  for (TTile[] row : board) {
    for (TTile t : row) {
      t.drawMe();
    //  if(play){
    //    t.playMe();
    //  }
    }
  }
  int ctrlX = ctrl.getX();
  int ctrlY = ctrl.getY();
  if (x_tick_counter == 20) {
    advanceXPlayhead();
    x_tick_counter = ctrlX;
  } 
  else {
    x_tick_counter++;
  }
  if (y_tick_counter == 20) {
    advanceYPlayhead();
    y_tick_counter = ctrlY;
  } 
  else {
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
  
}
