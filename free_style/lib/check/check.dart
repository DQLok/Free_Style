import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:free_style/check/data/point.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  static const int maxWin = 5;
  //create table
  TextEditingController controller = TextEditingController();
  int count = 1;
  double radius = 10;
  double large = 2;
  //list total
  List<PointCorner> listCorners = [];
  bool selectChange = false;
  List<PointCorner> listCornersPersonal = [];
  List<Offset> listCornersMachineWin = [];
  //list win
  List<Offset> listCornersPersonalWin = [];
  List<PointCorner> listCornersMachine = [];
  bool lockSettings = false;
  bool showInformation = false;
  bool checkWin = false;

  @override
  void initState() {
    super.initState();
  }

  createSize(double width, double height, double marginTop) {
    if (controller.text.isEmpty) return;
    listCorners = [];
    int? size = int.tryParse(controller.text);
    if (size == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter Number"),
      ));
      if (controller.text.trim().contains('lltm')) {
        lockSettings = true;
      } else {
        lockSettings = false;
      }
      return;
    }
    //----------
    listCornersPersonal = [];
    listCornersMachine = [];
    listCornersMachineWin = [];
    listCornersPersonalWin = [];
    checkWin = false;
    //----------
    count = size + 1;
    //corners
    for (int i = 0; i < count - 1; i++) {
      for (int j = 0; j < count - 1; j++) {
        listCorners.add(PointCorner(
            dx: (width / count) * (j + 1) - radius,
            dy: (height - marginTop) * (i + 1) / count - radius,
            selectMachine: false,
            selectPersonal: false,
            dotPoint: DotPoint(x: j, y: i),
            percent: 0));
      }
    }
    setState(() {});
  }

  selectPoint(TapUpDetails details, double marginTop) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.globalToLocal(details.globalPosition);
    int index = listCorners.indexWhere(
      (element) => ((element.dx + radius - offset.dx).abs() <= radius * 1.5 &&
          (element.dy + radius - (offset.dy - marginTop)).abs() <=
              radius * 1.5),
    );
    if (index != -1) {
      bool checkSelect =
          listCorners.elementAt(index).selectChange(selectChange);
      if (checkSelect) {
        PointCorner currentPoint = listCorners.elementAt(index);
        currentPoint.percent += 1 / 8;
        listCornersPersonal.add(currentPoint);
        // processWinPerson(person: listCornersPersonal, machine: null);
        // processMachine(currentPoint);
        processMachine(currentPoint);
      }
    }
    setState(() {});
  }

  processMachine(PointCorner currentPoint) {
    PointWithMaxLength futurePointPersonal =
        PointWithMaxLength(listPoint: [], pointCorner: null);
    PointWithMaxLength futurePointMachine =
        PointWithMaxLength(listPoint: [], pointCorner: null);
    if (listCornersMachine.isNotEmpty) {
      futurePointMachine = processListPoint(
          listCornersMachine: listCornersMachine,
          listCornersPersonal: [],
          currentPoint: currentPoint);
    }
    if (listCornersPersonal.isNotEmpty) {
      futurePointPersonal = processListPoint(
          listCornersMachine: [],
          listCornersPersonal: listCornersPersonal,
          currentPoint: currentPoint);
    }
    if (futurePointPersonal.pointCorner != null &&
        futurePointMachine.pointCorner != null) {
      if (futurePointMachine.listPoint.length >=
          futurePointPersonal.listPoint.length) {
        selectPointMachine(
            futurePointMachine.pointCorner!, futurePointMachine.listPoint);
      } else {
        selectPointMachine(
            futurePointPersonal.pointCorner!, futurePointPersonal.listPoint);
      }
    } else if (futurePointPersonal.pointCorner != null &&
        futurePointMachine.pointCorner == null) {
      selectPointMachine(
          futurePointPersonal.pointCorner!, futurePointPersonal.listPoint);
    } else if (futurePointPersonal.pointCorner == null &&
        futurePointMachine.pointCorner != null) {
      selectPointMachine(
          futurePointMachine.pointCorner!, futurePointMachine.listPoint);
    } else {
      PointCorner? pointCorner = randomFinish();
      if (pointCorner != null) {
        selectPointMachine(pointCorner, []);
      }
    }
    if (listCorners.every(
      (element) => !element.notSelected(),
    )) {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Caro'),
            content: const Text('Full'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('comfirm'),
              ),
            ],
          ),
        ),
      );
    }
    setState(() {});
  }

  PointWithMaxLength processListPoint({
    required List<PointCorner> listCornersMachine,
    required List<PointCorner> listCornersPersonal,
    required PointCorner currentPoint,
  }) {
    List<PointCorner> list = listCornersMachine.isNotEmpty
        ? listCornersMachine
        : listCornersPersonal;
    //column
    list.sort(
      (a, b) => a.pointY.compareTo(b.pointY),
    );
    List<PointCorner> listColumn = list
        .where(
          (element) => list.any((el) =>
              (element.pointX - el.pointX).abs() == 0 &&
              (element.pointY - el.pointY).abs() == 1),
        )
        .toList();
    //row
    list.sort(
      (a, b) => a.pointX.compareTo(b.pointX),
    );
    List<PointCorner> listRow = list
        .where(
          (element) => list.any((el) =>
              (element.pointX - el.pointX).abs() == 1 &&
              (element.pointY - el.pointY).abs() == 0),
        )
        .toList();
    //diagonal
    List<PointCorner> listDiagonal = list
        .where(
          (element) => list.any((el) =>
              (element.pointX - el.pointX).abs() == 1 &&
              (element.pointY - el.pointY).abs() == 1 &&
              !element.checkMatch(el.dotPoint)),
        )
        .toList();
    //filter point with group
    List<GroupOffsetPoint> mapColumn = filterPointWithNumber(listColumn, true);
    List<GroupOffsetPoint> mapRow = filterPointWithNumber(listRow, false);
    List<GroupOffsetPoint> mapDiagonal =
        filterPointWithNumberDiagonal(listDiagonal);
    //get list max point with group
    if (mapColumn.isNotEmpty) {
      mapColumn.sort(
        (a, b) => a.listPoint.length.compareTo(b.listPoint.length),
      );
      listColumn = mapColumn.last.listPoint;
    }
    if (mapRow.isNotEmpty) {
      mapRow.sort(
        (a, b) => a.listPoint.length.compareTo(b.listPoint.length),
      );
      listRow = mapRow.last.listPoint;
    }
    if (mapDiagonal.isNotEmpty) {
      mapDiagonal.sort(
        (a, b) => a.listPoint.length.compareTo(b.listPoint.length),
      );
      for (var element in mapDiagonal.reversed) {
        if (element.listPoint.every(
          (ele) => element.listPoint.every((el) =>
              (ele.pointX != el.pointX && ele.pointY != el.pointY) ||
              (ele.pointX == el.pointX && ele.pointY == el.pointY)),
        )) {
          listDiagonal = element.listPoint;
          break;
        }
      }
    }
    //sort point with group
    listColumn.sort(
      (a, b) => a.pointY.compareTo(b.pointY),
    );
    listRow.sort(
      (a, b) => a.pointX.compareTo(b.pointX),
    );
    listDiagonal.sort(
      (a, b) => a.pointX.compareTo(b.pointX),
    );
    List<List<PointCorner>> lastList = [listColumn, listRow, listDiagonal];
    lastList.sort(
      (a, b) => a.length.compareTo(b.length),
    );
    PointWithMaxLength futurePoint =
        PointWithMaxLength(listPoint: [], pointCorner: null);
    int length = lastList.length - 1;
    if (listColumn.length == maxWin) {
      setWin(listColumn);
      return futurePoint;
    }
    if (listRow.length == maxWin) {
      setWin(listRow);
      return futurePoint;
    }
    if (listDiagonal.length == maxWin) {
      setWin(listDiagonal);
      return futurePoint;
    }

    do {
      List<PointCorner> listTmp = lastList.elementAt(length);
      if (listTmp.isNotEmpty) {
        PointCorner beginPoint = listTmp.first;
        PointCorner endPoint = listTmp.last;
        if (beginPoint.checkMatch(endPoint.dotPoint)) {
          futurePoint = getPointFutureOnly(beginPoint, listTmp);
        } else {
          if (beginPoint.pointY == endPoint.pointY) {
            futurePoint = getPointFutureRow(beginPoint, endPoint, listTmp);
          }
          if (beginPoint.pointX < endPoint.pointX &&
              beginPoint.pointY < endPoint.pointY) {
            futurePoint =
                getPointFutureDiagonal(beginPoint, endPoint, true, listTmp);
          }
          if (beginPoint.pointX < endPoint.pointX &&
              beginPoint.pointY > endPoint.pointY) {
            futurePoint =
                getPointFutureDiagonal(beginPoint, endPoint, false, listTmp);
          }
          if (beginPoint.pointX == endPoint.pointX) {
            futurePoint = getPointFutureColumn(beginPoint, endPoint, listTmp);
          }
        }
      } else {
        futurePoint = getPointFutureOnly(currentPoint, [currentPoint]);
      }
      if (futurePoint.pointCorner == null) {
        length -= 1;
      } else {
        length = 0;
      }
    } while (length > 0);
    return futurePoint;
  }

  setWin(List<PointCorner> listWin) {
    List<Offset> listOffset = [];
    for (var element in listWin) {
      listOffset.add(Offset(element.dx + radius, element.dy + radius));
    }
    if (listWin.first.selectMachine) {
      listCornersMachineWin.addAll(listOffset);
    } else {
      listCornersPersonalWin.addAll(listOffset);
    }
    checkWin = true;
    setState(() {});
  }

  PointWithMaxLength getPointFutureOnly(
      PointCorner point, List<PointCorner> list) {
    List<GroupDotPoint> list8 = getEightCorner(point.dotPoint, count - 2);
    if (list8.isEmpty) {
      return PointWithMaxLength(listPoint: [point], pointCorner: point);
    }

    List<Map<int, PointCorner?>> list8Corner = [];
    PointCorner? maxPercent;
    for (var element in list8) {
      if (element.dotPoint == null) {
        list8Corner.add({element.level: null});
      } else {
        int index = listCorners.indexWhere(
          (el) => el.checkMatch(element.dotPoint!),
        );
        if (index <= -1) {
          list8Corner.add({element.level: null});
        } else {
          PointCorner pointCorner = listCorners.elementAt(index);
          maxPercent ??= pointCorner;
          if (maxPercent.percent < pointCorner.percent &&
              maxPercent.notSelected()) {
            maxPercent = pointCorner;
          }
          list8Corner.add({element.level: pointCorner});
          pointCorner.percent += 1 / 8;
        }
      }
    }
    if (maxPercent != null && !maxPercent.notSelected()) {
      List<PointCorner> listPercent = [];
      for (var element in list8Corner) {
        if (element.values.isNotEmpty && element.values.first != null) {
          listPercent.add(element.values.first!);
        }
      }
      if (listPercent.isNotEmpty) {
        int length = listPercent.length - 1;
        do {
          PointCorner pointCorner = listPercent.elementAt(length);
          if (pointCorner.notSelected()) {
            length = 0;
            maxPercent = pointCorner;
          } else {
            length -= 1;
          }
        } while (length > 0);
      }
    }
    return PointWithMaxLength(
        listPoint:
            maxPercent != null && maxPercent.notSelected() ? [maxPercent] : [],
        pointCorner:
            maxPercent != null && maxPercent.notSelected() ? maxPercent : null);
  }

  PointWithMaxLength getPointFutureRow(
      PointCorner beginPoint, PointCorner endPoint, List<PointCorner> list) {
    PointCorner? futurePointBegin;
    PointCorner? futurePointEnd;
    PointCorner? futurePoint;
    int maxRange = count - 2;
    if (beginPoint.pointX > 0) {
      futurePointBegin = listCorners.singleWhere(
        (element) =>
            element.pointY == beginPoint.pointY &&
            element.pointX == beginPoint.pointX - 1,
      );
    }
    if (endPoint.pointX < maxRange) {
      futurePointEnd = listCorners.singleWhere(
        (element) =>
            element.pointY == endPoint.pointY &&
            element.pointX == endPoint.pointX + 1,
      );
    }
    if (futurePointBegin != null) {
      futurePoint = futurePointBegin;
    }
    if (futurePointEnd != null) {
      futurePoint = futurePointEnd;
    }
    if (futurePointBegin != null && futurePointEnd != null) {
      if (futurePointBegin.percent >= futurePointEnd.percent &&
          futurePointBegin.notSelected()) {
        futurePoint = futurePointBegin;
      } else {
        futurePoint = futurePointEnd;
      }
    }
    return PointWithMaxLength(
        listPoint: list,
        pointCorner: futurePoint != null && futurePoint.notSelected()
            ? futurePoint
            : null);
  }

  PointWithMaxLength getPointFutureDiagonal(PointCorner beginPoint,
      PointCorner endPoint, bool checkLeft, List<PointCorner> list) {
    PointCorner? futurePointBegin;
    PointCorner? futurePointEnd;
    PointCorner? futurePoint;
    int maxRange = count - 2;
    if (checkLeft) {
      if (beginPoint.pointX > 0 && beginPoint.pointY > 0) {
        futurePointBegin = listCorners.singleWhere(
          (element) =>
              element.pointY == beginPoint.pointY - 1 &&
              element.pointX == beginPoint.pointX - 1,
        );
      }
      if (endPoint.pointX < maxRange && endPoint.pointY < maxRange) {
        futurePointEnd = listCorners.singleWhere(
          (element) =>
              element.pointY == endPoint.pointY + 1 &&
              element.pointX == endPoint.pointX + 1,
        );
      }
      if (futurePointBegin != null) {
        futurePoint = futurePointBegin;
      }
      if (futurePointEnd != null) {
        futurePoint = futurePointEnd;
      }
      if (futurePointBegin != null && futurePointEnd != null) {
        if (futurePointBegin.percent >= futurePointEnd.percent &&
            futurePointBegin.notSelected()) {
          futurePoint = futurePointBegin;
        } else {
          futurePoint = futurePointEnd;
        }
      }
    } else {
      if (beginPoint.pointX > 0 &&
          beginPoint.pointY > 0 &&
          beginPoint.pointY < maxRange) {
        futurePointBegin = listCorners.singleWhere(
          (element) =>
              element.pointY == beginPoint.pointY + 1 &&
              element.pointX == beginPoint.pointX - 1,
        );
      }
      if (endPoint.pointX < maxRange && endPoint.pointY < maxRange) {
        futurePointEnd = listCorners.singleWhere(
          (element) =>
              element.pointY == beginPoint.pointY - 1 &&
              element.pointX == beginPoint.pointX + 1,
        );
      }
      if (futurePointBegin != null) {
        futurePoint = futurePointBegin;
      }
      if (futurePointEnd != null) {
        futurePoint = futurePointEnd;
      }
      if (futurePointBegin != null && futurePointEnd != null) {
        if (futurePointBegin.percent >= futurePointEnd.percent &&
            futurePointBegin.notSelected()) {
          futurePoint = futurePointBegin;
        } else {
          futurePoint = futurePointEnd;
        }
      }
    }
    return PointWithMaxLength(
        listPoint: list,
        pointCorner: futurePoint != null && futurePoint.notSelected()
            ? futurePoint
            : null);
  }

  PointWithMaxLength getPointFutureColumn(
      PointCorner beginPoint, PointCorner endPoint, List<PointCorner> list) {
    PointCorner? futurePointBegin;
    PointCorner? futurePointEnd;
    PointCorner? futurePoint;
    int maxRange = count - 2;
    if (beginPoint.pointY > 0) {
      futurePointBegin = listCorners.singleWhere(
        (element) =>
            element.pointY == beginPoint.pointY - 1 &&
            element.pointX == beginPoint.pointX,
      );
    }
    if (endPoint.pointY < maxRange) {
      futurePointEnd = listCorners.singleWhere(
        (element) =>
            element.pointY == endPoint.pointY + 1 &&
            element.pointX == endPoint.pointX,
      );
    }
    if (futurePointBegin != null) {
      futurePoint = futurePointBegin;
    }
    if (futurePointEnd != null) {
      futurePoint = futurePointEnd;
    }
    if (futurePointBegin != null && futurePointEnd != null) {
      if (futurePointBegin.percent >= futurePointEnd.percent &&
          futurePointBegin.notSelected()) {
        futurePoint = futurePointBegin;
      } else {
        futurePoint = futurePointEnd;
      }
    }
    return PointWithMaxLength(
        listPoint: list,
        pointCorner: futurePoint != null && futurePoint.notSelected()
            ? futurePoint
            : null);
  }

  selectPointMachine(PointCorner pointCorner, List<PointCorner> list) {
    if (list.isEmpty) {
      // processMachine(pointCorner);
    } else {
      int index = listCorners.indexWhere(
        (element) =>
            element.pointX == pointCorner.pointX &&
            element.pointY == pointCorner.pointY,
      );
      if (index != -1) {
        PointCorner point = listCorners.elementAt(index);
        point.selectChange(!selectChange);
        point.percent = 0;
        listCornersMachine.add(point);
        list.sort(
          (a, b) => a.pointY.compareTo(b.pointY),
        );
        if (list.length == (maxWin - 1) &&
            (list.first.pointX == point.pointX ||
                list.last.pointX == point.pointX) &&
            (point.pointY < list.first.pointY ||
                point.pointY > list.last.pointY)) {
          list.add(point);
          setWin(list);
        }
      }
    }
  }

  PointCorner? randomFinish() {
    listCornersMachine.sort(
      (a, b) => a.pointX.compareTo(b.pointX),
    );
    listCornersPersonal.sort(
      (a, b) => a.pointY.compareTo(b.pointY),
    );
    int maxX = listCornersMachine.last.pointX > listCornersPersonal.last.pointX
        ? listCornersMachine.last.pointX
        : listCornersPersonal.last.pointX;
    int maxY = listCornersMachine.last.pointY > listCornersPersonal.last.pointY
        ? listCornersMachine.last.pointY
        : listCornersPersonal.last.pointY;
    PointCorner? maxPercent;
    if (maxX >= maxY && maxY > 0) {
      for (var i = 0; i < maxX; i++) {
        for (var j = 0; j < maxY; j++) {
          int index = listCorners.indexWhere(
            (element) =>
                element.pointX == i &&
                element.pointY == j &&
                element.notSelected(),
          );
          if (index != -1) {
            maxPercent = listCorners.elementAt(index);
            break;
          }
        }
      }
    }
    if (maxX < maxY && maxX > 0) {
      for (var i = 0; i < maxY; i++) {
        for (var j = 0; j < maxX; j++) {
          int index = listCorners.indexWhere(
            (element) =>
                element.pointX == j &&
                element.pointY == i &&
                element.notSelected(),
          );
          if (index != -1) {
            maxPercent = listCorners.elementAt(index);
            break;
          }
        }
      }
    }
    if (maxPercent != null && !maxPercent.notSelected()) {
      maxPercent = listCorners.firstWhere(
        (element) => element.notSelected(),
      );
    }
    if (listCorners.any(
      (element) => element.notSelected(),
    )) {
      maxPercent = listCorners.firstWhere(
        (element) => element.notSelected(),
      );
    }
    return maxPercent;
  }

  List<GroupDotPoint> getEightCorner(DotPoint dotPoint, int max) {
    int xp = dotPoint.x + 1;
    int xs = dotPoint.x - 1;
    int yp = dotPoint.y + 1;
    int ys = dotPoint.y - 1;
    List<GroupDotPoint> result = [];
    List<DotPoint?> list1 = [];
    List<DotPoint?> list2 = [];
    List<DotPoint?> list3 = [];
    //top
    if (xs >= 0 && ys >= 0) {
      list1.add(DotPoint(x: xs, y: ys));
    } else {
      list1.add(null);
    }
    if (xs >= -1 && ys >= 0) {
      list1.add(DotPoint(x: dotPoint.x, y: ys));
    } else {
      list1.add(null);
    }
    if (xs >= -1 && ys >= 0 && xp <= max) {
      list1.add(DotPoint(x: xp, y: ys));
    } else {
      list1.add(null);
    }

    //between
    if (xs >= 0 && ys >= -1) {
      list2.add(DotPoint(x: xs, y: dotPoint.y));
    } else {
      list2.add(null);
    }
    if (xp >= 0 && yp >= 0 && xp <= max) {
      list2.add(DotPoint(x: xp, y: dotPoint.y));
    } else {
      list2.add(null);
    }
    //bottom--------------------
    if (xs >= 0 && ys >= -1 && yp <= max) {
      list3.add(DotPoint(x: xs, y: yp));
    } else {
      list3.add(null);
    }
    if (xp >= 0 && yp > 0 && yp <= max) {
      list3.add(DotPoint(x: dotPoint.x, y: yp));
    } else {
      list3.add(null);
    }
    if (xp > 0 && yp > 0 && xp <= max && yp <= max) {
      list3.add(DotPoint(x: xp, y: yp));
    } else {
      list3.add(null);
    }
    for (var element in list1) {
      result.add(GroupDotPoint(level: 1, dotPoint: element));
    }
    for (var element in list2) {
      result.add(GroupDotPoint(level: 2, dotPoint: element));
    }
    for (var element in list3) {
      result.add(GroupDotPoint(level: 3, dotPoint: element));
    }
    return result;
  }

  List<GroupOffsetPoint> filterPointWithNumber(
      List<PointCorner> list, bool getX) {
    List<GroupOffsetPoint> map = [];
    for (var element in list) {
      if (getX) {
        int index = map.indexWhere(
          (el) => el.option.pointX == element.pointX,
        );
        if (index != -1) {
          map.elementAt(index).listPoint.add(element);
        } else {
          map.add(GroupOffsetPoint(option: element, listPoint: [element]));
        }
      } else {
        int index = map.indexWhere(
          (el) => el.option.pointY == element.pointY,
        );
        if (index != -1) {
          map.elementAt(index).listPoint.add(element);
        } else {
          map.add(GroupOffsetPoint(option: element, listPoint: [element]));
        }
      }
    }
    return map;
  }

  List<GroupOffsetPoint> filterPointWithNumberDiagonal(List<PointCorner> list) {
    List<GroupOffsetPoint> map = [];
    for (var element in list) {
      if (!map.any(
        (el) => el.option.checkMatch(element.dotPoint),
      )) {
        map.add(GroupOffsetPoint(option: element, listPoint: [element]));
      }
    }
    for (var element in map) {
      List<PointCorner> listTmp = list
          .where(
            (el) =>
                (el.pointX - element.option.pointX).abs() > 0 &&
                (el.pointY - element.option.pointY).abs() > 0 &&
                (el.pointX - element.option.pointX).abs() ==
                    (el.pointY - element.option.pointY).abs(),
          )
          .toList();
      if (listTmp.isNotEmpty) {
        element.listPoint.addAll(listTmp);
        element.listPoint.sort(
          (a, b) => a.pointX.compareTo(b.pointX),
        );
      }
    }
    return map;
  }

  resetInfor(double width, double height, double marginTop) {
    listCornersPersonal = [];
    listCornersPersonalWin = [];
    listCornersMachine = [];
    listCornersMachineWin = [];
    selectChange = false;
    checkWin = false;
    createSize(width, height, marginTop);
    setState(() {});
  }

  resetAll() {
    controller.clear();
    count = 1;
    radius = 10;
    large = 2;
    listCorners = [];
    selectChange = false;
    listCornersPersonal = [];
    listCornersPersonalWin = [];
    listCornersMachine = [];
    listCornersMachineWin = [];
    lockSettings = false;
    showInformation = false;
    checkWin = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    double marginTop = MediaQuery.viewPaddingOf(context).top + 50;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTapUp: checkWin
            ? null
            : (TapUpDetails details) {
                selectPoint(details, marginTop);
              },
        child: SingleChildScrollView(
          child: SizedBox(
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      left: 5,
                      top: MediaQuery.viewPaddingOf(context).top,
                      right: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: lockSettings
                        ? MainAxisAlignment.spaceBetween
                        : MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          if (lockSettings)
                            InkWell(
                              onTap: () {
                                showInformation = !showInformation;
                                setState(() {});
                              },
                              child: const Icon(Icons.info_rounded),
                            ),
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            child: InkWell(
                                onTap: () {},
                                child: const Icon(
                                  Icons.home,
                                  color: Colors.blueGrey,
                                )),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.close,
                                  color: Colors.blue,
                                ),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: const Text('Personal'),
                                )
                              ],
                            ),
                          ),
                          Container(
                            height: 50,
                            width: width / 5,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            alignment: Alignment.center,
                            child: TextField(
                              controller: controller,
                              onSubmitted: (value) {
                                createSize(width, height, marginTop);
                              },
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            child: Row(
                              children: [
                                const Icon(Icons.circle_outlined,
                                    color: Colors.red),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 5),
                                  child: const Text('Machine'),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      IntrinsicHeight(
                        child: Column(
                          children: [
                            if (lockSettings)
                              InkWell(
                                  onTap: () {
                                    resetAll();
                                  },
                                  child: const Icon(Icons.restore)),
                            Container(
                              margin: const EdgeInsets.only(top: 2),
                              child: InkWell(
                                  onTap: () {
                                    resetInfor(width, height, marginTop);
                                  },
                                  child: const Icon(
                                    Icons.restart_alt_outlined,
                                    color: Colors.blueGrey,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: width,
                  height: height - marginTop,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black)),
                  child: Stack(children: [
                    //row
                    ...List.generate(
                      count,
                      (index) => Positioned(
                        left: (width / count) * (++index),
                        child: Container(
                          width: large,
                          height: MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.1)),
                        ),
                      ),
                    ),
                    //column
                    ...List.generate(
                      count,
                      (index) => Positioned(
                        top: (height - marginTop) * (++index) / count,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: large,
                          decoration: BoxDecoration(
                              color: Colors.black.withOpacity(.1)),
                        ),
                      ),
                    ),
                    //conner
                    ...List.generate(
                      listCorners.length,
                      (index) => Positioned(
                          left: listCorners.elementAt(index).dx,
                          top: listCorners.elementAt(index).dy,
                          child: Stack(children: [
                            showInformation
                                ? Container(
                                    margin: const EdgeInsets.only(
                                        left: 15, top: 15),
                                    decoration:
                                        BoxDecoration(color: Colors.brown[50]),
                                    child: IntrinsicHeight(
                                      child: Column(
                                        children: [
                                          Text(
                                              "(${listCorners.elementAt(index).dotPoint.x},${listCorners.elementAt(index).dotPoint.y})\n"),
                                          Text(
                                              "${listCorners.elementAt(index).percent}")
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                            CircleAvatar(
                              radius:
                                  listCorners.elementAt(index).selectMachine ||
                                          listCorners
                                              .elementAt(index)
                                              .selectPersonal
                                      ? radius
                                      : 0,
                              backgroundColor: Colors.white,
                              child: listCorners.elementAt(index).selectMachine
                                  ? const Icon(
                                      Icons.circle_outlined,
                                      color: Colors.red,
                                    )
                                  : listCorners.elementAt(index).selectPersonal
                                      ? const Icon(
                                          Icons.close,
                                          color: Colors.blue,
                                        )
                                      : null,
                            ),
                          ])),
                    ),
                    CustomPaint(
                      painter: MyPainter(
                          listOffsetPerson: listCornersPersonalWin,
                          listOffsetMachine: listCornersMachineWin),
                      child: Container(),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  MyPainter(
      {super.repaint,
      required this.listOffsetPerson,
      required this.listOffsetMachine});
  final List<Offset> listOffsetPerson;
  final List<Offset> listOffsetMachine;

  @override
  void paint(Canvas canvas, Size size) {
    const pointMode = PointMode.polygon;
    // final points = [
    //   Offset(50, 100),
    //   Offset(150, 75),
    //   Offset(250, 250),
    //   Offset(130, 200),
    //   Offset(270, 100),
    // ];
    bool checkPerson = listOffsetPerson.isNotEmpty;
    List<Offset> listOffset =
        listOffsetPerson.isNotEmpty ? listOffsetPerson : listOffsetMachine;
    final paint = Paint()
      ..color = checkPerson ? Colors.blue : Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawPoints(pointMode, listOffset, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

// processMachine(PointCorner pointCorner) {
//     int maxRange = count - 2;
//     if (pointCorner.dotPoint.x < 0 ||
//         pointCorner.dotPoint.y < 0 ||
//         pointCorner.dotPoint.x > maxRange ||
//         pointCorner.dotPoint.y > maxRange) return;

//     if (listCorners.every(
//       (element) => !element.notSelected(),
//     )) {
//       showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (context) => PopScope(
//           canPop: false,
//           child: AlertDialog(
//             title: const Text('Caro'),
//             content: const Text('Full'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('comfirm'),
//               ),
//             ],
//           ),
//         ),
//       );
//       return;
//     }
//     List<GroupDotPoint> list8 = getEightCorner(pointCorner.dotPoint, maxRange);
//     if (list8.isEmpty) return;
//     try {
//       List<Map<int, PointCorner?>> list8Corner = [];

//       for (var element in list8) {
//         if (element.dotPoint == null) {
//           list8Corner.add({element.level: null});
//         } else {
//           int index = listCorners.indexWhere(
//             (el) => el.checkMatch(element.dotPoint!),
//           );
//           if (index <= -1) {
//             list8Corner.add({element.level: null});
//           } else {
//             PointCorner pointCorner = listCorners.elementAt(index);
//             list8Corner.add({element.level: pointCorner});
//             pointCorner.percent += 1 / 8;
//           }
//         }
//       }

//       List<PointCorner?> listGroup1 = [
//         list8Corner.elementAt(0).values.first,
//         list8Corner.elementAt(7).values.first,
//       ];
//       List<PointCorner?> listGroup2 = [
//         list8Corner.elementAt(1).values.first,
//         list8Corner.elementAt(6).values.first,
//       ];
//       List<PointCorner?> listGroup3 = [
//         list8Corner.elementAt(2).values.first,
//         list8Corner.elementAt(5).values.first,
//       ];
//       List<PointCorner?> listGroup4 = [
//         list8Corner.elementAt(3).values.first,
//         list8Corner.elementAt(4).values.first,
//       ];

//       double percent1 = 0;
//       double percent2 = 0;
//       double percent3 = 0;
//       double percent4 = 0;

//       for (var element in listGroup1) {
//         percent1 += element == null ? 0 : element.percent;
//       }
//       for (var element in listGroup2) {
//         percent2 += element == null ? 0 : element.percent;
//       }
//       for (var element in listGroup3) {
//         percent3 += element == null ? 0 : element.percent;
//       }
//       for (var element in listGroup4) {
//         percent4 += element == null ? 0 : element.percent;
//       }

//       List<GroupPercentPoint> mapPoints = [
//         GroupPercentPoint(percent: percent1, listPoint: listGroup1),
//         GroupPercentPoint(percent: percent2, listPoint: listGroup2),
//         GroupPercentPoint(percent: percent3, listPoint: listGroup3),
//         GroupPercentPoint(percent: percent4, listPoint: listGroup4),
//       ];

//       mapPoints.sort(
//         (a, b) => a.percent.compareTo(b.percent),
//       );

//       int length = mapPoints.length - 1;
//       bool check = false;
//       do {
//         if (length < 0) {
//           checkOverPoint(list8Corner, true);
//           break;
//         }
//         List<PointCorner?> maxPercent = mapPoints.elementAt(length).listPoint;
//         DotPoint? machinePoint = maxPercent.last != null
//             ? maxPercent.last!.dotPoint
//             : maxPercent.first?.dotPoint;

//         if (maxPercent.isEmpty || machinePoint == null) {
//           if (length == 0) {
//             checkOverPoint(list8Corner, false);
//             break;
//           }
//         } else {
//           //-----------
//           if (maxPercent.first == null && maxPercent.last != null) {
//             if (maxPercent.last!.notSelected()) {
//               machinePoint = getPoint(
//                   null, pointCorner, maxPercent.last!, true, false, maxRange);
//               if (pointCorner.checkMatch(machinePoint)) {
//                 length -= 1;
//                 check = true;
//               } else {
//                 check = false;
//                 if (machinePoint.x <= maxRange &&
//                     machinePoint.x >= 0 &&
//                     machinePoint.y <= maxRange &&
//                     machinePoint.y >= 0) {
//                   optimalSelectMachine(machinePoint: machinePoint);
//                 } else {
//                   checkOverPoint(list8Corner, false);
//                   break;
//                 }
//               }
//             } else {
//               length -= 1;
//               check = true;
//             }
//           }
//           //----------
//           if (maxPercent.first != null && maxPercent.last == null) {
//             if (maxPercent.first!.notSelected()) {
//               machinePoint = getPoint(
//                   maxPercent.first!, pointCorner, null, false, true, maxRange);
//               if (pointCorner.checkMatch(machinePoint)) {
//                 length -= 1;
//                 check = true;
//               } else {
//                 check = false;
//                 if (machinePoint.x <= maxRange &&
//                     machinePoint.x >= 0 &&
//                     machinePoint.y <= maxRange &&
//                     machinePoint.y >= 0) {
//                   optimalSelectMachine(machinePoint: machinePoint);
//                 } else {
//                   checkOverPoint(list8Corner, false);
//                   break;
//                 }
//               }
//             } else {
//               length -= 1;
//               check = true;
//             }
//           }
//           //----------
//           if (maxPercent.first != null && maxPercent.last != null) {
//             if (maxPercent.first!.notSelected() &&
//                 maxPercent.last!.notSelected()) {
//               if (length > 0) {
//                 length -= 1;
//                 check = true;
//               } else if (length == 0) {
//                 check = false;
//                 if (machinePoint.x <= maxRange &&
//                     machinePoint.x >= 0 &&
//                     machinePoint.y <= maxRange &&
//                     machinePoint.y >= 0) {
//                   optimalSelectMachine(machinePoint: machinePoint);
//                 } else {
//                   checkOverPoint(list8Corner, false);
//                   break;
//                 }
//               }
//             } else {
//               check = false;
//               if (!maxPercent.first!.notSelected() &&
//                   !maxPercent.last!.notSelected()) {
//                 machinePoint = getPoint(maxPercent.first!, pointCorner,
//                     maxPercent.last!, true, true, maxRange);
//               } else if (!maxPercent.first!.notSelected() &&
//                   maxPercent.last!.notSelected()) {
//                 machinePoint = getPoint(maxPercent.first!, pointCorner,
//                     maxPercent.last!, true, false, maxRange);
//               } else if (maxPercent.first!.notSelected() &&
//                   !maxPercent.last!.notSelected()) {
//                 machinePoint = getPoint(maxPercent.first!, pointCorner,
//                     maxPercent.last!, false, true, maxRange);
//               }
//               if (machinePoint.x <= maxRange &&
//                   machinePoint.x >= 0 &&
//                   machinePoint.y <= maxRange &&
//                   machinePoint.y >= 0) {
//                 optimalSelectMachine(machinePoint: machinePoint);
//               } else {
//                 checkOverPoint(list8Corner, true);
//                 break;
//               }
//             }
//           }
//         }
//       } while (check);
//     } catch (e) {
//       log('$e');
//       int index = listCorners.indexWhere(
//         (element) => element.notSelected(),
//       );
//       optimalSelectMachine(index: index);
//     }
//   }

//   PointCorner? changeCurrentPoint(
//       List<Map<int, PointCorner?>> list8Corner, bool incre) {
//     list8Corner.retainWhere(
//       (element) => element.values.first != null,
//     );
//     list8Corner.sort(
//       (a, b) => a.values.first!.percent.compareTo(b.values.first!.percent),
//     );
//     int indexPersonal = -1;
//     int indexMachine = -1;
//     if (incre) {
//       indexPersonal = list8Corner.indexWhere(
//         (element) => element.values.first!.selectPersonal,
//       );
//       indexMachine = list8Corner.indexWhere(
//         (element) => element.values.first!.selectMachine,
//       );
//     } else {
//       indexPersonal = list8Corner.lastIndexWhere(
//         (element) => element.values.first!.selectPersonal,
//       );
//       indexMachine = list8Corner.lastIndexWhere(
//         (element) => element.values.first!.selectMachine,
//       );
//     }

//     if (indexPersonal > -1) {
//       return list8Corner.elementAt(indexPersonal).values.first!;
//     } else if (indexMachine > -1) {
//       return list8Corner.elementAt(indexMachine).values.first!;
//     } else {
//       return null;
//     }
//   }

//   checkOverPoint(List<Map<int, PointCorner?>> list8Corner, bool incre) {
//     PointCorner? pointCorner = changeCurrentPoint(list8Corner, incre);
//     if (pointCorner != null) {
//       processMachine(pointCorner);
//     } else {
//       showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (context) => PopScope(
//           canPop: false,
//           child: AlertDialog(
//             title: const Text('Caro'),
//             content: const Text('Maximum'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('comfirm'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//   }

//   optimalSelectMachine({DotPoint? machinePoint, int? index}) {
//     int index = machinePoint != null
//         ? (listCorners.indexWhere(
//             (element) =>
//                 element.dotPoint.x == machinePoint.x &&
//                 element.dotPoint.y == machinePoint.y,
//           ))
//         : (listCorners.indexWhere(
//             (element) => element.notSelected(),
//           ));
//     if (index != -1) {
//       PointCorner point = listCorners.elementAt(index);
//       point.selectChange(!selectChange);
//       point.percent = 0;
//       listCornersMachine.add(point);
//       for (var el in listCornersMachine) {
//         el.percent -= 1 / 8;
//         if (el.percent < 0) {
//           el.percent = 0;
//         }
//       }
//       processWinPerson(person: null, machine: listCornersMachine);
//     } else {
//       showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (context) => PopScope(
//           canPop: false,
//           child: AlertDialog(
//             title: const Text('Caro'),
//             content: const Text('Full'),
//             actions: [
//               TextButton(
//                 onPressed: () {
//                   Navigator.pop(context);
//                 },
//                 child: const Text('comfirm'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//   }

//   DotPoint getPoint(PointCorner? first, PointCorner current, PointCorner? last,
//       bool checkFirst, bool checkLast, int maxRange) {
//     int x = 0;
//     int y = 0;
//     int xy = 0;
//     DotPoint result = current.dotPoint;
//     if (first == null && last != null) {
//       if (checkLast) {
//         x = 0;
//         y = 0;
//         xy = 0;
//         if (current.pointX > last.pointX && current.pointY < last.pointY) {
//           x = -1;
//           y = 1;
//         }
//         if (current.pointX == last.pointX && current.pointY < last.pointY) {
//           y = 1;
//         }
//         if (current.pointX < last.pointX && current.pointY < last.pointY) {
//           xy = 1;
//         }
//         if (current.pointX < last.pointX && current.pointY == last.pointY) {
//           x = 1;
//         }
//         result = dotPoint(x, y, xy, last.dotPoint);
//       } else {
//         result = last.dotPoint;
//       }
//     }
//     if (first != null && last == null) {
//       if (checkFirst) {
//         x = 0;
//         y = 0;
//         xy = 0;
//         if (current.pointX > first.pointX && current.pointY > first.pointY) {
//           xy = -1;
//         }
//         if (current.pointX == first.pointX && current.pointY > first.pointY) {
//           y = -1;
//         }
//         if (current.pointX < first.pointX && current.pointY > first.pointY) {
//           x = 1;
//           y = -1;
//         }
//         if (current.pointX > first.pointX && current.pointY == first.pointY) {
//           x = -1;
//         }
//         result = dotPoint(x, y, xy, first.dotPoint);
//       } else {
//         result = first.dotPoint;
//       }
//     }
//     if (first != null && last != null) {
//       if (checkFirst && checkLast) {
//         if (first.percent >= last.percent &&
//             first.pointX < maxRange &&
//             first.pointY < maxRange &&
//             first.pointX > 0 &&
//             first.pointY > 0) {
//           x = 0;
//           y = 0;
//           xy = 0;
//           if (current.pointX > first.pointX && current.pointY > first.pointY) {
//             xy = -1;
//           }
//           if (current.pointX == first.pointX && current.pointY > first.pointY) {
//             y = -1;
//           }
//           if (current.pointX < first.pointX && current.pointY > first.pointY) {
//             x = 1;
//             y = -1;
//           }
//           if (current.pointX > first.pointX && current.pointY == first.pointY) {
//             x = -1;
//           }
//           result = dotPoint(x, y, xy, first.dotPoint);
//         } else {
//           x = 0;
//           y = 0;
//           xy = 0;
//           if (current.pointX > last.pointX && current.pointY < last.pointY) {
//             x = -1;
//             y = 1;
//           }
//           if (current.pointX == last.pointX && current.pointY < last.pointY) {
//             y = 1;
//           }
//           if (current.pointX < last.pointX && current.pointY < last.pointY) {
//             xy = 1;
//           }
//           if (current.pointX < last.pointX && current.pointY == last.pointY) {
//             y = 1;
//           }
//           result = dotPoint(x, y, xy, first.dotPoint);
//         }
//       }
//       if (checkFirst && !checkLast) {
//         if (first.percent >= last.percent &&
//             first.pointX < maxRange &&
//             first.pointY < maxRange &&
//             first.pointX > 0 &&
//             first.pointY > 0) {
//           x = 0;
//           y = 0;
//           xy = 0;
//           if (current.pointX > first.pointX && current.pointY > first.pointY) {
//             xy = -1;
//           }
//           if (current.pointX == first.pointX && current.pointY > first.pointY) {
//             y = -1;
//           }
//           if (current.pointX < first.pointX && current.pointY > first.pointY) {
//             x = 1;
//             y = -1;
//           }
//           if (current.pointX > first.pointX && current.pointY == first.pointY) {
//             x = -1;
//           }
//           result = dotPoint(x, y, xy, first.dotPoint);
//         } else {
//           result = last.dotPoint;
//         }
//       }
//       if (!checkFirst && checkLast) {
//         if (first.percent < last.percent &&
//             first.pointX < maxRange &&
//             first.pointY < maxRange &&
//             first.pointX > 0 &&
//             first.pointY > 0) {
//           x = 0;
//           y = 0;
//           xy = 0;
//           if (current.pointX > last.pointX && current.pointY < last.pointY) {
//             x = -1;
//             y = 1;
//           }
//           if (current.pointX == last.pointX && current.pointY < last.pointY) {
//             y = 1;
//           }
//           if (current.pointX < last.pointX && current.pointY < last.pointY) {
//             xy = 1;
//           }
//           if (current.pointX < last.pointX && current.pointY == last.pointY) {
//             x = 1;
//           }
//           result = dotPoint(x, y, xy, first.dotPoint);
//         } else {
//           result = first.dotPoint;
//         }
//       }
//     }
//     return result;
//   }

//   DotPoint dotPoint(int x, int y, int xy, DotPoint point) {
//     int xP = point.x;
//     int yP = point.y;
//     bool check = false;
//     do {
//       xP = xP + x + xy;
//       yP = yP + y + xy;
//       int index = listCorners.indexWhere(
//         (element) => element.dotPoint.x == xP && element.dotPoint.y == yP,
//       );
//       if (index != -1) {
//         PointCorner pointCorner = listCorners.elementAt(index);
//         if (pointCorner.notSelected()) {
//           check = false;
//         } else {
//           if (pointCorner.selectMachine) {
//             x = -x;
//             y = -y;
//             xy = -xy;
//           }
//           check = true;
//         }
//       } else {
//         check = false;
//       }
//     } while (check);
//     return DotPoint(x: xP, y: yP);
//   }
//   //-----------------1--------------------

//   List<GroupDotPoint> getEightCorner(DotPoint dotPoint, int max) {
//     int xp = dotPoint.x + 1;
//     int xs = dotPoint.x - 1;
//     int yp = dotPoint.y + 1;
//     int ys = dotPoint.y - 1;
//     List<GroupDotPoint> result = [];
//     List<DotPoint?> list1 = [];
//     List<DotPoint?> list2 = [];
//     List<DotPoint?> list3 = [];
//     //top
//     if (xs >= 0 && ys >= 0) {
//       list1.add(DotPoint(x: xs, y: ys));
//     } else {
//       list1.add(null);
//     }
//     if (xs >= -1 && ys >= 0) {
//       list1.add(DotPoint(x: dotPoint.x, y: ys));
//     } else {
//       list1.add(null);
//     }
//     if (xs >= -1 && ys >= 0 && xp <= max) {
//       list1.add(DotPoint(x: xp, y: ys));
//     } else {
//       list1.add(null);
//     }

//     //between
//     if (xs >= 0 && ys >= -1) {
//       list2.add(DotPoint(x: xs, y: dotPoint.y));
//     } else {
//       list2.add(null);
//     }
//     if (xp >= 0 && yp >= 0 && xp <= max) {
//       list2.add(DotPoint(x: xp, y: dotPoint.y));
//     } else {
//       list2.add(null);
//     }
//     //bottom--------------------
//     if (xs >= 0 && ys >= -1 && yp <= max) {
//       list3.add(DotPoint(x: xs, y: yp));
//     } else {
//       list3.add(null);
//     }
//     if (xp >= 0 && yp > 0 && yp <= max) {
//       list3.add(DotPoint(x: dotPoint.x, y: yp));
//     } else {
//       list3.add(null);
//     }
//     if (xp > 0 && yp > 0 && xp <= max && yp <= max) {
//       list3.add(DotPoint(x: xp, y: yp));
//     } else {
//       list3.add(null);
//     }
//     for (var element in list1) {
//       result.add(GroupDotPoint(level: 1, dotPoint: element));
//     }
//     for (var element in list2) {
//       result.add(GroupDotPoint(level: 2, dotPoint: element));
//     }
//     for (var element in list3) {
//       result.add(GroupDotPoint(level: 3, dotPoint: element));
//     }
//     return result;
//   }

//   processWinPerson(
//       {required List<PointCorner>? person,
//       required List<PointCorner>? machine}) {
//     bool checkPerson = false;
//     List<PointCorner> list = [];
//     if (person != null) {
//       checkPerson = true;
//       list = person;
//     }
//     if (machine != null) {
//       checkPerson = false;
//       list = machine;
//     }
//     if (list.isEmpty) return;

//     list.sort(
//       (a, b) => a.pointY.compareTo(b.pointY),
//     );
//     List<PointCorner> listColumn = list
//         .where(
//           (element) => list.any((el) =>
//               (element.pointX - el.pointX).abs() == 0 &&
//               (element.pointY - el.pointY).abs() == 1),
//         )
//         .toList();
//     list.sort(
//       (a, b) => a.pointX.compareTo(b.pointX),
//     );
//     List<PointCorner> listRow = list
//         .where(
//           (element) => list.any((el) =>
//               (element.pointX - el.pointX).abs() == 1 &&
//               (element.pointY - el.pointY).abs() == 0),
//         )
//         .toList();
//     List<PointCorner> listDiagonal = list
//         .where(
//           (element) => list.any((el) =>
//               (element.pointX - el.pointX).abs() == 1 &&
//               (element.pointY - el.pointY).abs() == 1 &&
//               !element.checkMatch(el.dotPoint)),
//         )
//         .toList();
//     List<GroupOffsetPoint> mapColumn = filterPointWithNumber(listColumn, true);
//     List<GroupOffsetPoint> mapRow = filterPointWithNumber(listRow, false);
//     List<GroupOffsetPoint> mapDiagonal =
//         filterPointWithNumberDiagonal(listDiagonal);
//     if (mapColumn.isNotEmpty) {
//       mapColumn.sort(
//         (a, b) => a.listPoint.length.compareTo(b.listPoint.length),
//       );
//       listColumn = mapColumn.last.listPoint;
//     }
//     if (mapRow.isNotEmpty) {
//       mapRow.sort(
//         (a, b) => a.listPoint.length.compareTo(b.listPoint.length),
//       );
//       listRow = mapRow.last.listPoint;
//     }
//     if (mapDiagonal.isNotEmpty) {
//       mapDiagonal.sort(
//         (a, b) => a.listPoint.length.compareTo(b.listPoint.length),
//       );
//       for (var element in mapDiagonal.reversed) {
//         if (element.listPoint.every(
//           (ele) => element.listPoint.every(
//             (el) =>
//                 (ele.pointX != el.pointX && ele.pointY != el.pointY) ||
//                 (ele.pointX == el.pointX && ele.pointY == el.pointY),
//           ),
//         )) {
//           listDiagonal = element.listPoint;
//           break;
//         }
//       }
//     }
//     listColumn.sort(
//       (a, b) => a.pointY.compareTo(b.pointY),
//     );
//     listRow.sort(
//       (a, b) => a.pointX.compareTo(b.pointX),
//     );
//     listDiagonal.sort(
//       (a, b) => a.pointX.compareTo(b.pointX),
//     );
//     if (listColumn.length == maxWin) {
//       for (var element in listColumn) {
//         checkPerson
//             ? listCornersPersonalWin
//                 .add(Offset(element.dx + radius, element.dy + radius))
//             : listCornersMachineWin
//                 .add(Offset(element.dx + radius, element.dy + radius));
//       }
//     } else if (listRow.length == maxWin) {
//       for (var element in listRow) {
//         checkPerson
//             ? listCornersPersonalWin
//                 .add(Offset(element.dx + radius, element.dy + radius))
//             : listCornersMachineWin
//                 .add(Offset(element.dx + radius, element.dy + radius));
//       }
//     } else if (listDiagonal.length == maxWin) {
//       for (var element in listDiagonal) {
//         checkPerson
//             ? listCornersPersonalWin
//                 .add(Offset(element.dx + radius, element.dy + radius))
//             : listCornersMachineWin
//                 .add(Offset(element.dx + radius, element.dy + radius));
//       }
//     }
//     if (listCornersPersonalWin.length == 5 ||
//         listCornersMachineWin.length == 5) {
//       checkWin = true;
//       log('$listCornersPersonalWin\n$listCornersMachineWin');
//     }
//     setState(() {});
//   }