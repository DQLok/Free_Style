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
  List<PointCorner> listCornersPersonal = [];
  List<PointCorner> listCornersMachine = [];

  @override
  void initState() {
    super.initState();
  }

  createSize(double width, double height, double marginTop) {
    if (controller.text.isEmpty) return;
    listCorners = [];
    count = int.parse(controller.text);
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
        PointCorner currentPoint = listCorners.elementAt(index);
        currentPoint.percent += 1 / 8;
        listCornersPersonal.add(currentPoint);
        processMachine1(currentPoint);
      }
    }
    setState(() {});
  }

  processMachine1(PointCorner pointCorner) {
    if (pointCorner.dotPoint.x < 0 ||
        pointCorner.dotPoint.y < 0 ||
        pointCorner.dotPoint.x > count - 2 ||
        pointCorner.dotPoint.y > count - 2) return;

    List<GroupDotPoint> list8 = getEightCorner(pointCorner.dotPoint);
    if (list8.isEmpty) return;
    List<Map<int, PointCorner>> list8Corner = [];
    for (var element in listCorners) {
      for (var el in list8) {
        if (element.checkMatch(el.dotPoint)) {
          list8Corner.add({el.level: element});
          element.percent += 1 / 8;
        }
      }
    }

    List<PointCorner> listGroup1 = [];
    List<PointCorner> listGroup2 = [];
    List<PointCorner> listGroup3 = [];
    List<PointCorner> listGroup4 = [];

    for (var element in list8Corner) {
      switch (element.keys.first) {
        case 1:
          // mapGroup1.addAll({1: element.values.first});
          //----
          PointCorner? point1 = getPointGroup(element.values.toList(), 0);
          PointCorner? point2 = getPointGroup(element.values.toList(), 1);
          PointCorner? point3 = getPointGroup(element.values.toList(), 2);
          if (point1 != null) {
            listGroup1.add(point1);
          }
          if (point2 != null) {
            listGroup2.add(point2);
          }
          if (point3 != null) {
            listGroup3.add(point3);
          }
          break;
        case 2:
          // mapGroup2.addAll({2: element.values.first});
          //----
          PointCorner? point1 = getPointGroup(element.values.toList(), 0);
          PointCorner? point2 = getPointGroup(element.values.toList(), 1);
          if (point1 != null) {
            listGroup4.add(point1);
          }
          if (point2 != null) {
            listGroup4.add(point2);
          }
          break;
        case 3:
          // mapGroup3.addAll({3: element.values.first});
          //----
          PointCorner? point1 = getPointGroup(element.values.toList(), 0);
          PointCorner? point2 = getPointGroup(element.values.toList(), 1);
          PointCorner? point3 = getPointGroup(element.values.toList(), 2);
          if (point1 != null) {
            listGroup3.add(point1);
          }
          if (point2 != null) {
            listGroup2.add(point2);
          }
          if (point3 != null) {
            listGroup1.add(point3);
          }
          break;
        default:
          // mapGroup1.addAll({1: element.values.first});
          //----
          PointCorner? point1 = getPointGroup(element.values.toList(), 0);
          PointCorner? point2 = getPointGroup(element.values.toList(), 1);
          PointCorner? point3 = getPointGroup(element.values.toList(), 2);
          if (point1 != null) {
            listGroup1.add(point1);
          }
          if (point2 != null) {
            listGroup2.add(point2);
          }
          if (point3 != null) {
            listGroup3.add(point3);
          }
          break;
      }
    }

    double percent1 = 0;
    double percent2 = 0;
    double percent3 = 0;
    double percent4 = 0;

    for (var element in listGroup1) {
      percent1 += element.percent;
    }
    for (var element in listGroup2) {
      percent2 += element.percent;
    }
    for (var element in listGroup3) {
      percent3 += element.percent;
    }
    for (var element in listGroup4) {
      percent4 += element.percent;
    }

    List<GroupPercentPoint> mapPoints = [
      GroupPercentPoint(percent: percent1, listPoint: listGroup1),
      GroupPercentPoint(percent: percent2, listPoint: listGroup2),
      GroupPercentPoint(percent: percent3, listPoint: listGroup3),
      GroupPercentPoint(percent: percent4, listPoint: listGroup4),
    ];

    mapPoints.sort(
      (a, b) => a.percent.compareTo(b.percent),
    );

    int length = mapPoints.length - 1;
    bool check = false;
    List<PointCorner> maxPercent = [];
    do {
      List<PointCorner> tmp = mapPoints.elementAt(length).listPoint;
      if (tmp.isNotEmpty) {
        maxPercent = tmp;
      }
      DotPoint machinePoint = maxPercent.last.dotPoint;

      if (maxPercent.first.notSelected() && maxPercent.last.notSelected()) {
        if (length > 0) {
          length -= 1;
          check = true;
        } else if (length == 0) {
          check = false;
          optimalSelectMachine(machinePoint);
        }
      } else {
        check = false;
        if (!maxPercent.first.notSelected() && !maxPercent.last.notSelected()) {
          machinePoint = getPoint(
              maxPercent.first, pointCorner, maxPercent.last, true, true);
        } else if (!maxPercent.first.notSelected() &&
            maxPercent.last.notSelected()) {
          machinePoint = getPoint(
              maxPercent.first, pointCorner, maxPercent.last, true, false);
        } else if (maxPercent.first.notSelected() &&
            !maxPercent.last.notSelected()) {
          machinePoint = getPoint(
              maxPercent.first, pointCorner, maxPercent.last, false, true);
        }
        optimalSelectMachine(machinePoint);
      }
    } while (check);
  }

  PointCorner? getPointGroup(List<PointCorner> list, int index) {
    if (list.isEmpty) return null;
    if ((list.length - 1) >= index) {
      return list.elementAt(index);
    } else if ((index - list.length) == 1) {
      return list.last;
    }
    return null;
  }

  optimalSelectMachine(DotPoint machinePoint) {
    int index = listCorners.indexWhere(
      (element) =>
          element.dotPoint.x == machinePoint.x &&
          element.dotPoint.y == machinePoint.y,
    );
    if (index != -1) {
      PointCorner point = listCorners.elementAt(index);
      point.selectChange(!selectChange);
      listCornersMachine.add(point);
      for (var el in listCornersMachine) {
        el.percent = 0;
      }
    }
  }

  DotPoint getPoint(PointCorner first, PointCorner current, PointCorner last,
      bool checkFirst, bool checkLast) {
    int x = 0;
    int y = 0;
    int xy = 0;
    DotPoint result = current.dotPoint;
    if (checkFirst && checkLast) {
      if (first.percent >= last.percent) {
        x = 0;
        y = 0;
        xy = 0;
        if (current.pointX > first.pointX && current.pointY > first.pointY) {
          xy = -1;
        }
        if (current.pointX == first.pointX && current.pointY > first.pointY) {
          y = -1;
        }
        if (current.pointX < first.pointX && current.pointY > first.pointY) {
          x = 1;
          y = -1;
        }
        if (current.pointX > first.pointX && current.pointY == first.pointY) {
          x = -1;
        }
        result = dotPoint(x, y, xy, first.dotPoint);
      } else {
        x = 0;
        y = 0;
        xy = 0;
        if (current.pointX > last.pointX && current.pointY < last.pointY) {
          x = -1;
          y = 1;
        }
        if (current.pointX == last.pointX && current.pointY < last.pointY) {
          y = 1;
        }
        if (current.pointX < last.pointX && current.pointY < last.pointY) {
          xy = 1;
        }
        if (current.pointX < last.pointX && current.pointY == last.pointY) {
          y = 1;
        }
        result = dotPoint(x, y, xy, first.dotPoint);
      }
    }
    if (checkFirst && !checkLast) {
      if (first.percent >= last.percent) {
        x = 0;
        y = 0;
        xy = 0;
        if (current.pointX > first.pointX && current.pointY > first.pointY) {
          xy = -1;
        }
        if (current.pointX == first.pointX && current.pointY > first.pointY) {
          y = -1;
        }
        if (current.pointX < first.pointX && current.pointY > first.pointY) {
          x = 1;
          y = -1;
        }
        if (current.pointX > first.pointX && current.pointY == first.pointY) {
          x = -1;
        }
        result = dotPoint(x, y, xy, first.dotPoint);
      } else {
        result = last.dotPoint;
      }
    }
    if (!checkFirst && checkLast) {
      if (first.percent < last.percent) {
        x = 0;
        y = 0;
        xy = 0;
        if (current.pointX > last.pointX && current.pointY < last.pointY) {
          x = -1;
          y = 1;
        }
        if (current.pointX == last.pointX && current.pointY < last.pointY) {
          y = 1;
        }
        if (current.pointX < last.pointX && current.pointY < last.pointY) {
          xy = 1;
        }
        if (current.pointX < last.pointX && current.pointY == last.pointY) {
          x = 1;
        }
        result = dotPoint(x, y, xy, first.dotPoint);
      } else {
        result = first.dotPoint;
      }
    }
    return result;
  }

  DotPoint dotPoint(int x, int y, int xy, DotPoint point) {
    int xP = point.x;
    int yP = point.y;
    bool check = false;
    do {
      xP = xP + x + xy;
      yP = yP + y + xy;
      int index = listCorners.indexWhere(
        (element) => element.dotPoint.x == xP && element.dotPoint.y == yP,
      );
      if (index != -1) {
        PointCorner pointCorner = listCorners.elementAt(index);
        if (pointCorner.notSelected()) {
          check = false;
        } else {
          if (pointCorner.selectMachine) {
            x = -x;
            y = -y;
            xy = -xy;
          }
          check = true;
        }
      } else {
        check = false;
      }
    } while (check);
    return DotPoint(x: xP, y: yP);
  }
  //-----------------1--------------------

  List<GroupDotPoint> getEightCorner(DotPoint dotPoint) {
    return [
      //top
      if (dotPoint.x > 0 && dotPoint.y > 0)
        GroupDotPoint(
            level: 1, dotPoint: DotPoint(x: dotPoint.x - 1, y: dotPoint.y - 1)),
      if (dotPoint.y > 0)
        GroupDotPoint(
            level: 1, dotPoint: DotPoint(x: dotPoint.x, y: dotPoint.y - 1)),
      if (dotPoint.x < count - 2 && dotPoint.y > 0)
        GroupDotPoint(
            level: 1, dotPoint: DotPoint(x: dotPoint.x + 1, y: dotPoint.y - 1)),
      //between
      if (dotPoint.x > 0)
        GroupDotPoint(
            level: 2, dotPoint: DotPoint(x: dotPoint.x - 1, y: dotPoint.y)),
      if (dotPoint.x < count - 2)
        GroupDotPoint(
            level: 2, dotPoint: DotPoint(x: dotPoint.x + 1, y: dotPoint.y)),
      //bottom
      if (dotPoint.x > 0 && dotPoint.y < count - 2)
        GroupDotPoint(
            level: 3, dotPoint: DotPoint(x: dotPoint.x - 1, y: dotPoint.y + 1)),
      if (dotPoint.y < count - 2)
        GroupDotPoint(
            level: 3, dotPoint: DotPoint(x: dotPoint.x, y: dotPoint.y + 1)),
      if (dotPoint.x < count - 2 && dotPoint.y < count - 2)
        GroupDotPoint(
            level: 3, dotPoint: DotPoint(x: dotPoint.x + 1, y: dotPoint.y + 1)),
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
                    border: Border.all(color: Colors.redAccent)),
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

// default formula
// processMachine(PointCorner pointCorner) {
// if (pointCorner.dotPoint.x < 0 ||
//     pointCorner.dotPoint.y < 0 ||
//     pointCorner.dotPoint.x > count - 2 ||
//     pointCorner.dotPoint.y > count - 2) return;

// List<DotPoint> list8 = getEightCorner(pointCorner.dotPoint);
// List<PointCorner> list8Corner = [];
// for (var element in listCorners) {
//   for (var el in list8) {
//     if (element.checkMatch(el)) {
//       list8Corner.add(element);
//       element.percent += 1 / 8;
//     }
//   }
// }
// log(listCorners.toString());

// //desc
// list8Corner.sort(
//   (a, b) => b.percent.compareTo(a.percent),
// );

// DotPoint dotPointTmp =
//     DotPoint(x: pointCorner.pointX, y: pointCorner.pointY);

// //check new
// // bool checkNotArrow = true;
// for (var element in list8Corner) {
//   int index = listCorners.indexWhere(
//     (el) => el.checkMatch(element.dotPoint),
//   );
//   if (index != -1) {
//     if (listCorners.elementAt(index).notSelected()) {
//       dotPointTmp = DotPoint(
//           x: listCorners.elementAt(index).pointX,
//           y: listCorners.elementAt(index).pointY);
//       //----------
//       // listCorners.elementAt(index).selectChange(!selectChange);
//       // checkNotArrow = false;
//       break;
//     }
//   }
// }

// for (var element in list8Corner) {
//   int index = listCorners.indexWhere(
//     (el) => el.checkMatch(element.dotPoint),
//   );
//   if (index != -1) {
//     PointCorner tmp = listCorners.elementAt(index);
//     if (tmp.selectedPersonal()) {
//       int x = tmp.pointX;
//       int y = tmp.pointY;
//       int X = pointCorner.pointX;
//       int Y = pointCorner.pointY;
//       bool changeX = true;
//       bool changeY = true;
//       if (x < X) {
//         x = X + 1;
//         changeX = false;
//       }
//       if (y < Y) {
//         y = Y + 1;
//         changeY = false;
//       }
//       if (changeX) {
//         if (x > X) {
//           x = X - 1;
//         }
//       }
//       if (changeY) {
//         if (y > Y) {
//           y = Y - 1;
//         }
//       }
//       dotPointTmp = DotPoint(x: x, y: y);
//       break;
//     }
//   }
// }

// int index = listCorners.indexWhere(
//   (element) =>
//       element.dotPoint.x == dotPointTmp.x &&
//       element.dotPoint.y == dotPointTmp.y,
// );

// if (index != -1) {
//   if (listCorners.elementAt(index).notSelected()) {
//     listCorners.elementAt(index).selectChange(!selectChange);
//     if (listCorners.elementAt(index).percent > 0) {
//       listCorners.elementAt(index).percent -= 1 / 8;
//     }
//   }
// }
// setState(() {});
// }
//-------------------------------------------
//---------------------2---------------------
// processMachine2(PointCorner pointCorner) {
//   if (pointCorner.dotPoint.x < 0 ||
//       pointCorner.dotPoint.y < 0 ||
//       pointCorner.dotPoint.x > count - 2 ||
//       pointCorner.dotPoint.y > count - 2) return;

//   List<DotPoint> list8 = getEightCorner(pointCorner.dotPoint);
//   List<PointCorner> list8Corner = [];
//   for (var element in listCorners) {
//     for (var el in list8) {
//       if (element.checkMatch(el)) {
//         list8Corner.add(element);
//         element.percent += 1 / 8;
//       }
//     }
//   }

//   list8Corner.sort(
//     (a, b) => a.percent.compareTo(b.percent),
//   );
//   PointCorner tmp = list8Corner.reversed.first;
//   if (tmp.percent >= pointCorner.percent) {
//     PointCorner tmp0 = list8Corner.last;
//     for (var element in list8Corner) {
//       if (element.notSelected()) {
//         tmp0 = element;
//         break;
//       }
//     }
//     int index = listCorners.indexWhere(
//       (element) =>
//           element.dotPoint.x == tmp0.pointX &&
//           element.dotPoint.y == tmp0.pointY,
//     );
//     if (index != -1) {
//       listCorners.elementAt(index).selectChange(!selectChange);
//       listCurrentPoint.clear();
//     } else {}
//     setState(() {});
//     return;
//   }
//   bool notSelected = true;
//   for (var element in list8Corner.reversed) {
//     if (element.selectPersonal &&
//         !listCurrentPoint.any(
//           (el) => el.checkMatch(element.dotPoint),
//         )) {
//       tmp = element;
//       notSelected = false;
//       break;
//     }
//   }
//   if (notSelected) {
//     PointCorner tmp1 = list8Corner.last;
//     for (var element in list8Corner) {
//       if (element.notSelected()) {
//         tmp1 = element;
//         break;
//       }
//     }
//     int index = listCorners.indexWhere(
//       (element) =>
//           element.dotPoint.x == tmp1.pointX &&
//           element.dotPoint.y == tmp1.pointY,
//     );
//     if (index != -1) {
//       listCorners.elementAt(index).selectChange(!selectChange);
//       listCurrentPoint.clear();
//     } else {}
//     setState(() {});
//   } else {
//     listCurrentPoint.add(tmp);
//     processMachine2(tmp);
//     setState(() {});
//     return;
//   }
// }
//-----------------2--------------------
