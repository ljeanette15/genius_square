import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const GeominoesApp());

// Main app Widget
class GeominoesApp extends StatelessWidget {
  const GeominoesApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

// Home page (even though there's only one page)
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

// Contains the state (the meat of the page)
class _MyHomePageState extends State<HomePage> {
  List<List<bool>> grid = List.generate(7, (i) => List.generate(7, (j) => false));
  bool redSquareInGrid = false;

  @override
  Widget build(BuildContext context) {

    // Get screen dimensions to base the size off of
    double wd = MediaQuery.of(context).size.width;
    double ht = MediaQuery.of(context).size.height;
    double gridDim = min(wd, ht) / 2;

    return Scaffold(
      body: Center(
        // Column allows for vertical positioning
        child: Column(
          children: [
            // Epty box for margin above grid (there's probably a better way to do this)
            SizedBox(
              width: gridDim / 4,
              height: gridDim / 4
            ),

            // Box to hold the grid
            SizedBox(
              width: gridDim,
              height: gridDim,
              // The grid itself
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                ),
                // What does itemBuilder do?
                itemBuilder: (context, index) {
                  int rowIndex = index ~/ 7;
                  int colIndex = index % 7;
                  
                  return GestureDetector(
                    onTap: () {
                      if (redSquareInGrid) {
                        setState(() {
                          redSquareInGrid = false;
                          grid[rowIndex][colIndex] = true;
                        });
                      }
                    },

                    // The elements in the grid - need to change these to DragTargets
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },

                // Number of items in the grid
                itemCount: 7 * 7,

              ),
            ),

            // The square that will be dragged
            const SizedBox(height: 100),
            Draggable(
              feedback: Container(
                width: (gridDim - 12) / 7,
                height: (gridDim - 12) / 7,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(4)
                ),
              ),
              // Check if square is in grid - if it is set redSquareInGrid to true?
              onDragEnd: (details) {
                setState(() {
                  redSquareInGrid = true;
                });
              },
              // Not sure what this child is here for. The child is a bool
              child: redSquareInGrid
                  ? Container() // If red square is in the grid, hide the original red square
                  : Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4) ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
