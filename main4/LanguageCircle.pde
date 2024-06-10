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
    this.basic = createFont("American Typewriter", 24);
  }

  void draww() {
    // 타임라인과 연결 선을 그리기
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
