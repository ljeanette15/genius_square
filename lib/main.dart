import 'package:flutter/material.dart';
import 'package:genius_square/shapes.dart';
import 'package:genius_square/functions.dart';
import 'dart:async';
import 'package:intl/intl.dart';

void main() => runApp(const GeominoesApp());

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

// Contains the state (the meat of the page)
class MainPageState extends State<MainPage> {
  
  var gridPosList = List<Offset>.generate(36, (int index) => Offset(0.0, 0.0));
  var draggableInitPosList = List<Offset>.generate(9, (int index) => Offset(0.0, 0.0));
  List<int> occupied = [];
  var draggableDraggedBool = false;
  var prevScreenWidth = 0.0;
  var prevScreenHeight = 0.0;

  List<int> blockerIndeces = getBlockerIndeces();

  Timer? timer;
  Stopwatch stopwatch = Stopwatch();

  bool started = false;

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
    if (!started || (screenWidth != prevScreenWidth || screenHeight != prevScreenHeight)) {
      for(var i = 0; i < 9; i++) {
        double x = (i % 3) * (screenWidth / 3) + (((screenWidth / 3) - gridSquareWidth) / 2);
        double y = (gridBottom + (((i ~/ 3) + (1 / 2)) * (bottomSectionHeight / 3)) - (gridSquareWidth / 2));
        draggableInitPosList[i] = Offset(x, y);
      }
      stopwatch.start();
      started = true;

      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
            print("${stopwatch.elapsed.inSeconds}");
          });
        }
      );

    }

    if (occupied.length == 29) {
      stopwatch.stop();
      return Stack(
        children: <Widget> [
          Positioned(
            top: (screenHeight / 2) - (gridSquareWidth * 1.5),
            left: (screenWidth / 2) - (gridSquareWidth * 1.5),
            child: 
            Container(
              decoration: BoxDecoration(
                color: getStopwatchColor(stopwatch.elapsed.inSeconds),
                borderRadius: BorderRadius.circular(gridSquareWidth)
              ),
              width: gridSquareWidth * 3, 
              height: gridSquareWidth * 3, 
              child: 
                Center(
                  child: 
                    Text(
                      "${stopwatch.elapsed.inSeconds}",
                      style: TextStyle(
                        fontSize: gridSquareWidth * 1.2,
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                        decoration: TextDecoration.none
                      ),
                    )
                )
            ),
          )
        ]
      );

    }
    else {
      prevScreenHeight = screenHeight;
      prevScreenWidth = screenWidth;
      return Stack(
        children: <Widget>[

          // Timer
          Positioned(
            top: gridTop,
            left: (gridLeft / 2) - (gridSquareWidth * 1.5),
            child: 
            Container(
              decoration: BoxDecoration(
                color: getStopwatchColor(stopwatch.elapsed.inSeconds),
                borderRadius: BorderRadius.circular(gridSquareWidth)
              ),
              width: gridSquareWidth * 3, 
              height: gridSquareWidth * 3, 
              child: 
                Center(
                  child: 
                    Text(
                      "${stopwatch.elapsed.inSeconds}",
                      style: TextStyle(
                        fontSize: gridSquareWidth * 1.2,
                        color: Colors.black,
                        fontStyle: FontStyle.normal,
                        decoration: TextDecoration.none
                      ),
                    )
                ),
            )
          ),

          // Date
          Positioned(
            top: gridTop,
            left: gridRight + ((screenWidth - gridRight) / 2) - gridSquareWidth * 1.5,
            child: 
              Container(
                width: gridSquareWidth * 3,
                height: gridSquareWidth * 3,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black),
                  borderRadius: BorderRadius.circular(gridSquareWidth)
                ),
                child: 
                    Center(
                      child:
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Griddio",
                              style: TextStyle(
                                fontSize: gridSquareWidth * 0.8,
                                color: Colors.black,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.none
                              ),
                            ),
                            Text(
                              "${DateFormat.yMMMd().format(DateTime.now())}",
                              style: TextStyle(
                                fontSize: gridSquareWidth * 0.4,
                                color: Colors.black,
                                fontStyle: FontStyle.normal,
                                decoration: TextDecoration.none
                              ),
                            ),
                          ],
                        )
                    ),
              )
          ),

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
                        color: blockerIndeces.contains(i) ? Colors.grey.shade700 : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  });
                }),
              ),
            )
          ),

          // Pieces
          BigR(
            () {setState(() {
            });}, 
            draggableInitPosList[0], 
            Colors.red, 
            gridSquareWidth, 
            spacer, gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            0),
          TDragBox(
            () {setState(() {
            });}, 
            draggableInitPosList[1], 
            Colors.orange, 
            gridSquareWidth, 
            spacer, 
            gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            1),
          SDragBox(
            () {setState(() {
            });}, 
            draggableInitPosList[2], 
            Colors.yellow, 
            gridSquareWidth, 
            spacer, 
            gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            2),
          QuadDragBox(
            () {setState(() {
            });}, 
            draggableInitPosList[3], 
            Colors.green, 
            gridSquareWidth, 
            spacer, 
            gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            3),
          BigDragBox(
            () {setState(() {
            });},           
            draggableInitPosList[4], 
            Colors.teal, 
            gridSquareWidth, 
            spacer, 
            gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            4),
          SmallR(
            () {setState(() {
            });},          
            draggableInitPosList[5], 
            Colors.cyan, 
            gridSquareWidth, 
            spacer, 
            gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            5),
          SingleDragBox(
            () {setState(() {
            });},           
            draggableInitPosList[6], 
            Colors.blue, 
            gridSquareWidth, 
            spacer, 
            gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            6),
          DoubleDragBox(
            () {setState(() {
            });}, 
            draggableInitPosList[7], 
            Colors.indigo, 
            gridSquareWidth, 
            spacer, gridLeft, 
            gridRight, gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            7
          ),
          TripleDragBox(
            () {setState(() {
            });}, 
            draggableInitPosList[8], 
            Colors.purple, 
            gridSquareWidth, 
            spacer, 
            gridLeft, 
            gridRight, 
            gridTop, 
            gridBottom, 
            blockerIndeces, 
            occupied, 
            8),

        ]
      );
    }
  }
}