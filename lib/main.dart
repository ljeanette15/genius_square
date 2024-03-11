import 'package:flutter/material.dart';
import 'package:genius_square/shapes.dart';
import 'package:genius_square/functions.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

void main() => runApp(const GeominoesApp());

// Main app Widget
class GeominoesApp extends StatelessWidget {
  const GeominoesApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: InstructionPage(),
    );
  }
}

class InstructionPage extends StatefulWidget {
  const InstructionPage({super.key});

  @override
  State<InstructionPage> createState() => InstructionPageState();
}

class InstructionPageState extends State<InstructionPage> {
  
  @override
  Widget build(BuildContext context) {
    
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double boxWidth = (screenWidth < screenHeight) ? screenWidth * 0.8 : screenHeight * 0.8;
    double boxHeight = screenHeight / 2;

    double vertPadding = (screenWidth < screenHeight) ? ((screenWidth / 50) + 0.1 * (screenHeight - screenWidth)) : screenHeight / 50;
    double horPadding = (screenWidth < screenHeight) ? screenWidth / 50 : screenHeight / 50;

    double radius = (screenWidth < screenHeight) ? screenWidth / 100 : screenHeight / 100;
    double borderWeight = (screenWidth < screenHeight) ? screenWidth / 400 : screenHeight / 400;

    return Stack(
      children: [
        Positioned(
          bottom: screenHeight - (screenHeight / 6) + screenHeight / 100,
          left: (screenWidth - ((screenWidth < screenHeight) ? screenWidth * 0.8 : screenHeight * 0.8)) / 2,
          child: Container(
            width: boxWidth,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: borderWeight),
              borderRadius: BorderRadius.circular(radius)
            ),
            child: Center(
              child: Text(
                "Griddio",
                style: TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: (screenWidth < screenHeight) ? screenWidth / 10 : screenHeight / 10,
                  decoration: TextDecoration.none,
                ),
              ),
            )
          )
        ),
        
