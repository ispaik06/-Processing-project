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
    this.basic = createFont("American Typewriter", 24);
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
    x-=20;
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
