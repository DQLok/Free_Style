class PointCorner {
  double dx;
  double dy;
  bool selectFirst;
  bool selectSeconds;
  DotPoint dotPoint;
  double percent;

  PointCorner(
      {required this.dx,
      required this.dy,
      required this.selectFirst,
      required this.selectSeconds,
      required this.dotPoint,
      required this.percent});

  bool notSelected() {
    return !selectFirst && !selectSeconds ? true : false;
  }

  bool selectChange(bool check) {
    if (notSelected()) {
      if (check) {
        selectFirst = true;
        selectSeconds = false;
      } else {
        selectFirst = false;
        selectSeconds = true;
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
