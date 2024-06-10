Table table;
int canvasWidth = 1312;
int canvasHeight = 820;
int[] years = {1970, 1980, 1990, 2000, 2010};
String[] labels = {"Pre-1970", "1970s", "1980s", "1990s", "2000s", "2010s"};
int[] colors = {
  #D5D5D5, 
  #9BFFBA, 
  #ffe7a1, 
  #ffc5ee, 
  #b0faff, 
  #846cf9  
};


int[] text_colors = {
  #b0b0b0, 
  #87d5ac, 
  #e7c854, 
  #d69ccd, 
  #71e3ca, 
  #846cf9  
};
int LancircleDiameter = 55;
int circleDiameter = 35;

PFont label_font, basic_font_font;
PImage c_img, cpp_img, css_img, java_img, csharp_img, js_img, kotlin_img, go_img, php_img, python_img, ruby_img, rust_img, scala_img, sql_img, swift_img, ts_img, r_img, matlab_img, perl_img, fortran_img, pascal_img;
PVector p1, p2, p3;
color startColor, endColor;

// 언어 원의 위치와 크기를 저장할 리스트
ArrayList<LanguageCircle> languageCircles = new ArrayList<LanguageCircle>();


ArrayList<Circle> timelineCircles = new ArrayList<Circle>();

void setup() {
  size(1312, 820);
  background(255);
  
  // 글꼴 설정
  label_font = createFont("Helvetica-Black", 27);
  basic_font_font = createFont("Produkt", 24);
  
  // 언어 아이콘 이미지 불러오기
  c_img = loadImage("C.png");
  cpp_img = loadImage("C++.png");
  css_img = loadImage("CSS.png");
  java_img = loadImage("Java.png");
  csharp_img = loadImage("C#.png");
  js_img = loadImage("Javascript.png");
  kotlin_img = loadImage("Kotlin.png");
  go_img = loadImage("Go.png");
  php_img = loadImage("PHP.png");
  python_img = loadImage("Python.png");
  ruby_img = loadImage("Ruby.png");
  rust_img = loadImage("Rust.png");
  scala_img = loadImage("Scala.png");
  sql_img = loadImage("SQL.png");
  swift_img = loadImage("Swift.png");
  ts_img = loadImage("TypeScript.png");
  r_img = loadImage("R.png");
  matlab_img = loadImage("MATLAB.png");
  perl_img = loadImage("Perl.png");
  fortran_img = loadImage("FORTRAN.png");
  pascal_img = loadImage("Pascal.png");

  // CSV 파일을 읽어오기
  table = loadTable("Best20_sorted_updated.csv", "header");

  // 타임라인 원을 초기화
  initTimelineCircles();

  // 각 언어를 타임라인에 배치
  drawLanguages();
}

void initTimelineCircles() {
  int margin = 100;
  int startX = margin;
  int endX = width - margin;
  int yPosition = height / 2;
  int segmentLength = (int)((endX - startX) / labels.length);

  for (int i = 0; i < labels.length; i++) {
    int xPosition = startX + i * segmentLength;
    Circle circle = new Circle(xPosition, yPosition, circleDiameter, colors[i], labels[i]);
    timelineCircles.add(circle);
  }
}

void drawTimeline() {
  int margin = 100;
  int startX = margin;
  int endX = width - margin;
  int yPosition = height / 2;
  int segmentLength = (int)((endX - startX) / labels.length);

  // 메인 타임라인 선 그리기
  noStroke();
  //strokeWeight(10);
  //line(startX, yPosition, endX, yPosition);
  fill(200, 199, 199, 20);
  rect(0, yPosition-38/2, width, 38);
  for(int i=0; i<colors.length;i++) {
    fill(colors[i]);
    rect(startX + i*segmentLength, yPosition-38/2, segmentLength, 38);
  }
  //triangle(startX + (colors.length)*segmentLength, yPosition-38/2, startX + (colors.length)*segmentLength, yPosition+38/2, startX + (colors.length)*segmentLength + 50, yPosition);
  p3 = new PVector(startX + (colors.length)*segmentLength, yPosition-38/2);
  p2 = new PVector(startX + (colors.length)*segmentLength, yPosition+38/2);
  p1 = new PVector(startX + (colors.length)*segmentLength+50, yPosition);
  drawGradientTriangle(p1, p2, p3, colors[2], colors[colors.length-1]);
  
  
  
  for (Circle circle : timelineCircles) {
    circle.drawCircle();
  }
}

