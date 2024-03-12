import 'package:flutter/material.dart';

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
        borderRadius: BorderRadius.circular(width / 12)
      ),
    );
  }
}

// Class for the single square
class SingleDragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const SingleDragBox(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  SingleDragBoxState createState() => SingleDragBoxState();
}

class SingleDragBoxState extends State<SingleDragBox> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  int prevIndex = -1;

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

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            // Determine what index of the grid this spot is (to check whether it's open or not)
            double xPos = details.offset.dx - widget.gridLeft;
            int xIndex = (xPos / (widget.width + widget.spacer)).round();
            double yPos = (details.offset.dy - widget.gridTop);
            int yIndex = (yPos / (widget.width + widget.spacer)).round();
            int index = (6 * yIndex) + xIndex;

            double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
            double zeroPadded = 0.0 - (widget.width / 2);

            // Check if the block is in the grid at all
            if (xPos < gridDimPadded && xPos > zeroPadded &&
                yPos < gridDimPadded && yPos > zeroPadded) {
            
              // If the square isn't on a blocker or occupied spot
              if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index)) {
                
                setState(() {
                  
                  // Determine where it needs to be in order to lock to the grid
                  double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                
                  position = Offset(xpos, ypos);
                  dragEnded = true;

                  widget.occupied.add(index);
                  widget.onUpdate();
                  
                  prevIndex = index;
                });
              
              // If the spot is occupied, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                });
              }

            // If the square is dropped outside the grid, return to original position
            } else {
              setState(() {
                position = widget.initPos;
                dragEnded = false;
                prevIndex = -1;
              });
            }
          },
        feedback: RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width * 0.9),
        child: RoundBox(itemColor: widget.itemColor, width: widget.width),
      )
    );
  }
}


// Class for the double square
class DoubleDragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  DoubleDragBox(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  DoubleDragBoxState createState() => DoubleDragBoxState();
}

class DoubleDragBoxState extends State<DoubleDragBox> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  bool rotated = false;
  int prevIndex = -1;
  int prevIndex2 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = !rotated;
            position = widget.initPos;
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
            }
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            
            if (!rotated) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                });
              }
            } else { // Rotated

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double gridDimPadded = (widget.gridRight - widget.gridLeft) - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                });
              }
            } 
          },

          feedback:         
          Builder(
            builder:(context) {
              if (rotated) {
                return Column(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width)
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width)
                  ],
                );
              }
            },
          ),
          child: 
          Builder(
            builder:(context) {
              if (rotated) {
                return Column(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width)
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width)
                  ],
                );
              }
            },
          )
              
        )
      ),

    );
  }
}


// Class for the triple square
class TripleDragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const TripleDragBox(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  TripleDragBoxState createState() => TripleDragBoxState();
}

class TripleDragBoxState extends State<TripleDragBox> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  bool rotated = false;
  int prevIndex = -1;
  int prevIndex2 = -1;
  int prevIndex3 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = !rotated;
            position = widget.initPos;
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
            }
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            
            if (!rotated) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                });
              }
            } else {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + 2 * (widget.spacer + widget.width) - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double gridDimPadded = (widget.gridRight - widget.gridLeft) - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                });
              }
            } 
          },
          
          feedback:         
          Builder(
            builder:(context) {
              if (rotated) {
                return Column(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width)
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width)
                  ],
                );
              }
            },
          ),
          child: 
          Builder(
            builder:(context) {
              if (rotated) {
                return Column(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width)
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width)
                  ],
                );
              }
            },
          )
              
        )
      ),

    );
  }
}


// Class for the quadruple square
class QuadDragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const QuadDragBox(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  QuadDragBoxState createState() => QuadDragBoxState();
}

class QuadDragBoxState extends State<QuadDragBox> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  bool rotated = false;
  int prevIndex = -1;
  int prevIndex2 = -1;
  int prevIndex3 = -1;
  int prevIndex4 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = !rotated;
            position = widget.initPos;
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
            }
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            
            if (!rotated) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + 3 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + 2 * (widget.spacer + widget.width) - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + 3 * (widget.spacer + widget.width) - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = (widget.gridRight - widget.gridLeft) - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } 
          },
          
          feedback:         
          Builder(
            builder:(context) {
              if (rotated) {
                return Column(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                  ],
                );
              }
            },
          ),
          child: 
          Builder(
            builder:(context) {
              if (rotated) {
                return Column(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    RoundBox(itemColor: widget.itemColor, width: widget.width),
                  ],
                );
              }
            },
          )
              
        )
      ),

    );
  }
}


