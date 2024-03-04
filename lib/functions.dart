import "dart:math";
import "package:flutter/material.dart";

// Functions
List<int> getBlockerIndeces() {
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

MaterialColor getStopwatchColor(seconds) {
  if (seconds < 20) {
    return Colors.green;
  }
  else if (seconds < 40) {
    return Colors.yellow;
  }
  else {
    return Colors.red;
  }
}
