Table table, timelineTable;
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

PFont label_font, basic_font;
PImage c_img, cpp_img, css_img, java_img, csharp_img, js_img, kotlin_img, go_img, php_img, python_img, ruby_img, rust_img, scala_img, sql_img, swift_img, ts_img, r_img, matlab_img, perl_img, fortran_img, pascal_img;
PVector p1, p2, p3;
color startColor, endColor;

// 언어 원의 위치와 크기를 저장할 리스트
ArrayList<LanguageCircle> languageCircles = new ArrayList<LanguageCircle>();

// Circle 객체 리스트를 추가합니다.
ArrayList<Circle> timelineCircles = new ArrayList<Circle>();


boolean timelineCirclesClicked = false;
boolean isAnimating = false;
boolean animationUp = true;
float timelineYPosition = height / 2;
float targetYPosition = height/2;
float animationSpeed = 18;


PVector[] sectionBounds = new PVector[labels.length];
ArrayList<DynamicLanguageCircle> dynamicCircles = new ArrayList<DynamicLanguageCircle>();
DynamicLanguageCircle draggedCircle = null;
PVector lastMousePos;
PVector mouseVelocity;

void setup() {
  size(1312, 820);
  background(255);
  
  
  // 글꼴 설정
  label_font = createFont("Helvetica-Black", 27);
  basic_font = createFont("Produkt", 24);
  
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

  // CSV 파일을 읽습니다
  table = loadTable("Best20_sorted_updated.csv", "header");
  timelineTable = loadTable("Timeline_of_programming_languages.csv", "header");

  // 타임라인 원을 초기화합니다
  initTimelineCircles();

  // 각 언어를 타임라인에 배치합니다
  drawLanguages();
  
  // 초기화 부분 추가
  timelineYPosition = height / 2;
  
  
  initSectionBounds();
  // Initialize dynamic circles
  initDynamicCircles();
}

void initSectionBounds() {
  int margin = 70;
  int startX = margin;
  int endX = width - margin;
  int segmentLength = (endX - startX) / 5;  // 5 sections for 2-year periods

  for (int i = 0; i < 5; i++) {
    float x1 = startX + i * segmentLength;
    float x2 = startX + (i + 1) * segmentLength;
    sectionBounds[i] = new PVector(x1, x2);
  }
}

