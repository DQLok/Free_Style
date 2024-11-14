import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:free_style/number/data/point_number.dart';

class NumberPage extends StatefulWidget {
  const NumberPage({super.key});

  @override
  State<NumberPage> createState() => _NumberPageState();
}

class _NumberPageState extends State<NumberPage> {
  TextEditingController controller = TextEditingController();
  List<PointNumber> listPointNumbers = [];
  int maxNumber = 0;
  int radiusPoint = 0;

  @override
  void initState() {
    super.initState();
    maxNumber = 10;
    radiusPoint = 10;
  }

  createListNumber(
      {required double height,
      required double width,
      required double left,
      required double top,
      required double right,
      required double bottom}) {
    if (controller.text.isEmpty) return;
    listPointNumbers.clear();
    int? size = int.tryParse(controller.text);
    if (size == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Enter Number"),
      ));
      return;
    }
    if (size <= 0) return;
    double maxY = height - top - bottom - radiusPoint * 2.5;
    double minX = radiusPoint * 1.0;
    double maxX = width - radiusPoint * 2.5;
    double minY = radiusPoint * 1.0;
    while (listPointNumbers.length < size) {
      double dyR = math.Random().nextDouble() * height;
      double dxR = math.Random().nextDouble() * width;
      if (dxR > minX && dxR < maxX && dyR > minY && dyR < maxY) {
        if (listPointNumbers.every(
          (element) =>
              (element.dx - dxR).abs() > radiusPoint &&
              (element.dy - dyR).abs() > radiusPoint,
        )) {
          listPointNumbers.add(PointNumber(
              dx: dxR, dy: dyR, selectMachine: false, selectPersonal: false));
        }
      }
    }
    setState(() {});
  }

  createRegionSquare() {}

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    double vertical = MediaQuery.viewPaddingOf(context).vertical;
    double horizontal = MediaQuery.viewPaddingOf(context).horizontal;
    double sizeHeader = height / 10;
    return Scaffold(
      backgroundColor: Colors.grey,
      body: GestureDetector(
        onTapUp: (details) {
          log('${MediaQuery.of(context).size.width}');
          log('${details.localPosition.dx}');
        },
        child: Container(
          margin:
              EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
          color: Colors.white,
          child: Column(
            children: [
              Container(
                height: height / 10,
                width: width,
                color: Colors.blueGrey.shade100,
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            InkWell(
                                onTap: () {},
                                child: const Icon(Icons.restart_alt_rounded)),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: width / 2,
                      margin: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black)),
                      alignment: Alignment.center,
                      child: TextField(
                        controller: controller,
                        onSubmitted: (value) {
                          createListNumber(
                              height: height,
                              width: width,
                              left: horizontal,
                              top: vertical,
                              right: horizontal,
                              bottom: vertical + sizeHeader);
                        },
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    Expanded(
                      child: SizedBox(
                        child: Column(
                          children: [
                            InkWell(
                                onTap: () {
                                  createListNumber(
                                      height: height,
                                      width: width,
                                      left: horizontal,
                                      top: vertical,
                                      right: horizontal,
                                      bottom: vertical + sizeHeader);
                                },
                                child: const Icon(Icons.restart_alt_rounded)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: Stack(
                children: listPointNumbers.isNotEmpty
                    ? [
                        ...List.generate(
                          listPointNumbers.length,
                          (index) => Positioned(
                              left: listPointNumbers.elementAt(index).dx,
                              top: listPointNumbers.elementAt(index).dy,
                              child: CircleAvatar(
                                radius: 10,
                                child: Text('${++index}'),
                              )),
                        ),
                      ]
                    : [],
              ))
            ],
          ),
        ),
      ),
    );
  }
}
