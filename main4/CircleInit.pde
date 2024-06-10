class CircleInit {
  float x, y;
  int diameter;
  int col;
  String label;
  boolean isMouseOver = false;

  CircleInit(float x, float y, int diameter, int col, String label) {
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