void initDynamicCircles() {
  dynamicCircles.clear(); // Clear previous circles
  int baseYear = getBaseYearForDecade(selectedDecade);

  for (TableRow row : timelineTable.rows()) {
    String name = row.getString("Name");
    int year = row.getInt("Year");
    
    int sectionIndex;
    if (selectedDecade.equals("Pre-1970") && year <= 1961) {
      sectionIndex = 0;
    } else if (selectedDecade.equals("2010s") && year >= 2018) {
      sectionIndex = 4;
    } else {
      if (year < baseYear || year >= baseYear + 10) continue; // Skip if year is not within the selected decade
      sectionIndex = (year - baseYear) / 2;
    }
    
    if (sectionIndex < 0 || sectionIndex >= 5) continue;  // Skip if out of bounds

    float x = random(sectionBounds[sectionIndex].x, sectionBounds[sectionIndex].y);
    float y = random(120, height - 120);
    int circleColor = getColorByDecade(year);

    dynamicCircles.add(new DynamicLanguageCircle(x, y, 18, circleColor, name, sectionIndex));
  }
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

color darkenColor(color c, float factor) {
  float r = red(c) * factor;
  float g = green(c) * factor;
  float b = blue(c) * factor;
  return color(r, g, b);
}

void drawTimeline() {
  int margin = 100;
  int startX = margin;
  int endX = width - margin;
  int segmentLength = (endX - startX) / labels.length;

  // Adjust yPosition based on animation
  int yPosition = (int) timelineYPosition;

  // 메인 타임라인 선을 그립니다
  noStroke();
  fill(200, 199, 199, 20);
  rect(0, yPosition - 38 / 2, width, 38);
  
  
  for (int i = 0; i < colors.length; i++) {
    if (timelineCirclesClicked && !selectedDecade.equals(labels[i])) {
      fill(darkenColor(colors[i], 0.5)); // 명암을 낮춘 색상
    } else {
      fill(colors[i]); // 원래 색상
    }
    rect(startX + i * segmentLength, yPosition - 38 / 2, segmentLength, 38);
  }
  
  p3 = new PVector(startX + (colors.length) * segmentLength, yPosition - 38 / 2);
  p2 = new PVector(startX + (colors.length) * segmentLength, yPosition + 38 / 2);
  p1 = new PVector(startX + (colors.length) * segmentLength + 50, yPosition);
  drawGradientTriangle(p1, p2, p3, colors[2], colors[colors.length - 1]);

  color startGradientColor = colors[2];
  color endGradientColor = colors[colors.length - 1];

  if (timelineCirclesClicked && !selectedDecade.equals(labels[labels.length - 1])) {
    startGradientColor = darkenColor(startGradientColor, 0.5);
    endGradientColor = darkenColor(endGradientColor, 0.5);
  }

  drawGradientTriangle(p1, p2, p3, startGradientColor, endGradientColor);

  for (Circle circle : timelineCircles) {
    circle.y = yPosition;
    circle.drawCircle();
  }
  
  // 타임라인 레이블 그리기
  textAlign(CENTER);
  textFont(label_font);
  for (int i = 0; i < labels.length; i++) {
    float xPosition =  startX+ i * segmentLength ;
    if (timelineCirclesClicked && !selectedDecade.equals(labels[i])) {
      fill(darkenColor(text_colors[i], 0.5)); // 명암을 낮춘 텍스트 색상
    } else {
      fill(text_colors[i]); // 원래 텍스트 색상
    }
    text(labels[i], xPosition, yPosition + circleDiameter + 17);
  }
  
  //textFont(label_font);
  //textSize(25);
  //textAlign(CENTER);
  //fill(0);
  //text("Timeline of Programming Languages", width/2, height/2);
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

  // 각 시대별 언어의 X 오프셋을 설정합니다
  float[] decadeOffsets = new float[labels.length];  // 각 시대별 X 오프셋 초기화
  for (int i = 0; i < labels.length; i++) {
    decadeOffsets[i] = segmentLength / (decadeCounts[i] + 1);
  }

  // 각 언어에 대한 langYPos 값을 설정합니다.
  int[] langYPositions = {220, -250, 250, -180, 190, -137, 100, 225, -146, 193, -132, 242, -229, 169, -299, 288, -208, -139, 159, -221, -102, 158, 272, -264};

  // 언어에 대한 인덱스를 초기화합니다.
  int langIndex = 0;

  for (TableRow row : table.rows()) {
    int year = row.getInt("Year");
    String name = row.getString("Name");

    int decadeIndex = getDecadeIndex(year);
    float xPosition = startX + decadeIndex * segmentLength + decadeOffsets[decadeIndex];
    int langYPos = yPosition + langYPositions[langIndex++]; // langYPos 값을 직접 설정합니다.
    decadeOffsets[decadeIndex] += segmentLength / (decadeCounts[decadeIndex] + 1);

    // 타임라인과 연결 선을 그립니다
    stroke(colors[decadeIndex]);
    strokeWeight(4);
    line(xPosition, yPosition, xPosition, langYPos);

    // 언어 원을 그리고 리스트에 저장합니다
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

  // 애니메이션 처리
  if (isAnimating) {
    if (animationUp) {
      if (timelineYPosition > targetYPosition) {
        timelineYPosition -= animationSpeed;
      } else {
        timelineYPosition = targetYPosition;
        isAnimating = false;
      }
    } else {
      if (timelineYPosition < height / 2) {
        timelineYPosition += animationSpeed;
      } else {
        timelineYPosition = height / 2;
        isAnimating = false;
        timelineCirclesClicked = false;  // 언어 원과 연결선이 뜨도록 설정
      }
    }
  }

  // 타임라인 원이 클릭되지 않았거나 애니메이션이 끝난 경우에만 언어 원과 연결선 그리기
  if (!timelineCirclesClicked && !isAnimating) {
    for (LanguageCircle circle : languageCircles) {
      circle.draww();
    }
  }

  // 타임라인 그리기
  drawTimeline();

  // 작은 원들의 카드들을 저장할 리스트
  ArrayList<Card> visibleCards = new ArrayList<Card>();

  if (timelineCirclesClicked && !isAnimating && timelineYPosition == targetYPosition) {
    for (DynamicLanguageCircle circle : dynamicCircles) {
      circle.update();
      circle.display();

      if (circle.isCardVisible && circle.card != null) {
        visibleCards.add(circle.card);
      }
    }
  }

  // 타임라인이 완전히 올라간 상태에서만 세로선을 그리기
  if (timelineCirclesClicked && !isAnimating && timelineYPosition == targetYPosition) {
    drawVerticalLines();
  }

  // 모든 언어 원을 그린 후에 카드 그리기
  if (!timelineCirclesClicked) {
    for (LanguageCircle circle : languageCircles) {
      if (circle.isCardVisible && circle.card != null) {
        circle.card.display();
      }
    }
  }

  // 저장된 작은 원들의 카드들을 마지막에 그리기
  for (Card card : visibleCards) {
    card.display();
  }
  
  
}


void drawVerticalLines() {
  int numDivisions = 5;
  float divisionWidth = (width - 140) / (float) numDivisions;
  
  stroke(0);  // 검은색 선
  strokeWeight(0.1);  // 얇은 선
  line(70, 120, 70, height-20);
  line(width - 70, 120, width - 70, height-20);
  for (int i = 1; i < numDivisions; i++) {
    float x = 70 + i * divisionWidth;
    line(x, 120, x, height-20);
  }

  // 각 칸의 아래쪽 정중앙에 연도 범위 표시
  String[] yearRanges = getYearRangesForDecade();
  int colorIndex = getDecadeIndexByLabel(selectedDecade);
  fill(text_colors[colorIndex]);
  textFont(label_font);
  textAlign(CENTER);
  for (int i = 0; i < numDivisions; i++) {
    float x = 70 + i * divisionWidth + divisionWidth / 2;
    text(yearRanges[i], x, height - 20);  // height - 20 위치에 텍스트 표시
  }
}

String[] getYearRangesForDecade() {
  String[] yearRanges = new String[5];
  int baseYear = getBaseYearForDecade(selectedDecade); // 선택된 시대의 시작 연도 계산
  for (int i = 0; i < 5; i++) {
    int startYear = baseYear + (i * 2);
    int endYear = startYear + 1;
    
    if (selectedDecade.equals("Pre-1970") && i == 0) {
      yearRanges[i] = "1804~1961";
    } else if (selectedDecade.equals("2010s") && i == 4) {
      yearRanges[i] = "2018~2024";
    } else {
      yearRanges[i] = startYear + "~" + endYear;
    }
  }
  return yearRanges;
}

int getBaseYearForDecade(String decadeLabel) {
  switch (decadeLabel) {
    case "Pre-1970": return 1960;
    case "1970s": return 1970;
    case "1980s": return 1980;
    case "1990s": return 1990;
    case "2000s": return 2000;
    case "2010s": return 2010;
    default: return 1970;
  }
}

// 선택된 시대를 저장할 변수
String selectedDecade = "1990s";

void mouseClicked() {
  boolean clickedOnTimelineCircle = false;
  String clickedDecade = null;

  for (Circle circle : timelineCircles) {
    if (circle.isMouseOver) {
      clickedOnTimelineCircle = true;
      clickedDecade = circle.label;  // 클릭된 시대 저장
      break;
    }
  }

  if (clickedOnTimelineCircle) {
    if (!isAnimating) {
      if (timelineCirclesClicked) {
        // 타임라인이 이미 올라가 있는 상태
        if (selectedDecade.equals(clickedDecade)) {
          // 같은 버튼을 클릭하면 타임라인을 내림
          timelineCirclesClicked = false;
          animationUp = false;
          targetYPosition = height / 2;
        } else {
          // 다른 버튼을 클릭하면 연도 표시만 변경
          selectedDecade = clickedDecade;
          initDynamicCircles();  // Re-initialize circles for the new decade
        }
      } else {
        // 타임라인이 내려가 있는 상태
        selectedDecade = clickedDecade;
        timelineCirclesClicked = true;
        animationUp = true;
        targetYPosition = 40;
        initDynamicCircles();  // Initialize circles when raising the timeline
      }
      isAnimating = true;
    }
  } else if (!timelineCirclesClicked) {  // 타임라인이 중앙에 있을 때만 작동
    for (LanguageCircle circle : languageCircles) {
      if (circle.isMouseOver) {
        circle.openLanguageWindow();
      }
    }
  }
}


void mouseMoved() {
  if (!timelineCirclesClicked) {  // 타임라인이 중앙에 있을 때만 작동
    for (LanguageCircle circle : languageCircles) {
      circle.checkMouseOver();
      circle.hideCardIfMouseOutside();
    }
  }
  for (Circle circle : timelineCircles) {
    circle.checkMouseOver();
  }
  for (DynamicLanguageCircle c : dynamicCircles) {
    c.lastMousePos.set(mouseX, mouseY);  // 업데이트
  }
}



// Circle 클래스를 추가합니다.
class Circle {
  float x, y;
  int diameter;
  int col;
  String label;
  boolean isMouseOver = false;

  Circle(float x, float y, int diameter, int col, String label) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;
    this.col = col;
    this.label = label;
  }

  void drawCircle() {
    if (isMouseOver) {
      fill(col);
      stroke(0);
      strokeWeight(4);
      ellipse(x, y, diameter + 10 + 2, diameter + 10 + 2);
      stroke(255);
      strokeWeight(5);
      ellipse(x, y, diameter + 10, diameter + 10);
    } else {
      fill(col);
      stroke(0);
      strokeWeight(4);
      ellipse(x, y, diameter + 2, diameter + 2);
      stroke(255);
      strokeWeight(5);
      ellipse(x, y, diameter, diameter);
    }
    fill(text_colors[getDecadeIndexByLabel(label)]);
    textAlign(CENTER);
    textFont(label_font);
    text(this.label, x, y + diameter + 17);
  }

  void checkMouseOver() {
    float distance = dist(mouseX, mouseY, x, y);
    if (distance < diameter / 2) {
      isMouseOver = true;
    } else {
      isMouseOver = false;
    }
  }
}

class LanguageCircle {
  float x, y;
  int diameter;
  int col;
  String name;
  boolean isMouseOver = false;
  boolean isCardVisible = false;
  Card card;
  PFont basic;

  LanguageCircle(float x, float y, int diameter, int col, String name) {
    this.x = x;
    this.y = y;
    this.diameter = diameter;
    this.col = col;
    this.name = name;
    this.basic = createFont("Produkt", 24);
  }

  void draww() {
    // 타임라인과 연결 선을 그립니다
    stroke(col);
    strokeWeight(4);
    line(x, height / 2, x, y);

    // 프로그래밍 언어 아이콘 이미지 설정
    PImage img = getImageForLanguage(name);

    if (img != null) {
      if (isMouseOver) {
        fill(255);
        stroke(col);
        strokeWeight(3);
        ellipse(x, y, diameter + 20, diameter + 20);
        imageMode(CENTER);
        image(img, x, y, diameter + 14, diameter + 14);
      } else {
        fill(255);
        stroke(col);
        strokeWeight(3);
        ellipse(x, y, diameter, diameter);
        imageMode(CENTER);
        image(img, x, y, diameter - 6, diameter - 6);
      }
    } else { // 이미지 없으면 글자로 대체
      if (isMouseOver) {
        fill(255);
        stroke(col);
        strokeWeight(3);
        ellipse(x, y, diameter + 20, diameter + 20);

        fill(0);
        textAlign(CENTER, CENTER);
        textFont(basic);
        textSize(16);
        text(name, x, y);
      } else {
        fill(255);
        stroke(col);
        strokeWeight(3);
        ellipse(x, y, diameter, diameter);

        fill(0);
        textAlign(CENTER, CENTER);
        textFont(basic);
        textSize(12);
        text(name, x, y);
      }
    }
  }

  void checkMouseOver() {
    float distance = dist(mouseX, mouseY, x, y);
    if (distance < diameter / 2) {
      isMouseOver = true;
    } else {
      isMouseOver = false;
    }
  }

  void openLanguageWindow() {
    if (!isCardVisible) {
      TableRow row = getRowByLanguageName(name);
      if (row != null) {
        float cardX = x;
        float cardY = y;

        // langYPositions 값이 100 초과인 경우 위치 조정
        if (y - height/2 > 100) {
          cardY = y - 300;  // 카드의 높이를 고려하여 y 좌표 조정
        }
        if (x > width - 530) {
          cardX = x - 520;
        }

        int startColor = col;  // 시작 색상 설정
        card = new Card(cardX, cardY, row.getString("Name"), row.getString("Year"), row.getString("Developer"), row.getString("Purpose"), row.getString("Significance"), getImageForLanguage(name), startColor, true, true);
        isCardVisible = true;
      }
    }
  }

  void hideCardIfMouseOutside() {
    if (isCardVisible) {
      boolean outside = true;

      // 언어 원 내부 확인
      float distance = dist(mouseX, mouseY, x, y);
      if (distance < diameter / 2) {
        outside = false;
      }

      // 카드 내부 확인
      if (card != null && card.isMouseOverCard()) {
        outside = false;
      }

      // 마우스가 바깥에 있으면 카드 숨김
      if (outside) {
        card = null;
        isCardVisible = false;
      }
    }
  }

  TableRow getRowByLanguageName(String name) {
    for (TableRow row : table.rows()) {
      if (row.getString("Name").equals(name)) {
        return row;
      }
    }
    return null;
  }

  PImage getImageForLanguage(String name) {
    switch (name) {
      case "C": return c_img;
      case "C++": return cpp_img;
      case "CSS": return css_img;
      case "Java": return java_img;
      case "C#": return csharp_img;
      case "JavaScript": return js_img;
      case "Kotlin": return kotlin_img;
      case "Go": return go_img;
      case "PHP": return php_img;
      case "Python": return python_img;
      case "Ruby": return ruby_img;
      case "Rust": return rust_img;
      case "Scala": return scala_img;
      case "SQL": return sql_img;
      case "Swift": return swift_img;
      case "TypeScript": return ts_img;
      case "R": return r_img;
      case "MATLAB": return matlab_img;
      case "Perl": return perl_img;
      case "FORTRAN": return fortran_img;
      case "Pascal": return pascal_img;
      default: return null;
    }
  }
}




class Card {
  float x, y, xx, yy;
  String name, year, developer, predecessor, significance;
  PImage img;
  PFont basic;
  int startColor;
  boolean hasImage, xc, yc;

  // Constructor for cards without images
  Card(float x, float y, String name, String year, String developer, String predecessor, int startColor, boolean xc, boolean yc) {
    this.xx = x;
    this.yy = y;
    this.name = name;
    this.year = year;
    this.developer = developer;
    this.predecessor = predecessor;
    this.startColor = startColor;
    this.basic = createFont("Produkt", 24);
    this.hasImage = false;  // No image
    this.xc = xc;
    this.yc = yc;
  }

  // Constructor for cards with images
  Card(float x, float y, String name, String year, String developer, String predecessor, String significance, PImage img, int startColor, boolean xc, boolean yc) {
    this(x, y, name, year, developer, predecessor, startColor, xc, yc);
    this.significance = significance;
    this.img = img;
    this.hasImage = true;  // Has image
    this.xc = xc;
    this.yc = yc;
  }

  void display() {
    int rectWidth;
    if (hasImage) {
      rectWidth = 490;  // Fixed width for timeline circle cards
    } else {
      textFont(basic);
      textSize(34);
      float nameYearWidth = textWidth(name + " (" + year + ")");
      textSize(20);
      float developerWidth = textWidth("- Developer: " + developer);
      float predecessorWidth = textWidth("- Predecessor(s): " + predecessor);
      float significanceWidth = significance != null ? textWidth("- Significance: " + significance) : 0;

      float maxTextWidth = max(nameYearWidth, max(developerWidth, max(predecessorWidth, significanceWidth)));
      int minCardWidth = 300;
      rectWidth = int(max(minCardWidth, maxTextWidth + 40));  // Add some padding
    }

    int rectHeight = significance != null ? 320 : 300;  // Adjust height if significance is present
    int cornerRadius = 20;
    
    if(xc) x = xx+520 - rectWidth;
    else x = xx;
    if(yc) y = yy+300 - rectHeight;
    else y = yy;

    // Draw gradient inside the rounded rectangle
    fill(255);
    rect(x, y, rectWidth, rectHeight, cornerRadius);
    for (int i = 0; i <= rectHeight; i++) {
      float inter = map(i, 0, rectHeight, 0, 1);
      int c = lerpColor(startColor, color(204, 229, 255), inter);
      stroke(c);
      if (i < cornerRadius) {
        int x1 = (int)x + cornerRadius - int(sqrt(sq(cornerRadius) - sq(cornerRadius - i)));
        int x2 = (int)x + rectWidth - (cornerRadius - int(sqrt(sq(cornerRadius) - sq(cornerRadius - i))));
        line(x1, (int)y + i, x2, (int)y + i);
      } else if (i > rectHeight - cornerRadius) {
        int yOffset = i - (rectHeight - cornerRadius);
        int x1 = (int)x + cornerRadius - int(sqrt(sq(cornerRadius) - sq(yOffset)));
        int x2 = (int)x + rectWidth - (cornerRadius - int(sqrt(sq(cornerRadius) - sq(yOffset))));
        line(x1, (int)y + i, x2, (int)y + i);
      } else {
        line((int)x, (int)y + i, (int)x + rectWidth, (int)y + i);
      }
    }

    // Draw rounded rectangle border
    noFill();
    noStroke();
    strokeWeight(0.5);
    rect(x, y, rectWidth, rectHeight, cornerRadius);
    strokeWeight(2);

    // Draw language icon if available
    if (hasImage && img != null) {
      fill(255);
      ellipseMode(CENTER);
      ellipse(x + 50, y + 45, 70, 70);
      imageMode(CENTER);
      image(img, x + 50, y + 45, 60, 60);
      // Adjust text position for cards with images
      drawTextWithImage(rectWidth);
    } else {
      // Adjust text position for cards without images
      drawTextWithoutImage(rectWidth);
    }
  }

  void drawTextWithImage(int rectWidth) {
    // Set text properties
    fill(0);
    textFont(basic);
    textSize(34);
    textAlign(LEFT);
    text(name + " (" + year + ")", x + 100, y + 58);

    textSize(20);
    drawWrappedText("- Developer: " + developer, x + 30, y + 115, rectWidth - 120);
    drawWrappedText("- Predecessor(s): " + predecessor, x +30, y + 165, rectWidth - 120);
    if (significance != null) {
      drawWrappedText("- Significance: " + significance, x + 30, y + 245, rectWidth - 120);
    }
  }

  void drawTextWithoutImage(int rectWidth) {
    // Set text properties
    fill(0);
    textFont(basic);
    textSize(34);
    textAlign(LEFT);
    text(name + " (" + year + ")", x + 20, y + 58);  // Adjusted position

    textSize(20);
    drawWrappedText("- Developer: " + developer, x + 20, y + 115, rectWidth - 40);
    drawWrappedText("- Predecessor(s): " + predecessor, x + 20, y + 165, rectWidth - 40);
    if (significance != null) {
      drawWrappedText("- Significance: " + significance, x + 20, y + 245, rectWidth - 40);
    }
  }

  void drawWrappedText(String txt, float x, float y, int maxWidth) {
    String[] words = split(txt, ' ');
    String line = "";
    int lineHeight = 25;
    for (String word : words) {
      if (textWidth(line + word) < maxWidth) {
        line += word + " ";
      } else {
        text(line, x, y);
        line = word + " ";
        y += lineHeight;
      }
    }
    text(line, x, y);
  }

  boolean isMouseOverCard() {
    int rectWidth;
    if (hasImage) {
      rectWidth = 520;  // Fixed width for timeline circle cards
    } else {
      textFont(basic);
      textSize(34);
      float nameYearWidth = textWidth(name + " (" + year + ")");
      textSize(20);
      float developerWidth = textWidth("- Developer: " + developer);
      float predecessorWidth = textWidth("- Predecessor(s): " + predecessor);
      float significanceWidth = significance != null ? textWidth("- Significance: " + significance) : 0;

      float maxTextWidth = max(nameYearWidth, max(developerWidth, max(predecessorWidth, significanceWidth)));
      int minCardWidth = 300;
      rectWidth = int(max(minCardWidth, maxTextWidth + 40));  // Add some padding
    }

    int rectHeight = significance != null ? 340 : 300;  // Adjust height if significance is present

    return mouseX > x && mouseX < x + rectWidth && mouseY > y && mouseY < y + rectHeight;  // Updated to match new dimensions
  }
}





TableRow getRowByLanguageName(String name) {
  for (TableRow row : timelineTable.rows()) {
    if (row.getString("Name").equals(name)) {
      return row;
    }
  }
  return null;
}


class DynamicLanguageCircle {
  PVector pos;
  PVector velocity;
  PVector acceleration;
  float diameter;
  float mass;
  int circleColor;
  String name;
  int sectionIndex;
  boolean isBeingDragged = false;
  boolean isPressed = false;
  long pressStartTime = 0;
  boolean isCardVisible = false;
  Card card;
  PVector lastMousePos;

  DynamicLanguageCircle(float x, float y, float d, int c, String n, int section) {
    pos = new PVector(x, y);
    velocity = new PVector();
    acceleration = new PVector();
    diameter = d;
    mass = d * 0.1;
    circleColor = c;
    name = n;
    sectionIndex = section;
    lastMousePos = new PVector(mouseX, mouseY);
  }

  void applyForce(PVector force) {
    PVector f = PVector.div(force, mass);
    acceleration.add(f);
  }

  void update() {
    if (this != draggedCircle) {
      for (DynamicLanguageCircle other : dynamicCircles) {
        if (other != this) {
          float distance = PVector.dist(pos, other.pos);
          if (distance < diameter) {
            PVector repel = PVector.sub(pos, other.pos);
            repel.normalize();
            repel.mult(2);
            applyForce(repel);
            other.applyForce(repel.mult(-1));
          } else if (distance < diameter * 2) {
            PVector repel = PVector.sub(pos, other.pos);
            repel.normalize();
            repel.mult(0.5);
            applyForce(repel);
          }
        }
      }

      velocity.add(acceleration);
      pos.add(velocity);
      acceleration.mult(0);
      velocity.mult(0.95);

      // Ensure the circle stays within its section bounds
      float xMin = sectionBounds[sectionIndex].x + diameter / 2;
      float xMax = sectionBounds[sectionIndex].y - diameter / 2;
      float yMin = 120 + diameter / 2;
      float yMax = height - 120 - diameter / 2;

      pos.x = constrain(pos.x, xMin, xMax);
      pos.y = constrain(pos.y, yMin, yMax);

      // Reflect velocity if hitting the boundary
      if (pos.x == xMin || pos.x == xMax) {
        velocity.x *= -1;
      }
      if (pos.y == yMin || pos.y == yMax) {
        velocity.y *= -1;
      }
    }

    if (isPressed) {
      if (millis() - pressStartTime > 300 && !isCardVisible && lastMousePos.equals(new PVector(mouseX, mouseY))) {  // 2 seconds press without moving
        openLanguageCard();
        isCardVisible = true;
      } else if (!lastMousePos.equals(new PVector(mouseX, mouseY))) {
        isPressed = false;
        isCardVisible = false;
        card = null;
      }
    } else if (isCardVisible) {
      isCardVisible = false;
      card = null;
    }
  }

  void display() {
    textFont(basic_font);
    if (isBeingDragged) {
      fill(circleColor * 4);  // brighter color
      textSize(16);  // larger text size
    } else {
      fill(circleColor);
      if (sectionIndex == 0 && selectedDecade.equals("Pre-1970")) {
        textSize(8);  // smaller text size for 1804~1961 section
      } else {
        textSize(12);  // default text size
      }
    }
    noStroke();
    ellipse(pos.x, pos.y, diameter, diameter);
    fill(0);
    textAlign(CENTER);
    text(name, pos.x, pos.y + diameter / 2 + 12);
    
    if (isCardVisible && card != null) {
      card.display();
    }
  }

  boolean isMouseOver() {
    float d = dist(mouseX, mouseY, pos.x, pos.y);
    return d < diameter / 2;
  }

  void openLanguageCard() {
    TableRow row = getRowByLanguageName(name);
    if (row != null) {
      float cardX = pos.x;
      float cardY = pos.y;
      
      boolean xc = false, yc = false;
  
      // 위치 조정 로직
      if (pos.y - height / 2 > 100) {
        cardY = pos.y - 300;
        yc = true;
      }
      if (pos.x > width - 530) {
        cardX = pos.x - 520;
        xc = true;
      }
  
      int startColor = circleColor;
      card = new Card(cardX, cardY, row.getString("Name"), row.getString("Year"), row.getString("Chief developer, company"), row.getString("Predecessor(s)"), startColor, xc, yc);
      isCardVisible = true;
    }
  }
}

void mousePressed() {
  if (timelineCirclesClicked && !isAnimating && timelineYPosition == targetYPosition) {
    for (DynamicLanguageCircle c : dynamicCircles) {
      if (c.isMouseOver()) {
        draggedCircle = c;
        lastMousePos = new PVector(mouseX, mouseY);
        c.isBeingDragged = true;
        c.isPressed = true;
        c.pressStartTime = millis();
        break;
      }
    }
  }
}

void mouseReleased() {
  if (draggedCircle != null) {
    draggedCircle.velocity.set(mouseVelocity);
    draggedCircle.isBeingDragged = false;
    draggedCircle.isPressed = false;
    draggedCircle = null;
  } else {
    for (DynamicLanguageCircle c : dynamicCircles) {
      if (c.isMouseOver() && c.isCardVisible) {
        c.isCardVisible = false;
        c.card = null;
      }
    }
  }
}

void mouseDragged() {
  if (draggedCircle != null) {
    PVector currentMousePos = new PVector(mouseX, mouseY);
    mouseVelocity = PVector.sub(currentMousePos, lastMousePos);
    draggedCircle.pos.set(mouseX, mouseY);
    draggedCircle.velocity.set(mouseVelocity);
    lastMousePos = currentMousePos;
    draggedCircle.isPressed = false;
    draggedCircle.isCardVisible = false;
    draggedCircle.card = null;
  }
}



int getColorByDecade(int year) {
  if (year < 1970) {
    return colors[0];
  } else if (year < 1980) {
    return colors[1];
  } else if (year < 1990) {
    return colors[2];
  } else if (year < 2000) {
    return colors[3];
  } else if (year < 2010) {
    return colors[4];
  } else {
    return colors[5];
  }
}
