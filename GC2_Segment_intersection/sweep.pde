class Vertex {
  PVector loc;
  char attr;  // 't',stands for top , 'b',stands for bottom, 'c',stands for crossPoint(intersection Point)
  int index; // inside of the segs list

  Vertex(PVector loc_, char attr_, int index_) {
    loc=loc_;
    attr=attr_;
    index=index_;
  }
}

class Sweep {
  ArrayList<Vertex> target=new ArrayList<Vertex>();
  ArrayList<Integer> onLine=new ArrayList<Integer>(); //contain v's index
  ArrayList<PVector> intersection=new ArrayList<PVector>(); //to save final result.

  PVector nowSweep=new PVector(0, 0);

  Sweep(ArrayList<Seg> segs_) {
    int i=0;
    for (Seg s : segs_) {
      target.add(new Vertex(s.top, 't', i));
      target.add(new Vertex(s.bot, 'b', i));
      i++;
    }

    target = align(target);
  }

  ArrayList<Vertex> align(ArrayList<Vertex> list) {

    ArrayList<Vertex> temp=new ArrayList<Vertex>();

    temp.add(list.get(0));

    for (int i=0; i<list.size()-1; i++) {

      Vertex now = temp.get(i);
      Vertex next =list.get(i+1);

      if (next.loc.y > now.loc.y) {
        temp.add(next);
      } else if ((next.loc.y == now.loc.y) && (next.loc.x > now.loc.x)) {
        temp.add(next);
      } else {
        for (int j=0; j<=i; j++) {
          Vertex prev = temp.get(j);

          if ((prev.loc.y > next.loc.y)||((prev.loc.y==next.loc.y)&&(prev.loc.x > next.loc.x))) {
            temp.add(j, next);
            break;
          }
        }
      }
    }

    return temp;
  }

  boolean moveNext() {
    
    if (target.isEmpty()==false) {
      nowSweep = target.get(0).loc;
      update(target.get(0));
      target.remove(0);
      //for (int i=0; i<onLine.size(); i++) {
      //  print(onLine.get(i)+" ");
      //}
      //println();
      return false;
    }else{
      return true;
    }
  }

  void update(Vertex v) {
    if (v.attr=='t') {
      if (onLine.isEmpty()==true) {
        onLine.add(v.index);
      } else {
        int prevSize = onLine.size();
        for (int i=0; i<prevSize; i++) {
          if (v.loc.x < getX(segs.get(onLine.get(i)), v.loc.y)) {
            onLine.add(i, v.index);
            nearest_CollideCheck(i);
            return;
          }
        }
        if (onLine.size()==prevSize) {
          onLine.add(prevSize, v.index);
          nearest_CollideCheck(prevSize);
        }
      }
    } else if (v.attr=='b') {
      for (int i=0; i<onLine.size(); i++) {    

        if (onLine.get(i)==v.index) {
          onLine.remove(i);
          if (onLine.size()>=2 && (i>=1 && i<=onLine.size()-1) )
            bothside_CollideCheck(i-1, i);
          break;
        }
      }
    } else if (v.attr=='c') {
      intersect_CollideCheck(v);
    }
  }

  void nearest_CollideCheck(int i) {
    if (i-1>=0) {
      PVector intersectV = intersect(segs.get(onLine.get(i-1)), segs.get(onLine.get(i)));
      if (intersectV!=null && intersectV.y>nowSweep.y) {
        int prev=target.size();
        for (int j=0; j<target.size(); j++) {
          if (intersectV.y<target.get(j).loc.y ||(intersectV.y==target.get(j).loc.y && intersectV.x<target.get(j).loc.x)) {
            if (targetContain(intersectV)==false)
              target.add(j, new Vertex(intersectV, 'c', -100));
            break;
          }
        }

        if (target.size() == prev) {
          if (targetContain(intersectV)==false)
            target.add(new Vertex(intersectV, 'c', -100));
        }
      }
    }

    if (i+1 <= onLine.size()-1) {
      PVector intersectV = intersect(segs.get(onLine.get(i)), segs.get(onLine.get(i+1)));
      if (intersectV!=null && intersectV.y>nowSweep.y) {
        int prev=target.size();
        for (int j=0; j<target.size(); j++) {
          if (intersectV.y<target.get(j).loc.y ||(intersectV.y==target.get(j).loc.y && intersectV.x<target.get(j).loc.x)) {
            if (targetContain(intersectV)==false)
              target.add(j, new Vertex(intersectV, 'c', -100));
            break;
          }
        }

        if (target.size() == prev) {
          if (targetContain(intersectV)==false)
            target.add(new Vertex(intersectV, 'c', -100));
        }
      }
    }
  }

