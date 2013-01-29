import arb.soundcipher.*;
int FRAME_RATE = 120;
SoundCipher sc = new SoundCipher(this);


class TTile {
  int tWidth;
  int topLeftX;
  int topLeftY;
  int gridX;
  int gridY;
  //TONE
  boolean active = false;
  
  public float x_playhead_on = 0.0;
  public float y_playhead_on = 0.0;
  
  boolean isPlaying;

  void drawMe() {
    float combo = (x_playhead_on + y_playhead_on)*5;
    
    
    if(active && (x_playhead_on + y_playhead_on)/2 < .1){
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
    
    fill(gridX*10, gridY*10, 225/combo);
    
    //stroke(combo);
    strokeWeight(3);

    
    rect(topLeftX, topLeftY, tWidth, tWidth, 6);
  }

  void playMe(){
    sc.playNote(60+(sc.BLUES[(gridY % 6)]), 100, 1);
  }

  void clickCheck(int mX, int mY) {
    if (topLeftX < mX &&
      mX < (topLeftX + tWidth) &&
      topLeftY < mY &&
      mY < (topLeftY + tWidth)) {
      this.active = !this.active;
    }
  }

  TTile(int tlx, int tly, int w, int x, int y) {
    tWidth = w;
    topLeftX = tlx;
    topLeftY = tly;
    gridX = x;
    gridY = y;
  }
}

TTile[][] board;
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
      board[a][b] = new TTile(50 + (54 * a), 50 + (54 * b), 50, a, b);
    }
  }
}


void setup() {
  size(500, 500);
  generateBoard(8);
  frameRate(FRAME_RATE);
  background(0);
  sc.instrument= sc.CLARINET;
}

void draw() {
  //boolean play = false;
  //if (tick_counter == FRAME_RATE){
  //  play = true;
  //} else {
  //  tick_counter++;
  //}
  for (TTile[] row : board) {
    for (TTile t : row) {
      t.drawMe();
    //  if(play){
    //    t.playMe();
    //  }
    }
  }
  if (x_tick_counter == 20) {
    advanceXPlayhead();
    x_tick_counter = 0;
  } 
  else {
    x_tick_counter++;
  }
  if (y_tick_counter == 20) {
    advanceYPlayhead();
    y_tick_counter = 0;
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
}