// Class for the big square
class BigDragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const BigDragBox(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  BigDragBoxState createState() => BigDragBoxState();
}

class BigDragBoxState extends State<BigDragBox> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  bool rotated = false;
  int prevIndex = -1;
  int prevIndex2 = -1;
  int prevIndex3 = -1;
  int prevIndex4 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = !rotated;
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            // Check if the block is in the grid at all
            if (details.offset.dx > (widget.gridLeft - widget.width / 2) && ((details.offset.dx + widget.spacer + widget.width) < widget.gridRight - widget.width / 2) &&
                details.offset.dy > (widget.gridTop - widget.width / 2) && ((details.offset.dy + widget.spacer + widget.width) < widget.gridBottom - widget.width / 2)) {
              
              // Determine what index of the grid this spot is (to check whether it's open or not)
              int xIndex = ((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round();
              int yIndex = ((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              int xIndex2 = ((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round();
              int yIndex2 = ((details.offset.dy + widget.spacer + widget.width - widget.gridTop) / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;
            
              int xIndex3 = ((details.offset.dx + widget.spacer + widget.width - widget.gridLeft) / (widget.width + widget.spacer)).round();
              int yIndex3 = ((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              int xIndex4 = ((details.offset.dx + widget.spacer + widget.width - widget.gridLeft) / (widget.width + widget.spacer)).round();
              int yIndex4 = ((details.offset.dy + widget.spacer + widget.width - widget.gridTop) / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              // If the square isn't on a blocker or occupied spot
              if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                setState(() {
                  
                  // Determine where it needs to be in order to lock to the grid
                  double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                
                  position = Offset(xpos, ypos);
                  dragEnded = true;
                  widget.occupied.add(index);
                  widget.occupied.add(index2);
                  widget.occupied.add(index3);
                  widget.occupied.add(index4);
                  widget.onUpdate();
                  
                  prevIndex = index;
                  prevIndex2 = index2;
                  prevIndex3 = index3;
                  prevIndex4 = index4;
                });
              
              // If the spot is occupied, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }

            // If the square is dropped outside the grid, return to original position
            } else {
              setState(() {
                position = widget.initPos;
                dragEnded = false;
                prevIndex = -1;
                prevIndex2 = -1;
                prevIndex3 = -1;
                prevIndex4 = -1;
              });
            }
          },
          
          feedback:         
          Row(
            children: <Widget> [
              Column(
                children: <Widget> [
                  RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                  Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                  RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                ],
              ),
              Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: 2 * widget.width + widget.spacer,),
              Column(
                children: <Widget> [
                  RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                  Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                  RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                ],
              ),
            ],
          ),
          child: 
          Row(
            children: <Widget> [
              Column(
                children: <Widget> [
                  RoundBox(itemColor: widget.itemColor, width: widget.width),
                  Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                  RoundBox(itemColor: widget.itemColor, width: widget.width),
                ],
              ),
              Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: 2 * widget.width + widget.spacer,),
              Column(
                children: <Widget> [
                  RoundBox(itemColor: widget.itemColor, width: widget.width),
                  Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                  RoundBox(itemColor: widget.itemColor, width: widget.width),
                ],
              ),
            ],
          ),
        )
      ),

    );
  }
}


// Class for the small r
class SmallR extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const SmallR(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  SmallRState createState() => SmallRState();
}

class SmallRState extends State<SmallR> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  int rotated = 0;
  int prevIndex = -1;
  int prevIndex2 = -1;
  int prevIndex3 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = (rotated + 1) % 4;
            position = widget.initPos;
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
            }
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            
            if (rotated == 0) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && 
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;

                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                });
              }
            } else if (rotated == 1) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && 
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded) {

                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3))  {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.onUpdate();
        
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                  
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                });
              }
            } else if (rotated == 2) {
          
              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx + widget.spacer + widget.width - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && 
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded) {

                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3))  {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.onUpdate();
        
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                  
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                });
              }
            } else {
          
              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && 
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded) {

                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3))  {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.onUpdate();
        
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                  
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                });
              }
            } 
          },

          feedback:         
          Builder(
            builder:(context) {
              if (rotated == 0) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else if (rotated == 1) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else if (rotated == 2) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          child: 
          Builder(
            builder:(context) {
              if (rotated == 0) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else if (rotated == 1) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else if (rotated == 2) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          )
              
        )
      ),

    );
  }
}


// Class for the big r
class BigR extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const BigR(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  BigRState createState() => BigRState();
}