  void bothside_CollideCheck(int i1, int i2) {
    PVector intersectV = intersect(segs.get(onLine.get(i1)), segs.get(onLine.get(i2)));
    if (intersectV!=null && intersectV.y>nowSweep.y) {
      int prev=target.size();
      for (int j=0; j<target.size(); j++) {
        if (intersectV.y<target.get(j).loc.y ||(intersectV.y==target.get(j).loc.y && intersectV.x<target.get(j).loc.x)) {
          if (targetContain(intersectV)==false)
            target.add(j, new Vertex(intersectV, 'c', -100));
          break;
        }
      }

      if (target.size() == prev) {
        if (targetContain(intersectV)==false)
          target.add(new Vertex(intersectV, 'c', -100));
      }
    }
  }

  void intersect_CollideCheck(Vertex v) {
    boolean already=false;
    for (PVector vec : intersection) {
      if (vec.dist(v.loc)==0) {
        already=true;
        break;
      }
    }
    if(!already)
    intersection.add(v.loc);

    int start=-1;
    int howMany=0;

    for (int i=0; i<onLine.size(); i++) {
      if (abs(getX(segs.get(onLine.get(i)), nowSweep.y)-v.loc.x)<0.01) {
        if (start==-1) {
          start=i;
        }
        howMany++;
      } else if (start!=-1) {
        break;
      }
    }

    ArrayList<Integer> temp=new ArrayList<Integer>();

    for (int i=start; i<start+howMany; i++) {
      temp.add(0, onLine.get(start));
      onLine.remove(start);
    }

    onLine.addAll(start, temp);

    int moLeft=start;
    int moRight=start+howMany-1;

    if (moLeft>=1) {     
      PVector intersectV = intersect(segs.get(onLine.get(moLeft-1)), segs.get(onLine.get(moLeft)));
      if (intersectV!=null && intersectV.y>nowSweep.y) {
        int prev = target.size();
        for (int j=0; j<target.size(); j++) {
          if (intersectV.y<target.get(j).loc.y || (intersectV.y==target.get(j).loc.y && intersectV.x<target.get(j).loc.x)) {
            if (targetContain(intersectV)==false)
              target.add(j, new Vertex(intersectV, 'c', -100));
            break;
          }
        }

        if (target.size() ==prev) {
          if (targetContain(intersectV)==false)
            target.add(new Vertex(intersectV, 'c', -100));
        }
      }
    }

    if (moRight <=onLine.size()-2) {
      PVector intersectV = intersect(segs.get(onLine.get(moRight)), segs.get(onLine.get(moRight+1)));
      if (intersectV!=null && intersectV.y>nowSweep.y) {
        int prev = target.size();
        for (int j=0; j<target.size(); j++) {
          if (intersectV.y<target.get(j).loc.y || (intersectV.y==target.get(j).loc.y && intersectV.x<target.get(j).loc.x)) {
            if (targetContain(intersectV)==false)
              target.add(j, new Vertex(intersectV, 'c', -100));
            break;
          }
        }

        if (target.size() ==prev) {
          if (targetContain(intersectV)==false)
            target.add(new Vertex(intersectV, 'c', -100));
        }
      }
    }
  }

  boolean targetContain(PVector vec) {
    boolean contain=false;

    for (int i=0; i<target.size(); i++) {
      if (target.get(i).loc.dist(vec)==0) {
        contain=true;
        return contain;
      }
    }

    return contain;
  }

  float getX(Seg s, float y) {
    PVector a = PVector.sub(s.bot, s.top);
    return s.top.x+(a.x/a.y)*(y-s.top.y);
  }

  PVector intersect(Seg seg1, Seg seg2) {
    PVector p1=PVector.sub(seg1.bot, seg1.top);
    PVector p2=PVector.sub(seg2.bot, seg2.top);

    float x = (p1.y*p2.x*seg1.top.x - p1.x*p2.y*seg2.top.x + p1.x*p2.x*seg2.top.y - p1.x*p2.x*seg1.top.y) / (p1.y*p2.x - p1.x*p2.y);

    float bool1 = (seg1.top.x-x)*(seg1.bot.x-x);
    float bool2 = (seg2.top.x-x)*(seg2.bot.x-x);


    if (bool1<=0 && bool2<=0) {
      float y=(p1.y/p1.x)*(x-seg1.top.x)+seg1.top.y;
      return new PVector(x, y);
    } else {
      return null;
    }
  }
}