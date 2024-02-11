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

// Contains the state (the meat of the page)
class _MyHomePageState extends State<HomePage> {
  List<List<bool>> grid = List.generate(7, (i) => List.generate(7, (j) => false));

  @override
  Widget build(BuildContext context) {

    // Get screen dimensions to base the size off of
    double wd = MediaQuery.of(context).size.width;
    double ht = MediaQuery.of(context).size.height;
    double gridDim = min(wd, ht) / 2;
    int acceptedData = 0;

    return Scaffold(
      body: Center(
        // Column allows for vertical positioning
        child: Column(
          children: [
            // Empty box for margin above grid (there's probably a better way to do this)
            SizedBox(
              width: gridDim / 4,
              height: gridDim / 4
            ),

            // Box to hold the grid - maybe place inside of a stack? IDK
            SizedBox(
              width: gridDim,
              height: gridDim,

              // The grid itself
              child: GridView.count(
                primary:false,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                crossAxisCount: 7,
                children: <Widget> [
                  DragTarget<int>(
                    builder: (
                      BuildContext context,
                      List<dynamic> accepted,
                      List<dynamic> rejected,
                    ) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ), 
                        child: Text('$acceptedData'),
                      );
                    },
                    onAccept: (int data) {
                      setState(() {
                        acceptedData += data;
                      });
                    },
                  ),
                  Container(
                     margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),                 
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),              
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),                 
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),              
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),              
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),                 
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),              
                  Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ]
              ),
            ),

            // The square that will be dragged
            Draggable<int>(
              data: 10,
              feedback: RoundBox(itemColor: Colors.teal.withOpacity(0.2), width: gridDim / 7,),
              child: RoundBox(itemColor: Colors.teal, width: gridDim / 7,)
            ),
          ],
        ),
      ),
    );
  }
}
