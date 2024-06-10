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
