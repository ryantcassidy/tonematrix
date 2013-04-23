FPSRaytracer fpsraytracer;
int WIDTH = 800;
int HEIGHT = 800;
int DEPTH = 1500;
float camX = WIDTH/2;
float camY = HEIGHT/2;
float camZ = 370;
float lookX = 0;
float lookY = 0;
float lookZ = 0;
boolean drawSpheres = false;
boolean drawParticles = false;
int LIFETIME = 900;
int PARTICLE_SIZE = 1;
int SPEED = 2;
int MAX_COLLISIONS = 10;
float COLLISION_THRESHOLD = .3;


float vectorDist(PVector v1, PVector v2) {
  return dist(v1.x, v1.y, v1.z, 
  v2.x, v2.y, v2.z);
}

void setup() {
  size(WIDTH, HEIGHT, P3D);
  fpsraytracer = new FPSRaytracer();
  frameRate(2000);
}

void draw() {
  background(200);
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
  print(fpsraytracer.collisions.size());
  print("\n");
  print("-----\n");
  for(PVector p : fpsraytracer.collisions.keySet()){
    fpsraytracer.collisions.get(p).draw();
  }
}

void mouseMoved() {
  //Controls camera movement.
  camX -= mouseX - pmouseX;
  camY -= mouseY - pmouseY;
}

void mouseClicked() {
  PVector rand = new PVector(random(4),random(4),1);
  for(int x = -50; x < 50; x+=5){
    for(int y = -50; y < 50; y+=5){
      PVector pos = new PVector(camX+x,camY+y,camZ);
      pos.add(rand);
      fpsraytracer.addParticle(pos);
    }
  }
}

void keyPressed() {
  if(key == 'v'){
    drawSpheres = !drawSpheres;
    drawParticles = !drawParticles;
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
  }
}

class FPSRaytracer {
  ArrayList<Particle> particles = new ArrayList<Particle>();
  ArrayList<Sphere> spheres = new ArrayList<Sphere>();
  HashMap<PVector,Collision> collisions = new HashMap<PVector,Collision>();

  FPSRaytracer() {
    spheres.add(new Sphere(new PVector(-100, 0, 0), 100.0, color(255,0,0)));
    spheres.add(new Sphere(new PVector(100, 0, 0), 100.0, color(0,255,0)));
    spheres.add(new Sphere(new PVector(0, -100, 0), 100.0, color(0,0,255)));
    spheres.add(new Sphere(new PVector(0, 100, 0), 100.0, color(255)));
  }

  void update() {
    ArrayList<Particle> pRemove = new ArrayList<Particle>();
    PVector cam = new PVector(camX,camY,camZ);
    for (Particle p : particles) {
      if (p.lifetime <= 0 || 
          vectorDist(p.pos,cam) > DEPTH ||
          p.collisionCount >= MAX_COLLISIONS){
        pRemove.add(p);
        continue;
      }
      for (Sphere s : spheres) {
        if (p.hit(s)) {
          p.reflect(s);
          PVector cPos = new PVector(p.pos.x,p.pos.y,p.pos.z);
          cPos = clampToInt(cPos);
          color avgColor = averageColor(p.pColor,s.sColor);
          p.pColor = avgColor;
          Collision oldColl = collisions.get(cPos);
          if(oldColl != null){
            color oldColor = oldColl.cColor;
            avgColor = averageColor(avgColor,oldColor);
          }
          collisions.put(cPos, new Collision(cPos,avgColor));
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
  
  PVector clampToInt(PVector v){
    v.x = floor(v.x);
    v.y = floor(v.y);
    v.z = floor(v.z);
    return v;
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
    pVel.mult(SPEED);
    for(int i = 0; i < 50; i++){
      pPos.add(pVel);
    }
    color c = color(255);
    Particle p = new Particle(pPos,pVel,c);
    particles.add(p);
  }
  
  void addParticle() {
    PVector pPos = new PVector(camX, camY, camZ);
    PVector pVel = new PVector(lookX - camX,
                               lookY - camY, 
                               lookZ - camZ);
    pVel.normalize();
    pVel.mult(SPEED);
    for(int i = 0; i < 50; i++){
      pPos.add(pVel);
    }
    color c = color(255);
    Particle p = new Particle(pPos,pVel,c);
    particles.add(p);
  }
}

class Particle {

  PVector pos;
  PVector vel;
  color pColor;
  int collisionCount = 0;
  int lifetime = LIFETIME;

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
    strokeWeight(max(1,PARTICLE_SIZE));
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


