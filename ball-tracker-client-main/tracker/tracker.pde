/*
Certainly! Here's a summarized list of the requirements for the processing app for Mada:

1. **Develop a Custom Processing App**:
   - Design the app to be more visually appealing and "sexier" than usual.

2. **Integration of Mada's Logo**:
   - Ensure Mada's logo is prominently displayed within the app.

3. **Removal of Redundant Stadium Options**:
   - Streamline the app by removing unnecessary stadium-related options.

4. **Setup on Bahrain AWS Server**:
   - Deploy the app on the Bahrain AWS server for optimal regional performance.
   - Alternatively, create a dedicated MQTT channel to ensure isolated operation and avoid interference with existing systems.

5. **Dual Language Interface (Arabic and English)**:
   - Include menu options and writing in both Arabic and English.
   - Assess the need for special libraries to support the Arabic alphabet in the app.

6. **Long-Term Showroom Deployment**:
   - Design the app with a consideration for permanent display in Mada's showroom.

7. **Export as a Standalone Executable (EXE) File**:
   - Similar to the Telstra project, provide the app in an executable format for easy deployment and use.

8. **Coordination with Team Members**:
   - Collaborate with Tim for the AWS server setup and MQTT channel implementation.
   - Receive and incorporate Arabic translations as provided for accurate language support.
*/

import websockets.*;

import controlP5.*;
import java.awt.Robot;
import processing.awt.PSurfaceAWT;
import processing.awt.PSurfaceAWT.SmoothCanvas;

ControlP5 controlP5;
ControlP5 cp5;
PImage img;
PImage[] images = new PImage[3];
PImage[] ball = new PImage[3];
PImage paused;
Robot robot;
PImage goal_img;

GamePage game;
MainPage menu;
LoginPage login;
LeavePage leave;
Page visible;

SmoothCanvas canvas;
int windowX = 0;
int windowY = 0;

int appWidth = 1530; // Default is 1530 
int appHeight = 963; // Defauly is 963 

char lastKeyPressed = '\\';

boolean connectionLost = false;

void settings() {
  size(appWidth, appHeight);
}

void setup() {
  cp5 = new ControlP5(this);
  canvas = (SmoothCanvas) ((PSurfaceAWT)surface).getNative();
  
  try {
    robot = new Robot();
  } catch (Exception e) {
    println(e.getMessage());
  }

  game = new GamePage();
  menu = new MainPage();
  login = new LoginPage();
  leave = new LeavePage();

  addPages(game, menu, login, leave);
  visible = menu;

  ball[0] = loadImage(dataPath(FIG_PATH) + File.separator + "Soccer.png");
  ball[1] = loadImage(dataPath(FIG_PATH) + File.separator + "AFLBall.png");
  ball[2] = loadImage(dataPath(FIG_PATH) + File.separator + "CricketBall.png");

  images[0] = loadImage(dataPath(FIG_PATH) + File.separator + "PitchCorrect.png");
  images[1] = loadImage(dataPath(FIG_PATH) + File.separator + "Australia.png");
  images[2] = loadImage(dataPath(FIG_PATH) + File.separator + "Cricket.png");


  paused = loadImage(dataPath(FIG_PATH) + File.separator + "Pause.png");
  goal_img = loadImage(dataPath(FIG_PATH) + File.separator + "goal.gif");

  frameRate(60);
  webSetup();
}

void draw() {
  visible.show();
  if (connectionLost) {
    displayConnectionWarning();
  }
  else {
    connectedCorrectly();
  }
}

void connectedCorrectly() {
  // This just sets the text back to white when the internet connection is working
  fill(255, 255, 255);
}

void displayConnectionWarning() {
  fill(255, 0, 0);
  textSize(32);
  textAlign(CENTER, CENTER);
  text("Internet connection lost!", width / 2, height / 2);
}


//Print what the websocket server is sending to the console.
void webSocketEvent(String msg) {
  println(msg);
}

void controlEvent(ControlEvent theEvent) {
  /* events triggered by controllers are automatically forwarded to 
   the controlEvent method. by checking the name of a controller one can 
   distinguish which of the controllers has been changed.
   */
  if (!theEvent.isController()) { 
    return;
  }
  
  switch(theEvent.getController().getName()) {
    case MainPage.LOGIN_LABEL:
      if (visible != menu) {
        return;
      }
      
      visible = login;
      return;
      
    case MainPage.LIST_LABEL:
      if (visible != menu) {
        return;
      }

      int selectedStadium = (int) cp5.getController(MainPage.LIST_LABEL).getValue();
      menu.onClickList(selectedStadium);
      return;

    case MainPage.START_LABEL:
      if (visible != menu) {
        return;
      }

      menu.onClickStart();
      visible = game;

      windowX = canvas.getFrame().getX();
      windowY = canvas.getFrame().getY();

      if (robot != null) {
        // Java.AWT.Robot bug
        // must move mouse to 0,0 or else it'll jump to a random location
        robot.mouseMove(0, 0);

        // this is a poor solution, for now
        // if you move the window around, it will not work anymore
        // I'm not sure what we need to get the mouse on the top left no matter where the window is
        robot.mouseMove(windowX - 40, windowY);
      }

      return;

    case LeavePage.LEAVE_PAGE_YES_LABEL:
      leave.onClickYes();
      visible = menu;
      return;

    case LeavePage.LEAVE_PAGE_NO_LABEL:
      leave.onClickNo();
      visible = game;
      return;
    
    case LoginPage.SUBMIT_LABEL:
      login.onClickSubmit();
      visible = menu;
      return;
  }
}
