class Card {
  float x, y;
  String name, year, developer, purpose, significance;
  PImage img;
  PFont basic;
  int startColor;

  Card(float x, float y, String name, String year, String developer, String purpose, String significance, PImage img, int startColor) {
    this.x = x;
    this.y = y;
    this.name = name;
    this.year = year;
    this.developer = developer;
    this.purpose = purpose;
    this.significance = significance;
    this.img = img;
    this.basic = createFont("Produkt", 24);
    this.startColor = startColor;
  }

  void display() {
    int rectWidth = 520;
    int rectHeight = 300;
    int cornerRadius = 20;

    // 둥근 그라데이션 사각형 그리기
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

    
    noFill();
    stroke(0);
    strokeWeight(0.5);
    rect(x, y, rectWidth, rectHeight, cornerRadius);
    strokeWeight(2);
    
    // 프로그래밍 언어 로고 이미지
    if (img != null) {
      fill(255);
      ellipseMode(CENTER);
      ellipse(x + 50, y + 45, 70, 70);
      imageMode(CENTER);
      image(img, x + 50, y + 45, 60, 60);
    }

    // 속성 텍스트
    fill(0);
    textFont(basic);
    textSize(34);
    textAlign(LEFT);
    text(name + " (" + year + ")", x + 100, y + 58);

    textSize(20);
    drawWrappedText("- Developer: " + developer, x + 20, y + 115, rectWidth - 60);
    drawWrappedText("- Purpose: " + purpose, x + 20, y + 165, rectWidth - 60);
    drawWrappedText("- Significance: " + significance, x +20, y + 245, rectWidth - 60);
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
    return mouseX > x && mouseX < x + 520 && mouseY > y && mouseY < y + 300;
  }
}
