ArrayList<Seg> segs = new ArrayList<Seg>();

class Seg {
  PVector top;
  PVector bot;
  color col;

  Seg(PVector t_, PVector b_) {
    top=t_;
    bot=b_;
    col=color(random(360), 100, 100);
  }
}

void seg_Gen(int num, int leng) {
  segs.clear();

  float segLeng=leng;

  for (int i=0; i<num; ) {
    PVector t1 = new PVector(random(10, width-10), random(10, height-10));
    PVector t2 = new PVector(random(10, width-10), random(10, height-10));

    float tLeng = PVector.sub(t1, t2).mag();

    if (tLeng<segLeng) {
    } else {
      if (t1.y<t2.y) {
        segs.add(new Seg(t1, t2));
      } else if (t1.y==t2.y) {
        if (t1.x<t2.x) {
          segs.add(new Seg(t1, t2));
        } else {
          segs.add(new Seg(t2, t1));
        }
      } else {
        segs.add(new Seg(t2, t1));
      }
      i++;
    }
  }
}