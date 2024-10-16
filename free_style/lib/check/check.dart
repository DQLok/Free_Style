import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:free_style/check/data/point.dart';

class CheckPage extends StatefulWidget {
  const CheckPage({super.key});

  @override
  State<CheckPage> createState() => _CheckPageState();
}

class _CheckPageState extends State<CheckPage> {
  TextEditingController controller = TextEditingController();
  int count = 1;
  double radius = 10;
  double large = 2;
  List<PointCorner> listCorners = [];
  bool selectChange = false;
  List<PointCorner> listCurrentPoint = [];

  @override
  void initState() {
    super.initState();
  }

  createSize(double width, double height, double marginTop) {
    if (controller.text.isEmpty) return;
    listCorners = [];
    count = int.parse(controller.text);
    //corners
    for (int i = 0; i < count; i++) {
      for (int j = 0; j < count; j++) {
        listCorners.add(PointCorner(
            dx: (width / count) * (j + 1) - radius,
            dy: (height - marginTop) * (i + 1) / count - radius,
            selectMachine: false,
            selectPersonal: false,
            dotPoint: DotPoint(x: j, y: i),
            percent: 0));
      }
    }
    log(listCorners.toString());
    setState(() {});
  }

  selectPoint(TapUpDetails details, double marginTop) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.globalToLocal(details.globalPosition);
    log("${offset.dx} - ${offset.dy}");
    log("${radius * 1.5}");
    log("${listCorners.first.dx + radius - offset.dx} && ${listCorners.first.dy + radius - (offset.dy - marginTop)}");
    int index = listCorners.indexWhere(
      (element) => ((element.dx + radius - offset.dx).abs() <= radius * 1.5 &&
          (element.dy + radius - (offset.dy - marginTop)).abs() <=
              radius * 1.5),
    );
    if (index != -1) {
      bool checkSelect =
          listCorners.elementAt(index).selectChange(selectChange);
      if (checkSelect) {
        // selectChange = !selectChange;
        PointCorner currentPoint = listCorners.elementAt(index);
        currentPoint.percent += 1 / 8;
        listCurrentPoint.add(currentPoint);
        processMachine2(currentPoint);
      }
    }
    setState(() {});
  }

  processMachine2(PointCorner pointCorner) {
    if (pointCorner.dotPoint.x < 0 ||
        pointCorner.dotPoint.y < 0 ||
        pointCorner.dotPoint.x > count - 2 ||
        pointCorner.dotPoint.y > count - 2) return;

    List<DotPoint> list8 = getEightCorner(pointCorner.dotPoint);
    List<PointCorner> list8Corner = [];
    for (var element in listCorners) {
      for (var el in list8) {
        if (element.checkMatch(el)) {
          list8Corner.add(element);
          element.percent += 1 / 8;
        }
      }
    }

    list8Corner.sort(
      (a, b) => a.percent.compareTo(b.percent),
    );
    PointCorner tmp = list8Corner.reversed.first;
    if (tmp.percent >= pointCorner.percent) {
      PointCorner tmp0 = list8Corner.last;
      for (var element in list8Corner) {
        if (element.notSelected()) {
          tmp0 = element;
          break;
        }
      }
      int index = listCorners.indexWhere(
        (element) =>
            element.dotPoint.x == tmp0.pointX &&
            element.dotPoint.y == tmp0.pointY,
      );
      if (index != -1) {
        listCorners.elementAt(index).selectChange(!selectChange);
        listCurrentPoint.clear();
      } else {}
      setState(() {});
      return;
    }
    bool notSelected = true;
    for (var element in list8Corner.reversed) {
      if (element.selectPersonal &&
          !listCurrentPoint.any(
            (el) => el.checkMatch(element.dotPoint),
          )) {
        tmp = element;
        notSelected = false;
        break;
      }
    }
    if (notSelected) {
      PointCorner tmp1 = list8Corner.last;
      for (var element in list8Corner) {
        if (element.notSelected()) {
          tmp1 = element;
          break;
        }
      }
      int index = listCorners.indexWhere(
        (element) =>
            element.dotPoint.x == tmp1.pointX &&
            element.dotPoint.y == tmp1.pointY,
      );
      if (index != -1) {
        listCorners.elementAt(index).selectChange(!selectChange);
        listCurrentPoint.clear();
      } else {}
      setState(() {});
    } else {
      listCurrentPoint.add(tmp);
      processMachine2(tmp);
      setState(() {});
      return;
    }
  }

  //-----------------1--------------------
  processMachine1(PointCorner pointCorner) {
    if (pointCorner.dotPoint.x < 0 ||
        pointCorner.dotPoint.y < 0 ||
        pointCorner.dotPoint.x > count - 2 ||
        pointCorner.dotPoint.y > count - 2) return;

    List<DotPoint> list8 = getEightCorner(pointCorner.dotPoint);
    List<PointCorner> list8Corner = [];
    for (var element in listCorners) {
      for (var el in list8) {
        if (element.checkMatch(el)) {
          list8Corner.add(element);
          element.percent += 1 / 8;
        }
      }
    }

    List<Map<double, List<PointCorner>>> mapPoints = [
      {
        (list8Corner.first.percent + list8Corner.last.percent): [
          list8Corner.first,
          list8Corner.last
        ]
      },
      {
        (list8Corner.elementAt(1).percent + list8Corner.elementAt(6).percent): [
          list8Corner.elementAt(1),
          list8Corner.elementAt(6)
        ]
      },
      {
        (list8Corner.elementAt(2).percent + list8Corner.elementAt(5).percent): [
          list8Corner.elementAt(2),
          list8Corner.elementAt(5)
        ]
      },
      {
        (list8Corner.elementAt(3).percent + list8Corner.elementAt(4).percent): [
          list8Corner.elementAt(3),
          list8Corner.elementAt(4)
        ]
      },
    ];
    mapPoints.sort(
      (a, b) => a.keys.first.compareTo(b.keys.first),
    );

    List<PointCorner> maxPercent = mapPoints.last.values as List<PointCorner>;

    if (!maxPercent.first.notSelected() && !maxPercent.last.notSelected()) {
      getPoint(maxPercent.first, pointCorner, maxPercent.last);
    } else if (!maxPercent.first.notSelected()) {
      getPoint(maxPercent.first, pointCorner, null);
    } else if (!maxPercent.last.notSelected()) {
      getPoint(null, pointCorner, maxPercent.last);
    }
  }

  DotPoint getPoint(
      PointCorner? first, PointCorner current, PointCorner? last) {
    int x = 0;
    int y = 0;
    int xy = 0;
    DotPoint result = current.dotPoint;
    if (first != null && last != null) {
      if (first.percent >= last.percent) {
        x = 0;
        y = 0;
        xy = 0;
        if (current.pointX > first.pointX) {
          xy = -1;
        }
        if (current.pointX == first.pointX) {
          y = -1;
        }
        if (current.pointX < first.pointX) {
          x = 1;
        }
        result = dotPoint(x, y, xy, first.dotPoint);
      } else {
        x = 0;
        y = 0;
        xy = 0;
        if (current.pointX > last.pointX) {
          x = -1;
          y = 1;
        }
        if (current.pointX == last.pointX) {
          y = 1;
        }
        if (current.pointX < last.pointX) {
          xy = 1;
        }
        result = dotPoint(x, y, xy, first.dotPoint);
      }
    }
    if (first != null && last == null) {}
    return result;
  }

  DotPoint dotPoint(int x, int y, int xy, DotPoint point) {
    int xP = point.x;
    int yP = point.y;
    bool check = false;
    do {
      xP = xP + x + y + xy;
      yP = yP + x + y + xy;
      int index = listCorners.indexWhere(
        (element) => element.dotPoint.x == xP && element.dotPoint.y == yP,
      );
      if (index != -1) {
        check = true;
      } else {
        check = false;
      }
    } while (check);
    return DotPoint(x: xP, y: yP);
  }
  //-----------------1--------------------

  processMachine(PointCorner pointCorner) {
    if (pointCorner.dotPoint.x < 0 ||
        pointCorner.dotPoint.y < 0 ||
        pointCorner.dotPoint.x > count - 2 ||
        pointCorner.dotPoint.y > count - 2) return;

    List<DotPoint> list8 = getEightCorner(pointCorner.dotPoint);
    List<PointCorner> list8Corner = [];
    for (var element in listCorners) {
      for (var el in list8) {
        if (element.checkMatch(el)) {
          list8Corner.add(element);
          element.percent += 1 / 8;
        }
      }
    }
    log(listCorners.toString());

    //desc
    list8Corner.sort(
      (a, b) => b.percent.compareTo(a.percent),
    );

    DotPoint dotPointTmp =
        DotPoint(x: pointCorner.pointX, y: pointCorner.pointY);

    //check new
    // bool checkNotArrow = true;
    for (var element in list8Corner) {
      int index = listCorners.indexWhere(
        (el) => el.checkMatch(element.dotPoint),
      );
      if (index != -1) {
        if (listCorners.elementAt(index).notSelected()) {
          dotPointTmp = DotPoint(
              x: listCorners.elementAt(index).pointX,
              y: listCorners.elementAt(index).pointY);
          //----------
          // listCorners.elementAt(index).selectChange(!selectChange);
          // checkNotArrow = false;
          break;
        }
      }
    }

    for (var element in list8Corner) {
      int index = listCorners.indexWhere(
        (el) => el.checkMatch(element.dotPoint),
      );
      if (index != -1) {
        PointCorner tmp = listCorners.elementAt(index);
        if (tmp.selectedPersonal()) {
          int x = tmp.pointX;
          int y = tmp.pointY;
          int X = pointCorner.pointX;
          int Y = pointCorner.pointY;
          bool changeX = true;
          bool changeY = true;
          if (x < X) {
            x = X + 1;
            changeX = false;
          }
          if (y < Y) {
            y = Y + 1;
            changeY = false;
          }
          if (changeX) {
            if (x > X) {
              x = X - 1;
            }
          }
          if (changeY) {
            if (y > Y) {
              y = Y - 1;
            }
          }
          dotPointTmp = DotPoint(x: x, y: y);
          break;
        }
      }
    }

    int index = listCorners.indexWhere(
      (element) =>
          element.dotPoint.x == dotPointTmp.x &&
          element.dotPoint.y == dotPointTmp.y,
    );

    if (index != -1) {
      if (listCorners.elementAt(index).notSelected()) {
        listCorners.elementAt(index).selectChange(!selectChange);
        if (listCorners.elementAt(index).percent > 0) {
          listCorners.elementAt(index).percent -= 1 / 8;
        }
      }
    }

    // if (checkNotArrow) {
    //   // bool check = false;
    //   for (int y = pointCorner.dotPoint.y; y >= 0; y--) {
    //     for (int x = pointCorner.dotPoint.x; x >= 0; x--) {
    //       int index = listCorners.indexWhere(
    //         (element) => element.dotPoint.x == x && element.dotPoint.y == y,
    //       );
    //       if (index != -1) {
    //         if (listCorners.elementAt(index).notSelected()) {
    //           listCorners.elementAt(index).selectChange(!selectChange);
    //           // check = false;
    //           break;
    //         }
    //       }
    //     }
    //   }
    // }
    setState(() {});
  }

  List<DotPoint> getEightCorner(DotPoint dotPoint) {
    return [
      //top
      if (dotPoint.x > 0 && dotPoint.y > 0)
        DotPoint(x: dotPoint.x - 1, y: dotPoint.y - 1),
      if (dotPoint.y > 0) DotPoint(x: dotPoint.x, y: dotPoint.y - 1),
      if (dotPoint.x < count - 2 && dotPoint.y > 0)
        DotPoint(x: dotPoint.x + 1, y: dotPoint.y - 1),
      //between
      if (dotPoint.x > 0) DotPoint(x: dotPoint.x - 1, y: dotPoint.y),
      if (dotPoint.x < count - 2) DotPoint(x: dotPoint.x + 1, y: dotPoint.y),
      //bottom
      if (dotPoint.x > 0 && dotPoint.y < count - 2)
        DotPoint(x: dotPoint.x - 1, y: dotPoint.y + 1),
      if (dotPoint.y < count - 2) DotPoint(x: dotPoint.x, y: dotPoint.y + 1),
      if (dotPoint.x < count - 2 && dotPoint.y < count - 2)
        DotPoint(x: dotPoint.x + 1, y: dotPoint.y + 1),
    ];
  }

  @override
  Widget build(BuildContext context) {
    double marginTop = MediaQuery.viewPaddingOf(context).top + 50;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: GestureDetector(
        onTapUp: (TapUpDetails details) {
          selectPoint(details, marginTop);
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 50,
                width: width / 4,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                margin:
                    EdgeInsets.only(top: MediaQuery.viewPaddingOf(context).top),
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
                        decoration: const BoxDecoration(color: Colors.black),
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
                        decoration: const BoxDecoration(color: Colors.black),
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
                          Container(
                            margin: const EdgeInsets.only(left: 15, top: 15),
                            decoration: BoxDecoration(color: Colors.brown[50]),
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
                          ),
                          CircleAvatar(
                            radius: listCorners
                                        .elementAt(index)
                                        .selectMachine ||
                                    listCorners.elementAt(index).selectPersonal
                                ? radius
                                : 0,
                            backgroundColor: listCorners
                                    .elementAt(index)
                                    .selectMachine
                                ? Colors.red
                                : listCorners.elementAt(index).selectPersonal
                                    ? Colors.yellow
                                    : null,
                          ),
                        ])),
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
