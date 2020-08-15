ArrayList<PVector[]> lines = new ArrayList<PVector[]>();
float angle = 0;
float viewAngle = 60;
PVector pos = new PVector(400,400);

void setup(){
  size(800,800);
  Init();
}

void keyPressed() {
  if (key == 'z') {
    viewAngle -= 1;
  } else if (key == 'x'){
    viewAngle += 1;
  } else if (key == 'e') {
    angle += 0.1;
  } else if (key == 'q'){
    angle -= 0.1;
  } else 
  {
    float dx = cos(angle)*10;
    float dy = sin(angle)*10;
    PVector dir = new PVector(dx,dy);
    if (key == 'w'){
      pos = pos.add(dir);
    } else if (key == 's'){
      pos = pos.sub(dir);
    } else 
    {
      dir = dir.rotate(HALF_PI);
      if (key == 'd')
      {
        pos = pos.add(dir);
      } else if (key == 'a'){
        pos = pos.sub(dir);
      }
    }
  }
}

float lineLength(float x1, float y1, float x2, float y2){ return sqrt(sq(x1 - x2) + sq(y1 - y2));}

float slope(float x1, float y1, float x2, float y2) { return (y2-y1)/(x2-x1); }

float pointToLineDistance(PVector p, PVector P0, PVector P1)
{
  float A = P0.y-P1.y;
  float B = P1.x-P0.x;
  float C = -A*P0.x-B*P0.y;
  float d = (abs(A*p.x + B*p.y + C))/(sqrt(sq(A)+sq(B)));
  float a = lineLength(p.x,p.y,P0.x,P0.y);
  float c = lineLength(p.x,p.y,P1.x,P1.y);
  float b = lineLength(P0.x,P0.y,P1.x,P1.y);
  float c1 = sq(a) + sq(b) - sq(c);
  float c2 = sq(c) + sq(b) - sq(a);
  boolean inside = c1 > 0 && c2 > 0;
  if (inside)
    return d;
   return min(a,c);
}

PVector DoesLinesIntersects(PVector l1p1, PVector l1p2, PVector l2p1, PVector l2p2)
{
    float s1_x, s1_y, s2_x, s2_y; //<>//
    s1_x = l1p2.x - l1p1.x;
    s1_y = l1p2.y - l1p1.y;
    s2_x = l2p2.x - l2p1.x;
    s2_y = l2p2.y - l2p1.y;

    float s, t;
    s = (-s1_y * (l1p1.x - l1p1.x) + s1_x * (l1p1.y - l1p1.y)) / (-s2_x * s1_y + s1_x * s2_y);
    t = ( s2_x * (l1p1.y - l2p1.y) - s2_y * (l1p1.x - l2p1.x)) / (-s2_x * s1_y + s1_x * s2_y);

    if (s >= 0 && s <= 1 && t >= 0 && t <= 1)
    {
      PVector r = new PVector(l1p1.x + (t * s1_x), l1p1.y + (t * s1_y));
      if (r.x < max(l2p1.x, l2p2.x) && r.x > min(l2p1.x, l2p2.x) && r.y < max(l2p1.y, l2p2.y) && r.y > min(l2p1.y, l2p2.y))
        return r;
    }
    return null;
}

float LineLength(PVector p0, PVector p1){ return sqrt(sq(p0.x - p1.x) + sq(p0.y - p1.y)); }

void InitLines(float x1, float y1, float x2, float y2)
{
  PVector p11 = new PVector(x1, y1);
  PVector p12 = new PVector(x2, y2);
  PVector[] ps = {p11,p12};
  lines.add(ps);
}

void Init()
{
  InitLines(30, 50, 750, 150);
  InitLines(600, 50, 601, 400);
}

void draw(){
  float[] zbuffer = new float[800];
  float x = pos.x;
  float y = pos.y;
  background(0);
  stroke(255,255,255);
  for (PVector[] p: lines)
  {
    PVector p1 = p[0];
    PVector p2 = p[1];
    for (int xx = -400; xx < 400; xx++)
    {
      //float a = (xx - 400)/400.0*viewAngle;
      //float ar = radians(a); //<>//
      //PVector p0 = new PVector(x, y);
      //pos = new PVector(10,10);
      float dx = cos(angle)*xx;
      float dy = sin(angle)*xx;
      PVector dir = new PVector(dx,dy);
      PVector dir2 = new PVector(cos(angle)*100,sin(angle)*100);
      PVector p01 = pos.copy().add(dir.copy().setMag(10));
      PVector p0 = pos.copy().add(dir.copy().rotate(HALF_PI));//new PVector(x + cos(angle)* xx, y + sin(angle)* xx);
      PVector p00 = p0.copy().add(dir2.copy().setMag(300));//pos.copy().add(dir.copy()).add(p0.copy());//p0.copy().add(p0.copy().rotate(-HALF_PI));//p0.copy().add(p0.copy().add(dir.copy().rotate(-HALF_PI).mult(15)));
      //println("pos", pos, "dir", dir, "dir2", dir2, "p0", p0, "p01", p01, "p00", p00);
      //PVector p00 = p0.copy().rotate(-HALF_PI).mult(10);// new PVector(x + cos(angle + ar)* 1000, y + sin(angle + ar)* 1000);
      //PVector p00 = new PVector(x + cos(angle + ar)* 1000, y + sin(angle + ar)* 1000);
      //println(a);
      //line(p0.x,p0.y,p00.x,p00.y);
      //PVector p00 = new PVector(xx, 0);
      //float d = pointToLineDistance(new PVector(x,y), new PVector(x1,y1), new PVector(x2,y2));
      PVector intersection = DoesLinesIntersects(p0,p00,p1,p2);
      if (intersection !=null)
      {
        float d = 200 - (LineLength(p0, intersection));
        if (zbuffer[xx + 400] < d)
          zbuffer[xx+400] = d;
      } 
    }
  }
  
  for (int xx = 0; xx < 800; xx++)
    {
      float d = zbuffer[xx];
      stroke(d,d,d);
      line(xx, 400 - d*2, xx, 400 + d*2);
      //println(d);
    }
  drawMinimap();
  //noLoop();
}

PVector offsetVector = new PVector(590,10);

PVector offset(PVector p)
{
  return p.copy().div(4).add(offsetVector);
}

void drawMinimap()
{
  stroke(255,255,255);
  fill(0);
  rect(590,10, 200, 200);
  for (PVector[] p: lines)
  {
    PVector p1 = offset(p[0]);
    PVector p2 = offset(p[1]);
    line(p1.x,p1.y,p2.x,p2.y);
  }
  PVector p = offset(pos);
  circle(p.x, p.y, 5);
  float x1 = p.x + 20 * cos(angle);
  float y1 = p.y + 20 * sin(angle);
  line(p.x,p.y,x1,y1);
  
}