class BigRState extends State<BigR> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  int rotated = 0;
  int prevIndex = -1;
  int prevIndex2 = -1;
  int prevIndex3 = -1;
  int prevIndex4 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = (rotated + 1) % 4;
            position = widget.initPos;
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
            }
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            
            if (rotated == 0) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else if (rotated == 1) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + (2 * (widget.spacer + widget.width)) - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = (widget.gridRight - widget.gridLeft) - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else if (rotated == 2) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + 2 * (widget.spacer + widget.width) - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + 2 * (widget.spacer + widget.width) - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } 
          },

          feedback:         
          Builder(
            builder:(context) {
              if (rotated == 0) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else if (rotated == 1) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else if (rotated == 2) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          
          child: 
          Builder(
            builder:(context) {
              if (rotated == 0) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else if (rotated == 1) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else if (rotated == 2) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          )
              
        )
      ),

    );
  }
}


// Class for the T
class TDragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const TDragBox(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  TDragBoxState createState() => TDragBoxState();
}

class TDragBoxState extends State<TDragBox> {
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  int rotated = 0;
  int prevIndex = -1;
  int prevIndex2 = -1;
  int prevIndex3 = -1;
  int prevIndex4 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = (rotated + 1) % 4;
            position = widget.initPos;
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
            }
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            
            if (rotated == 0) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else if (rotated == 1) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx + widget.spacer + widget.width - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + (2 * (widget.spacer + widget.width)) - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = (widget.gridRight - widget.gridLeft) - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else if (rotated == 2) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx + widget.spacer + widget.width - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + 2 * (widget.spacer + widget.width) - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } 
          },

          feedback:         
          Builder(
            builder:(context) {
              if (rotated == 0) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else if (rotated == 1) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else if (rotated == 2) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          
          child: 
          Builder(
            builder:(context) {
              if (rotated == 0) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else if (rotated == 1) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else if (rotated == 2) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                  ],
                );
              }  else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          )
              
        )
      ),

    );
  }
}


// Class for the S
class SDragBox extends StatefulWidget {
  final Offset initPos;
  final Color itemColor;
  final double width;
  final double spacer;
  final double gridLeft;
  final double gridRight;
  final double gridTop;
  final double gridBottom;
  final List<int> blockerPosList;
  final List<int> occupied;
  final int identifier;

  final Function() onUpdate;

  const SDragBox(this.onUpdate, this.initPos, this.itemColor, this.width, this.spacer, this.gridLeft, this.gridRight, this.gridTop, this.gridBottom, this.blockerPosList, this.occupied, this.identifier);

  @override
  SDragBoxState createState() => SDragBoxState();
}

class SDragBoxState extends State<SDragBox> {  
  Offset position = const Offset(0.0, 0.0);
  bool dragEnded = false;
  bool rotated = false;
  int prevIndex = -1;
  int prevIndex2 = -1;
  int prevIndex3 = -1;
  int prevIndex4 = -1;

