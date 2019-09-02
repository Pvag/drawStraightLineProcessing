// Dragging mouse draws points to screen;
// if SHIFT is pressed before and at the beginning of mouse drag, draws a straight line, instead.

// Author: Paolo Vagnini
//         paolondon at gmail dot com

// github repo: https://github.com/Pvag/drawStraightLineProcessing

// Available Interactions:
// . dragging mouse (draws points)
// . dragging mouse while pressing the SHIFT key (draws lines interactively)

// The drawing of the line is interactive, meaning that the user can play around with its orientation,
// before deciding to actually finalize the line on the canvas.

// The sketch uses 2 layers to draw objects: one for the temporary line that is continously
// cleaned and re-drawn on a temporary layer, while dragging the mouse, with the SHIFT key pressed(*);
// the other layer is used to actually store the desired line, when the user releases the mouse button,
// after dragging with the SHIFT key pressed.

// Drawing of the temporary line only stops after mouse is released; then the permanent line is drawn.

// Trying the sketch out will let you understand this faster than reading my description, sorry !

// (*) This happens whether the SHIFT key is released before or after the mouse.

PVector start;
boolean isDrawingLine;
PGraphics tempLinesLayer; // layer for temporary lines (interactive functionality to better chose line orientation)
PGraphics permanentPointsAndLinesLayer; // layer with permanent objects (points and lines)
color bkgColor;

void setup() {
  size(600, 400);
  bkgColor = color(255);
  background(bkgColor);
  isDrawingLine = false;
  tempLinesLayer = createGraphics(width, height);
  permanentPointsAndLinesLayer = createGraphics(width, height);
}

void draw() {
  clearFinalImage();
  drawTempLineIfMouseStillPressedAfterDragging(); // needed because mouseDragged doesn't fire if mouse is not moving
  drawPermanentLayer();
}

// core function with most of the logic
// ====
// this program is event-driven, especially by this event
//
// . if the user is holding SHIFT + dragging the mouse, draw a line
// on the temporary layer
//
// . if the user has released SHIFT, but still dragging the mouse, keep
// drawing the line on the temporary layer
//
// . if the user was drawing the line, but has released the mouse button,
// render the final line on the permanent layer, whether the SHIFT button
// is still pressed or not
//
// . if the user is dragging, and has started dragging without pressing
// the SHIFT button, draw points on the permanent layer
//
// . if the user was drawing points, pressing SHIFT will start drawing a line
// on the temporary layer; releasing SHIFT will not stop from drawing the temporary line;
// only releasing the mouse will render the line on the permanent layer
//
// anyways, this behavior is easily customizable, by modifying the code
//
void mouseDragged() {
  if (keyCode == SHIFT) {
    if (!isDrawingLine) {
      setStartingPointOfLine();
      isDrawingLine = true;
    }
    else {
      updateTempLayer();
      drawTempLayer();
    }
  }
  else if (keyCode == ENTER && isDrawingLine) {
    updateTempLayer();
    drawTempLayer();
  }
  else {
    addPointToPermanentLayer(); // user is dragging without pressing SHIFT
  }
}

void drawTempLineIfMouseStillPressedAfterDragging() {
  if (mousePressed && isDrawingLine && mouseIsNotMoving()) {
    drawTempLayer();
  }
}

boolean mouseIsNotMoving() {
  return ( (pmouseX == mouseX) && (pmouseY == mouseY) );
}

// since the drawing happens on layers, clear the canvas from anything
// that was rendered at the previous frame; layers, together with the data they hold,
// will be added on top of this clean slate canvas
void clearFinalImage() {
  background(bkgColor);
}

// actually render the permanent layer to screen
void drawPermanentLayer() {
  image(permanentPointsAndLinesLayer, 0, 0);
}

void setStartingPointOfLine() {
  start = new PVector(mouseX, mouseY);
}

void updateTempLayer() {
  tempLinesLayer.beginDraw();
  tempLinesLayer.background(bkgColor, 0); // clean this layer at each call, but with 0 opacity !
  tempLinesLayer.line(start.x, start.y, mouseX, mouseY);
  tempLinesLayer.endDraw();
}

// draw the actual line on the temporary layer
void drawTempLayer() {
  image(tempLinesLayer, 0, 0);
}

void addPointToPermanentLayer() {
  permanentPointsAndLinesLayer.beginDraw();
  permanentPointsAndLinesLayer.point(mouseX, mouseY);
  permanentPointsAndLinesLayer.endDraw();
}

void addLineToPermanentLayer() {
  permanentPointsAndLinesLayer.beginDraw();
  permanentPointsAndLinesLayer.line(start.x, start.y, mouseX, mouseY);
  permanentPointsAndLinesLayer.endDraw();
}

// re-set drawing state to false and render the line on the permanent layer
void mouseReleased() {
  if (isDrawingLine) {
    isDrawingLine = false;
    //clearFinalImage();
    addLineToPermanentLayer();
    //drawPermanentLayer();
  }
}

// re-set the key
// TODO see if there's a way to set the key to a different value, e.g. NULL, instead of ENTER
void keyReleased() {
  if (keyCode == SHIFT) keyCode = ENTER; 
}
