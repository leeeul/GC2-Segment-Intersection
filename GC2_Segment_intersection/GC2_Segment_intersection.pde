float size=8;
Sweep s;
int count=0;
void setup() {
  smooth(8);
  size(1200, 700);

  seg_Gen(20, 50);
  s=new Sweep(segs);

  colorMode(HSB, 360, 100, 100);

  strokeWeight(0.8);
  frameRate(1);
}

void draw() {
  background(0);
  count++;
  textAlign(CENTER);

  s.moveNext();

  for (Seg s : segs) {
    stroke(s.col);
    noFill();
    beginShape();
    vertex(s.top.x, s.top.y);
    vertex(s.bot.x, s.bot.y);
    endShape();
  }

  for (PVector p : s.intersection) {
    stroke(#FFFFFF, 255);
    fill(#FFFFFF, 180);
    ellipse(p.x, p.y, size, size);
  }

  for (int i=0; i<segs.size(); i++) {
    fill(#FFFFFF, 200);
    text(i, segs.get(i).top.x, segs.get(i).top.y-5);
  }

  stroke(#00FF00);
  line(0, s.nowSweep.y, width, s.nowSweep.y);
  textAlign(LEFT);

  text("Sweeping : " + s.onLine.size(), 10, 20);
  text("Intersection : " + s.intersection.size(), 10, 35);
  text("Count : "+count, 10, 50);
}

void keyPressed() {
  seg_Gen(40, 50);
  s=new Sweep(segs);
  count=0;
}