  @override
  Widget build(BuildContext context) {
    if (!dragEnded) {
      position = widget.initPos;
    }
    return Positioned(

      // Keep track of position by positioning it into a stack using left and top of the shape
      left: position.dx,
      top: position.dy,

      child: GestureDetector(

        onTap: () {
          setState(() {
            rotated = !rotated;
            position = widget.initPos;
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
            }
          });
        },

        child: 
        Draggable(
          data: widget.identifier,

          onDragStarted: () {
            // Remove previous position from occupied list
            if (widget.occupied.contains(prevIndex)) {
              widget.occupied.remove(prevIndex);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex2)) {
              widget.occupied.remove(prevIndex2);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex3)) {
              widget.occupied.remove(prevIndex3);
              widget.onUpdate();
            }
            if (widget.occupied.contains(prevIndex4)) {
              widget.occupied.remove(prevIndex4);
              widget.onUpdate();
            }
          },

          // When the drag ends, calculate where it is on the grid then decide if it should be dropped or returned back
          onDragEnd: (details) {
            
            if (!rotated) {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx + widget.spacer + widget.width - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx + 2 * (widget.spacer + widget.width) - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = widget.gridRight - widget.gridLeft - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } else {

              // Determine what index of the grid this spot is (to check whether it's open or not)
              double xPos = details.offset.dx - widget.gridLeft;
              int xIndex = (xPos / (widget.width + widget.spacer)).round();
              double yPos = (details.offset.dy - widget.gridTop);
              int yIndex = (yPos / (widget.width + widget.spacer)).round();
              int index = (6 * yIndex) + xIndex;

              double xPos2 = (details.offset.dx - widget.gridLeft);
              int xIndex2 = (xPos2 / (widget.width + widget.spacer)).round();
              double yPos2 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex2 = (yPos2 / (widget.width + widget.spacer)).round();
              int index2 = (6 * yIndex2) + xIndex2;

              double xPos3 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex3 = (xPos3 / (widget.width + widget.spacer)).round();
              double yPos3 = (details.offset.dy + widget.spacer + widget.width - widget.gridTop);
              int yIndex3 = (yPos3 / (widget.width + widget.spacer)).round();
              int index3 = (6 * yIndex3) + xIndex3;

              double xPos4 = (details.offset.dx + widget.spacer + widget.width - widget.gridLeft);
              int xIndex4 = (xPos4 / (widget.width + widget.spacer)).round();
              double yPos4 = (details.offset.dy + (2 * (widget.spacer + widget.width)) - widget.gridTop);
              int yIndex4 = (yPos4 / (widget.width + widget.spacer)).round();
              int index4 = (6 * yIndex4) + xIndex4;

              double gridDimPadded = (widget.gridRight - widget.gridLeft) - (widget.width / 2);
              double zeroPadded = 0.0 - (widget.width / 2);

              // Check if the block is in the grid at all
              if (xPos < gridDimPadded && xPos > zeroPadded && xPos2 < gridDimPadded && xPos2 > zeroPadded && xPos3 < gridDimPadded && xPos3 > zeroPadded && xPos4 < gridDimPadded && xPos4 > zeroPadded &&
                  yPos < gridDimPadded && yPos > zeroPadded && yPos2 < gridDimPadded && yPos2 > zeroPadded && yPos3 < gridDimPadded && yPos3 > zeroPadded && yPos4 < gridDimPadded && yPos4 > zeroPadded) {
              
                // If the square isn't on a blocker or occupied spot
                if (!widget.blockerPosList.contains(index) && !widget.occupied.contains(index) && 
                    !widget.blockerPosList.contains(index2) && !widget.occupied.contains(index2) && 
                    !widget.blockerPosList.contains(index3) && !widget.occupied.contains(index3) && 
                    !widget.blockerPosList.contains(index4) && !widget.occupied.contains(index4)) {
                  
                  setState(() {
                    
                    // Determine where it needs to be in order to lock to the grid
                    double xpos = widget.gridLeft + (((details.offset.dx - widget.gridLeft) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                    double ypos = widget.gridTop + (((details.offset.dy - widget.gridTop) / (widget.width + widget.spacer)).round()) * (widget.width + widget.spacer);
                  
                    position = Offset(xpos, ypos);
                    dragEnded = true;

                    widget.occupied.add(index);
                    widget.occupied.add(index2);
                    widget.occupied.add(index3);
                    widget.occupied.add(index4);
                    widget.onUpdate();
                    
                    prevIndex = index;
                    prevIndex2 = index2;
                    prevIndex3 = index3;
                    prevIndex4 = index4;
                  });
                
                // If the spot is occupied, return to original position
                } else {
                  setState(() {
                    position = widget.initPos;
                    dragEnded = false;
                    prevIndex = -1;
                    prevIndex2 = -1;
                    prevIndex3 = -1;
                    prevIndex4 = -1;
                  });
                }

              // If the square is dropped outside the grid, return to original position
              } else {
                setState(() {
                  position = widget.initPos;
                  dragEnded = false;
                  prevIndex = -1;
                  prevIndex2 = -1;
                  prevIndex3 = -1;
                  prevIndex4 = -1;
                });
              }
            } 
          },
          
          feedback:         
          Builder(
            builder:(context) {
              if (rotated) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width)
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width)
                      ],
                    )
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.2), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          ),
          child: 
          Builder(
            builder:(context) {
              if (rotated) {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width)
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width)
                      ],
                    )
                  ],
                );
              } else {
                return Row(
                  children: <Widget> [
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                      ],
                    ),
                    Container(color: Colors.white.withOpacity(0), width: widget.spacer, height: widget.width,),
                    Column(
                      children: <Widget> [
                        RoundBox(itemColor: widget.itemColor, width: widget.width),
                        Container(color: Colors.white.withOpacity(0), width: widget.width, height: widget.spacer,),
                        RoundBox(itemColor: widget.itemColor.withOpacity(0.0), width: widget.width),
                      ],
                    ),
                  ],
                );
              }
            },
          )
              
        )
      ),

    );
  }
}