void drawGradientTriangle(PVector p1, PVector p2, PVector p3, color startColor, color endColor) {
  float steps = 100; // Number of steps for gradient
  for (int i = 0; i <= steps; i++) {
    float t = map(i, 0, steps, 0, 1);
    color interColor = lerpColor(startColor, endColor, t);
    
    PVector interP1 = PVector.lerp(p1, p2, t);
    PVector interP2 = PVector.lerp(p1, p3, t);
    
    noStroke();
    fill(interColor);
    beginShape();
    vertex(interP1.x, interP1.y);
    vertex(interP2.x, interP2.y);
    vertex(p3.x, p3.y);
    vertex(p2.x, p2.y);
    endShape(CLOSE);
  }
}


void drawLanguages() {
  int margin = 100;
  int startX = margin;
  int endX = width - margin;
  int yPosition = height / 2;
  int segmentLength = (endX - startX) / labels.length;

  // 각 시대별 언어 수를 세어 X 간격을 설정합니다
  int[] decadeCounts = new int[labels.length];
  for (TableRow row : table.rows()) {
    int year = row.getInt("Year");
    int decadeIndex = getDecadeIndex(year);
    decadeCounts[decadeIndex]++;
  }

  float[] decadeOffsets = new float[labels.length];  
  for (int i = 0; i < labels.length; i++) {
    decadeOffsets[i] = segmentLength / (decadeCounts[i] + 1);
  }

  int[] langYPositions = {220, -250, 250, -180, 190, -137, 100, 225, -146, 193, -132, 242, -229, 169, -299, 288, -208, -139, 159, -221, -102, 158, 272, -264};

  int langIndex = 0;

  for (TableRow row : table.rows()) {
    int year = row.getInt("Year");
    String name = row.getString("Name");

    int decadeIndex = getDecadeIndex(year);
    float xPosition = startX + decadeIndex * segmentLength + decadeOffsets[decadeIndex];
    int langYPos = yPosition + langYPositions[langIndex++]; // langYPos 값을 직접 설정합니다.
    decadeOffsets[decadeIndex] += segmentLength / (decadeCounts[decadeIndex] + 1);

    // 타임라인과 연결 선을 그리기
    stroke(colors[decadeIndex]);
    strokeWeight(4);
    line(xPosition, yPosition, xPosition, langYPos);

    // 언어 원을 그리고 리스트에 저장
    LanguageCircle circle = new LanguageCircle(xPosition, langYPos, LancircleDiameter, colors[decadeIndex], name);
    languageCircles.add(circle);
    circle.draww();
  }
}

int getDecadeIndex(int year) {
  if (year < 1970) return 0;
  else if (year < 1980) return 1;
  else if (year < 1990) return 2;
  else if (year < 2000) return 3;
  else if (year < 2010) return 4;
  else return 5;
}

int getDecadeIndexByLabel(String label) {
  for (int i = 0; i < labels.length; i++) {
    if (labels[i].equals(label)) {
      return i;
    }
  }
  return -1;
}

void draw() {
  background(250);
  

  // 언어 원 그리기
  for (LanguageCircle circle : languageCircles) {
    circle.draww();
  }
  
  // 타임라인 그리기
  drawTimeline();

  // 모든 언어 원을 그린 후에 카드 그리기
  for (LanguageCircle circle : languageCircles) {
    if (circle.isCardVisible && circle.card != null) {
      circle.card.display();
    }
  }
}

void mouseMoved() {
  for (LanguageCircle circle : languageCircles) {
    circle.checkMouseOver();
    circle.hideCardIfMouseOutside();
  }
  for (Circle circle : timelineCircles) {
    circle.checkMouseOver();
  }
}

void mouseClicked() {
  for (LanguageCircle circle : languageCircles) {
    if (circle.isMouseOver) {
      circle.openLanguageWindow();
    }
  }
}
