final int MILLI_SEC_DELAY = 250;

enum State {
  PAUSED, ONGOING, FINISHED;
}

public class GamePage extends Page {
  int time;
  double timestamp;
  double checkpoint;
  int pass, home, away, oob, possession, goal, tutorial;
  String action, stadium, url;
  int selectedImage;
  State state;

  GamePage() {
    state = State.PAUSED;
    time = millis();
    pass = 0;
    goal = 0;
    away = 0;
    oob = 0;

    tutorial = 0;
    possession = POSSESSION_NEUTRAL;
    timestamp = 0;
    checkpoint = 0;
    selectedImage = -1;
  }

  void setStadium(String url, String stadium, int selectedImage) {
    this.url = url;
    this.stadium = stadium;
    this.selectedImage = selectedImage;

    switch(url) {
    case DALYMOUNT_PARK:
      this.action = "dalymount_IRL_sendMessage";
      println("dalymount_IRL_sendMessage");
      break;
    case MARVEL_STADIUM:
      this.action = "marvel_AUS_sendMessage";
      break;
    case MELBOURNE_CRICKET_GROUND:
      this.action = "mcg_AUS_sendMessage";
      break;
    }
  }

  // TODO: note that this was sending mouse/7 instead of mouse/15... need to change 15 to be a constant!!! This is the x coordinate being sent to AWS
  String toTautJson() {
    return "{\n\"T\":" +
      String.format("%.02f", timestamp) + ",\n\"X\":" +
      mouseX/15 + ",\n\"Y\":" +
      mouseY/15 + ",\n\"P\":" +
      possession + ",\n\"Pa\":" +
      pass + ",\n\"G\":" +
      goal + ",\n\"T\":" +
      tutorial + "\n\"O\":" +
      oob +
      "\n}";
  }

  String toJsonRequest() {
    if (action == null) {
      println("Can't send message to the server before setting the stadium");
    }

    return "{\"action\": \"" + action + "\", \"message\": {\"T\":" +
      String.format("%.02f", timestamp) + ",\"X\":" +
      mouseX/15 + ",\"Y\":" +
      mouseY/15 + ",\"P\":" +
      possession + ",\"Pa\":" +
      pass + ",\"G\":" +
      goal + ",\"T\":" +
      tutorial + ",\"O\":" +
      oob +
      "}}";
  }

  void show() {
    super.show();

    textSize(20);

    imageMode(CORNER);
    image(images[selectedImage], 0, 0, width, height);
    //imageMode(CENTER);
    //image(ball[selectedImage], mouseX, mouseY);
    //make cursor outline of circle
    strokeWeight(10);
    ellipse(mouseX, mouseY, 50, 50);
    noFill();
    //when possession is 1, the ellipse is red, when possession is 0, the ellipse is blue, when possession is 66, the ellipse is white
    //when mouse is pressed, the ellipse gets bigger for a split second

    if (possession == POSSESSION_HOME) {
      stroke(POSSESSION_HOME_COLOUR); // set stroke color to Northern Ireland jersey color
    } else if (possession == POSSESSION_AWAY) {
      stroke(POSSESSION_AWAY_COLOUR); // set stroke color to Finald jersey color
    } else {
      stroke(255); // default stroke color
    }

    //if pass, goal, or out is pressed, the ellipse gets bigger for a split second
    if (pass == 1)
      ellipse(mouseX, mouseY, 100, 100);
    if (home == 1)
      //goal.gif is added to middle of screen
      image(goal_img, (width/2)-300, 300, 700, (height/2));


    int leftPad = 10;
    int rightPad = 1340;

    //Instructions on screen
    text("Mouse Click - Possession Change", leftPad, 30);
    text("Press 'A' - Pass", leftPad, 55);
    text("Press '1' - Goal", leftPad, 80);
    //text("Press '2' - Behind", leftPad, 105);
    // text("Press 'J' - T1", leftPad, 130);
    // text("Press 'K' - T2", leftPad, 155);
    // text("Press 'L' - T3", leftPad, 180);
    // text("Press 'D' - OOB", leftPad, 205);

    // write output as text on screen for testing purposes.
    text("Timestamp: " + String.format("%.02f", timestamp), rightPad, 30);
    text("X: " + mouseX/15, rightPad, 55);
    text("Y: " + mouseY/15, rightPad, 80);
    text("Possession: " + possession, rightPad, 105);
    text("Pass: " + pass, rightPad, 130);
    text("Goal: " + goal, rightPad, 155);
    //text("OOB: " + oob, rightPad, 180);


    if (state == State.PAUSED) {
      imageMode(CENTER);
      image(paused, width/2+17, height/2, 1200, 750);
    }

    //Everything within this if statement occurs every n seconds and sends the information to the AWS server.
    int clock = millis();
    if (state == State.ONGOING && clock > time + MILLI_SEC_DELAY) {

      // Iterate timestamp by MILLI_SEC_DELAY = 500; seconds.
      float elapsed = clock - time;
      println("Elapsed time since last request: " + elapsed);

      time = clock;
      timestamp = (float)time / 1000.0 - checkpoint;

      webSendJson(toJsonRequest());
      saveAppend(toTautJson());

      //Ensure that the vibrations only l bast one frame.
      this.reset();
    }

    //Controller variables.
    onKeyPressed(keyPressed, key);

    // Check if mouse is pressed and modify possession accordingly
    if (mousePressed) {
      if (possession == 1) {
        possession = 0;
      }
      else {
        possession = 1; 
      }
      // Reset mousePressed to false after changing possession
      mousePressed = false;
    }
  }

  void onKeyPressed(boolean keyPressed, char key) {
    if (!keyPressed) {
      lastKeyPressed = '\\';
      return;
    }

    char k = Character.toUpperCase(key);
    if (lastKeyPressed == k) {
      return;
    }
    lastKeyPressed = k;

    if (k == 'E') {
      visible = leave;
      return;
    }

    if (k == ' ') {
      if (state == State.PAUSED) {
        state = State.ONGOING;
        return;
      }

      state = State.PAUSED;
      checkpoint = timestamp;
      timestamp = 0;
      return;
    }

    if (state != State.ONGOING) {
      return;
    }

    switch (k) {

    case '1':
      if (goal == 0) {
        goal = 1;
      }
      break;
    
    case '2':
      if (oob == 0) {
        oob = 1;
      }
      break;
      
    case 'A':
      if (pass == 0) {
        pass = 1;
      }
      break;

    case 'J':
      if (tutorial == 0) {
        tutorial = 1;
      }
      break;
    
    case 'K':
      if (tutorial == 0) {
        tutorial = 2;
      }
      break;
    
    case 'L':
      if (tutorial == 0) {
        tutorial = 3;
      }
      break;
    
    case 'D':
      if (tutorial == 0) {
        oob = 1;
      }
      break;

    }
  }

  public void start() {
    state = State.PAUSED;
    webConnect(url);
    saveStart(stadium);
  }

  public void finish() {
    state = State.FINISHED;
    webDisconnect();
    saveEnd();
  }

  void reset() {
    if (pass == 1) {
      pass = 0;
    }
    if (home == 1) {
      home = 0;
    }
    if (away == 1) {
      away = 0;
    }
    if (goal == 1) {
      goal = 0;
    }
    if (tutorial != 0) {
      tutorial = 0;
    }
    if (oob ==1) {
      oob = 0;
    }
  }
}
