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
      return;
    }
    List<GroupDotPoint> list8 = getEightCorner(pointCorner.dotPoint);
    if (list8.isEmpty) return;
    List<Map<int, PointCorner?>> list8Corner = [];

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
          list8Corner.add({element.level: pointCorner});
          pointCorner.percent += 1 / 8;
        }
      }
    }

    List<PointCorner?> listGroup1 = [
      list8Corner.elementAt(0).values.first,
      list8Corner.elementAt(7).values.first,
    ];
    List<PointCorner?> listGroup2 = [
      list8Corner.elementAt(1).values.first,
      list8Corner.elementAt(6).values.first,
    ];
    List<PointCorner?> listGroup3 = [
      list8Corner.elementAt(2).values.first,
      list8Corner.elementAt(5).values.first,
    ];
    List<PointCorner?> listGroup4 = [
      list8Corner.elementAt(3).values.first,
      list8Corner.elementAt(4).values.first,
    ];

    double percent1 = 0;
    double percent2 = 0;
    double percent3 = 0;
    double percent4 = 0;

    for (var element in listGroup1) {
      percent1 += element == null ? 0 : element.percent;
    }
    for (var element in listGroup2) {
      percent2 += element == null ? 0 : element.percent;
    }
    for (var element in listGroup3) {
      percent3 += element == null ? 0 : element.percent;
    }
    for (var element in listGroup4) {
      percent4 += element == null ? 0 : element.percent;
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
    do {
      if (length < 0) {
        checkOverPoint(list8Corner);
        break;
      }
      List<PointCorner?> maxPercent = mapPoints.elementAt(length).listPoint;
      DotPoint? machinePoint = maxPercent.last != null
          ? maxPercent.last!.dotPoint
          : maxPercent.first?.dotPoint;

      if (maxPercent.isEmpty || machinePoint == null) {
        if (length == 0) {
          checkOverPoint(list8Corner);
          break;
        }
      } else {
        //-----------
        if (maxPercent.first == null && maxPercent.last != null) {
          if (maxPercent.last!.notSelected()) {
            machinePoint =
                getPoint(null, pointCorner, maxPercent.last!, true, false);
            if (pointCorner.checkMatch(machinePoint)) {
              length -= 1;
              check = true;
            } else {
              check = false;
              optimalSelectMachine(machinePoint);
            }
          } else {
            length -= 1;
            check = true;
          }
        }
        //----------
        if (maxPercent.first != null && maxPercent.last == null) {
          if (maxPercent.first!.notSelected()) {
            machinePoint =
                getPoint(maxPercent.first!, pointCorner, null, false, true);
            if (pointCorner.checkMatch(machinePoint)) {
              length -= 1;
              check = true;
            } else {
              check = false;
              optimalSelectMachine(machinePoint);
            }
          } else {
            length -= 1;
            check = true;
          }
        }
        //----------
        if (maxPercent.first != null && maxPercent.last != null) {
          if (maxPercent.first!.notSelected() &&
              maxPercent.last!.notSelected()) {
            if (length > 0) {
              length -= 1;
              check = true;
            } else if (length == 0) {
              check = false;
              optimalSelectMachine(machinePoint);
            }
          } else {
            check = false;
            if (!maxPercent.first!.notSelected() &&
                !maxPercent.last!.notSelected()) {
              machinePoint = getPoint(
                  maxPercent.first!, pointCorner, maxPercent.last!, true, true);
            } else if (!maxPercent.first!.notSelected() &&
                maxPercent.last!.notSelected()) {
              machinePoint = getPoint(maxPercent.first!, pointCorner,
                  maxPercent.last!, true, false);
            } else if (maxPercent.first!.notSelected() &&
                !maxPercent.last!.notSelected()) {
              machinePoint = getPoint(maxPercent.first!, pointCorner,
                  maxPercent.last!, false, true);
            }
            optimalSelectMachine(machinePoint);
          }
        }
      }
    } while (check);
  }

  PointCorner? changeCurrentPoint(List<Map<int, PointCorner?>> list8Corner) {
    list8Corner.retainWhere(
      (element) => element.values.first != null,
    );
    list8Corner.sort(
      (a, b) => a.values.first!.percent.compareTo(b.values.first!.percent),
    );
    int indexPersonal = list8Corner.lastIndexWhere(
      (element) => element.values.first!.selectPersonal,
    );
    int indexMachine = list8Corner.lastIndexWhere(
      (element) => element.values.first!.selectMachine,
    );
    if (indexPersonal > -1) {
      return list8Corner.elementAt(indexPersonal).values.first!;
    } else if (indexMachine > -1) {
      return list8Corner.elementAt(indexMachine).values.first!;
    } else {
      return null;
    }
  }

  checkOverPoint(List<Map<int, PointCorner?>> list8Corner) {
    PointCorner? pointCorner = changeCurrentPoint(list8Corner);
    if (pointCorner != null) {
      processMachine1(pointCorner);
    } else {
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text('Caro'),
            content: const Text('Maximum'),
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
      point.percent = 0;
      listCornersMachine.add(point);
      for (var el in listCornersMachine) {
        el.percent -= 1 / 8;
        if (el.percent < 0) {
          el.percent = 0;
        }
      }
    }
  }

  DotPoint getPoint(PointCorner? first, PointCorner current, PointCorner? last,
      bool checkFirst, bool checkLast) {
    int x = 0;
    int y = 0;
    int xy = 0;
    DotPoint result = current.dotPoint;
    if (first == null && last != null) {
      if (checkLast) {
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
        result = dotPoint(x, y, xy, last.dotPoint);
      } else {
        result = last.dotPoint;
      }
    }
    if (first != null && last == null) {
      if (checkFirst) {
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
        result = first.dotPoint;
      }
    }
    if (first != null && last != null) {
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
      list1.add(DotPoint(x: dotPoint.x - 1, y: dotPoint.y - 1));
    } else {
      list1.add(null);
    }
    if ((xs == 0 || xs == -1) && ys >= 0) {
      list1.add(DotPoint(x: dotPoint.x, y: dotPoint.y - 1));
    } else {
      list1.add(null);
    }
    if (xs >= -1 && ys >= 0) {
      list1.add(DotPoint(x: dotPoint.x + 1, y: dotPoint.y - 1));
    } else {
      list1.add(null);
    }

    //between
    if (xs >= 0 && ys == 0) {
      list2.add(DotPoint(x: dotPoint.x - 1, y: dotPoint.y));
    } else {
      list2.add(null);
    }
    if (xp >= 0 && yp >= 0) {
      list2.add(DotPoint(x: dotPoint.x + 1, y: dotPoint.y));
    } else {
      list2.add(null);
    }
    //bottom--------------------
    if (xs >= 0 && ys > 0 && yp > 0) {
      list3.add(DotPoint(x: dotPoint.x - 1, y: dotPoint.y + 1));
    } else {
      list3.add(null);
    }
    if (xp >= 0 && yp > 0) {
      list3.add(DotPoint(x: dotPoint.x, y: dotPoint.y + 1));
    } else {
      list3.add(null);
    }
    if (xp > 0 && yp > 0) {
      list3.add(DotPoint(x: dotPoint.x + 1, y: dotPoint.y + 1));
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
