class PointCorner {
  double dx;
  double dy;
  bool selectMachine;
  bool selectPersonal;
  DotPoint dotPoint;
  double percent;

  PointCorner(
      {required this.dx,
      required this.dy,
      required this.selectMachine,
      required this.selectPersonal,
      required this.dotPoint,
      required this.percent});

  bool notSelected() {
    return !selectMachine && !selectPersonal ? true : false;
  }

  bool selectedMachine() {
    return selectMachine;
  }

  bool selectedPersonal() {
    return selectPersonal;
  }

  bool selectChange(bool check) {
    if (notSelected()) {
      if (check) {
        selectMachine = true;
        selectPersonal = false;
      } else {
        selectMachine = false;
        selectPersonal = true;
      }
      return true;
    }
    return false;
  }

  int pointX() {
    return dotPoint.x;
  }

  int pointY() {
    return dotPoint.y;
  }

  void setPointX(int x) {
    dotPoint.x = x;
  }

  void setPointY(int y) {
    dotPoint.y = y;
  }

  bool checkMatch(DotPoint dotPoint) {
    return this.dotPoint.x == dotPoint.x && this.dotPoint.y == dotPoint.y
        ? true
        : false;
  }

  @override
  String toString() {
    return "($dx - $dy - [${dotPoint.x},${dotPoint.y}]) - $percent\n";
  }
}

class DotPoint {
  int x;
  int y;
  DotPoint({
    required this.x,
    required this.y,
  });

  @override
  String toString() {
    return "[$x,$y]";
  }
}
