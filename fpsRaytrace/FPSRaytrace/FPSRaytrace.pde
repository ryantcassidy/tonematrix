FPSRaytracer fpsraytracer;
int WIDTH = 500;
int HEIGHT = 500;
int DEPTH = 500;
float camX = WIDTH/2;
float camY = HEIGHT/2;
float camZ = 370;
float lookX = 0;
float lookY = 0;
float lookZ = 0;
boolean drawSpheres = false;
int LIFETIME = 500;
int PARTICLE_SIZE = 4;


float vectorDist(PVector v1, PVector v2) {
  return dist(v1.x, v1.y, v1.z, 
  v2.x, v2.y, v2.z);
}

void setup() {
  size(WIDTH, HEIGHT, OPENGL);
  fpsraytracer = new FPSRaytracer();
  frameRate(20);
}

void draw() {
  background(255);
  camera(camX, camY, camZ, lookX, lookY, lookZ, 0, 1, 0);
  fpsraytracer.update();
  if (drawSpheres){
    for(Sphere s : fpsraytracer.spheres){
      sphereDetail(30);
      noStroke();
      fill(s.sColor);
      pushMatrix();
      translate(s.pos.x,s.pos.y,s.pos.z);
      sphere(s.radius);
      popMatrix();
    }
  }
  print(fpsraytracer.particles.size());
  print("\n");
  for(Collision c : fpsraytracer.collisions){
    c.draw();
  }
}

void mouseMoved() {
  //Controls camera movement.
  camX -= mouseX - pmouseX;
  camY -= mouseY - pmouseY;
  fpsraytracer.addParticle();
}

void mouseDragged() {
  fpsraytracer.addParticle();
}

void keyPressed() {
  if(key == 'm'){
    drawSpheres = !drawSpheres;
  }
  if(key == 'w'){
    lookZ+=10;
    camZ +=10;
  }
  if(key == 's'){
    lookZ-=10;
    camZ -=10;
  }
  if(key == 'd'){
    lookX+=10;
    camX +=10;
  }
  if(key == 'a'){
    lookX-=10;
    camX -=10;
  }
  if(key == '>'){
    for(int x = -100; x < 100; x++){
      for(int y = -100; y < 100; y++){
        fpsraytracer.addParticle(new PVector(x+camX,y+camY,camZ));
      }
    }
  }
}

class FPSRaytracer {
  ArrayList<Particle> particles = new ArrayList<Particle>();
  ArrayList<Sphere> spheres = new ArrayList<Sphere>();
  ArrayList<Collision> collisions = new ArrayList<Collision>();

  FPSRaytracer() {
    spheres.add(new Sphere(new PVector(-100, 0, 0), 100.0, color(255,0,0)));
    spheres.add(new Sphere(new PVector(100, 0, 0), 100.0, color(0,255,0)));
    spheres.add(new Sphere(new PVector(0, -100, 0), 100.0, color(0,0,255)));
    spheres.add(new Sphere(new PVector(0, 100, 0), 100.0, color(255)));
  }

  void update() {
    ArrayList<Particle> pRemove = new ArrayList<Particle>();
    for (Particle p : particles) {
      if (p.lifetime <= 0 || 
          vectorDist(p.pos,new PVector(camX,camY,camZ)) > DEPTH ||
          p.collisionCount >= 4){
        pRemove.add(p);
        break;
      }
      for (Sphere s : spheres) {
        if (p.hit(s)) {
          p.reflect(s);
          PVector cPos = new PVector(p.pos.x,p.pos.y,p.pos.z);
          color avgColor = averageColor(p.pColor,s.sColor);
          p.pColor = avgColor;
          collisions.add(new Collision(cPos,avgColor));
          break;
        }
      }
      p.update();
      p.draw();
    }
    for (Particle p : pRemove) {
      particles.remove(p);
    }
  }
  
  color averageColor(color c1, color c2){
    int r1 = (c1 >> 16) & 0xFF;
    int r2 = (c2 >> 16) & 0xFF;
    
    int g1 = (c1 >> 8) & 0xFF;
    int g2 = (c2 >> 8) & 0xFF;
    
    int b1 = c1 & 0xFF;
    int b2 = c2 & 0xFF;
    
    int r = (r1 + r2)/2;
    int g = (g1 + g2)/2;
    int b = (b1 + b2)/2;
    
    return color(r,g,b);
  } 
  
  void addParticle(PVector position){
    PVector pPos = position;
    PVector pVel = new PVector(lookX - camX,
                               lookY - camY, 
                               lookZ - camZ);
    pVel.normalize();
    pVel.mult(5);
    pVel.mult(new PVector(random(4),1,random(4)));
    color c = color(120);
    Particle p = new Particle(pPos,pVel,c);
    particles.add(p);
  }
  
  void addParticle() {
    PVector pPos = new PVector(camX, camY, camZ);
    PVector pVel = new PVector(lookX - camX,
                               lookY - camY, 
                               lookZ - camZ);
    pVel.normalize();
    pVel.mult(5);
    pVel.mult(new PVector(random(4),1,random(4)));
    color c = color(120);
    Particle p = new Particle(pPos,pVel,c);
    particles.add(p);
  }
}

class Particle {

  PVector pos;
  PVector vel;
  color pColor;
  int collisionCount = 0;
  int lifetime = floor(random(LIFETIME));

  Particle(PVector pos, PVector vel, color pColor) {
    this.pos = pos;
    this.vel = vel;
    this.pColor = pColor;
  }

  void update() {
    lifetime--;
    pos.add(vel);
  }

  void reflect(Sphere s) {
    PVector particleDirection = PVector.mult(vel,pos);
    PVector normal = PVector.sub(s.pos,pos);
    normal.normalize();
    PVector twoNdotDirNormal = PVector.mult(normal,abs(2*PVector.dot(particleDirection,normal)));
    PVector reflectedDirection = PVector.sub(particleDirection,twoNdotDirNormal);
    reflectedDirection.normalize();
    vel = reflectedDirection;
    
  }

  boolean hit(Sphere sphere) {
    boolean hit = vectorDist(this.pos, sphere.pos) <= (sphere.radius + PARTICLE_SIZE);
    if(hit){
      collisionCount++;
    }
    return hit;
  }

  void draw() {
//    noStroke();
//    fill(pColor);
//    sphereDetail(2);
//    pushMatrix();
//    translate(pos.x,pos.y,pos.z);
//    sphere(PARTICLE_SIZE);
//    popMatrix();
    stroke(pColor);
    strokeWeight(PARTICLE_SIZE);
    smooth();
    point(pos.x,pos.y,pos.z);
//    line(pos.x, pos.y, pos.z, pos.x+vel.x, pos.y+vel.y, pos.z+vel.z);
  }
}

class Collision {

  PVector pos;
  color cColor;

  Collision(PVector pos, color cColor) {
    this.pos = pos;
    this.cColor = cColor;
  }

  void draw() {
//    sphereDetail(9);
//    pushMatrix();
//    translate(pos.x,pos.y,pos.z);
//    sphere(10);
//    popMatrix();
    stroke(cColor);
    strokeWeight(max(1,PARTICLE_SIZE/(fpsraytracer.collisions.size())));
    point(pos.x,pos.y,pos.z);
  }
}

class Sphere {

  PVector pos;
  float radius;
  color sColor;

  Sphere(PVector pos, float radius, color sColor) {
    this.pos = pos;
    this.radius = radius;
    this.sColor = sColor;
  }
}