        Positioned(
          top: screenHeight / 6,
          left: (screenWidth - ((screenWidth < screenHeight) ? screenWidth * 0.8 : screenHeight * 0.8)) / 2,
          child:
          Container(
            padding: EdgeInsets.fromLTRB(horPadding, vertPadding, horPadding, vertPadding),
            width: boxWidth,
            height: boxHeight, 
            decoration: BoxDecoration(
              color: Colors.grey.shade400, 
              borderRadius: BorderRadius.circular(radius)
            ),
            child: Column(
              children: [
                Text(
                  "How To Play:",
                  style: TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: (screenWidth < screenHeight) ? screenWidth / 17 : screenHeight / 17,
                  decoration: TextDecoration.none,
                  ),
                ),
                SizedBox(height: boxHeight / 30,),
                Text(
                  "Fit every piece on the grid as fast as possible.",
                  style: TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: (screenWidth < screenHeight) ? screenWidth / 27 : screenHeight / 27,
                  decoration: TextDecoration.none,
                  ),
                ),
                Text(
                  "- Pieces cannot be placed on the dark squares   ",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: (screenWidth < screenHeight) ? screenWidth / 32 : screenHeight / 32,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.left,
                ),
                Text(
                  "- To rotate a piece, simply click or tap that piece",
                  style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontSize: (screenWidth < screenHeight) ? screenWidth / 32 : screenHeight / 32,
                    decoration: TextDecoration.none,
                  ),
                  textAlign: TextAlign.left,
                ),
                SizedBox(height: boxHeight / 20,),
                FilledButton(
                  onPressed: () async {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => MainPage(),
                        transitionDuration: Duration(milliseconds: 0),
                        transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                      ),
                    );
                  }, 
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(radius),
                      ),
                      padding: EdgeInsets.fromLTRB(boxWidth / 5, boxHeight / 20, boxWidth / 5, boxHeight / 20)
                    ),
                  child: 
                    Text(
                      "Start",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        color: Colors.black,
                        decoration: TextDecoration.none,
                        fontSize: (screenWidth < screenHeight) ? screenWidth / 20 : screenHeight / 20
                      ),
                    )
                ),
                SizedBox(height: boxHeight / 20,),
                Text(
                  "Come back every day for a new, unique configuration!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                  fontSize: (screenWidth < screenHeight) ? screenWidth / 32 : screenHeight / 32,
                  decoration: TextDecoration.none,
                  ),
                ),
              ],
            ),
          )
        ),
      ],
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
  
  var gridPosList = List<Offset>.generate(36, (int index) => const Offset(0.0, 0.0));
  var draggableInitPosList = List<Offset>.generate(9, (int index) => const Offset(0.0, 0.0));
  List<int> occupied = [];
  var draggableDraggedBool = false;
  var prevScreenWidth = 0.0;
  var prevScreenHeight = 0.0;

  List<int> blockerIndeces = getBlockerIndeces();

  Timer? timer;
  Stopwatch stopwatch = Stopwatch();

  bool started = false;

  String fontfamily = "Roboto";

  @override
  Widget build(BuildContext context) {

    // Get screen dimensions to base the size off of
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double gridDim1 = screenHeight / 2.4;
    double gridDim2 = screenWidth / 2.1;
    double gridDim = (gridDim1 < gridDim2) ? gridDim1 : gridDim2;
    double gridLeft = (screenWidth - gridDim) / 2;
    double gridTop = (screenHeight - gridDim) / 6;
    double gridBottom = gridTop + gridDim;
    double gridRight = gridLeft + gridDim;
    double spacer = gridDim / 200;
    double gridSquareWidth = (gridDim - (5 * spacer)) / 6;
    double corners = gridSquareWidth / 12;
    double gws = gridSquareWidth + spacer;
    
    // Get positions of grid squares
    for(var i = 0; i < 36; i++) {
      gridPosList[i] = Offset(gridLeft + ((i % 6) * (gridSquareWidth + spacer)), 
                              gridTop + ((i ~/ 6) * (gridSquareWidth + spacer)));
    }

    // Set positions of draggables if this is the initialization (or when screen size changes)
    if (!started || (screenWidth != prevScreenWidth || screenHeight != prevScreenHeight)) {

      double xbigR = (((screenWidth / 3) - (gws * 3)) / 2);
      double ybigR = gridBottom + 1.2 * gridSquareWidth;
      draggableInitPosList[0] = Offset(xbigR, ybigR);

      double xT = (gridLeft - 3 * gws) / 2;
      double yT = gridBottom - 2 * gws;
      draggableInitPosList[1] = Offset(xT, yT);

      double xS = gridRight + (gridLeft - 3 * gws) / 2;
      double yS = gridBottom - 2 * gws;
      draggableInitPosList[2] = Offset(xS, yS);

      double xQuad = (screenWidth / 3) + (((screenWidth / 3) - (4 * gws)) / 2);
      double yQuad = gridBottom + 1.2 * gridSquareWidth;
      draggableInitPosList[3] = Offset(xQuad, yQuad);

      double xTriple = 2 * (screenWidth / 3) + (((screenWidth / 3) - (3 * gws)) / 2);
      double yTriple = gridBottom + 1.2 * gridSquareWidth;
      draggableInitPosList[8] = Offset(xTriple, yTriple);

      double xSmallR = (((screenWidth / 3) - 2 * gws) / 2);
      double ySmallR = gridBottom + 4.4 * gws;
      draggableInitPosList[5] = Offset(xSmallR, ySmallR);

      double xDouble = (screenWidth / 3) + (((screenWidth / 3) - 2 * gws) / 2);
      double yDouble = gridBottom + 5.2 * gws;
      draggableInitPosList[7] = Offset(xDouble, yDouble);

      double xSingle = (screenWidth / 3) + (((screenWidth / 3) - gws) / 2);
      double ySingle = gridBottom + 3.2 * gws;
      draggableInitPosList[6] = Offset(xSingle, ySingle);

      double xBig = 2 * (screenWidth / 3) + (((screenWidth / 3) - 2 * gws) / 2);
      double yBig = gridBottom + 4.4 * gws;
      draggableInitPosList[4] = Offset(xBig, yBig);
      
      stopwatch.start();
      started = true;

      timer = Timer.periodic(
        const Duration(seconds: 1),
        (timer) {
          setState(() {
          });
        }
      );

    }

    if (occupied.length == 29) {
      stopwatch.stop();
      return Stack(
        children: <Widget> [
          Positioned(
            top: (screenHeight / 2) - (gridSquareWidth * 6),
            left: (screenWidth / 2) - (gridSquareWidth * 3),
            child: 
            Column(
              children: <Widget> [
                Container(
                  decoration: BoxDecoration(
                    color: getStopwatchColor(stopwatch.elapsed.inSeconds),
                    borderRadius: BorderRadius.circular(gridSquareWidth)
                  ),
                  width: gridSquareWidth * 6, 
                  height: gridSquareWidth * 3, 
                  child: 
                    Center(
                      child: 
                        Text(
                          "${stopwatch.elapsed.inSeconds}s",
                          style: TextStyle(
                            fontFamily: fontfamily,
                            fontSize: gridSquareWidth * 1.2,
                            color: Colors.black,
                            fontStyle: FontStyle.normal,
                            decoration: TextDecoration.none
                          ),
                        )
                    )
                ),
                RoundBox(itemColor: Colors.white.withOpacity(0.0), width: gridSquareWidth / 2),
                SizedBox(
                  width: gridSquareWidth * 6, 
                  height: gridSquareWidth,
                  child:                 
                    FilledButton(
                      onPressed: () async {
                        if (stopwatch.elapsed.inSeconds < 20){
                          await Clipboard.setData(ClipboardData(text: "Griddio #${getGameNum()}}: 🟢 ${stopwatch.elapsed.inSeconds}s" ));
                        } else if (stopwatch.elapsed.inSeconds < 40) {
                          await Clipboard.setData(ClipboardData(text: "Griddio #${getGameNum()}: 🟡 ${stopwatch.elapsed.inSeconds}s" ));
                        } else {
                          await Clipboard.setData(ClipboardData(text: "Griddio #${getGameNum()}: 🔴 ${stopwatch.elapsed.inSeconds}s" ));
                        }
                      }, 
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(gridSquareWidth / 4)
                        )
                      ),
                      child: 
                        Text(
                          "Share",
                          style: TextStyle(
                            fontFamily: fontfamily,
                            color: Colors.blue.shade800,
                            decoration: TextDecoration.none,
                            fontSize: gridSquareWidth * 0.6
                          ),
                        )
                    )
                ),
                RoundBox(itemColor: Colors.white.withOpacity(0.0), width: gridSquareWidth / 4),
                Container(
                  width: gridSquareWidth * 6,
                  height: gridSquareWidth * 2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(gridSquareWidth / 4),
                    color: Colors.grey,
                  ),
                  child:
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget> [
                        Text(
                          "Next Griddio in:",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: fontfamily,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontSize: gridSquareWidth * 0.8,
                          ),
                        ),
                        Text(
                          "${24 - DateTime.now().hour} hrs, ${60 - DateTime.now().minute} min, ${60 - DateTime.now().second} s",
                          style: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontFamily: fontfamily,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            fontSize: gridSquareWidth * 0.4,
                          ),
                        ),
                      ],
                    )
                )
              ],
            ),
          )
        ]
      );

    }
    else {
      prevScreenHeight = screenHeight;
      prevScreenWidth = screenWidth;
      return Stack(
        children: [

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
                        fontFamily: fontfamily,
                        fontSize: gridSquareWidth * 1.2,
                        color: Colors.black,
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
                                fontWeight: FontWeight.w400,
                                fontFamily: fontfamily,
                                fontSize: gridSquareWidth * 0.8,
                                color: Colors.black,
                                decoration: TextDecoration.none
                              ),
                            ),
                            Text(
                              DateFormat.yMMMd().format(DateTime.now()),
                              style: TextStyle(
                                fontWeight: FontWeight.w400,
                                fontFamily: fontfamily,
                                fontSize: gridSquareWidth * 0.4,
                                color: Colors.black,
                                decoration: TextDecoration.none
                              ),
                            ),
                          ],
                        )
                    ),
              )
          ),

          // Grid
          for (var i = 0; i < 36; i++) ... [
            Positioned(
              top: gridTop + (i / 6).floor() * gws,
              left: gridLeft + (i % 6) * gws,
              child: Container(
                width: gridSquareWidth,
                height: gridSquareWidth,
                decoration: BoxDecoration(
                  color: blockerIndeces.contains(i) ? Colors.grey.shade700 : Colors.grey,
                  borderRadius: BorderRadius.circular(corners),
                ),
              )
            )
          ],

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