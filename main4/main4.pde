import g4p_controls.*;
import java.util.Arrays;

GDropList dropList1, dropList2; // 드롭다운 메뉴 객체
int[] chartData = new int[9]; // 각 시대별 언어 개수를 저장할 배열
int[] yearData1 = new int[10]; // 첫 번째 드롭다운 메뉴의 연도별 언어 개수를 저장할 배열
int[] yearData2 = new int[10]; // 두 번째 드롭다운 메뉴의 연도별 언어 개수를 저장할 배열
String[] eras = {"1800s", "1940s", "1950s", "1960s", "1970s", "1980s", "1990s", "2000s", "2010s"};
String selectedEra1 = "1990s"; // 첫 번째 드롭다운 메뉴의 초기 선택 값
String selectedEra2 = "2000s"; // 두 번째 드롭다운 메뉴의 초기 선택 값

int[] eraColors = {
  #D5D5D5,
  #D5D5D5,
  #D5D5D5,
  #D5D5D5,
  #9BFFBA,
  #ffe7a1,
  #ffc5ee,
  #b0faff,
  #846cf9
};

int[] eraTextColors = {
  #b0b0b0,
  #b0b0b0,
  #b0b0b0,
  #b0b0b0,
  #87d5ac,
  #e7c854,
  #d69ccd,
  #71e3ca,
  #846cf9
};
int globalMaxCountTop; // 위쪽 그래프의 최대값
int globalMaxCountBottom; // 아래쪽 그래프의 최대값


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
  //basic_font = createFont("Produkt", 24);
  basic_font = createFont("American Typewriter", 24);

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

  // CSV 파일 읽어오기
  table = loadTable("Best20_sorted_updated.csv", "header");
  timelineTable = loadTable("Timeline_of_programming_languages.csv", "header");

  // 타임라인 원을 초기화
  initTimelineCircles();

  // 각 언어를 타임라인에 배치
  drawLanguages();

  // 초기화 부분 추가
  timelineYPosition = height / 2;


  initSectionBounds();
  // Initialize dynamic circles
  initDynamicCircles();

  int margin = 50;
  int chartWidth = (int)(width - 4 * margin)/2;
  int chartHeight = (height - 3 * margin) / 2;

  // 드롭다운 메뉴 초기화 (visible 속성은 false로 시작)
  dropList1 = new GDropList(this,  641 - 90, 400-20, 90, 190, 9);
  dropList1.setItems(eras, 0);
  dropList1.addEventHandler(this, "handleDropListEvents");
  dropList1.setSelected(Arrays.asList(eras).indexOf(selectedEra1));
  dropList1.setVisible(false);
  dropList1.setLocalColorScheme(GCScheme.BLUE_SCHEME); // 색상 변경
  dropList1.setOpaque(true);

  dropList2 = new GDropList(this,  1232 - 90  ,400-20, 90, 190, 9);
  dropList2.setItems(eras, 0);
  dropList2.addEventHandler(this, "handleDropListEvents");
  dropList2.setSelected(Arrays.asList(eras).indexOf(selectedEra2));
  dropList2.setVisible(false);
  dropList2.setLocalColorScheme(GCScheme.BLUE_SCHEME); // 색상 변경
  dropList2.setOpaque(true);


  // 초기화 작업
  loadChartData();
  updateYearData();
  
  // 위쪽 그래프에서 최대값 계산 (10년 단위)
  globalMaxCountTop = max(chartData);
  globalMaxCountTop *= 1.2; // 최대값에 여유를 줌
    
  
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

  // 메인 타임라인 선을 그리기
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

