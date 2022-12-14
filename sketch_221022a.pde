public class Point {
  public float x, y;
  public Point(float x, float y) {
    this.x = x;
    this.y = y;
  }
}

public class LineSegment {
  Point p1, p2;
  public LineSegment(Point p1, Point p2) {
    this.p1 = p1;
    this.p2 = p2;
  }
  public void draw() {
    line(p1.x, p1.y, p2.x, p2.y);
  }
  public Line toLine() {
    return new Line(this);
  }
}

public class Line {
  float a;
  float b;
  float straightX;
  LineSegment originalSegment;
  public Line(float a, float b) {
    this.a = a;
    this.b = b;
  }
  public Line(LineSegment line) {
    float bottom = line.p2.x - line.p1.x;
    originalSegment = line;
    if (bottom >= 0.000003 || bottom <= -0.000003) {
      a = (line.p2.y - line.p1.y) / bottom;
    } else {
      a = Float.MAX_VALUE;
      straightX = line.p1.x;
    }
    b = line.p1.y - a * line.p1.x;
  }
  public void draw() {
    if (a >= Float.MAX_VALUE - 1.0) {
      line(straightX, -1000, straightX, 2000);
    } else {
      float tempX1 = -1000;
      float tempX2 = 2000;
      float tempY1 = a * tempX1 + b;
      float tempY2 = a * tempX2 + b;
      line(tempX1, tempY1, tempX2, tempY2);
    }
  }
}

float outer(Point p1, Point p2) {
  return p1.x * p2.y - p1.y * p2.x;
}
Point sub(Point p1, Point p2) {
  return new Point(p1.x - p2.x, p1.y - p2.y);
}
Point add(Point p1, Point p2) {
  return new Point(p1.x + p2.x, p1.y + p2.y);
}
boolean isSamePoint(Point p1, Point p2) {
  if (abs(p1.x - p2.x) <= 0.000003 && abs(p1.y - p2.y) <= 0.000003) {
    return true;
  }
  return false;
}
boolean intercept(LineSegment seg1, LineSegment seg2) {
  
  Point a = seg1.p1;
  Point b = seg1.p2;
  Point c = seg2.p1;
  Point d = seg2.p2;
  
  if (isSamePoint(a, c) || isSamePoint(a, d) || isSamePoint(b, c) || isSamePoint(b, d)) {
    return true;
  }
  
  Point ac = sub(c, a);
  Point cb = sub(b, c);
  float outerACCB = outer(ac, cb);
  
  Point ad = sub(d, a);
  Point db = sub(b, d);
  float outerADDB = outer(ad, db);
  
  Point bd = sub(d, b);
  float outerCBBD = outer(cb, bd);
  
  Point ca = sub(a, c);
  float outerCAAD = outer(ca, ad);
  
  if (isPositive(outerACCB) != isPositive(outerADDB) && isPositive(outerCBBD) != isPositive(outerCAAD)) {
    return true;
  }
  return false;
} 

boolean isPositive(float value) {
  if (value >= 0) {
    return true;
  } else {
    return false;
  }
}

Point interceptPoint(Line line1, Line line2) {
  float x = 0;
  float y = 0;
  
  if (isSamePoint(line1.originalSegment.p1, line2.originalSegment.p1)) {
    return line1.originalSegment.p1;
  }
  if (isSamePoint(line1.originalSegment.p1, line2.originalSegment.p2)) {
    return line1.originalSegment.p1;
  }
  if (isSamePoint(line1.originalSegment.p2, line2.originalSegment.p1)) {
    return line1.originalSegment.p2;
  }
  if (isSamePoint(line1.originalSegment.p2, line2.originalSegment.p2)) {
    return line1.originalSegment.p2;
  }
  if (line1.b == Float.POSITIVE_INFINITY || line1.b == Float.NEGATIVE_INFINITY) {
    x = line1.originalSegment.p1.x;
    y = line2.a * x + line2.b;
  } else {
    x = (line2.b - line1.b) / (line1.a - line2.a);
    y = line1.a * x + line1.b;
  }
  if (line2.b == Float.POSITIVE_INFINITY || line2.b == Float.NEGATIVE_INFINITY) {
    x = line2.originalSegment.p1.x;
    y = line1.a * x + line1.b;
  } else {
    x = (line2.b - line1.b) / (line1.a - line2.a);
    y = line1.a * x + line1.b;
  }
  return new Point(x, y);
}

LineSegment lineSeg1;
LineSegment lineSeg2;

Line line1;
Line line2;

void setup() {
  size(1000, 1000);
  lineSeg1 = new LineSegment(new Point(500, 500), new Point(300, 400));
  lineSeg2 = new LineSegment(new Point(250, 350), new Point(150, 450));
  line1 = new Line(lineSeg1);
  line2 = new Line(lineSeg2);
}

void draw() {
  clear();
  stroke(255, 255, 255);
  lineSeg1.p2 = new Point(mouseX, mouseY);
  float elapsed = float(millis()) / 3000.0;
  float movingX = cos(elapsed) * 400;
  float movingY = sin(elapsed) * 400;
  float smallMovingX = cos(elapsed * 5);
  float smallMovingY = cos(elapsed * 5);
  lineSeg2.p1.x = 500 + movingX + cos(smallMovingX) * 100;
  lineSeg2.p1.y = 500 + movingY + sin(smallMovingY) * 100;
  lineSeg2.p2.x = 500 + movingX + cos(smallMovingX + PI) * 100;
  lineSeg2.p2.y = 500 + movingY + sin(smallMovingY + PI) * 100;
  stroke(50, 50, 50);
  lineSeg1.toLine().draw();
  lineSeg2.toLine().draw();
  if (intercept(lineSeg1, lineSeg2)) {
    stroke(0, 255, 255);
  } else {
    stroke(255, 255, 255);
  }
  lineSeg1.draw();
  lineSeg2.draw();
  
  line1 = lineSeg1.toLine();
  line2 = lineSeg2.toLine();
  
  Point inter = interceptPoint(line1, line2);
  fill(255, 255, 0);
  noStroke();
  circle(inter.x, inter.y, 3);
  
  fill(255, 255, 255);
  text("line1: a: " + str(line1.a) + " b: " + str(line1.b), 10, 15);
  text("line2: a: " + str(line2.a) + " b: " + str(line2.b), 10, 30);
  text("intercepting point x: " + str(inter.x), 10, 45);
  text("intercepting point y: " + str(inter.y), 10, 60);
  
  /*test*/
  //clear();
  //LineSegment seg1 = new LineSegment(new Point(100, 100), new Point(300, 300));
  //LineSegment seg2 = new LineSegment(new Point(100, 400), new Point(200, 300));
  //stroke(50, 50, 50);
  //seg1.toLine().draw();
  //seg2.toLine().draw();
  //if (intercept(seg1, seg2)) {
  //  stroke(0, 255, 255);
  //} else {
  //  stroke(255, 255, 255);
  //}
  //seg1.draw();
  //seg2.draw();
  //Line tempLine1 = seg1.toLine();
  //Line tempLine2 = seg2.toLine();
  //Point inter = interceptPoint(tempLine1, tempLine2);
  //fill(255, 255, 0);
  //noStroke();
  //circle(inter.x, inter.y, 3);
}
