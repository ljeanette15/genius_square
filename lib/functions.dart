
int getMonthDaysElapsed(int month) {
  if (month == 1) {
    return 0;
  } else if (month == 2) {
    return 31;
  } else if (month == 3) {
    return 31 + 28;
  } else if (month == 4) {
    return 31 + 28 + 31;
  } else if (month == 5) { 
    return 31 + 28 + 31 + 30;
  } else if (month == 6) {
    return 31 + 28 + 31 + 30 + 31;
  } else if (month == 7) {
    return 31 + 28 + 31 + 30 + 31 + 30;
  } else if (month == 8) {
    return 31 + 28 + 31 + 30 + 31 + 30 + 31;
  } else if (month == 9) {
    return 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31;
  } else if (month == 10) {
    return 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30;
  } else if (month == 11) {
    return 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31;
  } else {
    return 31 + 28 + 31 + 30 + 31 + 30 + 31 + 31 + 30 + 31 + 30;
  }
}

int getGameNum() {
  var startDate = DateTime.utc(2024, 1, 1);
  var todayDate = DateTime.now();
  var gameNum = ((todayDate.year - startDate.year) * 365) + getMonthDaysElapsed(todayDate.month) + ((todayDate.day - startDate.day));
  return gameNum;
}

// TODO: Need to make blocker indeces more random. Right now only one really changes
List<int> getBlockerIndeces() {

  int gameNum = getGameNum();

  var blockerIndeces = List<int>.generate(7, (int index) => index);

  List<int> diceOne = [27, 34, 29, 33, 28, 22];
  List<int> diceTwo = [3, 35, 16, 23, 17, 10];
  List<int> diceThree = [15, 26, 9, 21, 14, 20];
  List<int> diceFour = [0, 32, 18, 25, 19, 12];
  List<int> diceFive = [13, 7, 8, 2, 1, 6];
  List<int> diceSix = [4, 24, 11, 31];
  List<int> diceSeven = [5, 30];

  blockerIndeces[0] = diceOne[gameNum % 6];
  blockerIndeces[1] = diceTwo[(gameNum / 6).floor() % 6];
  blockerIndeces[2] = diceThree[(gameNum / (6 * 6)).floor() % 6];
  blockerIndeces[3] = diceFour[(gameNum / (6 * 6 * 6)).floor() % 6];
  blockerIndeces[4] = diceFive[(gameNum / (6 * 6 * 6 * 6)).floor() % 6];
  blockerIndeces[5] = diceSix[(gameNum / (6 * 6 * 6 * 6 * 6)).floor() % 4];
  blockerIndeces[6] = diceSeven[(gameNum / (6 * 6 * 6 * 6 * 6 * 4)).floor() % 2];

  return blockerIndeces;
}