void drawTimelineInit() {
  int margin = 100;
  int startX = margin;
  int endX = width - margin;
  int segmentLength = (endX - startX) / labels.length;

  // Adjust yPosition based on animation
  int yPosition = (int) timelineYPosition;

  // 메인 타임라인 선을 그리기
  noStroke();
  fill(200, 199, 199, 20);
  rect(0, yPosition - 38 / 2, width, 38);


  for (int i = 0; i < colors.length; i++) {
    fill(colors[i]); // 원래 색상
    fill(darkenColor(colors[i], 0.5)); // 명암을 낮춘 색상
    rect(startX + i * segmentLength, yPosition - 38 / 2, segmentLength, 38);
  }

  p3 = new PVector(startX + (colors.length) * segmentLength, yPosition - 38 / 2);
  p2 = new PVector(startX + (colors.length) * segmentLength, yPosition + 38 / 2);
  p1 = new PVector(startX + (colors.length) * segmentLength + 50, yPosition);
  drawGradientTriangle(p1, p2, p3, colors[2], colors[colors.length - 1]);

  color startGradientColor = colors[2];
  color endGradientColor = colors[colors.length - 1];


  startGradientColor = darkenColor(startGradientColor, 0.5);
  endGradientColor = darkenColor(endGradientColor, 0.5);

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
    fill(text_colors[i]); // 원래 텍스트 색상
    fill(darkenColor(text_colors[i], 0.5)); // 명암을 낮춘 텍스트 색상
    text(labels[i], xPosition, yPosition + circleDiameter + 17);
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

  // 각 시대별 언어 수를 세어 X 간격을 설정
  int[] decadeCounts = new int[labels.length];
  for (TableRow row : table.rows()) {
    int year = row.getInt("Year");
    int decadeIndex = getDecadeIndex(year);
    decadeCounts[decadeIndex]++;
  }

  // 각 시대별 언어의 X 오프셋을 설정
  float[] decadeOffsets = new float[labels.length];  // 각 시대별 X 오프셋 초기화
  for (int i = 0; i < labels.length; i++) {
    decadeOffsets[i] = segmentLength / (decadeCounts[i] + 1);
  }

  // 각 언어에 대한 langYPos 값을 설정
  int[] langYPositions = {220, -250, 250, -180, 190, -137, 100, 225, -146, 193, -132, 242, -229, 169, -299, 288, -208, -139, 159, -221, -102, 158, 272, -264};

  // 언어에 대한 인덱스를 초기화
  int langIndex = 0;

  for (TableRow row : table.rows()) {
    int year = row.getInt("Year");
    String name = row.getString("Name");

    int decadeIndex = getDecadeIndex(year);
    float xPosition = startX + decadeIndex * segmentLength + decadeOffsets[decadeIndex];
    int langYPos = yPosition + langYPositions[langIndex++]; // langYPos 값을 직접 설정
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

boolean isSecondaryScreen = false;
boolean isStartScreen = true;
boolean isSpacePressed = false;
boolean isMouseOverRect = false; 
void keyPressed() {
  if(isStartScreen){
    if(key==' ') {
      isSpacePressed = true;
    }
  }else if(!isStartScreen && !timelineCirclesClicked && !isSecondaryScreen){
    if(key==' ') {
      isSpacePressed = false;
      isStartScreen = true;
    }
  }
  
}

float textYPos = 320; // 글씨의 초기 y 위치
float textSpeed = 28; // 글씨가 올라가는 속도

void draw() {
  if(!isSpacePressed) {
    if(isStartScreen) {
      background(250);
      drawTimelineInit();
      
      timelineCirclesClicked = false;
      animationUp = false;
      targetYPosition = height / 2;
      
      rectMode(CENTER);
      if (isMouseOverRect) {
        fill(0, 0, 0, 30); // 마우스가 사각형 위에 있을 때 불투명도 증가
      } else {
        fill(0, 0, 0, 10); // 기본 불투명도
      }
      stroke(0);
      strokeWeight(0.8);
      rect(width/2, height/2, 1312*0.98, 820*0.5, 25);
      rectMode(CORNER);
      
      
      textAlign(CENTER, CENTER);
      textFont(label_font);
      fill(0);
      textSize(40);
      textYPos = 320;
      text("Timeline of Programming Languages", width/2, textYPos);
      
      //textFont(basic_font);
      //fill(100, 100, 100, 100);
      //textSize(20);
      //text("Click or Press Space", width/2, height-40);
      
      //// 떨림 효과를 위한 텍스트
      //textFont(basic_font);
      //fill(100, 100, 100, 100);
      //textSize(20);
      //float shakeX = random(-1, 1)*2;
      //float shakeY = random(-1, 1)*0;
      //text("Click or Press Space", width/2 + shakeX, height - 40 + shakeY);
      
      
      // 무지개색 효과를 위한 텍스트
      float colorSpd = 0.05;
      color rainbowColor = color((sin(frameCount * colorSpd) * 127 + 128), (sin(frameCount * colorSpd + TWO_PI / 3) * 127 + 128), (sin(frameCount * colorSpd + TWO_PI * 2 / 3) * 127 + 128));
      textFont(basic_font);
      fill(rainbowColor);
      textSize(26);
      text(" Click or Press Space ", width/2, height - 56);
    }
  }else if(isSpacePressed && isStartScreen){
    background(250);
    drawTimelineInit();
    
    textAlign(CENTER, CENTER);
    textFont(label_font);
    fill(0);
    textSize(40);
    text("Timeline of Programming Languages", width/2, textYPos);

    if (textYPos < 900) {
      textYPos += textSpeed; // 텍스트를 위로 이동
    } else {
      isStartScreen = false;
      isSpacePressed = false;
    }
    
    timelineCirclesClicked = false;
    animationUp = false;
    targetYPosition = height / 2;
  }
  
  if(!isStartScreen){
    if (!isSecondaryScreen) {
      drawPrimaryScreen();
      dropList1.setVisible(false);
      dropList2.setVisible(false);
    } else {
      drawSecondaryScreen();
      dropList1.setVisible(true);
      dropList2.setVisible(true);
    }
  }
  
}


void drawPrimaryScreen() {
  background(250);
  
  //textAlign(CENTER, CENTER);
  //textFont(label_font);
  //fill(0);
  //textSize(40);
  //text("Timeline of Programming Languages", width/2, 320);
  
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
    performTaskWhenTimelineUp();
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
boolean isMouseOverGraphButton = false;
boolean isMouseOverBackButton = false;

void performTaskWhenTimelineUp() {
  // 버튼 색상 설정
  if (isMouseOverGraphButton) {
    fill(190, 0, 0); // 어두운 빨간색
    // 오른쪽 상단에 직사각형 버튼 그리기
    rect(width - 100, 80, 90, 30, 10);
    fill(230);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Graph", width - 55, 95);
  } else {
    fill(255, 0, 0); // 빨간색
    // 오른쪽 상단에 직사각형 버튼 그리기
    rect(width - 100, 80, 90, 30, 10);
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Graph", width - 55, 95);
  }

}

void drawSecondaryScreen() {
  background(255); // 흰 배경

  if (isMouseOverBackButton) {
    fill(0, 0, 160); // 어두운 파란색
    // 왼쪽 상단에 직사각형 버튼 그리기
    rect(10, 10, 90, 30, 10);
    fill(220);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Back", 55, 25);
  } else {
    fill(0, 0, 255); // 파란색
    // 왼쪽 상단에 직사각형 버튼 그리기
    rect(10, 10, 90, 30, 10);
    fill(255);
    textSize(16);
    textAlign(CENTER, CENTER);
    text("Back", 55, 25);
  }

  drawLineChart();
}

void loadChartData() {
  // 각 시대별 언어 개수 계산
  for (TableRow row : timelineTable.rows()) {
    int year = row.getInt("Year");
    if (year < 1900) chartData[0]++;
    else if (year < 1950) chartData[1]++;
    else if (year < 1960) chartData[2]++;
    else if (year < 1970) chartData[3]++;
    else if (year < 1980) chartData[4]++;
    else if (year < 1990) chartData[5]++;
    else if (year < 2000) chartData[6]++;
    else if (year < 2010) chartData[7]++;
    else chartData[8]++;
  }
}

void updateYearData() {
  // 첫 번째 드롭다운 메뉴에서 선택된 시대에 대한 연도별 언어 개수 계산
  int decadeStart1 = getDecadeStart(selectedEra1);
  yearData1 = new int[10]; // 10년간의 데이터
  if (selectedEra1.equals("1800s")) {
    yearData1 = new int[]{0, 1, 0, 0, 0, 0, 0, 1, 0, 0}; // 1804년과 1879년을 표시
  } else {
    for (TableRow row : timelineTable.rows()) {
      int year = row.getInt("Year");
      if (year >= decadeStart1 && year < decadeStart1 + 10) {
        yearData1[year - decadeStart1]++;
      }
    }
  }

  // 두 번째 드롭다운 메뉴에서 선택된 시대에 대한 연도별 언어 개수 계산
  int decadeStart2 = getDecadeStart(selectedEra2);
  yearData2 = new int[10]; // 10년간의 데이터
  if (selectedEra2.equals("1800s")) {
    yearData2 = new int[]{0, 1, 0, 0, 0, 0, 0, 1, 0, 0}; // 1804년과 1879년을 표시
  } else {
    for (TableRow row : timelineTable.rows()) {
      int year = row.getInt("Year");
      if (year >= decadeStart2 && year < decadeStart2 + 10) {
        yearData2[year - decadeStart2]++;
      }
    }
  }

  // 전체 데이터에서 최대값 계산
  globalMaxCountBottom = 0;
  for (int i = 0; i < 9; i++) {
    int startYear = getDecadeStart(eras[i]);
    int[] tempData = new int[10];
    for (TableRow row : timelineTable.rows()) {
      int year = row.getInt("Year");
      if (year >= startYear && year < startYear + 10) {
        tempData[year - startYear]++;
      }
    }
    globalMaxCountBottom = max(globalMaxCountBottom, max(tempData));
  }
  globalMaxCountBottom *= 1.2;
}

int getDecadeStart(String era) {
  switch (era) {
    case "1800s":
      return 1800; // 1800s의 경우 1800-1899로 처리
    case "1940s":
      return 1940; // 1940s의 경우 1940-1949로 처리
    case "1950s":
      return 1950; // 1950s의 경우 1950-1959로 처리
    case "1960s":
      return 1960; // 1960s의 경우 1960-1969로 처리
    case "1970s":
      return 1970;
    case "1980s":
      return 1980;
    case "1990s":
      return 1990;
    case "2000s":
      return 2000;
    case "2010s":
      return 2010;
    default:
      return 1990;
  }
}

void handleDropListEvents(GDropList list, GEvent event) {
  if (list == dropList1) {
    selectedEra1 = eras[list.getSelectedIndex()];
  } else if (list == dropList2) {
    selectedEra2 = eras[list.getSelectedIndex()];
  }
  updateYearData();
}

void drawLineChart() {
  int margin = 50;
  int chartHeight = (height - 3 * margin) / 2; // 각 그래프의 높이
  int chartWidth = width - 6 * margin; // 그래프의 너비
  int halfChartWidth = (chartWidth - 2 * margin) / 2; // 아래 그래프의 너비, 그래프 간의 간격을 위해 2 * margin을 뺌

  // 첫 번째 그래프 (위쪽 중앙)
  int xx = 6 * margin -50;
  int ll = chartWidth-6*margin + 100;
  drawSingleChart(6 * margin, margin, chartWidth-6*margin, chartHeight-2*margin, chartData, eras, "Number of Programming Languages by Decade", -1, xx, ll);
  // 테두리 직사각형 그리기
  noFill();
  stroke(0);
  rect(xx, margin-30, ll, chartHeight-2*margin+75);

  // 두 번째 그래프 (아래쪽 왼쪽)
  int decadeStart1 = getDecadeStart(selectedEra1);
  String[] years1;
  if (selectedEra1.equals("1800s")) {
    years1 = new String[]{"", "1804", "", "", "", "", "",  "1879", ""};
  } else {
    years1 = new String[10];
    for (int i = 0; i < 10; i++) {
      years1[i] = str(decadeStart1 + i);
    }
  }
  // 테두리 직사각형 그리기
  noFill();
  stroke(0);
  xx = 3 * margin-70;
  ll = halfChartWidth+margin-15+70;
  rect(xx, margin + chartHeight+15, ll, chartHeight+65);
  drawSingleChart(3 * margin-15, 2 * margin + chartHeight, halfChartWidth, chartHeight, yearData1, years1, "Number of Programming Languages by Year (" + selectedEra1 + ")", getEraIndex(selectedEra1), xx, ll);

  // 세 번째 그래프 (아래쪽 오른쪽)
  int decadeStart2 = getDecadeStart(selectedEra2);
  String[] years2;
  if (selectedEra2.equals("1800s")) {
    years2 = new String[]{"", "1804", "", "", "", "", "",  "1879", ""};
  } else {
    years2 = new String[10];
    for (int i = 0; i < 10; i++) {
      years2[i] = str(decadeStart2 + i);
    }
  }
  // 테두리 직사각형 그리기
  noFill();
  stroke(0);
  xx = (int)4.5 * margin+30 + halfChartWidth + margin - 65;
  ll = halfChartWidth+margin-15+70;
  rect(xx, margin + chartHeight+15, ll, chartHeight+65);
  drawSingleChart((int)4.5 * margin+15 + halfChartWidth + margin, 2 * margin + chartHeight, halfChartWidth, chartHeight, yearData2, years2, "Number of Programming Languages by Year (" + selectedEra2 + ")", getEraIndex(selectedEra2), xx, ll);
}

void drawSingleChart(int xOffset, int yOffset, int chartWidth, int chartHeight, int[] data, String[] labels, String title, int colorIndex, int xx, int ll) {
  // 축 그리기
  stroke(0);
  strokeWeight(1.5);
  //line(xOffset, yOffset, xOffset, yOffset + chartHeight); // y축
  line(xx, yOffset + chartHeight, xx+ll, yOffset + chartHeight); // x축

  // 제목 그리기
  textAlign(CENTER);
  textSize(19);
  fill(0);
  text(title, xOffset + chartWidth / 2, yOffset);

  int globalMaxCount = globalMaxCountBottom;
  if(title.equals("Number of Programming Languages by Decade")) {
    globalMaxCount = globalMaxCountTop;
  }
  // 데이터 점 및 꺾은선 그리기
  float xStep = chartWidth / (data.length - 1);
  float prevX = xOffset;
  float prevY = yOffset + chartHeight - (data[0] / float(globalMaxCount)) * chartHeight;

  for (int i = 0; i < data.length; i++) {
    float x = xOffset + i * xStep;
    float y = yOffset + chartHeight - (data[i] / float(globalMaxCount)) * chartHeight;

    // 꺾은선 그리기
    if (i > 0) {
      stroke(0);
      strokeWeight(0.8);
      line(prevX, prevY, x, y);
    }

    prevX = x;
    prevY = y;
  }
  for (int i = 0; i < data.length; i++) {
    float x = xOffset + i * xStep;
    float y = yOffset + chartHeight - (data[i] / float(globalMaxCount)) * chartHeight;

    // 점 그리기
    stroke(0.7);
    fill(colorIndex == -1 ? eraColors[i] : eraColors[colorIndex]);
    if(title.equals("Number of Programming Languages by Decade")) {
      ellipse(x, y, 12, 12);
    }
    else ellipse(x, y, 10, 10);

    // 각 점 위에 숫자 표시
    textAlign(CENTER);
    textSize(12);
    fill(0);
    text(data[i], x, y - 12);

    prevX = x;
    prevY = y;
  }

  // 레이블 그리기
  textAlign(CENTER);
  for (int i = 0; i < labels.length; i++) {
    float x = xOffset + i * xStep;
    fill(colorIndex == -1 ? eraTextColors[i] : eraTextColors[colorIndex]);
    if(title.equals("Number of Programming Languages by Decade")) {
      textSize(20);
    }
    else textSize(14);
    text(labels[i], x, yOffset + chartHeight + 20);
  }
  
}

int getEraIndex(String era) {
  for (int i = 0; i < eras.length; i++) {
    if (eras[i].equals(era)) {
      return i;
    }
  }
  return -1; // Invalid label
}



int getDecadeIndex(String label) {
  for (int i = 0; i < labels.length; i++) {
    if (labels[i].equals(label)) {
      return i;
    }
  }
  return -1; // Invalid label
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
  case "Pre-1970":
    return 1960;
  case "1970s":
    return 1970;
  case "1980s":
    return 1980;
  case "1990s":
    return 1990;
  case "2000s":
    return 2000;
  case "2010s":
    return 2010;
  default:
    return 1970;
  }
}

// 선택된 시대를 저장할 변수
String selectedDecade = "1990s";


void mouseClicked() {
  if (isMouseOverRect && isStartScreen) {
    isSpacePressed = true;
    
  }else{
  
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
}


void mouseMoved() {
  // Graph 버튼에 마우스가 위치한 경우 체크
  if (mouseX > width - 100 && mouseX < width - 10 && mouseY > 80 && mouseY < 110) {
    isMouseOverGraphButton = true;
  } else {
    isMouseOverGraphButton = false;
  }

  // Back 버튼에 마우스가 위치한 경우 체크
  if (mouseX > 10 && mouseX < 100 && mouseY > 10 && mouseY < 40) {
    isMouseOverBackButton = true;
  } else {
    isMouseOverBackButton = false;
  }

  if (!isSecondaryScreen) {
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
  
  if (mouseX > width/2 - 1312*0.98/2 && mouseX < width/2 + 1312*0.98/2 && mouseY > height/2 - 820*0.5/2 && mouseY < height/2 + 820*0.5/2) {
    isMouseOverRect = true;
  } else {
    isMouseOverRect = false;
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




void mousePressed() {
  if (!isSecondaryScreen) {
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
    // Graph 버튼 클릭 감지
    if (mouseX > width - 100 && mouseX < width - 10 && mouseY > 80 && mouseY < 110) {
      isSecondaryScreen = true;
      dropList1.setVisible(true);
      dropList2.setVisible(true);
    }
  } else {
    // Back 버튼 클릭 감지
    if (mouseX > 10 && mouseX < 100 && mouseY > 10 && mouseY < 40) {
      isSecondaryScreen = false;
      dropList1.setVisible(false);
      dropList2.setVisible(false);
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
