ArrayList<PVector[]> lines = new ArrayList<PVector[]>();
float angle = -HALF_PI;
int viewAngleBase = 10;
int viewAngle = 100;
int viewDistance = 400;
PVector pos = new PVector(425,425);

void setup(){
  size(800,800);
  Init();
}

void keyPressed() {
  if (key == 'z') {
    viewAngle -= 1;
  } else if (key == 'x'){
    viewAngle += 1;
  } else if (key == 'c') {
    viewAngleBase -= 1;
  } else if (key == 'v'){
    viewAngleBase += 1;
  } if (key == 'b') {
    viewDistance -= 1;
  } else if (key == 'n'){
    viewDistance += 1;
  } else if (key == 'e') {
    angle += 0.05;
  } else if (key == 'q'){
    angle -= 0.05;
  } else 
  {
    float dx = cos(angle)*2;
    float dy = sin(angle)*2;
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
  float[] abc = lineABC(P0,P1);
  float A = abc[0];
  float B = abc[1];
  float C = abc[2];
  float d = (abs(A*p.x + B*p.y + C))/(sqrt(sq(A)+sq(B)));
  float a = lineLength(p.x,p.y,P0.x,P0.y);
  float c = lineLength(p.x,p.y,P1.x,P1.y);
  float b = lineLength(P0.x,P0.y,P1.x,P1.y);
 
  if (IsInside(p,P0,P1))
    return d;
   return min(a,c);
}

float[] lineABC(PVector P0, PVector P1)
{
  float A = P0.y-P1.y;
  float B = P1.x-P0.x;
  float C = -A*P0.x-B*P0.y;
  return new float[]{A,B,C}; 
}

boolean IsInside(PVector p, PVector P0, PVector P1)
{
  float a = lineLength(p.x,p.y,P0.x,P0.y);
  float c = lineLength(p.x,p.y,P1.x,P1.y);
  float b = lineLength(P0.x,P0.y,P1.x,P1.y);
  float c1 = sq(a) + sq(b) - sq(c);
  float c2 = sq(c) + sq(b) - sq(a);
  return c1 > 0 && c2 > 0;
} //<>//

PVector DoesLinesIntersects2(PVector l1p1, PVector l1p2, PVector l2p1, PVector l2p2)
{
  float[] abc1 = lineABC(l1p1, l1p2);
  float[] abc2 = lineABC(l2p1, l2p2);
  float a1 = abc1[0];
  float a2 = abc2[0];
  float b1 = abc1[1];
  float b2 = abc2[1];
  float c1 = abc1[2];
  float c2 = abc2[2];
  float x = (b1*c2 - b2*c1)/(a1*b2-a2*b1);
  float y = (a2*c1-a1*c2)/(a1*b2-a2*b1);
  PVector p = new PVector(x,y);
  if (IsInside(p,l1p1,l1p2) && IsInside(p,l2p1,l2p2))
    return p;
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
  InitLines(0, 0, 800, 0);
  InitLines(0, 0, 0, 800);
  InitLines(800, 0, 800, 800);
  InitLines(0, 800, 800, 800);
  
  InitLines(300, 300, 400, 300);
  InitLines(350, 250, 350, 350);
  
  InitLines(600, 500, 700, 500);
  InitLines(600, 500, 650, 550);
  InitLines(650, 550, 700, 500);
  
  InitLines(100, 400, 200, 300);
  InitLines(200, 300, 300, 400);
  
  InitLines(200, 500, 300, 700);
  
  InitLines(400, 400, 450, 400);
  InitLines(500, 400, 550, 400);
  InitLines(400, 400, 400, 500);
  InitLines(550, 400, 550, 500);
  InitLines(400, 500, 550, 500);
}

void draw(){
  float[] zbuffer = new float[800];
  float x = pos.x;
  float y = pos.y;
  background(0);
  noStroke();
  fill(100,100,255);
  rect(0,0,800,400);
  fill(100,255,100);
  rect(0,400,800,800);
  stroke(255,255,255);
  float dva = (viewAngleBase*1.0)/viewAngle;
  float dxx = viewAngle*10.0/zbuffer.length;
  for (PVector[] p: lines)
  {
    PVector p1 = p[0];
    PVector p2 = p[1];
    
    for (int xx = -viewAngle*5; xx < viewAngle*5; xx++)
    {
      //println(xx*dva);
      PVector pos0 = new PVector((xx/5.0)*dva,0);
      PVector pos1 = new PVector((xx/5.0), viewDistance);      
      pos0.rotate(angle - HALF_PI).add(pos);
      pos1.rotate(angle - HALF_PI).add(pos);
      
      //line(pos0.x, pos0.y, pos1.x, pos1.y);
      PVector intersection = DoesLinesIntersects2(pos0, pos1,p1,p2);
      if (intersection !=null)
      {
        float d = LineLength(pos0, intersection);
        float zbv = zbuffer[(int)((xx+viewAngle*5) / dxx)];
        if (zbv < 0.01 || zbv > d)
          zbuffer[(int)((xx+viewAngle*5) / dxx)] = d;
      } 
    }
    //stroke(255,255,0);
    //line(p1.x,p1.y,p2.x,p2.y);
  }
  stroke(255,255,255);
  
  for (int xx = -viewAngle*5; xx < viewAngle*5; xx++)
    {
      int xc = (int)((xx+viewAngle*5)/dxx);
      //println(xc);
      float d = viewDistance - zbuffer[xc]; //<>//
      stroke(d,d,d);
      if (zbuffer[xc] > 0 )
        line(800 - xc, 400 - d, 800 - xc, 400 + d);
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
