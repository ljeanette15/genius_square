import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const GeominoesApp());


class GeominoesApp extends StatelessWidget {
  const GeominoesApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<HomePage> {
  List<List<bool>> grid = List.generate(7, (i) => List.generate(7, (j) => false));
  bool redSquareInGrid = false;

  @override
  Widget build(BuildContext context) {

    double wd = MediaQuery.of(context).size.width;
    double ht = MediaQuery.of(context).size.height;
    double gridDim = min(wd, ht) / 2;

    return Scaffold(
      body: Center(
        // Column is like VStack. 
        // I need something similar to a Zstack so the pieces go over the grid
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Margin above grid (there's probably a better way to do this)
            SizedBox(
              width: gridDim / 4,
              height: gridDim / 4
            ),

            // Grid is a GridView inside of a SizedBox
            SizedBox(
              width: gridDim,
              height: gridDim,
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
                    child: Container(
                      // Make this based on screen size somehow
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: grid[rowIndex][colIndex] ? Colors.red : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  );
                },
                itemCount: 7 * 7,
              ),
            ),
            // The red square that will be dragged
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
