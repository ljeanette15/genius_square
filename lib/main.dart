import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const GeominoesApp());

// Functions
List getBlockerIndeces() {
  var blockerIndeces = List<int>.generate(7, (int index) => index);

  List<int> diceOne = [27, 34, 29, 33, 28, 22];
  List<int> diceTwo = [3, 35, 16, 23, 17, 10];
  List<int> diceThree = [15, 26, 9, 21, 14, 20];
  List<int> diceFour = [0, 32, 18, 25, 19, 12];
  List<int> diceFive = [5, 30, 5, 5, 30, 30];
  List<int> diceSix = [13, 7, 8, 2, 1, 6];
  List<int> diceSeven = [4, 24, 4, 11, 31, 31];

  blockerIndeces[0] = diceOne[Random().nextInt(6)];
  blockerIndeces[1] = diceTwo[Random().nextInt(6)];
  blockerIndeces[2] = diceThree[Random().nextInt(6)];
  blockerIndeces[3] = diceFour[Random().nextInt(6)];
  blockerIndeces[4] = diceFive[Random().nextInt(6)];
  blockerIndeces[5] = diceSix[Random().nextInt(6)];
  blockerIndeces[6] = diceSeven[Random().nextInt(6)];

  return blockerIndeces;
}

// Main app Widget
class GeominoesApp extends StatelessWidget {
  const GeominoesApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainPage(),
    );
  }
}

// Home page (even though there's only one page)
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => MainPageState();
}

// Create a class for the red square
class RoundBox extends StatelessWidget {
  final Color itemColor;
  final double width;

  const RoundBox({
    super.key,
    required this.itemColor,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: width,
      decoration: BoxDecoration(
        color: itemColor,
        borderRadius: BorderRadius.circular(5)
      ),
    );
  }
}

// Class for the dragged boxes
class DragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final int identifier;


  const DragBox(this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.identifier);

  @override
  DragBoxState createState() => DragBoxState();
}

class DragBoxState extends State<DragBox> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(
      left: position.dx,
      top: position.dy,
      child: Draggable(
        data: widget.identifier,
        onDragEnd: (details) {
          // If the block is in the grid at all
          if (details.offset.dx > widget.gridLeft && details.offset.dx < widget.gridRight &&
              details.offset.dy > widget.gridTop && details.offset.dy < widget.gridBottom) {
                setState(() {
                  // Determine where it needs to be in order to lock to the grid
                  double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  position = Offset(xpos, ypos);
                  dragEnded = true;
                });
          } else {
            setState(() {
              position = widget.initPos;
              dragEnded = false;
            });
          }
        },
        feedback: RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width * 0.9),
        child: RoundBox(itemColor: widget.itemColor, width: widget.width),
      )
    );
  }
}

// Contains the state (the meat of the page)
class MainPageState extends State<MainPage> {
  
  var gridPosList = List<Offset>.generate(36, (int index) => Offset(0.0, 0.0));
  var draggableInitPosList = List<Offset>.generate(9, (int index) => Offset(0.0, 0.0));
  var draggableDraggedBool = false;
  var prevScreenWidth = 0.0;
  var prevScreenHeight = 0.0;

  var blockerIndeces = getBlockerIndeces();

  @override
  Widget build(BuildContext context) {

    // Get screen dimensions to base the size off of
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double gridDim = screenHeight / 2.5;
    double gridLeft = (screenWidth - gridDim) / 2;
    double gridTop = (screenHeight - gridDim) / 6;
    double gridBottom = gridTop + gridDim;
    double gridRight = gridLeft + gridDim;
    double bottomSectionHeight = screenHeight - gridBottom;
    const spacer = 3.0;
    double gridSquareWidth = (gridDim - (5 * spacer)) / 6;
    
    // Get positions of grid squares
    for(var i = 0; i < 36; i++) {
      gridPosList[i] = Offset(gridLeft + ((i % 6) * (gridSquareWidth + spacer)), 
                              gridTop + ((i ~/ 6) * (gridSquareWidth + spacer)));
    }

    // Set positions of draggables if this is the initialization (or when screen size changes)
    if (!draggableDraggedBool || (screenWidth != prevScreenWidth || screenHeight != prevScreenHeight)) {
      for(var i = 0; i < 9; i++) {
        double x = (i % 3) * (screenWidth / 3) + (((screenWidth / 3) - gridSquareWidth) / 2);
        double y = (gridBottom + (((i ~/ 3) + (1 / 2)) * (bottomSectionHeight / 3)) - (gridSquareWidth / 2));
        draggableInitPosList[i] = Offset(x, y);
      }
    }

    prevScreenHeight = screenHeight;
    prevScreenWidth = screenWidth;

    return Stack(
      children: <Widget>[
        // Grid
        Positioned(
          left: gridLeft,
          top: gridTop,
          child: SizedBox(
            width: gridDim,
            height: gridDim,
            child: GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                crossAxisSpacing: spacer,
                mainAxisSpacing: spacer,
              ),
              children: List<Widget>.generate(36, (int i) {
                return Builder(builder: (BuildContext context) {
                  return Container(
                    decoration: BoxDecoration(
                      color: blockerIndeces.contains(i) ? Colors.white : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                });
              }),
            ),
          )
        ),

        // Pieces
        DragBox(draggableInitPosList[0], Colors.red, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 0),
        DragBox(draggableInitPosList[1], Colors.orange, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 1),
        DragBox(draggableInitPosList[2], Colors.yellow, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 2),
        DragBox(draggableInitPosList[3], Colors.green, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 3),
        DragBox(draggableInitPosList[4], Colors.teal, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 4),
        DragBox(draggableInitPosList[5], Colors.cyan, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 5),
        DragBox(draggableInitPosList[6], Colors.blue, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 6),
        DragBox(draggableInitPosList[7], Colors.indigo, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 7),
        DragBox(draggableInitPosList[8], Colors.purple, gridSquareWidth, spacer, gridLeft, gridRight, gridTop, gridBottom, 8),

      ]
    );
  }
}